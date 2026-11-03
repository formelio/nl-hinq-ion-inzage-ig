This volume specifies the credentials of this use case technically. It covers the credential
types, their fields, how HINQ issues the organization credentials and how they are kept up to date.
Where the credentials are used is described in
[Identification and Authentication](exchange.html#identification-and-authentication).

### Credential Overview

The data user presents all credentials in a single Verifiable Presentation when it requests an
access token. The organization credentials are stored in the wallet of the data user's Nuts node.
The self-attested credentials are created for every access-token request.

| Credential | Type | Required |
|------------|------|----------|
| URA Credential | `HinqUraCredential` | Yes, unless an `X509Credential` is presented |
| AGB Credential | `HinqAgbCredential` | Yes, unless an `X509Credential` is presented |
| Zorgaanbiedertype Credential | `HinqHealthcareProviderRoleTypeCredential` | Always |
| X509Credential | `X509Credential` | No. It is an alternative to the URA and AGB Credentials. |
| NutsEmployeeCredential | `NutsEmployeeCredential` | Always |
| HinqBsnCredential | `HinqBsnCredential` | Always |

Every credential has a signing party and a trusted party. The **signing party** creates the
credential and signs it with its key. The signature proves that the credential was not changed. The
**trusted party** acts as the certificate authority of the credential. It vouches for the content,
the way a certificate authority vouches for the identity in a certificate. The data holder accepts
the content because it trusts that party.

| Credential | Signing party | Trusted party | How the data holder knows whom to trust |
|------------|---------------|---------------|------------------------------------------|
| URA, AGB and Zorgaanbiedertype Credentials | HINQ | HINQ | The presentation definition requires HINQ's DID as issuer. |
| X509Credential | The data user, with the key of its UZI server certificate | UZI register | The `did:x509` certificate chain must lead to a CA of the UZI register. |
| NutsEmployeeCredential and HinqBsnCredential | The data user | The data user | Nobody else vouches for the content. The data holder trusts the data user. |

### Credential Specifications

The URA, AGB and Zorgaanbiedertype Credentials share the following specifications:

1. **Issuer.** HINQ issues the credentials with its `did:web` DID. This DID is not determined yet.
   The examples use the placeholder `did:web:example.hinq.nl`. The presentation definition only
   accepts these credentials when they are issued by this DID.
2. **JSON-LD context.** The credential types are custom types. They are defined in a JSON-LD
   context that HINQ publishes. Its URL is not determined yet. The examples use the placeholder
   `https://example.hinq.nl/credentials/v1`. See [JSON-LD Context](#json-ld-context).
3. **Structure.** The credentials differ only in `type` and `credentialSubject`. The following
   example shows a complete URA Credential.

```json
{
  "@context": [
    "https://www.w3.org/2018/credentials/v1",
    "https://w3id.org/vc/status-list/2021/v1",
    "https://example.hinq.nl/credentials/v1"
  ],
  "id": "did:web:example.hinq.nl#f3a1c2d4-5b6e-4f70-8a9b-0c1d2e3f4a5b",
  "type": ["VerifiableCredential", "HinqUraCredential"],
  "issuer": "did:web:example.hinq.nl",
  "issuanceDate": "2026-11-01T00:00:00Z",
  "expirationDate": "2027-11-01T00:00:00Z",
  "credentialSubject": {
    "id": "did:web:example.vendor.nl:iam:organization-a",
    "organization": {
      "ura": "12345678"
    }
  },
  "credentialStatus": {
    "id": "https://example.hinq.nl/statuslist/1#42",
    "type": "StatusList2021Entry",
    "statusPurpose": "revocation",
    "statusListIndex": "42",
    "statusListCredential": "https://example.hinq.nl/statuslist/1"
  },
  "proof": {
    "type": "JsonWebSignature2020",
    "created": "2026-11-01T00:00:00Z",
    "proofPurpose": "assertionMethod",
    "verificationMethod": "did:web:example.hinq.nl#key-1",
    "jws": "eyJhbGciOiJFUzI1NiIsImI2NCI6ZmFsc2UsImNyaXQiOlsiYjY0Il19..<signature>"
  }
}
```

#### URA Credential

The URA Credential carries the URA-number of the data user's organization. The URA is the primary
organization identifier in this use case.

| Field | Value |
|-------|-------|
| `type` | `HinqUraCredential` |
| `credentialSubject.organization.ura` | The URA-number of the organization |
| HINQ verifies against | ZorgAB |

URA stands for UZI-Register Abonneenummer. Its OID is `2.16.528.1.1007.3.3`. The URA is used as the
organization identifier for the following reasons:

- Identification by URA conforms to the national information model for healthcare organizations.
  This model is the Zorginformatiebouwsteen Zorgaanbieder, published on
  [zibs.nl](https://zibs.nl/wiki/Zorgaanbieder-v3.6(2024NL)).
- The URA-number is issued by a public organization, the CIBG.

See the complete example in [Credential Specifications](#credential-specifications).

#### AGB Credential

The AGB Credential carries the AGB code of the data user's organization. It is an extra existence
and match check. It confirms that the care provider exists and corresponds to the organization.

| Field | Value |
|-------|-------|
| `type` | `HinqAgbCredential` |
| `credentialSubject.organization.agb` | The AGB code of the organization |
| HINQ verifies against | Vektis |

```json
"type": ["VerifiableCredential", "HinqAgbCredential"],
"credentialSubject": {
  "id": "did:web:example.vendor.nl:iam:organization-a",
  "organization": {
    "agb": "01234567"
  }
}
```

#### Zorgaanbiedertype Credential

The Zorgaanbiedertype Credential expresses which type of healthcare organization the data user is.
The data holder needs it for the consent check. It is also used for role and ZIB filtering.

| Field | Value |
|-------|-------|
| `type` | `HinqHealthcareProviderRoleTypeCredential` |
| `credentialSubject.roleCodeNL` | A code from the OrganisatieTypeCodelijst |
| HINQ verifies against | The OrganisatieTypeCodelijst |

The code comes from the OrganisatieTypeCodelijst of the
[zib Zorgaanbieder](https://zibs.nl/wiki/Zorgaanbieder-v3.6(2024NL)). Its value set OID is
`2.16.840.1.113883.2.4.3.11.60.40.2.17.2.3`. The codes come from the code system RoleCodeNL. Its OID
is `2.16.840.1.113883.2.4.15.1060`. Examples are `Z3` for a huisartspraktijk and `V4` for a
ziekenhuis.

```json
"type": ["VerifiableCredential", "HinqHealthcareProviderRoleTypeCredential"],
"credentialSubject": {
  "id": "did:web:example.vendor.nl:iam:organization-a",
  "roleCodeNL": "Z3"
}
```

#### X509Credential

The `X509Credential` is a standard Nuts credential. It is specified in
[RFC023](https://nuts-foundation.gitbook.io/drafts/rfc/rfc023-x509credential). It represents the
organization's UZI server certificate as a Verifiable Credential. HINQ does not issue it. A data user
that already has a UZI server certificate can present it instead of the URA and AGB Credentials.

The credential differs from the HINQ-issued credentials in the following ways:

- **Signing party.** The organization signs the credential with the private key of its UZI server
  certificate. The `issuer` of the credential is a `did:x509` DID derived from that certificate. The
  trusted party is the UZI register. See [Credential Overview](#credential-overview).
- **Format.** The credential is in JWT format. Its proof is verified with the public key of the
  certificate.
- **Trust.** The data holder accepts the credential when the certificate chain leads to a CA of the
  UZI register. The certificate chain is checked for revocation.
- **Content.** The `credentialSubject` only contains attributes of the certificate. The URA is taken
  from the `otherName` field of the certificate's subject alternative name.
- **Validity.** The credential cannot be valid longer than the certificate.
- **Precedence.** A data user can hold both an `X509Credential` and the URA and AGB Credentials. In
  that case the `X509Credential` is presented, and the data holder uses the URA from the
  `X509Credential`.

The following example shows the `credentialSubject` of the decoded JWT:

```json
"credentialSubject": {
  "id": "did:web:example.vendor.nl:iam:organization-a",
  "subject": {
    "O": "Huisartsenpraktijk Voorbeeld",
    "L": "Groningen"
  },
  "san": {
    "otherName": "<otherName value of the UZI server certificate>"
  }
}
```

### Self-Attested Credentials

The `NutsEmployeeCredential` and the `HinqBsnCredential` are not issued by HINQ and are not stored
in a wallet. The data user's system creates them for every access-token request. It passes them in
the `credentials` field of the `request-service-access-token` call. The data user's Nuts node issues
them with the organization's own DID and adds them to the Verifiable Presentation. The data holder's
PDP gets their fields back when it introspects the token. An example request is shown in
[Transactions](transactions.html#pull).

[Issuance](#issuance) and [Lifecycle](#lifecycle) do not apply to these credentials.

#### NutsEmployeeCredential

The `NutsEmployeeCredential` identifies the healthcare professional who makes the request. The data
user's system fills its fields from the professional's authenticated user session. Why the
credential is needed is described in [Healthcare Professional](exchange.html#healthcare-professional).

| Field | Value |
|-------|-------|
| `type` | `NutsEmployeeCredential` |
| `credentialSubject.identifier` | A unique identifier of the professional within the organization. Examples are an e-mail address or an employee number. |
| `credentialSubject.name` | The name of the professional |
| `credentialSubject.roleName` | The role of the professional |

```json
"type": ["VerifiableCredential", "NutsEmployeeCredential"],
"credentialSubject": {
  "identifier": "j.doe@example.nl",
  "name": "John Doe",
  "roleName": "Nurse"
}
```

#### HinqBsnCredential

The `HinqBsnCredential` binds the access token to one patient. The data user requests a separate
access token for every patient. The name comes from the
[HINQ JSON-LD context](#json-ld-context) that defines the credential type. HINQ does not issue it.
The data user's system self-attests it. Why the token is bound to a patient is described in
[HinqBsnCredential](exchange.html#hinqbsncredential).

| Field | Value |
|-------|-------|
| `type` | `HinqBsnCredential` |
| `credentialSubject.bsn` | The BSN of the patient |

```json
"type": ["VerifiableCredential", "HinqBsnCredential"],
"credentialSubject": {
  "bsn": "123456782"
}
```

### JSON-LD Context

The `HinqUraCredential`, `HinqAgbCredential`, `HinqHealthcareProviderRoleTypeCredential` and
`HinqBsnCredential` are custom credential types. The standard Nuts JSON-LD context does not define
them. HINQ publishes a JSON-LD context that defines these types and their fields.

The context file is
[`hinq-credentials-v1.jsonld`](https://github.com/formelio/nl-hinq-ion-inzage-ig/blob/main/jsonld/hinq-credentials-v1.jsonld)
in the `jsonld/` directory of this repository. HINQ will also publish it at its context URL.
The URL is not determined yet. The file and the examples use the placeholder
`https://example.hinq.nl/credentials/v1`.

**Why it is needed.** The credentials are JSON-LD credentials with a `JsonWebSignature2020` proof.
This signature is not computed over the raw JSON. The Nuts node uses the JSON-LD contexts to turn the
credential into a normalized list of statements. The signature is computed over that list. A node that
does not know the context cannot build the list. It therefore cannot store, present or verify the
credential.

The Nuts nodes of the data user and the data holder **MUST** load the HINQ context:

- The data user's node needs it to store the credentials in its wallet and to present them.
- The data holder's node needs it to verify the credentials at the token request.

**How it is configured.** A Nuts node runs in strict mode by default. It only uses JSON-LD contexts it
is configured for. There are two configuration options under `jsonld.contexts`:

- `localmapping` maps the context URL to a local copy of the context file, such as the file in this
  repository. This pins the version of the context and removes the dependency on HINQ's server at
  runtime.
- `remoteallowlist` allows the node to fetch the context from its URL. The node fetches the context at
  startup. When the context changes, the node must be restarted.

Setting either list replaces its default entries. The default entries **MUST** therefore be repeated
in the configuration. Otherwise the node can no longer process other credentials. The defaults are
listed in the Nuts node
[configuration reference](https://nuts-node.readthedocs.io/en/stable/pages/deployment/configuration.html).
See
[Custom Credential Configuration](https://nuts-node.readthedocs.io/en/stable/pages/deployment/verifiable-credentials.html)
in the Nuts node documentation for examples.

### Issuance

This section applies to the HINQ-issued organization credentials.

#### Requesting Credentials

Issuance in this pilot is a deliberately simple, manual process. It stays that way while no
automated, authoritative issuer exists.

1. The data user sends HINQ the **DID** of the organization it requests credentials for.
2. HINQ checks the URA against ZorgAB, the AGB against Vektis and the Zorgaanbiedertype against the
   OrganisatieTypeCodelijst.
3. HINQ issues the credentials to that DID. Its Nuts node issues each credential with an
   `expirationDate` and with StatusList2021 revocation enabled. This uses the
   `POST /internal/vcr/v2/issuer/vc` API with `withStatusList2021Revocation` set to `true`.
4. HINQ delivers the credentials to the data user, for example by e-mail.

#### Loading Credentials into the Nuts Node

The data user stores each credential in the wallet of its Nuts node with the
`POST /internal/vcr/v2/holder/{subjectID}/vc` API. The `subjectID` is the subject of the data user's
organization on its Nuts node. The Nuts node only accepts the credential when the following
conditions are met:

- `credentialSubject.id` is a DID of that subject.
- The signature is valid.
- The credential is not expired or revoked.

From then on, the Nuts node includes the credentials in the Verifiable Presentation when it requests
an access token.

### Lifecycle

This section applies to the HINQ-issued organization credentials.

#### Validity and Renewal

Each credential is **valid for one year**. The `expirationDate` is set one year after the
`issuanceDate`. This matches the maturity of this pilot. When the validation rules change, the whole
network has adopted the change within at most a year. That is the remaining lifetime of the
longest-running credential.

Credentials are **rechecked and re-issued every year**. HINQ re-runs the checks of
[Requesting Credentials](#requesting-credentials) before it issues a fresh credential. Expiry and
re-issuance are deliberately aligned. The yearly renewal also confirms that the organization still
exists in its current form. The data user loads the new credentials into its Nuts node before the old
ones expire.

#### Changes and Revocation

HINQ revokes a credential by setting its bit in the StatusList2021 status list. This uses the
`DELETE /internal/vcr/v2/issuer/vc/{id}` API. The status list is referenced in the `credentialStatus`
of the credential. A revoked credential no longer passes verification and can no longer be used to
obtain an access token.

A yearly recheck cannot catch every change in time. The **data user is therefore responsible for
reporting changes to HINQ**. Examples are:

- The organization ceases to exist.
- The organization merges with or is acquired by another organization.
- The URA, the AGB or the organization type changes.

On such a report HINQ revokes the affected credentials. Where applicable, it issues new ones.

Where the pilot governance requires a credential to be revoked, HINQ revokes it on a formal request.

### Why HINQ Acts as Issuer

There is no authoritative national issuer for these credentials today. The URA can be derived from a
UZI server certificate, but every vendor then has to obtain and manage its own certificate. For the
Zorgaanbiedertype there is no issuer at all. HINQ therefore performs the checks and issues the
credentials for the pilot. As a non-profit care cooperation, it already performs these checks for
several hundred organizations across various care sectors. The role is handed over once an
authoritative alternative exists. Each credential is kept separate, so the switch can be made per
credential.
