### Overview

This implementation guide describes the agreements and specifications for making **HINQ ION** data
available to requesting parties in a generic, reusable way. It lets a data user retrieve the data
that HINQ ION makes available on behalf of source healthcare organizations, in a secure and
auditable way. The data user is a care provider with a treatment relationship with the patient.

In this pilot stage, the source system is **Medicom**, a huisartsinformatiesysteem, and the data
users are the **Rivo-Noord** region viewers. The data is huisarts data. See [Dataset](dataset.html). The longer-term ambition is for this guide to serve as a generic specification for
exposing HINQ ION data to requesting parties. It is harmonized with the other generic Nuts
specifications, Zorginzage and 360°-graden, and is largely derived from them.

### Status and Scope

This guide is a proposition for a production-grade pilot on a relatively small scale: a select set
of organizations exchanging Medicom data with the Rivo-Noord viewers. It is a plan for what can be
piloted with the building blocks available today. There is no commitment to use it, to bring it
live, or to follow the Zorginzage governance, release schedule or planning. The architectural
choices are made for what is practical and usable for this pilot, which is why the guide is
versioned below 1.0. The current version is 0.2.0. The changes per version are listed in
[History](changes.html). The guiding principle is to reuse the building blocks that already exist.

> **Versioning rule.** This specification is sized for a small pilot. Several choices are
> deliberate pilot simplifications and are expected to change as the scope grows. Addressing is out
> of scope, so the endpoints are configured instead of discovered. The URA, AGB and Zorgaanbiedertype
> credentials are issued by HINQ instead of by a national authority. When the pilot grows beyond a handful of
> organizations, or when a national URA issuer becomes available, a new version is created to adopt
> it.

### Relationship to the Zorginzage Specification

This guide reuses building blocks from the [Zorginzage 2026
template](https://nuts-foundation.github.io/nl-zorginzage-ig/). The relevant content is copied into
this guide so that the HINQ ION Inzage specification is self-contained and does not change when the
Zorginzage specification evolves. Only the technical building blocks are taken over. The Zorginzage
governance, reciprocity, commitment, roadmap and release-policy chapters are out of scope. Where
this pilot deviates from Zorginzage, the deviation is stated explicitly. The deviations are:

- **Addressing is out of scope.** The data user knows the data holder's endpoints up front. See
  [Addressing](exchange.html#addressing).
- **Only gericht bevragen.** There is a single known data holder. See
  [Exchange Pattern](exchange.html#exchange-pattern-gericht-bevragen).
- **HINQ-issued organization credentials.** HINQ issues the URA, AGB and Zorgaanbiedertype
  credentials. An `X509Credential` from a UZI server certificate is accepted as an alternative. See
  [Healthcare Organization](exchange.html#healthcare-organization).
- **Patient-bound access tokens.** In Zorginzage, an access token is bound to one organization. In
  this specification, each token is also bound to one patient through the `HinqBsnCredential`. See
  [HinqBsnCredential](exchange.html#hinqbsncredential).

### Key Technical Choices

- **Nuts v6.** Organizations are authenticated with did:web and Verifiable Credentials. The data user
  gets an access token for the `ion_inzage` scope from HINQ's Nuts node. See
  [Access Control](exchange.html#access-control).
- **Patient-bound DPoP tokens.** Every access token is bound to one patient and to a key of the data
  user. The data user sends a new DPoP proof with every request. See
  [DPoP Proof](transactions.html#dpop-proof).
- **Consent.** The data holder checks the patient's consent at every request. See
  [Consent](exchange.html#consent).
- **FHIR R4.** The data user searches for the patient by BSN and then requests the patient's data.
  The allowed requests are listed in the
  [CapabilityStatement](CapabilityStatement-HINQIONDataHolder.html).
- **Mutual TLS.** The FHIR requests use mutual TLS with PKIoverheid certificates. See
  [Network Security](exchange.html#network-security).

### HINQ as Credential Issuer

To keep onboarding short in this pilot, HINQ acts as the issuer of the URA, AGB and Zorgaanbiedertype
credentials. They authenticate the data user's organization and provide the details for the consent
check. This avoids blocking on slower-moving national identity infrastructure. An organization with
a UZI server certificate can use an `X509Credential` instead of the URA and AGB credentials. See
[Healthcare Organization](exchange.html#healthcare-organization) for the credential set.

### Participating Parties and Roles

The use case has two roles:

- **Data holder.** Vastleggen / beschikbaarstellen, which means record and make available. After
  authentication and authorization, HINQ ION makes the data of the source system available to a data
  user.
- **Data user.** Raadplegen / tonen, which means consult and display. The data user requests the
  data from HINQ ION and displays it to the healthcare professional. In this pilot, the data user is
  a Rivo-Noord viewer.

There is no mandatory reciprocity. A participant does not have to implement both roles.

| Party | Data holder | Data user |
|-------|:--:|:--:|
| HINQ ION (Medicom source data) | ✓ |   |
| Rivo-Noord region viewer(s)     |   | ✓ |

HINQ is the owner of this specification and the trusted issuer of the organization credentials.

### Organization of This Guide

- [Exchange Architecture](exchange.html): the technical agreements. These are the exchange pattern,
  identification, authentication, addressing, access control, consent and network security.
- [Credentials & Issuance](credentials.html): the credentials, how HINQ issues the organization
  credentials, and their validity, renewal and revocation.
- [Transactions](transactions.html): the sequence diagram of the interactions, and example requests
  and responses for the access token, the DPoP proof, the patient search, the data request, paging
  and errors.
- [Integration](integration.html): the environments and the steps a data user follows to connect,
  with the configuration and test requests.
- [Dataset](dataset.html): the huisarts data that is made available, and the request for each data
  element.
- [Artifacts](artifacts.html): the conformance resources and examples of this guide. These are the
  [CapabilityStatement](CapabilityStatement-HINQIONDataHolder.html), the machine-readable list of
  the requests the data holder supports, and an illustrative example Patient.
- [History](changes.html): the changes per version.

### Support

For support interpreting and implementing this specification, join the
[Nuts Foundation Slack](https://join.slack.com/t/nuts-foundation/shared_invite/zt-420yjjig5-FpyD6enK0egq2ZO5WJh6vQ).
