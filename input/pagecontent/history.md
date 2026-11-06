### Version: 0.2.0 (Current)

- [Implementation Guide](https://formelio.github.io/nl-hinq-ion-inzage-ig/)
- [Compare to v0.1.0](https://github.com/formelio/nl-hinq-ion-inzage-ig/compare/v0.1.0...main)

Significant changes:

- **Patient-bound access tokens.** Every access token is bound to one patient through the
  self-attested `HinqBsnCredential`. The data user requests a separate token for every patient.
- **X509Credential as an alternative.** An `X509Credential` from a UZI server certificate is accepted
  instead of the URA and AGB credentials. The Zorgaanbiedertype credential is always required.
- **Credential type names.** The HINQ-issued credentials are named `HinqUraCredential`,
  `HinqAgbCredential` and `HinqHealthcareProviderRoleTypeCredential`.
- **Exchange Architecture restructured.** The page has an exchange flow overview, an Addressing
  section, and an Access Control section that covers the token request, the data request, consent
  and conformance. The Consent section lists the information the data user must provide, without
  naming a consent registry.
- **Credentials & Issuance rewritten.** The page covers the credential overview with the signing and
  trusted party, the credential specifications, the self-attested credentials, the JSON-LD context,
  issuance and the lifecycle.
- **Transactions restructured.** The page has an updated sequence diagram and examples for the access
  token request, token introspection, patient search, data request and errors.
- **Integration page added.** The new page describes the steps a data user follows to connect:
  the Nuts node configuration, the organization subject, the credentials, mTLS for the FHIR requests
  and test requests.
- **Dataset defined.** The Dataset page lists the huisarts data elements and a generic request for
  each. Medicom provides STU3 resources following MedMij Huisartsgegevens 2.0. The HINQ ION service
  converts them to R4.
- **Deviations from Zorginzage.** The list of deviations on the Home page is complete and includes
  the patient-bound access tokens.
- **Technical artifacts.** The repository contains Nuts policy files for production and acceptance,
  and the JSON-LD context for the HINQ credential types.
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
