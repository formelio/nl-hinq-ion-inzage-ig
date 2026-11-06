### Overview

This implementation guide describes the agreements and specifications for making **HINQ ION** data
available to requesting parties in a generic, reusable way. It lets a data user retrieve, in a secure and auditable way, the data that the HINQ ION makes
available on behalf of a source system. The data user is a care provider with a treatment
relationship.

In this pilot stage the source system is **Medicom** and the data users are the **Rivo-Noord**
region viewers. The longer-term ambition is for this guide to serve as a generic specification for
exposing HINQ ION data to requesting parties, harmonized with the other generic Nuts specifications
(Zorginzage and 360°-graden). It is largely derived from them.

### Status and Scope

This guide is a proposition for a production-grade pilot on a relatively small scale: a select set
of organizations exchanging Medicom data with the Rivo-Noord viewers. It is a plan for what could be
piloted now, as of June 2026. There is no commitment to use it, to bring it live, or to follow the
Zorginzage governance, release schedule or planning. The architectural choices are made for what is
practical and usable for this pilot, which is why the guide is versioned below 1.0. The
guiding principle is to reuse the building blocks that already exist.

> Versioning rule. This specification is dimensioned for a small pilot. Several choices below are
> deliberate pilot simplifications and are expected to change as the scope grows: addressing is out
> of scope (endpoints are hardcoded rather than discovered), and organization credentials (URA, AGB)
> are issued by HINQ rather than by a national authority. When the pilot grows beyond a handful of
> organizations, or when a national URA issuer becomes available, a new version is created to adopt
> it.

### Relationship to the Zorginzage Specification

This guide reuses building blocks from the [Zorginzage 2026
template](https://nuts-foundation.github.io/nl-zorginzage-ig/). The relevant content is copied into
this guide so that the HINQ ION Inzage specification is self-contained and does not change when the
Zorginzage specification evolves. Only the technical building blocks are taken over; the Zorginzage
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

### Release-Time-Based Components

Some components name a preferred end-state option together with the pragmatic choice the pilot makes
while the preferred option is not yet available. This lets the pilot start with available technology
while staying ready to adopt the preferred generic functions as they mature.

### HINQ as Credential Issuer

To keep onboarding short in this pilot, HINQ acts as the issuer for the Verifiable Credentials used
to authenticate organizations and to satisfy source-system consent checks. This avoids blocking on
slower-moving national identity infrastructure. See
[Authentication](exchange.html#healthcare-organization) for the credential set.

### Participating Parties and Roles (Pilot)

The two roles are vastleggen / beschikbaarstellen (record and make available) for the data holder and
raadplegen / tonen (consult and display) for the data user. See [Use Case & Roles](functional.html)
for the role definitions.

| Party | Vastleggen / beschikbaarstellen (data holder) | Raadplegen / tonen (data user) |
|-------|:--:|:--:|
| HINQ ION (Medicom source data) | ✓ |   |
| Rivo-Noord region viewer(s)     |   | ✓ |

Addressing is out of scope for this pilot (see [Exchange Architecture](exchange.html)).

### Organization of This Guide

- [Use Case & Roles](functional.html): functional overview, the participating parties and their
  roles, and the functional flows (in Dutch).
- [Exchange Architecture](exchange.html): the technical agreements: exchange patterns,
  identification, authentication, addressing, authorization, consent and network
  security (in English).
- [Credentials & Issuance](credentials.html): the organization credentials, how HINQ issues them,
  and the validity/recheck/revocation flows (in English).
- [Transactions](transactions.html): the sequence diagram of the interactions and example requests and responses (in English).
- [Integration](integration.html): the steps a data user follows to connect, with the configuration
  and test requests (in English).
- [Dataset](dataset.html): the data exposed in this pilot (in English).

### Support

For support interpreting and implementing this specification, join the
[Nuts Foundation Slack](https://join.slack.com/t/nuts-foundation/shared_invite/zt-420yjjig5-FpyD6enK0egq2ZO5WJh6vQ).
