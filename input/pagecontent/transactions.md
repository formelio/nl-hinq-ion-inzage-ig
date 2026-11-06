This page shows the interactions between the data user and the data holder, with an example of every
request and response. Why these interactions are needed is described in
[Exchange Architecture](exchange.html).

### Overview

The sequence diagram shows a data user retrieving data for one patient.

<style>
  .sequence-diagram svg { max-width: 100% !important; height: auto !important; }
</style>
<div class="sequence-diagram">{% include sequence-diagram-pull.svg %}</div>

| Participant | Role |
|-------------|------|
| Healthcare professional | Uses the data user application. |
| Data user application | The Rivo-Noord viewer. It authenticates the healthcare professional and makes all requests. |
| Data user's Nuts node | Holds the organization credentials and requests the access token. |
| Data holder's Nuts node | The authorization server. It issues the access token and introspects it. |
| PDP | The data holder's policy decision point. It checks every FHIR request. |
| HINQ ION service | Receives the FHIR requests that the PDP allows. It acts as a proxy and retrieves the data from the source organizations. It handles the authorization towards those organizations. |
| Source system | The system of a source healthcare organization that holds the data. |

The interaction has four steps:

1. **Log in.** The healthcare professional logs in to the data user application. The application
   keeps the details it needs for the `NutsEmployeeCredential`.
