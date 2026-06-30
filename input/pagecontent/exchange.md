This volume contains the technical agreements for making HINQ ION data available. The content is
adapted from the Zorginzage 2026 building blocks so that this guide is self-contained; the HINQ ION
Inzage-specific choices are noted where they apply.

### Exchange pattern: gericht bevragen

This exchange uses the communication pattern "gericht bevragen" (targeted querying). See the
[Whitepaper Communicatiepatronen](https://www.datavoorgezondheid.nl/documenten/2025/07/14/whitepaper-communicatiepatronen-vws)
of the Ministry of Health (in Dutch).

- **Gericht bevragen** — the data user already knows that data is present at the data holder,
  requests the data from that data holder, and receives or retrieves it.

There is a single, known data holder (HINQ ION) whose endpoints are known up front, so every exchange
in this pilot is gericht bevragen on a patient the data user already has in context.

A data exchange consists of the following steps:

1. **Authentication** — the data user authenticates at organisation and person level.
2. **Patient search** — the data user searches the patient on BSN at the data holder to obtain the
   patient's technical identifier.
3. **Data request** — the data user requests data using that technical identifier.
4. **Authorisation** — the data holder checks that the requestor is whitelisted, authorises the
   request, and checks explicit patient consent (see [Consent](#consent)) before returning data.

Addressing is **not** a step in this pilot: the data user is assumed to already know the data
holder's endpoints (see [Addressing](#addressing)).

### Principles

- This specification makes use of did:web and verifiable credentials (commonly referred to as
  "Nuts v6").
- This specification makes use of FHIR R4 APIs.

### Identification

#### Healthcare organisations — identifier: URA

Healthcare organisations are identified using the URA-number (UZI-Register Abonneenummer,
OID `2.16.528.1.1007.3.3`).

Rationale:

- Identification by URA conforms to the national information model for healthcare organisations
  (Zorginformatiebouwsteen Zorgaanbieder, [zibs.nl](https://zibs.nl/wiki/Zorgaanbieder-v3.6(2024NL))).
- The URA-number is issued by a public organisation (CIBG).

A global, unique organisation identifier is required for this exchange, and the URA is that
identifier. How the URA is made verifiable in this pilot — via a HINQ-issued credential rather than a
UZI server certificate — is described under [Authentication](#authentication-organisation-identity).

#### Healthcare organisations — HealthcareProviderRoleType (Zorgaanbiedertype)

Healthcare organisations express which type(s) of healthcare organisation they are through a
HealthcareProviderRoleType (Zorgaanbiedertype) attribute. This type is needed for consent checks at
the source system (including OTV-consent via Mitz) and for role/ZIB filtering. In this pilot the
corresponding credential is required and is issued by HINQ (see
[Authentication](#authentication-organisation-identity)).

#### Vendor organisations

Vendor organisations are not identified by a business identifier. They are authenticated at the
transport layer; see [Network security](#network-security).

#### Healthcare professionals — local employee identifier

Healthcare professionals are identified using a local employee identifier, with local employee name
and local employee role as non-identifying attributes. All professionals have a local employee
number, while a national healthcare professional identifier and role are not yet available for all
professionals. The mechanism is described in detail in [Professional
Authentication](authentication.html).

### Authentication

Authentication establishes a verifiable identity for the parties in a data exchange, at three
levels: healthcare organisations (by URA), healthcare professionals (federated from data user to
data holder), and vendor organisations (at the transport layer). Organisation- and
professional-level authentication is performed via the standard did:web-based Nuts processes.

#### Authentication — organisation identity

A global organisation identifier is required, and the agreed identifier is the **URA**. The
requesting organisation presents the following credentials, all issued by HINQ:

- **URA credential** — the primary organisation identifier, verified by HINQ against ZorgAB.
- **AGB credential** — an extra existence/match check confirming that the care provider exists and
  corresponds to the organisation, verified by HINQ against Vektis.
- **Zorgaanbiedertype credential** (HealthcareProviderRoleType) — required for the source system's
  consent checks (including Mitz) and for role/ZIB filtering.

The `identifier` value of the URA credential carries the URA-number; the credentials are presented
together in a single Verifiable Presentation when an access token is requested. Which credentials
must be presented is declared by the presentation definition for the `ion_inzage` scope (see
[Authorisation](#authorisation)).

##### Why HINQ acts as issuer

There is no authoritative national issuer for the URA-as-a-credential today; such an issuer (for
example at the CIBG) is the real end solution. Until it exists, the available fallback — deriving the
URA from a UZI server X509 certificate, as in Zorginzage/PZP — has known downsides: every vendor must
obtain and manage its own certificate, which costs money and requires someone to maintain and
coordinate all of those certificates, a significant ongoing time investment.

On top of that, there is simply no issuer at all for the other credentials this use case needs — the
Zorgaanbiedertype today, and potentially further ones in the future (such as a region-membership
credential). It therefore makes sense to have a single trusted party that manually performs the
checks and then issues these credentials. HINQ is the logical party to take this on for the pilot: as
a non-profit care cooperation it already performs these checks at scale for several hundred
organisations across various care sectors, and therefore has both the required legal basis and the
operational experience for this issuance and maintenance. This is on the explicit understanding that the role is handed over once a better,
authoritative alternative becomes available. Keeping each credential separate preserves the
flexibility to switch to such an alternative per credential, without re-bundling.

How an organisation obtains these credentials, and the validity, recheck and revocation flows, are
described in [Credentials & Issuance](credentials.html).

#### Authentication — professional identity (EmployeeID)

The healthcare professional's identity is federated from the data user to the data holder by
including a `NutsEmployeeCredential` in the access-token request. The professional is identified by a
local identifier (the "EmployeeID" — an e-mail address or employee number), with initials, family
name and role as additional attributes.

- Data users **MUST** federate healthcare professional identity using a `NutsEmployeeCredential`
  (see the request body in [Transactions](transactions.html#pull)).

The professional's identifying information is needed at the data holder for NEN 7513 audit logging,
which the `NutsEmployeeCredential` carries, and it can be used now independent of national
initiatives (e.g. Dezi) that are not yet in place. **Because this mechanism is central to the pilot,
it is documented in full on a dedicated page: [Professional
Authentication](authentication.html).**

> **Caveat: the user experience is limited.** The EmployeeID interaction (and its pop-up) is
> accepted for this pilot, but improving or removing it is a likely change before a larger-scale
> pilot.

#### Vendor authentication

Vendor organisations are authenticated at the transport layer through mTLS; see
[Network security](#network-security).

### Addressing

Addressing would discover the FHIR base URL and the authorisation server URL of a data holder.

**In this pilot, addressing is out of scope.** Because there is a single, known data holder
(HINQ ION) and the number of participants is very small, hosting a discovery service is not
worthwhile — it is sub-optimal and adds significant technical complexity for little benefit at this
scale. Instead, the data user is **assumed to already know the data holder's endpoints**, which are
configured (hardcoded) by the organisation. There is therefore no discovery step.

To perform an exchange, the data user must know the following three things about the data holder:

1. **`authorization_server`** — the data holder's OAuth2 issuer URL, of the form
   `https://<node>/oauth2/<subject>`. This immediately identifies the data holder, because its
   subject/DID is contained in the URL; from it the Nuts node resolves the data holder's metadata and
   keys.
2. **Resource endpoint** — the FHIR base URL where the actual data request is sent after the token
   has been obtained. The client adds the access token as a Bearer token, and the resource server
   validates it at the authorization server.
3. **`scope`** — the use-case scope, which for this use case is **`ion_inzage`**. Strictly speaking
   this is a use-case constant rather than a property of the data holder, but the caller must know it.
   The same identifier names the authorisation policy for this use case (see
   [Authorisation](#authorisation)).

End-state: the preferred future direction is the **Generieke Functie Adressering (GFA)**. Once it is
available, this pilot would adopt it to replace the hardcoded endpoint configuration.

### Authorisation

This specification follows the Zorginzage authorisation model: a fine-grained, policy-based access
model rather than a role-based model. Whether a requestor gets access depends on whether the request
passes the access policies of the data holder.

In addition, **requesting parties are whitelisted at the source.** Only data users that HINQ has
explicitly admitted to the pilot are accepted; a request from a party that is not on the whitelist is
rejected regardless of the credentials it presents.

Access is gated in two places. At the **token request**, the credentials a requester must present
(the URA, AGB and Zorgaanbiedertype credentials — see
[Authentication](#authentication-organisation-identity)) are demanded through a *presentation
definition* bound to the `ion_inzage` scope: the data holder's authorization server publishes it, and
the requester's Nuts node fetches it and builds a Verifiable Presentation that satisfies it before a
token is issued. This presentation definition lives in the data holder's Nuts node `policy.directory`
alongside the access policy below, and is independent of any discovery service (which this pilot does
not use). A starting-point presentation definition for the `ion_inzage` scope — with placeholder
credential types and issuer DID — is provided in the
[`policy/`](https://github.com/formelio/nl-hinq-ion-inzage-ig/tree/main/policy) directory of this
repository. The access policy below then governs the **data request** itself.

- Policies are expressed in a domain-specific language called Rego, so everyone uses the same
  rulesets evaluated against a commonly agreed information model. Implementers are free not to
  implement a Rego interpreter, as long as their solution follows exactly the same rules as the
  Rego policy for this use case.
- The applicable policies for this use case are version-controlled in a Git repository for this
  pilot.
- The data holder operates a policy enforcement point (PEP) and has access to a policy decision
  point (PDP), e.g. the PDP functionality in the Nuts Knooppunt.

Conformance:

- The data holder organisation **MUST** reject requests from organisations that are not on the
  requestor whitelist.
- The data holder organisation **MUST** enforce the rules described in the commonly defined Rego
  policy for this use case.
- The data holder organisation **MAY** implement a Rego interpreter.

The policy **MUST** take the following into account:

- Presence of the URA identifier of the requesting organisation **MUST** be checked.
- When the request is for a FHIR endpoint, conformance to a CapabilityStatement **MUST** be
  evaluated.
- Patient context is mandatory: for search interactions a patient id or BSN **MUST** be derivable
  from the query; for read interactions the requested resource **MUST** have a direct link to a
  patient.
- Explicit patient consent **MUST** be checked before returning data (see [Consent](#consent)).

### Consent

Consent verification is part of the authorisation decision. The data holder checks that a valid
explicit consent for the requested exchange is present before releasing data. The check is performed
by the data holder (the source system), wherever the patient's consent is stored — locally, at an
OTV such as Mitz, or in another consent registry; the storage location does not matter for this
specification.

Conformance:

- The data holder **MUST** check the presence of a valid explicit patient consent for the requested
  exchange before returning data.
- The data holder **MAY** check consent in a local system, at an online toestemmingsvoorziening
  (OTV, e.g. Mitz), or in another consent registry.

Attributes available for the consent check include: URA of the data user, Zorgaanbiedertype of the
data user, BSN of the patient, and the use-case identifier (`ion_inzage`). The URA, AGB and Zorgaanbiedertype
credentials needed for these checks are issued by HINQ (see
[Authentication](#authentication-organisation-identity)).

### Network security

In production and acceptance environments, vendor organisations **MUST** use server- and
client-authentication (mutual TLS) based on PKIoverheid certificates. In test environments,
PKIoverheid certificates or public-trust certificates **MUST** be used.

The national specifications for network security ("Veilig Netwerk") are not yet finalised; the
current concept version prescribes PKIoverheid certificates, which are already widely in use by
vendors.
