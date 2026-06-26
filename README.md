# nl-hinq-ion-inzage-ig — HINQ ION Inzage Implementation Guide

Self-contained FHIR Implementation Guide for making **HINQ ION** data available to requesting parties
in a generic way. In this pilot stage it exposes **Medicom** data to a select set of organisations —
the **Rivo-Noord** region viewers.

The guide selectively **reuses building blocks** from the
[Zorginzage 2026 template](https://nuts-foundation.github.io/nl-zorginzage-ig/), but the relevant
content is **copied in** so this specification does not change when Zorginzage changes. It does
**not** adopt the Zorginzage governance, release cycle or planning — every choice here is made on
account of this HINQ ION pilot.

This is a **proposition**, not a commitment to build or go live. It is explicitly **not a 1.0**.

The long-term ambition is for this guide to become a generic specification for exposing HINQ ION data
to any requesting party, harmonised with the other generic Nuts specifications (Zorginzage and
360°-graden).

Rendered guide: <https://formelio.github.io/nl-hinq-ion-inzage-ig/>

## Key pilot deviations from Zorginzage / PZP

- **Addressing is out of scope** — no discovery service; the data holder's endpoints
  (`authorization_server`, FHIR base URL, `scope`) are hardcoded by the data user. End-state:
  Generieke Functie Adressering.
- **Only gericht bevragen** — single known data holder, so no localisation / indexed querying.
- **Organisation authentication via HINQ-issued credentials** — URA, AGB and Zorgaanbiedertype,
  issued by HINQ instead of an X509/UZI server certificate.
- **Requestors are whitelisted** at the source.

## Structure

| Page | Content |
|------|---------|
| Home | Purpose, scope, proposition disclaimer, participants, versioning rule |
| Use Case & Roles | Use case, role split, participating parties, functional flows |
| Exchange Architecture | Exchange pattern, identification, authentication (incl. HINQ-issued credentials), addressing, authorisation, consent, network security |
| Professional Authentication | Detailed Nuts EmployeeID mechanism |
| Transactions | Pull retrieval, patient context |
| Dataset | Medicom dataset reuse, open questions |
| History | Changelog |

## Build & deploy

The guide is rendered in CI (`.github/workflows/build_deploy.yml`): on every push to `main` a
Docker image containing SUSHI and the HL7 IG Publisher is built, the IG is generated into
`./output`, and the result is deployed to GitHub Pages.

### Validate FSH locally

```bash
npx fsh-sushi sushi .
```

### Full local render (requires Docker)

```bash
docker build . -t ig-builder
docker run --rm --name=ig-builder \
  -v ./input:/app/input \
  -v ./output:/app/output \
  -v ./ig.ini:/app/ig.ini \
  -v ./sushi-config.yaml:/app/sushi-config.yaml \
  ig-builder
# open ./output/index.html
```
