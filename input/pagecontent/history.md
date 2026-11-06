### Version: 0.2.0 (Current)

- [Implementation Guide](https://formelio.github.io/nl-hinq-ion-inzage-ig/)
- [Compare to v0.1.0](https://github.com/formelio/nl-hinq-ion-inzage-ig/compare/v0.1.0...main)

Significant changes:

**Changes for implementers**

- **Patient-bound access tokens.** Every access token is bound to one patient through the
  self-attested `HinqBsnCredential`. The data user requests a separate token for every patient.
- **DPoP access tokens.** The access token is a DPoP token. The data user sends a new DPoP proof
  with every FHIR request, and the data holder validates it.
- **X509Credential as an alternative.** An `X509Credential` from a UZI server certificate is
  accepted instead of the URA and AGB credentials. The Zorgaanbiedertype credential is always
  required.
- **Credential types renamed.** `UraCredential`, `AgbCredential` and
  `HealthcareProviderRoleTypeCredential` are renamed to `HinqUraCredential`, `HinqAgbCredential`
  and `HinqHealthcareProviderRoleTypeCredential`.
- **Network security clarified.** Mutual TLS applies to the FHIR requests only. HINQ's FHIR
  endpoint has a PKIoverheid G1 server certificate and accepts G1 or G4 client certificates. The
  Nuts endpoints use publicly trusted certificates.
- **Consent information.** The professional's role is no longer part of the consent check. It is
  recorded for audit logging.

**Pages**

- **Exchange Architecture restructured.** The page has an exchange flow overview, a short
  Addressing section, and an Access Control section that covers the token request, the data
  request, consent and conformance. The Consent section lists the information the data user must
  provide, without naming a consent registry.
- **Credentials & Issuance rewritten.** The page covers the credential overview with the signing
  and trusted party, the credential specifications, the self-attested credentials, the JSON-LD
  context, issuance and the lifecycle.
- **Transactions restructured.** The page has an updated sequence diagram and examples for the
  access token request, the DPoP proof, token introspection, patient search, data request and
  errors.
- **Integration page added.** The new page describes the steps a data user follows to connect: the
  Nuts node configuration, the organization subject, the credentials, mTLS for the FHIR requests
  and test requests with DPoP proofs.
- **Dataset defined.** The Dataset page lists the huisarts data elements and a generic request for
  each. Medicom provides STU3 resources following MedMij Huisartsgegevens 2.0. The HINQ ION service
  converts them to R4.
- **Use Case & Roles removed.** The Dutch page repeated the Home page. Its role definitions and the
  owner and trusted issuer are now on the Home page.
- **Deviations from Zorginzage.** The list of deviations on the Home page is complete.

**Repository**

- **Policy rewritten.** The Nuts policy is split into a production and an acceptance file. It now
  covers the `X509Credential`, the `NutsEmployeeCredential` and the `HinqBsnCredential`, and uses
  the valid `scope_policy` value `profile-only`.
- **JSON-LD context added.** The repository contains the JSON-LD context for the HINQ credential
  types.
- **Spelling.** The guide uses American English.

### Version: 0.1.0

- [Implementation Guide](https://formelio.github.io/nl-hinq-ion-inzage-ig/)
- [Source code](https://github.com/formelio/nl-hinq-ion-inzage-ig)

Initial proposition for the HINQ ION Inzage pilot: making HINQ ION (Medicom) data available to the
Rivo-Noord region viewers for a select set of organizations. Reuses the Zorginzage 2026 building
blocks (copied in, not referenced) and drops the Zorginzage governance, roadmap and release-policy
chapters. Key pilot deviations: addressing is out of scope (endpoints are hardcoded), exchange is
always gericht bevragen, and organization credentials (URA, AGB and Zorgaanbiedertype) are issued by
HINQ.

<!-- Template for future entries:
### Version: 0.3.0
- [Compare to v0.2.0](https://github.com/formelio/nl-hinq-ion-inzage-ig/compare/v0.2.0...main)
- Significant changes:
-->
