This volume describes the organisation credentials used in this pilot, how HINQ issues them, and how
they are kept up to date. **Why** these credentials are needed and **why HINQ** is the issuing party
is covered in [Exchange Architecture →
Authentication](exchange.html#authentication-organisation-identity); this volume covers **how to
obtain them** and the **maintenance flows**.

### The credential set

In this pilot HINQ acts as the trusted issuer for the organisation credentials. All three are
required and are presented together in a single Verifiable Presentation when an access token is
requested.

| Credential | Purpose | HINQ verifies against |
|------------|---------|-----------------------|
| **URA credential** | Primary organisation identifier (authentication of the data user). The `identifier` carries the URA-number. | ZorgAB |
| **AGB credential** | Extra existence/match check that the care provider exists and corresponds to the organisation. | Vektis |
| **Zorgaanbiedertype credential** (HealthcareProviderRoleType) | Needed for the source system's consent checks (including Mitz) and for role/ZIB filtering. | Nictiz codelist (organisation type) |

### Issuance process (pilot)

Issuance is a deliberately simple, manual process while no automated, authoritative issuer exists:

1. The requesting organisation sends HINQ the **DID** of the organisation it is requesting
   credentials for.
2. HINQ performs the checks above (URA against ZorgAB, AGB against Vektis, Zorgaanbiedertype against
   the Nictiz codelist).
3. HINQ issues the credentials to that DID and delivers them to the organisation (for example by
   e-mail), after which they are loaded into the organisation's Nuts node wallet.

This manual route keeps onboarding short and avoids blocking on slower-moving identity
infrastructure.

### Validity and maintenance

**Validity — one year.** Each credential is **active for one year**. Tying validity to a one-year
window matches the maturity of this pilot: if the validation rules change, the whole network has
adopted the change within at most a year (the remaining lifetime of the longest-running credential).

**Proactive yearly recheck and re-issuance.** Credentials are **rechecked and re-issued every year**
as a proactive measure to ensure the underlying data is still correct. Re-validation re-runs the same
checks (ZorgAB, Vektis, Nictiz codelist) before a fresh credential is issued; expiry and re-issuance
are deliberately aligned so that the yearly renewal doubles as the moment to confirm the organisation
still exists in its current form.

**Requestor responsibility for changes and revocations.** Because a yearly recheck cannot catch
everything in time, it is the **responsibility of the data requestor to proactively communicate
changes to HINQ** so that credentials can be re-issued or revoked. This includes, for example, the
organisation ceasing to exist, being merged into or acquired by another organisation, or any change
to the details underlying a credential (URA, AGB, or organisation type). On such a notification HINQ
revokes and, where applicable, re-issues the affected credentials.

**Escalated revocation.** Where the pilot governance requires a credential to be revoked, HINQ
carries out the revocation on a formal request, after which the credential can no longer be used in a
data request.
