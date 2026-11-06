This page lists the steps a data user follows to connect to the HINQ ION for the `ion_inzage` use
case. After the last step, the data user retrieves data for a test patient. Why each step is needed
is described in [Exchange Architecture](exchange.html) and [Credentials & Issuance](credentials.html).
The requests themselves are explained in [Transactions](transactions.html).

### Overview

The integration has six steps:

1. [Configure the Nuts Node](#step-1-configure-the-nuts-node)
2. [Create the Organization Subject](#step-2-create-the-organization-subject)
3. [Obtain the Organization Credentials](#step-3-obtain-the-organization-credentials)
4. [Load the Credentials into the Wallet](#step-4-load-the-credentials-into-the-wallet)
5. [Configure mTLS for FHIR Requests](#step-5-configure-mtls-for-fhir-requests)
6. [Test the Connection](#step-6-test-the-connection)

### Environments

HINQ provides two environments:

| Environment | Purpose | Certificates |
|-------------|---------|--------------|
| Acceptance | Testing the integration before going live. Contains test patients. | PKIoverheid client certificates. An `X509Credential` from a production or test UZI CA is accepted. |
| Production | Live use with real patient data. | PKIoverheid client certificates. An `X509Credential` from a production UZI CA is accepted. |

Start in the acceptance environment. [Going to Production](#going-to-production) lists what changes
for production. Every environment needs its own subject and credentials. Credentials from one
environment are not valid in the other.

### Prerequisites

- A Nuts node of version **v6.2.0 or later**. At the time of writing, the latest version is v6.2.19.
- A reverse proxy in front of the Nuts node. It accepts HTTPS with a server certificate from a
  publicly trusted CA and forwards the requests to the node.
- A PKIoverheid client certificate for the data user application, issued under the G1 or the G4
  hierarchy. It is used for mTLS on the FHIR requests.
- An application that authenticates healthcare professionals in its own user session.
- `curl` and `jq`, to run the test requests in [Step 6](#step-6-test-the-connection).
- Optional: a UZI server certificate, to use an `X509Credential` instead of the URA and AGB
  credentials.

### Values Used on This Page

The examples on this page use the following values. Values marked as a placeholder are not
determined yet. HINQ provides the real values.

| Name | Acceptance | Production |
|------|------------|------------|
| HINQ authorization server | `https://nuts.acc.example.hinq.nl/oauth2/hinq-ion` | `https://nuts.example.hinq.nl/oauth2/hinq-ion` |
| HINQ FHIR base URL | `https://fhir.acc.example.hinq.nl/fhir` | `https://fhir.example.hinq.nl/fhir` |
| Scope | `ion_inzage` | `ion_inzage` |
| HINQ e-mail address | `credentials@example.hinq.nl` | `credentials@example.hinq.nl` |
| HINQ JSON-LD context URL | `https://example.hinq.nl/credentials/v1` | `https://example.hinq.nl/credentials/v1` |
| Test patient with consent | BSN `123456782` | Not applicable |
| Test patient without consent | BSN `111222333` | Not applicable |

All HINQ values in this table are **placeholders**. The scope is final.

The examples also use these values of the data user. Replace them with your own:

| Name | Example |
|------|---------|
| Public URL of your Nuts node | `https://nuts.example-vendor.nl` |
| Internal interface of your Nuts node | `http://localhost:8081` |
| Subject of your organization | `organization-a` |

### Step 1: Configure the Nuts Node

Configure the Nuts node in `nuts.yaml`. In the Docker image, the file is
`/nuts/config/nuts.yaml`.

```yaml
url: https://nuts.example-vendor.nl
strictmode: true
didmethods:
  - web

http:
  internal:
    address: 127.0.0.1:8081
  public:
    address: :8080

jsonld:
  contexts:
    remoteallowlist:
      # Nuts defaults. Setting remoteallowlist replaces them, so they are repeated here.
      - https://schema.org
      - https://www.w3.org/2018/credentials/v1
      - https://w3c-ccg.github.io/lds-jws2020/contexts/lds-jws2020-v1.json
      - https://w3id.org/vc/status-list/2021/v1
      # HINQ context
      - https://example.hinq.nl/credentials/v1
```

- **`url`** is the public HTTPS URL of your Nuts node. It becomes part of your organization's DID.
- **`didmethods`** enables only `did:web`. The use case does not use `did:nuts`.
- **`jsonld.contexts.remoteallowlist`** allows the node to fetch the HINQ JSON-LD context from its
  URL. See [JSON-LD Context](credentials.html#json-ld-context) for why the context is needed.

**Alternative: a local copy of the context.** The context URL is a placeholder and is not published
yet. Until it is, load the context from a local file with `localmapping` instead of
`remoteallowlist`. Download
[`hinq-credentials-v1.jsonld`](https://github.com/formelio/nl-hinq-ion-inzage-ig/blob/main/jsonld/hinq-credentials-v1.jsonld)
and place it at the mapped path:

```yaml
jsonld:
  contexts:
    localmapping:
      # Nuts defaults. Setting localmapping replaces them, so they are repeated here.
      https://nuts.nl/credentials/2024: assets/contexts/nuts-2024.ldjson
      https://nuts.nl/credentials/v1: assets/contexts/nuts.ldjson
      https://schema.org: assets/contexts/schema-org-v13.ldjson
      https://w3c-ccg.github.io/lds-jws2020/contexts/lds-jws2020-v1.json: assets/contexts/lds-jws2020-v1.ldjson
      https://w3id.org/vc/status-list/2021/v1: assets/contexts/w3c-statuslist2021.ldjson
      https://www.w3.org/2018/credentials/v1: assets/contexts/w3c-credentials-v1.ldjson
      # HINQ context
      https://example.hinq.nl/credentials/v1: /nuts/config/contexts/hinq-credentials-v1.jsonld
```

The node loads the local file at startup and fails to start when the file is missing. A local copy
also pins the version of the context.

The reverse proxy **MUST** forward the following paths of the public interface over HTTPS:

| Path | Used for |
|------|----------|
| `/iam` | Resolving your organization's DID document |
| `/oauth2` | OAuth2 metadata |
| `/.well-known` | DID and OAuth2 metadata |

The internal interface **MUST NOT** be reachable from outside your network. It has no built-in
authentication unless `http.internal.auth` is configured.

The server certificate on the reverse proxy **MUST** be issued by a publicly trusted CA. HINQ's
Nuts node checks it against the standard trust store of its operating system, and a PKIoverheid
certificate is not in that trust store. HINQ's Nuts endpoint also uses a publicly trusted
certificate, so your Nuts node needs no extra root certificates.

The traffic between your Nuts node and HINQ's Nuts node does not need mTLS. Only the FHIR requests
do. See [Step 5](#step-5-configure-mtls-for-fhir-requests).

Restart the node and check that it is healthy:

```bash
curl http://localhost:8081/health
```

### Step 2: Create the Organization Subject

Create a subject for your organization. The Nuts node creates its `did:web` DID and keys.

```bash
curl -X POST http://localhost:8081/internal/vdr/v2/subject \
  -H "Content-Type: application/json" \
  -d '{"subject": "organization-a"}'
```

The DID is in `documents[0].id` of the response:

```json
{
  "subject": "organization-a",
  "documents": [
    {
      "id": "did:web:nuts.example-vendor.nl:iam:<id>",
      ...
    }
  ]
}
```

Check that the DID document is publicly reachable at
`https://nuts.example-vendor.nl/iam/<id>/did.json`. HINQ's Nuts node fetches it to verify your
presentations.

### Step 3: Obtain the Organization Credentials

Request the credentials from HINQ by e-mail:

- **To:** `credentials@example.hinq.nl` **Placeholder.**
- **Subject:** `HINQ Nuts v6 Credentials`
- **Content:**
  - the URA of the organization
  - the AGB code of the organization
  - the organization type, a code from the OrganisatieTypeCodelijst such as `Z3`
  - the DID from [Step 2](#step-2-create-the-organization-subject)

HINQ checks the details and sends back the `HinqUraCredential`, the `HinqAgbCredential` and the
`HinqHealthcareProviderRoleTypeCredential`. Their content is described in
[Credential Specifications](credentials.html#credential-specifications).

**With a UZI server certificate.** You can create an `X509Credential` instead of requesting the URA
and AGB credentials. Mention this in the e-mail. HINQ then only issues the
`HinqHealthcareProviderRoleTypeCredential`, which is always required.

Create the `X509Credential` with the
[go-didx509-toolkit](https://github.com/nuts-foundation/go-didx509-toolkit):

```bash
docker run --rm \
  -v "$(pwd)/uzi-chain.pem:/cert-chain.pem:ro" \
  -v "$(pwd)/uzi-key.pem:/cert-key.pem:ro" \
  nutsfoundation/go-didx509-toolkit:main \
  vc /cert-chain.pem /cert-key.pem "<subject DN of the UZI root CA>" did:web:nuts.example-vendor.nl:iam:<id>
```

- `uzi-chain.pem` contains the UZI server certificate followed by its CA certificates.
- `uzi-key.pem` is the private key of the UZI server certificate.
- The output is the credential as a JWT.

The trusted UZI CAs are listed in
[`policy/README.md`](https://github.com/formelio/nl-hinq-ion-inzage-ig/blob/main/policy/README.md#trusted-issuers).
See [X509Credential](credentials.html#x509credential) for its content.

### Step 4: Load the Credentials into the Wallet

Load every credential into the wallet of your organization's subject. A JSON-LD credential is sent as
a JSON object:

```bash
curl -X POST http://localhost:8081/internal/vcr/v2/holder/organization-a/vc \
  -H "Content-Type: application/json" \
  -d @hinq-ura-credential.json
```

A JWT credential, such as the `X509Credential`, is sent as a JSON string:

```bash
curl -X POST http://localhost:8081/internal/vcr/v2/holder/organization-a/vc \
  -H "Content-Type: application/json" \
  -d "\"$(cat x509-credential.jwt)\""
```

The node responds with `204 No Content` when the credential is stored. It only accepts a credential
when its `credentialSubject.id` is your DID, its signature is valid and it is not expired or
revoked.

Check the content of the wallet:

```bash
curl http://localhost:8081/internal/vcr/v2/holder/organization-a/vc
```

The wallet **MUST** hold either the URA and AGB credentials or an `X509Credential`, and always the
Zorgaanbiedertype credential.

**Renewal.** HINQ re-issues the credentials every year. Load the new credentials, then delete the old
ones. When the wallet holds two matching credentials of the same type, the Nuts node presents the
first one it finds, which can be the old one. Delete a credential by its `id`, URL-encoded:

```bash
curl -X DELETE \
  "http://localhost:8081/internal/vcr/v2/holder/organization-a/vc/$(jq -rn --arg id "<credential id>" '$id|@uri')"
```

### Step 5: Configure mTLS for FHIR Requests

The FHIR requests from your application to HINQ use mutual TLS:

- **Your client certificate.** Your application **MUST** present a PKIoverheid client certificate
  issued under the G1 or the G4 hierarchy.
- **HINQ's server certificate.** HINQ's FHIR endpoint has a PKIoverheid server certificate issued
  under the G1 hierarchy. Your application **MUST** trust the G1 root. Add
  `PrivateRootCA-G1.cer`, Staat der Nederlanden Private Root CA - G1, from
  [cert.pkioverheid.nl](http://cert.pkioverheid.nl/) to its truststore.

HINQ only checks that your client certificate is issued under G1 or G4. You do not need to register
the certificate with HINQ.

The examples below use these files:

| File | Content |
|------|---------|
| `client.pem` | Your PKIoverheid client certificate |
| `client.key` | The private key of your client certificate |
| `pkioverheid-g1-root.pem` | The G1 root certificate in PEM format |

### Step 6: Test the Connection

Run these requests in order. They use the test patient with consent first and the test patient
without consent last.

#### Request an Access Token

Request an access token for the test patient with consent. Fill in the `NutsEmployeeCredential` with
a test user of your application.

```bash
RESPONSE=$(curl -s -X POST \
  http://localhost:8081/internal/auth/v2/organization-a/request-service-access-token \
  -H "Content-Type: application/json" \
  -d '{
    "authorization_server": "https://nuts.acc.example.hinq.nl/oauth2/hinq-ion",
    "scope": "ion_inzage",
    "token_type": "DPoP",
    "credentials": [
      {
        "@context": ["https://www.w3.org/2018/credentials/v1", "https://nuts.nl/credentials/v1"],
        "type": ["VerifiableCredential", "NutsEmployeeCredential"],
        "credentialSubject": {
          "identifier": "test.user@example-vendor.nl",
          "name": "Test User",
          "roleName": "Huisarts"
        }
      },
      {
        "@context": ["https://www.w3.org/2018/credentials/v1", "https://example.hinq.nl/credentials/v1"],
        "type": ["VerifiableCredential", "HinqBsnCredential"],
        "credentialSubject": { "bsn": "123456782" }
      }
    ]
  }')
TOKEN=$(echo "$RESPONSE" | jq -r .access_token)
DPOP_KID=$(echo "$RESPONSE" | jq -r .dpop_kid)
echo "$RESPONSE"
```

**Expected:** a response with `"token_type": "DPoP"`, an `access_token` and a `dpop_kid`. The full
response is shown in [Access Token Request](transactions.html#access-token-request).

The Nuts node caches access tokens. A request with the same body returns the cached token while it is
valid. A request for another patient has a different body and gets a new token.

#### Create DPoP Proofs

Every FHIR request needs a new DPoP proof for its HTTP method and URL. This shell function asks
your Nuts node for one. The `dpop_kid` contains `#` and `:`, so it is URL-encoded in the path:

```bash
dpop() {
  curl -s -X POST \
    "http://localhost:8081/internal/auth/v2/dpop/$(jq -rn --arg k "$DPOP_KID" '$k|@uri')" \
    -H "Content-Type: application/json" \
    -d "$(jq -n --arg htm "$1" --arg htu "$2" --arg token "$TOKEN" \
      '{htm: $htm, htu: $htu, token: $token}')" | jq -r .dpop
}
```

The first argument is the HTTP method. The second is the URL without query parameters. See
[DPoP Proof](transactions.html#dpop-proof).

#### Search the Patient

```bash
URL=https://fhir.acc.example.hinq.nl/fhir/Patient/_search
curl -X POST "$URL" \
  --cert client.pem --key client.key --cacert pkioverheid-g1-root.pem \
  -H "Authorization: DPoP $TOKEN" \
  -H "DPoP: $(dpop POST "$URL")" \
  -H "Content-Type: application/x-www-form-urlencoded" \
  --data-urlencode "identifier=http://fhir.nl/fhir/NamingSystem/bsn|123456782"
```

**Expected:** `200 OK` with a Bundle that contains one Patient. Note the Patient's `id` for the next
request. See [Patient Search](transactions.html#patient-search).

#### Request Data

```bash
URL=https://fhir.acc.example.hinq.nl/fhir/Observation
curl "$URL?patient=<patient id>" \
  --cert client.pem --key client.key --cacert pkioverheid-g1-root.pem \
  -H "Authorization: DPoP $TOKEN" \
  -H "DPoP: $(dpop GET "$URL")" \
  -H "Accept: application/fhir+json"
```

**Expected:** `200 OK` with a Bundle of the patient's resources. See
[Data Request](transactions.html#data-request).

When the Bundle has a link with relation `next`, there are more results. Request that URL unchanged,
with a new DPoP proof for its URL without query parameters. Repeat until the Bundle has no `next`
link. See [Paging](transactions.html#paging).

#### Check That Access Is Denied Without Consent

Repeat [Request an Access Token](#request-an-access-token) with BSN `111222333`. Then repeat
[Search the Patient](#search-the-patient) with the new token and BSN `111222333`.

**Expected:** `403 Forbidden` with an `OperationOutcome`. See [Errors](transactions.html#errors).

The connection works when the first three requests succeed and the last one is denied.

### Troubleshooting

| Symptom | Likely cause | Fix |
|---------|--------------|-----|
| Token request returns `412` | The wallet does not hold the credentials the presentation definition requires. | Check the wallet. See [Step 4](#step-4-load-the-credentials-into-the-wallet). |
| Token request returns `400` | A parameter is wrong, or the self-attested credentials do not match the presentation definition. | Check the request body against [Access Token Request](transactions.html#access-token-request). |
| Token request returns `502` | HINQ's authorization server rejected the request. | Check that the HINQ JSON-LD context is loaded and that your DID document is publicly reachable with a publicly trusted certificate. |
| Token request returns `503` | HINQ's authorization server cannot be reached. | Check the authorization server URL and outbound network access. |
| Loading a credential returns `400` | The credential is invalid, or `credentialSubject.id` is not your DID. | Check that HINQ issued it to the DID of your subject. |
| TLS handshake fails on a FHIR request | The client certificate is missing or not issued under G1 or G4, or the G1 root is not trusted. | See [Step 5](#step-5-configure-mtls-for-fhir-requests). |
| FHIR request returns `401` | The access token is missing, invalid or expired, or the DPoP proof is missing or invalid. | Request a new access token. Create a new proof for every request, with the exact method and the URL without query parameters. Send the token with the `DPoP` scheme, not `Bearer`. |
| FHIR request returns `400` | The request does not follow the CapabilityStatement, for example an unlisted resource type or search parameter. | Check the request against [Dataset](dataset.html#requests). |
| FHIR request returns `403` | Access is denied, for example because the patient has no consent or the BSN differs from the token. | Check that the token was requested for the same BSN. |
| FHIR request returns `429` | Too many requests. | Wait for the time in the `Retry-After` header. |
| FHIR request returns `502`, `503` or `504` | A source system, the consent check or the HINQ ION service is not available. | Retry later. See [Errors](transactions.html#errors). |

### Going to Production

For production, change the following:

- Use the production values from [Values Used on This Page](#values-used-on-this-page).
- Request new credentials from HINQ for the DID of your production subject. Credentials from
  acceptance are not valid in production.
- Use a production PKIoverheid client certificate. For the `X509Credential`, use a production UZI
  server certificate.
- Test with real patients only after the acceptance tests have passed. There are no test patients in
  production at the moment.
