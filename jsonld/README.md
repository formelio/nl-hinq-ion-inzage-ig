# JSON-LD Context for HINQ Credentials

`hinq-credentials-v1.jsonld` is the JSON-LD context that defines the HINQ credential types and
their fields. HINQ will publish it at its context URL. Until then,
`https://example.hinq.nl/credentials/v1` is a **placeholder** URL. The same placeholder is used as
the `hinq:` term namespace inside the file, so replace both when the URL is known.

| Type | Fields |
|------|--------|
| `HinqUraCredential` | `credentialSubject.organization.ura` |
| `HinqAgbCredential` | `credentialSubject.organization.agb` |
| `HinqHealthcareProviderRoleTypeCredential` | `credentialSubject.roleCodeNL` |
| `HinqBsnCredential` | `credentialSubject.bsn` |

The file follows the structure of the Nuts `NutsUraCredential` context. `organization` maps to
`schema:organization`, as in the Nuts contexts. The other fields map to the `hinq:` namespace.
Every term is protected, so a later context in a credential cannot redefine it. A field that the
context does not define is dropped during JSON-LD processing and is not covered by the signature.

Changing the context of an issued credential changes its canonical form and breaks its signature.
Publish a changed context under a new URL, such as `.../v2`, and keep the old one available.

## Who Uses It

- HINQ uses it to issue the `HinqUraCredential`, `HinqAgbCredential` and
  `HinqHealthcareProviderRoleTypeCredential`.
- The data user's Nuts node uses it to store and present the credentials, and to self-attest the
  `HinqBsnCredential`.
- The data holder's Nuts node uses it to verify the credentials at the token request.

Each node loads it through `jsonld.contexts.localmapping` or `jsonld.contexts.remoteallowlist`. See
[JSON-LD Context](https://formelio.github.io/nl-hinq-ion-inzage-ig/credentials.html#json-ld-context)
in the Implementation Guide.