2. **[Access Token Request](#access-token-request).** The data user requests an access token for one
   patient. The data user knows the data holder's endpoints up front. See
   [Addressing](exchange.html#addressing).
3. **[Patient Search](#patient-search).** The data user searches the patient on BSN to get the
   patient's logical id at the data holder.
4. **[Data Request](#data-request).** The data user requests the patient's data with that logical id.

At every FHIR request, the PDP checks the token through
[Token Introspection](#token-introspection). [Errors](#errors) lists the responses when a request is
rejected.

### Access Token Request

The data user requests the access token from its own Nuts node. Its Nuts node fetches the
presentation definition for the `ion_inzage` scope from the data holder's authorization server. It
then presents the organization credentials from its wallet together with the credentials in the
request body.

**Request**

```http
POST <internal Nuts interface>/internal/auth/v2/<subjectID>/request-service-access-token
Content-Type: application/json

{
  "authorization_server": "https://<data-holder-node>/oauth2/<subject>",
  "scope": "ion_inzage",
  "token_type": "Bearer",
  "credentials": [
    {
      "@context": [
        "https://www.w3.org/2018/credentials/v1",
        "https://nuts.nl/credentials/v1"
      ],
      "type": ["VerifiableCredential", "NutsEmployeeCredential"],
      "credentialSubject": {
        "identifier": "j.doe@example.nl",
        "name": "John Doe",
        "roleName": "Nurse"
      }
    },
    {
      "@context": [
        "https://www.w3.org/2018/credentials/v1",
        "https://example.hinq.nl/credentials/v1"
      ],
      "type": ["VerifiableCredential", "HinqBsnCredential"],
      "credentialSubject": {
        "bsn": "123456782"
      }
    }
  ]
}
```

**Response**

```http
HTTP/1.1 200 OK
Content-Type: application/json

{
  "access_token": "<access token>",
  "token_type": "Bearer",
  "expires_in": 900,
  "scope": "ion_inzage"
}
```

**Rules**

- The data user **MUST** request a separate access token for every patient.
- The request **MUST** contain a `NutsEmployeeCredential` and a `HinqBsnCredential`. Their fields are
  listed in [Self-Attested Credentials](credentials.html#self-attested-credentials).
- The organization credentials are presented from the wallet. They are not part of the request body.
  See [Healthcare Organization](exchange.html#healthcare-organization).

### Token Introspection

At every FHIR request, the PDP introspects the access token at the data holder's Nuts node. The
response contains the claims that the [policy](https://github.com/formelio/nl-hinq-ion-inzage-ig/tree/main/policy)
defines. The PDP uses them for the access rules and the consent check.

**Request**

```http
POST <internal Nuts interface>/internal/auth/v2/accesstoken/introspect
Content-Type: application/x-www-form-urlencoded

token=<access token>
```

**Response**

```http
HTTP/1.1 200 OK
Content-Type: application/json

{
  "active": true,
  "iss": "https://<data-holder-node>/oauth2/<subject>",
  "client_id": "https://<data-user-node>/oauth2/<subject>",
  "scope": "ion_inzage",
  "iat": 1793606400,
  "exp": 1793607300,
  "organization_id": "did:web:example.vendor.nl:iam:organization-a",
  "organization_ura": "12345678",
  "organization_agb": "01234567",
  "organization_role_code_nl": "Z3",
  "employee_identifier": "j.doe@example.nl",
  "employee_name": "John Doe",
  "employee_role": "Nurse",
  "patient_bsn": "123456782"
}
```

The example shows the claims for the HINQ-issued credentials. With an `X509Credential`, the response
has `organization_name` and `organization_city` but it is missing `organization_agb`. The Nuts node also
returns the presented credentials. They are left out of the example.

### Patient Search

The data user searches the patient on BSN. The result gives the patient's logical id at the data
holder.

**Rules**

- The search **MUST** follow [IHE PDQm ITI-78](https://profiles.ihe.net/ITI/PDQm/ITI-78.html).
- The search **MUST** be on BSN, with `identifier.system` `http://fhir.nl/fhir/NamingSystem/bsn`.
- The search **MUST** use POST. GET-based search is not allowed.
- The BSN in the search **MUST** be the BSN the access token is bound to.

**Request**

```http
POST {fhir_base}/Patient/_search
Authorization: Bearer <access token>
Content-Type: application/x-www-form-urlencoded

identifier=http://fhir.nl/fhir/NamingSystem/bsn|123456782
```

**Response**

```http
HTTP/1.1 200 OK
Content-Type: application/fhir+json

{
  "resourceType": "Bundle",
  "type": "searchset",
  "total": 1,
  "entry": [
    {
      "fullUrl": "{fhir_base}/Patient/patient-123",
      "resource": {
        "resourceType": "Patient",
        "id": "patient-123",
        "identifier": [
          {
            "system": "http://fhir.nl/fhir/NamingSystem/bsn",
            "value": "123456782"
          }
        ]
      },
      "search": { "mode": "match" }
    }
  ]
}
```

When no patient matches, the response is `200 OK` with an empty Bundle.

The data user can add `_include=Patient:general-practitioner` to also retrieve the huisarts and
the huisartsenpraktijk. See [Patient](dataset.html#patient) in the Dataset.

### Data Request

The data user requests the patient's data with the logical id from the patient search. It reuses the
access token for all requests for this patient.

**Rules**

- Every request **MUST** be scoped to the patient, with `patient={id}` or `subject=Patient/{id}`.
- Only search requests are allowed on individual resource types.

**Request**

[Dataset](dataset.html) lists the request for every data element. The example requests the
patient's observations.

```http
GET {fhir_base}/Observation?patient=patient-123
Authorization: Bearer <access token>
Accept: application/fhir+json
```

**Response**

```http
HTTP/1.1 200 OK
Content-Type: application/fhir+json

{
  "resourceType": "Bundle",
  "type": "searchset",
  "total": 1,
  "entry": [
    {
      "fullUrl": "{fhir_base}/Observation/observation-1",
      "resource": {
        "resourceType": "Observation",
        "id": "observation-1",
        "status": "final",
        "category": [
          {
            "coding": [
              {
                "system": "http://terminology.hl7.org/CodeSystem/observation-category",
                "code": "vital-signs"
              }
            ]
          }
        ],
        "code": {
          "coding": [
            {
              "system": "http://loinc.org",
              "code": "29463-7",
              "display": "Body weight"
            }
          ]
        },
        "subject": { "reference": "Patient/patient-123" },
        "effectiveDateTime": "2026-10-01",
        "valueQuantity": {
          "value": 72,
          "unit": "kg",
          "system": "http://unitsofmeasure.org",
          "code": "kg"
        }
      },
      "search": { "mode": "match" }
    }
  ]
}
```

### Errors

**Access token request.** When the data user's wallet does not hold credentials that match the
presentation definition, no token is issued. The same applies when the data holder's authorization
server rejects the presentation. The data user's Nuts node returns an error. Its format is described
in the Nuts node [auth v2 API documentation](https://nuts-node.readthedocs.io/en/stable/pages/integrating/api.html).

**FHIR requests.** The data holder rejects a patient search or data request with one of the
following status codes:

| Status | When |
|--------|------|
| `400 Bad Request` | The request does not follow the rules of the transaction. Examples are a GET-based patient search, a patient search that is not on BSN, a data request without a patient parameter, or an invalid search parameter. |
| `401 Unauthorized` | The access token is missing, invalid or expired. Introspection returns `"active": false`. |
| `403 Forbidden` | The access token is valid, but the request does not meet the access rules. Examples are a missing consent, a request for another patient than the token is bound to, or a request for an excluded resource type such as `List` or `Bundle`. |

The response body is a FHIR `OperationOutcome`.

For a `400`, the `OperationOutcome` says what is wrong with the request:

```http
HTTP/1.1 400 Bad Request
Content-Type: application/fhir+json

{
  "resourceType": "OperationOutcome",
  "issue": [
    {
      "severity": "error",
      "code": "invalid",
      "diagnostics": "Patient search must use POST"
    }
  ]
}
```

For a `401`, the response also has a `WWW-Authenticate` header, as described in
[RFC 6750](https://www.rfc-editor.org/rfc/rfc6750#section-3). The data user requests a new access
token:

```http
HTTP/1.1 401 Unauthorized
Content-Type: application/fhir+json
WWW-Authenticate: Bearer error="invalid_token"

{
  "resourceType": "OperationOutcome",
  "issue": [
    {
      "severity": "error",
      "code": "login",
      "diagnostics": "The access token is missing, invalid or expired"
    }
  ]
}
```

For a `403`, the `OperationOutcome` does not say which access rule failed. This keeps consent
information from leaking to the data user:

```http
HTTP/1.1 403 Forbidden
Content-Type: application/fhir+json

{
  "resourceType": "OperationOutcome",
  "issue": [
    {
      "severity": "error",
      "code": "forbidden",
      "diagnostics": "Access denied"
    }
  ]
}
```
