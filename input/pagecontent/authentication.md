This volume explains, in detail, how **professional authentication** works in this pilot.
Professional authentication via the Nuts EmployeeID is the primary means of identifying the person
behind a request. Organisation authentication, and the credentials HINQ issues for it, are described
in [Exchange Architecture](exchange.html#authentication-organisation-identity).

### Why professional authentication matters

Two things must be true for a data holder to safely release patient data to a data user:

1. **There is a real person behind the request.** The data is requested by a healthcare professional
   acting in a treatment relationship, not by an unattended system. The EmployeeID makes this
   plausible: a professional logged in, a user session was created, and the professional's details
   travel with the request.
2. **The request can be audited.** Under NEN 7513, the data holder must log who accessed which
   patient's data. The EmployeeID carries exactly the identifying information needed for that audit
   trail, and lets the data holder check that the source system is passing through the correct user.

### What the EmployeeID is

The EmployeeID is conveyed as a **`NutsEmployeeCredential`** — a Verifiable Credential that the data
user's Nuts node self-attests for the logged-in professional and includes in the access-token
request. In Nuts v6 this credential is **self-attested**: it does not need an external issuer
signature, and its authenticity comes from the organisation's signature over the presentation (see
the [Requesting Access (outbound)](https://wiki.nuts.nl/books/implementing-a-nuts-use-case/page/requesting-access-outbound)
guide). Its `credentialSubject` carries:

| Field | Required? | Meaning |
|-------|:--:|---------|
| `identifier` | yes | A unique identifier for the user within the organisation. **This may be an e-mail address or an employee number.** |
| `name`       | yes | The professional's name (for the audit log and for display at the data holder). |
| `roleName`   | no  | The professional's local role (e.g. "Nurse"). |

The `identifier` is **local** to the data user organisation: it is unique and stable there (an e-mail
address or employee number), but it is not a national professional identifier. Every professional has
such a local identifier today, whereas a national professional identifier and role are not yet
available for everyone — which is why the pilot relies on the local one.

### How the flow works, step by step

This flow is **fully non-interactive** — there is no confirmation pop-up or challenge (see
[note on RFC019](#note-the-rfc019-html-challenge-is-outdated)).

1. **Log in.** The healthcare professional logs in to the data user application (the Rivo-Noord
   viewer). The application creates a **user session** and stores the user info needed for the
   `NutsEmployeeCredential` (`identifier`, `name`, `roleName`). This login (with 2FA and a
   personal account) is where the "real person behind the request" is established.
2. **Start a query.** Later in the session, the professional starts a query for a specific patient.
3. **Request a token.** The data user's Nuts node self-attests the `NutsEmployeeCredential` for the
   session user and includes it in the call to `request-service-access-token`, alongside the
   organisation credentials (URA, AGB, Zorgaanbiedertype). No user interaction takes place at this
   step.
4. **Federation to the data holder.** The data user's Nuts node and the data holder's Nuts node
   exchange the request; the professional's identity is thereby **federated** from the data user to
   the data holder. The data holder receives an access token bound to the signed presentation.
5. **Introspection.** On each FHIR call, the data holder's PEP introspects the access token and
   receives the requesting URA together with the user block `{ identifier, name, roleName }`.
6. **Audit & authorise.** The data holder logs the access (NEN 7513) using the user block and applies
   its authorisation and consent checks before returning data.

The exact request body is shown in [Transactions](transactions.html#pull).

### Note: the RFC019 HTML challenge is outdated

Earlier Nuts (v5) defined an interactive "EmployeeIdentity authentication means"
([RFC019](https://nuts-foundation.gitbook.io/drafts/rfc/rfc019-employee-identity-means)) in which the
node presented a **mandatory HTML confirmation page** that the professional had to approve before the
credential was issued. **That mechanism is outdated and does not apply to Nuts v6.** In v6 the
`NutsEmployeeCredential` is simply self-attested and included in the token request without any
challenge, as described above. This guide follows the v6 approach; the assurance that a real person
is behind the request comes from the data user application's own login (2FA, personal accounts), not
from a Nuts-enforced confirmation page.

### Limitations and future direction

- **Self-attested / app-level assurance.** The "person behind the request" is established by the data
  user application's login, not proven cryptographically by Nuts. This is accepted for the pilot.
- **Local, not national.** The `identifier` is unique within the data user organisation, not
  nationally. If a national professional authentication means such as **Dezi login** proves more
  user-friendly, it could be evaluated as an alternative in a future pilot.

The organisation credentials presented alongside the `NutsEmployeeCredential` (URA, AGB,
Zorgaanbiedertype) and how HINQ issues them are described in [Exchange
Architecture](exchange.html#authentication-organisation-identity).
