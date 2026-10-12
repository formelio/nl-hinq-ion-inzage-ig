This volume contains the technical agreements for making HINQ ION data available. The content is
adapted from the Zorginzage 2026 building blocks so that this guide is self-contained. The HINQ ION
Inzage-specific choices are noted where they apply.

### Overview

#### Exchange Pattern: Gericht Bevragen

This exchange uses the communication pattern "gericht bevragen", which means targeted querying. The
data user already knows that data is present at the data holder. It requests the data from that data
holder and receives or retrieves it. The pattern is described in the
[Whitepaper Communicatiepatronen](https://www.datavoorgezondheid.nl/documenten/2025/07/14/whitepaper-communicatiepatronen-vws)
of the Ministry of Health. This whitepaper is in Dutch.

There is a single, known data holder, HINQ ION, and its endpoints are known up front. Every exchange
in this pilot is therefore gericht bevragen on a patient the data user already has in context.

#### Principles

- This specification makes use of did:web and verifiable credentials. This is commonly referred to as
  "Nuts v6".
- This specification makes use of FHIR R4 APIs.

#### Exchange Flow

A data exchange consists of the following steps:

1. **Access token request.** The data user requests an access token for one specific patient. It
   authenticates at organisation and person level and supplies the patient's BSN in a
   `NutsBSNCredential`. The token is bound to that patient. See
   [Identification and Authentication](#identification-and-authentication) and
   [NutsBSNCredential](#nutsbsncredential).
2. **Patient search.** The data user searches the patient on BSN at the data holder to obtain the
   patient's technical identifier.
3. **Data request.** The data user requests data using that patient's technical identifier.

The data holder performs four access checks. The details are in [Access control](#access-control).

| Check | At the token request | At every FHIR request |
|-------|:--:|:--:|
| The organisation credentials match the presentation definition | ✓ | |
| The request comes from a whitelisted IP address | | ✓ |
| The access rules are met | | ✓ |
| Explicit patient consent is present | | ✓ |

Addressing is **not** a step in this pilot. The data user is assumed to already know the data
holder's endpoints.

### Endpoints and Configuration

Addressing would discover the FHIR base URL and the authorisation server URL of a data holder.
**In this pilot, addressing is out of scope.** Instead, the data user is **assumed to already know
the data holder's endpoints**. The organisation configures these endpoints as fixed values. There is
therefore no discovery step.

#### What the Data User Must Know?

To perform an exchange, the data user must know the following three things about the data holder:

1. **`authorization_server`.** This is the data holder's OAuth2 issuer URL, of the form
   `https://<node>/oauth2/<subject>`. The URL immediately identifies the data holder, because it
   contains the data holder's subject/DID. From it, the Nuts node resolves the data holder's metadata
   and keys.
2. **Resource endpoint.** This is the FHIR base URL where the actual data request is sent after the
   token has been obtained. The client adds the access token as a Bearer token. The resource server
   validates the token at the authorization server.
3. **`scope`.** This is the use-case scope. For this use case it is **`ion_inzage`**. Strictly
   speaking, the scope is a use-case constant rather than a property of the data holder, but the
   caller must know it. The same identifier names the authorisation policy for this use case. See
   [Access control](#access-control).

#### Why Is There No Discovery?

There is a single known data holder, HINQ ION, and the number of participants is very small.
Hosting a discovery service is therefore not worthwhile. It is sub-optimal and adds significant
technical complexity for little benefit at this scale.

The preferred end-state is the **Generieke Functie Adressering**, or GFA. Once it is available, this
pilot would adopt it to replace the fixed endpoint configuration.

### Identification and Authentication

Authentication establishes a verifiable identity for the parties in a data exchange. It works at
three levels:

- Healthcare organisations are authenticated by their URA.
- The identity of healthcare professionals is federated from the data user to the data holder.
- Vendor organisations are authenticated at the transport layer with mTLS.

Organisation-level and professional-level authentication use the standard did:web-based Nuts
processes.

#### Healthcare Organisation

##### Required Credentials

The requesting organisation presents the following credentials. HINQ issues the URA, AGB and
Zorgaanbiedertype credentials. [Credentials & Issuance](credentials.html) describes how HINQ
verifies, issues and maintains them.

| Credential | Purpose | Verified against |
|------------|---------|------------------|
| **URA Credential** | The primary organisation identifier. | ZorgAB |
| **AGB Credential** | An extra existence and match check. It confirms that the care provider exists and corresponds to the organisation. | Vektis |
| **Zorgaanbiedertype Credential** | Expresses which types of healthcare organisation the requestor is. Its technical name is `HealthcareProviderRoleTypeCredential`. The source system needs it for the consent check at Mitz. It is also used for role and ZIB filtering. | Nictiz codelist |
| **X509Credential** | A standard Nuts credential derived from the organisation's UZI server certificate. It carries the UZI, URA and AGB. HINQ does not issue it. | The UZI certificate chain |

An organisation that already has an `X509Credential` MAY present it instead of the URA Credential
and the AGB Credential. The `Zorgaanbiedertype Credential` is always required.

##### Why HINQ Acts as Issuer

There is no authoritative issuer yet for these credentials. HINQ therefore performs the checks and
issues them for the pilot. The role is handed over once an authoritative alternative exists.
[Credentials & Issuance](credentials.html) describes the full rationale. It also describes how an
organisation obtains the credentials and how validity, rechecks and revocation work.

#### Healthcare Professional

##### NutsEmployeeCredential

Healthcare professionals are identified using a local employee identifier, called the "EmployeeID".
The local employee name and local employee role are added as non-identifying attributes. All
professionals have a local employee number. A national healthcare professional identifier and role
are not yet available for all professionals.

The healthcare professional's identity **MUST** be federated from the data user to the data holder. The data
user does this by including a `NutsEmployeeCredential` in the access-token request. The request body is shown in [Transactions](transactions.html#pull).

The `NutsEmployeeCredential` is **self-attested** by the data user's system. This is in line with the
Zorginzage authentication approach in Nuts v6. The data user's application authenticates the
professional in its own user session. It fills the credential fields from that session. These fields
are the name, the role and the identifier. The data user's system **MUST** supply these fields and is
expected to have verified them. This lets the data holder meet its NEN 7513 audit logging
obligations. The approach works today, independent of national initiatives such as Dezi that are not
yet in place.

##### Implementation

**No interactive challenge.** The credential is built from the data user's own authenticated session.
There is explicitly no HTML challenge or pop-up. This differs from the previous Nuts v5 employee
identity means, described in
[RFC019](https://nuts-foundation.gitbook.io/drafts/rfc/rfc019-employee-identity-means). That approach
hosted a web page for the professional to confirm their details. Under the self-attested model the
data user is trusted to have authenticated the professional and checked the supplied fields.

The data user passes the employee fields directly in the `request-service-access-token` call. The
Nuts node places them in the claims of the returned access token. The application therefore does
**not** need to render an HTML page from its Nuts node to obtain the token. The exact
request/response shape and API details are in the Nuts node
[auth v2 API documentation](https://nuts-node.readthedocs.io/en/stable/pages/integrating/api.html)
and on the [Requesting Access](https://wiki.nuts.nl/books/implementing-a-nuts-use-case/page/requesting-access-outbound)
wiki page.

#### Vendor Organisation

Vendor organisations are not identified by a business identifier. They are authenticated at the
transport layer through mTLS. See [Network security](#network-security).

### Access Control

This specification follows the Zorginzage authorisation model. This is a fine-grained, policy-based
access model rather than a role-based model. Whether a requestor gets access depends on whether the
request passes the access policies of the data holder.

Access is gated in two places: at the token request and at the data request.

#### Token Request

The data user requests the access token from its own Nuts node. The access-token request contains
the organisation credentials, a `NutsEmployeeCredential` and a `NutsBSNCredential`. Together they
identify the requesting organisation, the healthcare professional and the patient.

##### Organisation Credentials

The requester must present the [required credentials](#required-credentials). A *presentation
definition* bound to the `ion_inzage` scope demands these credentials. The data holder's
authorization server publishes this presentation definition. The requester's Nuts node fetches it and
builds a Verifiable Presentation that satisfies it. Only then is a token issued. [Policy](policy.html)
describes the presentation definition and how it is loaded into the data holder's Nuts node.

##### NutsEmployeeCredential

This credential federates the identity of the healthcare professional to the data holder. The data 
user's system self-attests it. [Healthcare Professional](#healthcare-professional) describes the 
credential fields and how the data user fills them.

When the PDP introspects the token, it gets the professional's identifier and role back. The PDP uses
them for the consent check. See [Consent](#consent).

- The access-token request **MUST** include a `NutsEmployeeCredential`.

##### NutsBSNCredential

Every access token in this use case is bound to a single patient. The data user binds the token by
including a `NutsBSNCredential` in the access-token request. This credential carries the patient's
BSN. It works the same way as the [`NutsEmployeeCredential`](#healthcare-professional).

When the PDP introspects the token at the data holder's Nuts node, it gets the BSN back. The PDP uses
it for the consent check and passes it on with the request.

**Why patient-bound tokens.** By default, Nuts scopes access tokens to the organisation and use case,
and the data holder derives the patient from each request. Nuts leaves this choice to the use case. This
use case binds every token to one patient for the following reasons:

- **Smaller impact of misuse.** An organisation-level token can be used for any patient at the data
  holder. A leaked or misused patient-bound token exposes only one patient.
- **Trusted patient context.** The patient is part of the signed token, not of the unsigned HTTP
  request. A tampered token is rejected.
- **Every patient access passes the authorization server.** The data user needs a new token for each
  patient. This gives the data holder one place to apply rate limits, logging and alerting.
- **No request-body inspection.** The patient search is a POST request with the BSN in the body. The
  PDP does not read request bodies. The token gives the PDP the BSN for every request, including the
  patient search.

The `NutsBSNCredential` is self-attested, so it does not prove the requester's relationship with the
patient. It narrows access but does not replace the authorisation checks. The data holder still
checks consent at Mitz for this patient, requester and professional. See [Consent](#consent).

- The data user **MUST** request a separate access token for every patient.
- The data user **MUST** include a `NutsBSNCredential` with the patient's BSN in the access-token
  request.

#### Data Request

**Requesting parties are IP-whitelisted at the FHIR endpoint.** HINQ keeps a whitelist with the IP
addresses of the data users it has explicitly admitted to the pilot. The data holder rejects a
request to the FHIR endpoint when it comes from an IP address that is not on this whitelist. This
applies regardless of the access token or credentials the requester presents.

The access rules below govern the **data request** itself. The data holder evaluates them in its
policy decision point, or PDP. This specification does not prescribe how the PDP implements the
rules. It only requires that the PDP applies exactly these rules.

Zorginzage expresses its access rules as a shared policy in the Rego language. That way many
independent data holders apply exactly the same ruleset. This pilot has a single data holder, so
there is no shared Rego policy. The rules in this section are the normative ruleset instead. If more
data holders join the use case later, a shared Rego policy can be added at that point.

The access rules are:

- Presence of the required fields for consent check **MUST** be checked. See [Consent](#consent).
- Patient context is mandatory. The access token **MUST** be bound to a patient. The PDP takes the
  patient's BSN from the token, not from the request.
- The requested data **MUST** belong to the patient the access token is bound to.
- Explicit patient consent **MUST** be checked before returning data. See [Consent](#consent).

#### Consent

Consent verification is part of the authorisation decision. The data holder checks that a valid
explicit consent for the requested exchange is present before releasing data. The data holder
performs this check at Mitz. Mitz is the national online toestemmingsvoorziening, or OTV, where
patients record their consent.

The data holder performs the Mitz "gesloten vraag", which means closed question. It asks Mitz
whether consent exists for this specific requester, data holder and patient. The request to Mitz
contains the following fields:

| Mitz field | Value | Source |
|------------|-------|--------|
| `PatientBSN` | The BSN of the patient | The `NutsBSNCredential` in the access token |
| `ProviderInstitutionID` | The URA of the requesting organisation | The URA credential or the `X509Credential` |
| `ConsultingFacilityType` | The Zorgaanbiedertype of the requesting organisation | The Zorgaanbiedertype credential |
| `SubjectRole` | The role code of the healthcare professional | The `NutsEmployeeCredential` |
| `ProviderID` | The identifier of the healthcare professional | The `NutsEmployeeCredential` |
| `AuthorInstitutionID` | The URA of the data holder organisation | Configured at the data holder |
| `HealthcareFacilityType` | The Zorgaanbiedertype of the data holder organisation | Configured at the data holder |
| `EventCode` | `GGC002`. This is the fixed code for the gesloten vraag. | Fixed value |
| `PurposeOfUse` | `TREAT` | Fixed value |

The URA comes from the `X509Credential` when the requesting organisation presents one. Otherwise it
comes from the HINQ-issued URA credential. See [Healthcare Organisation](#healthcare-organisation).
The AGB credential is not used for the consent check.

#### Conformance

The data holder organisation:

- **MUST** reject a request to the FHIR endpoint when it comes from an IP address that is not on
  the requestor whitelist.
- **MUST** enforce the access rules described in [At the data request](#data-request).
- **MUST** check the presence of a valid explicit patient consent for the requested exchange before
  returning data.
- **MUST** perform this consent check at Mitz.
- **MUST** only return data of the patient the access token is bound to.

### Network Security

In production and acceptance environments, vendor organisations **MUST** use mutual TLS based on
PKIoverheid certificates. Mutual TLS means that both the server and the client authenticate. In test
environments, PKIoverheid certificates or public-trust certificates **MUST** be used.

The national specifications for network security, called "Veilig Netwerk", are not yet finalised.
The current concept version prescribes PKIoverheid certificates. These are already widely in use by
vendors.
