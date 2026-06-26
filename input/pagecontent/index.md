### Overview

This implementation guide describes the agreements and specifications for making **HINQ ION** data
available to requesting parties in a generic, reusable way. It lets a data user — a care provider
with a treatment relationship — retrieve, in a secure and auditable way, the data that the HINQ ION
makes available on behalf of a source system.

In this pilot stage the source system is **Medicom** and the data users are the **Rivo-Noord**
region viewers. The longer-term ambition is for this guide to serve as a generic specification for
exposing HINQ ION data to requesting parties, harmonised with — and largely derived from — the
other generic Nuts specifications (Zorginzage and 360°-graden).

### Status and scope

This guide is a proposition for a production-grade pilot on a relatively small scale: a select set
of organisations exchanging Medicom data with the Rivo-Noord viewers. It is a plan for what could be
piloted now, as of June 2026. There is no commitment to use it, to bring it live, or to follow the
Zorginzage governance, release schedule or planning. The architectural choices are made for what is
practical and usable for this pilot, which is why the guide is versioned 0.1.0 rather than 1.0. The
guiding principle is to reuse the building blocks that already exist.

> Versioning rule. This specification is dimensioned for a small pilot. Several choices below are
> deliberate pilot simplifications and are expected to change as the scope grows: addressing is out
> of scope (endpoints are hardcoded rather than discovered), requesting parties are individually
> whitelisted at the source, and organisation credentials (URA, AGB) are issued by HINQ rather than
> by a national authority. When the pilot grows beyond a handful of organisations, or when the
> generic functions (addressing, a national URA issuer) become available, a new
> version is created to adopt them.

### Relationship to the Zorginzage specification

This guide reuses building blocks from the [Zorginzage 2026
template](https://nuts-foundation.github.io/nl-zorginzage-ig/). The relevant content is copied into
this guide so that the HINQ ION Inzage specification is self-contained and does not change when the
Zorginzage specification evolves. Only the technical building blocks are taken over; the Zorginzage
governance, reciprocity, commitment, roadmap and release-policy chapters are out of scope. Where
this pilot deviates from Zorginzage — most notably on addressing and organisation authentication —
the deviation is stated explicitly.

### Release-time-based components

Some components name a preferred end-state option together with the pragmatic choice the pilot makes
while the preferred option is not yet available. This lets the pilot start with available technology
while staying ready to adopt the preferred generic functions as they mature. The pattern applies to
[addressing](exchange.html#addressing) (end-state: Generieke Functie Adressering).

### HINQ as credential issuer

To keep onboarding short in this pilot, HINQ acts as the issuer for the Verifiable Credentials used
to authenticate organisations and to satisfy source-system consent checks. This avoids blocking on
slower-moving national identity infrastructure. See
[Authentication](exchange.html#authentication-organisation-identity) for the credential set.

### Participating parties and roles (pilot)

The two roles are vastleggen / beschikbaarstellen (record and make available — the data holder) and
raadplegen / tonen (consult and display — the data user). See [Use Case & Roles](functional.html)
for the role definitions.

| Party | Vastleggen / beschikbaarstellen (data holder) | Raadplegen / tonen (data user) |
|-------|:--:|:--:|
| HINQ ION (Medicom source data) | ✓ |   |
| Rivo-Noord region viewer(s)     |   | ✓ |

Addressing is out of scope for this pilot (see [Exchange Architecture](exchange.html)).

### Organisation of this guide

- [Use Case & Roles](functional.html) — functional overview, the participating parties and their
  roles, and the functional flows (in Dutch).
- [Exchange Architecture](exchange.html) — the technical agreements: exchange patterns,
  identification, authentication, addressing, authorisation, consent and network
  security (in English).
- [Professional Authentication](authentication.html) — a detailed explanation of the Nuts EmployeeID
  mechanism (in English).
- [Credentials & Issuance](credentials.html) — the organisation credentials, how HINQ issues them,
  and the validity/recheck/revocation flows (in English).
- [Transactions](transactions.html) — the individual transactions of the pull flow (in English).
- [Dataset](dataset.html) — the data exposed in this pilot (in English).

### Support

For support interpreting and implementing this specification, join the
[Nuts Foundation Slack](https://join.slack.com/t/nuts-foundation/shared_invite/zt-420yjjig5-FpyD6enK0egq2ZO5WJh6vQ).
