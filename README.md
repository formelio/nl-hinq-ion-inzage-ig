# HINQ ION Inzage Implementation Guide

This repository contains the FHIR Implementation Guide for making **HINQ ION** data available to
requesting parties over Nuts. In this pilot stage it exposes **Medicom** data to the **Rivo-Noord**
region viewers.

- **Rendered guide:** <https://formelio.github.io/nl-hinq-ion-inzage-ig/>
- **Status:** version 0.2.0, draft. This is a **proposition**, not a commitment to build or go
  live. It is explicitly **not a 1.0**.

## Where to Start

| You are | Start with |
|---------|------------|
| A data user who wants to connect | [Integration](https://formelio.github.io/nl-hinq-ion-inzage-ig/integration.html) |
| A reviewer of the specification | [Exchange Architecture](https://formelio.github.io/nl-hinq-ion-inzage-ig/exchange.html) and [Credentials & Issuance](https://formelio.github.io/nl-hinq-ion-inzage-ig/credentials.html) |
| An operator of the data holder | [`policy/`](policy/README.md) and [`jsonld/`](jsonld/README.md) |
| A contributor to this guide | [Building the Guide](#building-the-guide) and [Contributing](#contributing) |

## Scope

The guide reuses building blocks from the
[Zorginzage 2026 template](https://nuts-foundation.github.io/nl-zorginzage-ig/). The relevant
content is **copied in**, so this specification does not change when Zorginzage changes. The
Zorginzage governance, release cycle and planning are **not** adopted. Every choice here is made for
this HINQ ION pilot.

The long-term ambition is for this guide to become a generic specification for exposing HINQ ION
data to any requesting party. It is harmonized with the other generic Nuts specifications,
Zorginzage and 360°-graden.

The key deviations from Zorginzage are:

- **Addressing is out of scope.** The data user knows the data holder's endpoints up front.
- **Only gericht bevragen.** There is a single known data holder.
- **HINQ-issued organization credentials.** HINQ issues the URA, AGB and Zorgaanbiedertype
  credentials. An `X509Credential` from a UZI server certificate is accepted as an alternative.
- **Patient-bound access tokens.** Each access token is bound to one patient through the
  self-attested `HinqBsnCredential`.

Each deviation is explained in
[Relationship to the Zorginzage Specification](https://formelio.github.io/nl-hinq-ion-inzage-ig/index.html#relationship-to-the-zorginzage-specification).

## Guide Pages

| Page | Content |
|------|---------|
| [Home](https://formelio.github.io/nl-hinq-ion-inzage-ig/index.html) | Purpose, scope, relationship to Zorginzage, roles, participating parties and organization of the guide |
| [Exchange Architecture](https://formelio.github.io/nl-hinq-ion-inzage-ig/exchange.html) | Exchange pattern, addressing, identification and authentication, access control, consent and network security |
| [Credentials & Issuance](https://formelio.github.io/nl-hinq-ion-inzage-ig/credentials.html) | Credential specifications, self-attested credentials, the JSON-LD context, issuance and lifecycle |
| [Transactions](https://formelio.github.io/nl-hinq-ion-inzage-ig/transactions.html) | Sequence diagram, and example requests and responses for the access token request, DPoP proof, token introspection, patient search, data request and errors |
| [Integration](https://formelio.github.io/nl-hinq-ion-inzage-ig/integration.html) | The steps a data user follows to connect: Nuts node configuration, credentials, mTLS and test requests |
| [Dataset](https://formelio.github.io/nl-hinq-ion-inzage-ig/dataset.html) | The huisarts data elements and the request for each |
| [History](https://formelio.github.io/nl-hinq-ion-inzage-ig/history.html) | Changelog |

## Repository Layout

```
sushi-config.yaml            Guide metadata, dependencies, pages and menu
input/
  pagecontent/               Page content in Markdown, one file per page
  fsh/                       FSH source: the CapabilityStatement and the example Patient
  images-source/             PlantUML source of the sequence diagram
  ignoreWarnings.txt         IG Publisher warnings that are accepted, with the reason for each
policy/
  production/ion_inzage.json Nuts policy for production
  acceptance/ion_inzage.json Nuts policy for acceptance
jsonld/
  hinq-credentials-v1.jsonld JSON-LD context for the HINQ credential types
Dockerfile, Makefile         Local render with SUSHI and the IG Publisher
_gen*, _update*, _build*     Standard IG Publisher scripts
```

## Technical Artifacts

**`policy/`.** The data holder's Nuts node loads the policy through its `policy.directory` setting.
The policy maps the `ion_inzage` scope to the presentation definition that every access token
request must meet. There is one directory per environment, because a Nuts node fails on a duplicate
scope. The two files differ only in the trusted UZI CAs. See [`policy/README.md`](policy/README.md).

**`jsonld/`.** The Nuts nodes of both the data user and the data holder load the JSON-LD context.
Without it, they cannot store, present or verify the HINQ credentials. See
[`jsonld/README.md`](jsonld/README.md).

## Building the Guide

### Validate FSH Locally

```bash
npx fsh-sushi build .
```

### Full Local Render

A full render requires Docker.

```bash
make builder   # build the ig-builder image, once or after Dockerfile changes
make ig        # render the guide, caching packages in ./build-cache
```

Open `./output/index.html` to view the result. The QA report is in `./output/qa.html`.

### Publishing

CI renders the guide with `.github/workflows/build_deploy.yml`. On every push to `main`, CI builds
the same Docker image, generates the guide into `./output` and deploys it to GitHub Pages. Pushing to
`main` therefore publishes the guide.

## Contributing

- **Pages.** Page content starts at `###` headings, because the IG Publisher renders the page title
  itself. Cross-page links use the generated `.html` names with anchors. Renaming a heading breaks
  the links to it.
- **Adding or removing a page.** Update `pages` and `menu` in `sushi-config.yaml`, the Organization
  of This Guide section in `input/pagecontent/index.md`, and the Guide Pages table in this README.
- **Deviations.** The deviation lists in `index.md` and this README must stay in sync.
- **Policy.** Make every change in both policy files, except the trusted UZI CAs.
- **Changelog.** Record significant changes in `input/pagecontent/history.md`. Bump `version` in
  `sushi-config.yaml` for a new release.
- **Style.** Pages use American English.
- **Quality.** SUSHI must build without errors, and the QA report must have no new errors or
  warnings. Accepted warnings go in `input/ignoreWarnings.txt` with the reason.

## Support

For support interpreting and implementing this specification, join the
[Nuts Foundation Slack](https://join.slack.com/t/nuts-foundation/shared_invite/zt-420yjjig5-FpyD6enK0egq2ZO5WJh6vQ).

## License

This guide is published under the [EUPL-1.2](LICENSE).
