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
user's Nuts node issues from and to the organisation's DID for the logged-in professional, and
includes in the access-token request. Its `credentialSubject` carries (per
[RFC019](https://nuts-foundation.gitbook.io/drafts/rfc/rfc019-employee-identity-means)):

| Field | Required? | Meaning |
|-------|:--:|---------|
| `identifier` | yes | A unique identifier for the user within the organisation. **This may be an e-mail address or an employee number.** |
| `initials`   | yes | The professional's initials. |
| `familyName` | yes | The professional's family name. |
| `roleName`   | no  | The professional's local role (e.g. "Nurse"). |

The `identifier` is **local** to the data user organisation: it is unique and stable there (an e-mail
address or employee number), but it is not a national professional identifier. Every professional has
such a local identifier today, whereas a national professional identifier and role are not yet
available for everyone — which is why the pilot relies on the local one.

### How the flow works, step by step

1. **Log in.** The healthcare professional logs in to the data user application (the Rivo-Noord
   viewer). The application creates a **user session** and stores the user info needed for the
   `NutsEmployeeCredential` (`identifier`, `initials`, `familyName`, `roleName`).
2. **Start a query.** Later in the session, the professional starts a query for a specific patient.
3. **Mandatory confirmation.** Before the credential is issued, the Nuts node presents a confirmation
   page to the professional. This page is **always shown and is not optional**: per
   [RFC019](https://nuts-foundation.gitbook.io/drafts/rfc/rfc019-employee-identity-means) the node
   MUST link the page to the session and MUST ensure the displayed user data cannot be altered. The
   dialog explains that the user's data will be exposed to the resource server (the data holder) and
   that the user is acting on behalf of their organisation; the professional confirms or rejects it.
   The session identifier has a maximum lifetime of 15 minutes.
4. **Issue the credential & request a token.** On confirmation, the data user's Nuts node mints the
   `NutsEmployeeCredential` for the session user and includes it in the call to
   `request-service-access-token`, alongside the organisation credentials (URA, AGB,
   Zorgaanbiedertype). The presentation proof contains a contract (per RFC002) declaring that the
   user acts on behalf of the organisation for a specific time period.
5. **Federation to the data holder.** The data user's Nuts node and the data holder's Nuts node
   exchange the request; the professional's identity is thereby **federated** from the data user to
   the data holder. The data holder receives an access token bound to this presentation.
6. **Introspection.** On each FHIR call, the data holder's PEP introspects the access token and
   receives the requesting URA together with the user block `{ identifier, initials, familyName,
   roleName }`.
7. **Audit & authorise.** The data holder logs the access (NEN 7513) using the user block and applies
   its authorisation and consent checks before returning data.

The exact request body is shown in [Transactions](transactions.html#pull).

### Where the trust comes from

A common and reasonable question is: if the professional's details are handed to the node as plain
JSON, where does the verifiability come from?

**The signature is at the presentation level, not on the employee credential.** You hand your *own*
Nuts node the employee's claims (`identifier`, `initials`, `familyName`, `roleName`) as plain JSON in
the `credentials` field of the token request — that is only the input. Your node then mints the
`NutsEmployeeCredential` and wraps it in a **Verifiable Presentation that it signs with your
organisation's private key**, the key bound to your organisation's `did:web`. There is no external
issuer countersignature on the employee credential itself; per the Nuts documentation these
credentials *"don't need to be signed"* because *"the presentation signature provides authenticity."*
So the integrity and authenticity of the employee data come from the organisation's signature over
the whole presentation, not from a third party vouching for the individual.

This makes the trust chain: the HINQ-issued **URA and AGB** credentials prove *which organisation*
this is (those **are** signed by a trusted issuer); the organisation then **cryptographically signs a
presentation** that vouches for its own employee; and the data holder trusts the organisation's
self-attestation about its own staff (which it logs for NEN 7513).

What the data holder can therefore **verify cryptographically**:

- the **presentation signature** — proving the request genuinely came from organisation X, untampered;
- the **organisation's identity** — anchored in the HINQ-issued URA/AGB credentials;
- **time validity** — the `NutsEmployeeCredential` carries `issuanceDate`/`expirationDate` (capped at
  a maximum of one day per RFC019), and the resulting access token is short-lived, so a stale
  credential is rejected.

What the data holder **cannot** verify cryptographically, and must instead trust by conformance:

- that the **mandatory confirmation page was actually shown and confirmed by a human**. RFC019 makes
  presenting that page an *issuer* obligation; nothing in the credential proves a person clicked. The
  data holder trusts that the requesting organisation's node implemented RFC019 correctly. The
  assurance level is therefore **organisation-attested, not user-proven** — a personal authentication
  means (such as Dezi) is what would later upgrade this to cryptographically proven user interaction.

### Limitations and future direction

- **User experience.** The EmployeeID interaction (and its pop-up) is accepted for this pilot, but
  improving or removing it is a likely change before a larger-scale pilot.
- **Local, not national.** The `identifier` is unique within the data user organisation, not
  nationally. If a national professional authentication means such as **Dezi login** proves more
  user-friendly, it could be evaluated as an alternative in a future pilot.

The organisation credentials presented alongside the `NutsEmployeeCredential` (URA, AGB,
Zorgaanbiedertype) and how HINQ issues them are described in [Exchange
Architecture](exchange.html#authentication-organisation-identity).
