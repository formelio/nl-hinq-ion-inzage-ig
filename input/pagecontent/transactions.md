This volume describes the individual transactions used in the pull flow. There is no discovery
registration transaction in this pilot, because [addressing is out of
scope](exchange.html#addressing): the data user is assumed to already know the data holder's
endpoints.

### Pull

The sequence for the pull scenario is shown below.

<div width="90%" style="width: 90vw;">{% include sequence-diagram-pull.svg %}</div>
<br clear="all"/>

Key steps:

- The healthcare professional authenticates in the data user application (the Rivo-Noord viewer). The
  application creates a user session and stores the user info needed for the `NutsEmployeeCredential`
  (see [Professional Authentication](authentication.html)).
- The data user uses the data holder's **hardcoded** endpoints — the `authorization_server` (OAuth2
  issuer URL) and the FHIR base URL (see [Addressing](exchange.html#addressing)). There is no
  discovery step.
- The data user requests an access token, presenting the organisation credentials (URA, AGB) and
  federating the professional identity by including a `NutsEmployeeCredential` (see below).
- The data user performs a Patient search on BSN (see [Patient context](#patient-context)), followed
  by the data request using the patient's technical identifier.
- The data holder checks that the requestor is whitelisted, authorises the request, checks explicit
  consent ([Consent](exchange.html#consent)), and returns the data.

The access-token request is made against the data user's own Nuts node. Its body specifies the data
holder's `authorization_server` (the hardcoded OAuth2 issuer URL), the use-case `scope`
(`ion_inzage`), and the credentials to present — including the `NutsEmployeeCredential`:

```
POST <internal Nuts interface>/internal/auth/v2/<subjectID>/request-service-access-token
Content-Type: application/json

{
  "authorization_server": "https://<data-holder-node>/oauth2/<subject>",
  "scope": "ion_inzage",
  "credentials": [
    {
      "@context": [
        "https://www.w3.org/2018/credentials/v1",
        "https://nuts.nl/credentials/v1"
      ],
      "type": ["VerifiableCredential", "NutsEmployeeCredential"],
      "credentialSubject": {
        "identifier": "j.doe@example.nl",
        "initials": "J.",
        "familyName": "Doe",
        "roleName": "Nurse"
      }
    }
  ]
}
```

The `identifier` is a unique identifier for the user within the organisation — an e-mail address or
an employee number. Before the credential is issued, the professional must complete the **mandatory**
EmployeeIdentity confirmation page (always shown); see [Professional
Authentication](authentication.html).

The organisation credentials (URA, AGB and Zorgaanbiedertype) are presented from the data user's Nuts
node wallet; see [Authentication](exchange.html#authentication-organisation-identity).

### Patient context

All queries are patient-specific. The data user needs the logical id of the patient at the data
holder and includes it in every query (e.g. `patient=123` or `subject=Patient/123`). The logical id
is obtained through an initial search on the Patient endpoint using the BSN as identifier:

- the search **MUST** follow [IHE PDQm ITI-78](https://profiles.ihe.net/ITI/PDQm/ITI-78.html), with
  these additional agreements:
  - search **MUST** be performed on BSN (`identifier.system` = `http://fhir.nl/fhir/NamingSystem/bsn`);
  - only POST-based search is allowed; GET-based search is not allowed.
- data user organisations **MUST** support POST-based Patient search;
- data holder organisations **MUST** support POST-based Patient search.

```
POST {fhir_base}/Patient/_search

Header: Content-Type = x-www-form-urlencoded

Body: identifier=http://fhir.nl/fhir/NamingSystem/bsn|{bsn}
```

### Individual resource requests

- Read requests are only allowed on individual resource types, excluding `List`, `Composition` and
  `Bundle` resources.
- Search requests are only allowed on individual resource types, excluding `List`, `Composition`
  and `Bundle` resources.
