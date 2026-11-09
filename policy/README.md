# `ion_inzage` Policy for the Nuts Node

This directory contains the policy files that a HINQ ION Inzage **data holder** loads into its Nuts
node through the `policy.directory` configuration key. They are the technical counterpart of the
[Access Control](https://formelio.github.io/nl-hinq-ion-inzage-ig/exchange.html#access-control)
section of the Implementation Guide. Keep the two in sync.

## Environments

| File | Environment |
|------|-------------|
| `production/ion_inzage.json` | Production |
| `acceptance/ion_inzage.json` | Acceptance |

The two files are identical except for the trusted UZI CAs of the `X509Credential`. See
[Trusted issuers](#trusted-issuers). Every other change must be made in both files.

Each environment has its own directory because the Nuts node loads every `*.json` file in
`policy.directory`. Two files that define the same scope make the node fail to start. Point
`policy.directory` at `production/` or at `acceptance/`, never at `policy/` itself.

## `ion_inzage.json`

The file maps the OAuth2 scope `ion_inzage` to a presentation definition in the `organization`
profile, with `scope_policy: profile-only`. The presentation definition says which Verifiable Credentials the data
user must present to get an access token.

### Required Credentials

The input descriptors are grouped, and two `submission_requirements` combine the groups:

| Group | Input descriptors | Rule |
|-------|-------------------|------|
| `uzi` | `X509Credential` | Organization identity. Pick one of `uzi` or `hinq_identity`. |
| `hinq_identity` | `HinqUraCredential`, `HinqAgbCredential` | Organization identity. Pick one of `uzi` or `hinq_identity`. |
| `required` | `HinqHealthcareProviderRoleTypeCredential`, `NutsEmployeeCredential`, `HinqBsnCredential` | All are always required. |

The `uzi` group is listed first in `from_nested`. When the data user's wallet satisfies both groups,
the Nuts node picks the first one, so the `X509Credential` is presented.

The `NutsEmployeeCredential` and the `HinqBsnCredential` are self-attested by the data user. They are
matched in the `organization` profile, in line with existing production policies.

### Formats

- `ldp_vc` with `JsonWebSignature2020`, for the HINQ-issued and self-attested credentials.
- `jwt_vc` with `PS256`, for the `X509Credential`.
- `jwt_vp` with `ES256`, for the Verifiable Presentation.

### Introspection Claims

Fields with an `id` are returned as claims when the data holder's PDP introspects the token:

| Claim | Source |
|-------|--------|
| `organization_id` | `credentialSubject.id` of the URA credential or the `X509Credential` |
| `organization_ura` | `credentialSubject.organization.ura`, or the URA captured from `san.otherName` of the `X509Credential` |
| `organization_name`, `organization_city` | `subject.O` and `subject.L` of the `X509Credential`. Only present with an `X509Credential`. |
| `organization_agb` | `credentialSubject.organization.agb`. Only present with the HINQ-issued credentials. |
| `healthcare_provider_role_type` | `credentialSubject.roleCodeNL` |
| `employee_identifier`, `employee_name`, `employee_role` | `NutsEmployeeCredential` |
| `patient_bsn` | `credentialSubject.bsn` of the `HinqBsnCredential` |

### Trusted Issuers

- **HINQ-issued credentials:** `$.issuer` must equal HINQ's issuer DID. `did:web:example.hinq.nl` is
  a **placeholder** in both files. It must be replaced with HINQ's issuer DID for that environment.
- **`X509Credential`:** `$.issuer` must be a `did:x509` DID whose chain contains one of the listed UZI
  server CAs. The hash is the base64url-encoded SHA-256 of the DER-encoded CA certificate.

  | Hash | CA | Production | Acceptance |
  |------|----|:--:|:--:|
  | `vdhg746H4rLH67NN1unhdxo6PF3shQunCA4-KQTb2Jc` | UZI-register Private Server CA G1 | ✓ | ✓ |
  | `sDTL__yv54TtrvSf7601TtvHgj2NZSLT2m-Okf8oqkI` | UZI Server G4 PKIoverheid Private G TLS SYS 2025 | ✓ | ✓ |
  | `GwlhBZuEFlSHXSRUXQuTs3_YpQxAahColwJJj35US1A` | TEST UZI-register Private Server CA G1 | | ✓ |
  | `svKzNxhS07V1dKkekWOZV0d6Ao7_qvjqXegWB32YjZE` | ACCEPTATIE UZI Server - G4 Priv G-TLS SYS - 2025 | | ✓ |

  Acceptance accepts both the production CAs and the test CAs. The production CA certificates are
  published on <https://zorgcsp.nl/ca-certificaten/>. The test CA certificates are published on
  <https://acceptatie.zorgcsp.nl/ca-certificaten/>.

  Compute a hash yourself from a downloaded CA certificate:

  ```bash
  openssl x509 -inform DER -in <ca>.cer -outform DER \
    | openssl dgst -sha256 -binary | basenc --base64url | tr -d '='
  ```

  Add the hash of every new UZI server CA generation to both files.

### `scope_policy: profile-only`

The node rejects any scope in the token request other than `ion_inzage`. The presentation definition
is the only check before a token is issued. Consent, patient context and the allowed FHIR queries are
checked by HINQ's PDP at every FHIR request, not by the Nuts node.
