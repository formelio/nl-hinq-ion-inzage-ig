# Nuts node policy (`policy.directory`) for the `ion_inzage` use case

This directory contains the authorization-policy artifact that a HINQ ION Inzage **data holder**
loads into its Nuts node via the [`policy.directory`](https://nuts-node.readthedocs.io/) config key.
It is the technical, loadable counterpart to the
[Authorisation](https://formelio.github.io/nl-hinq-ion-inzage-ig/exchange.html#authorisation) section
of the Implementation Guide.

## `ion_inzage.json`

Maps the OAuth2 scope `ion_inzage` to a **presentation definition** (which Verifiable Credentials a
requester must present) plus a **`scope_policy`**. The file format follows the Nuts node policy
schema: each scope maps to one or more credential profiles (`organization`, `service_provider`,
`user`) and an optional `scope_policy`.

The `organization` profile requires the three HINQ-issued organisation credentials:

- **URA credential** — primary organisation identifier
- **AGB credential** — existence/match check
- **Zorgaanbiedertype credential** (HealthcareProviderRoleType)

### ⚠️ Placeholders — finalise before production

The credential **`type` names**, the **`credentialSubject` field paths**, and the **issuer DID**
(`did:web:example.hinq.nl`) are **placeholders**. They must be replaced with the actual values from
HINQ's issued credential schemas (the real credential types HINQ mints and HINQ's production issuer
DID). The structure, however, is correct and loadable.

### `scope_policy: profile_only`

In this pilot HINQ is the **only** data holder and runs its **own** policy enforcement point (PEP).
The Nuts node therefore only needs to enforce the **presentation requirements** (that the requester
presented valid URA + AGB + Zorgaanbiedertype credentials) before issuing a token — that is what
`profile_only` does. The **data-request authorization** (explicit consent check, patient context,
allowed FHIR queries) is enforced by HINQ's resource server/PEP, and those rules are specified
normatively in the IG's Authorisation section.

### Why there is no Rego policy file here

A shared **Rego** policy is the Zorginzage mechanism for making many independent data holders apply
the *exact same* ruleset. In this pilot that benefit does not apply: HINQ is the single source, its
PEP is not a Rego interpreter, and nothing would load a Rego file (`scope_policy` is `profile_only`,
not `dynamic`). The access rules are instead captured in the IG prose. If the use case later grows to
multiple data holders, or moves to `scope_policy: dynamic` with an AuthZen PDP, a Rego policy can be
added at that point.
