### Inleiding

Deze implementatiegids bevat de afspraken en specificaties om gegevens uit de **HINQ ION**
beschikbaar te stellen aan bevragende partijen. Het doel is het technisch definiëren van deze
generieke ontsluiting voor een pilot op kleine schaal.

In deze pilotfase betreft het **Medicom-gegevens** die beschikbaar worden gesteld aan de
**Rivo-Noord**-viewers van een beperkte set organisaties. Met deze use case kan een zorgverlener met
een behandelrelatie de voor hem of haar relevante gegevens die via de HINQ ION beschikbaar zijn,
gericht raadplegen en tonen. De inhoudelijke definitie en de dataset staan in [Dataset](dataset.html).

De ambitie is dat deze gids op termijn als generieke specificatie dient voor het ontsluiten van
HINQ ION-gegevens aan bevragende partijen, in lijn met de overige generieke Nuts-specificaties
(Zorginzage en 360°-graden).

### Relatie tot de Zorginzage-specificatie

Deze implementatiegids hergebruikt bouwstenen uit de [Zorginzage 2026-specificatie](https://nuts-foundation.github.io/nl-zorginzage-ig/)
en neemt de relevante inhoud integraal over, zodat deze gids zelfstandig leesbaar is en niet
meewijzigt wanneer de Zorginzage-specificatie wordt aangepast. Alleen de technische bouwstenen
worden overgenomen; de governance, het releasebeleid en de planning van Zorginzage vallen buiten
scope. Waar deze pilot afwijkt van Zorginzage — met name op adressering en
organisatie-authenticatie — wordt dat expliciet benoemd. Zie [Home](index.html) voor de
uitgangspunten.

### Rollen

In deze use case worden twee rollen onderscheiden:

- **Datahouder (data holder)** — vastleggen / beschikbaarstellen. De HINQ ION stelt, na
  authenticatie en autorisatie, de gegevens van het bronsysteem (Medicom) beschikbaar aan een
  datagebruiker.
- **Datagebruiker (data user)** — raadplegen / tonen. De organisatie die de gegevens bij de HINQ ION
  opvraagt en aan de zorgverlener toont — in deze pilot een Rivo-Noord-viewer.

In deze pilot geldt geen verplichte wederkerigheid: een deelnemer hoeft niet beide rollen te
implementeren. Welke partij welke rol(len) vervult in deze pilotpropositie staat hieronder.

### Deelnemende partijen en hun rollen (pilot)

| Partij | Vastleggen / beschikbaarstellen (datahouder) | Raadplegen / tonen (datagebruiker) |
|--------|:--:|:--:|
| HINQ ION (Medicom-brongegevens) | ✓ |   |
| Rivo-Noord-viewer(s)            |   | ✓ |

### Rollen en uitvoerders

| Rol | Uitvoerder |
|-----|------------|
| Eigenaar van deze specificatie | HINQ |
| Vertrouwde uitgever (credentials) | HINQ (zie [Exchange Architecture](exchange.html#authentication-organisation-identity)) |
| Deelnemer (datagebruiker)      | Rivo-Noord-viewer, opgenomen op de whitelist bij de bron |

### Functionele flows

Op hoofdlijnen verloopt de gerichte raadpleging als volgt (de technische uitwerking staat in
[Exchange Architecture](exchange.html) en [Transactions](transactions.html)):

1. Een zorgverlener opent de datagebruiker-applicatie (de Rivo-Noord-viewer) en start een
   raadpleging voor een specifieke patiënt.
2. De datagebruiker kent de endpoints van de datahouder (HINQ ION) al: adressering is buiten scope
   en de endpoints zijn vooraf vastgelegd (hardcoded). Er is dus geen discovery-stap.
3. De datagebruiker authenticeert zich (organisatie en persoon) en doet een patiëntzoekvraag op
   BSN bij de datahouder.
4. De datahouder controleert dat de bevrager op de whitelist staat, autoriseert de vraag,
   controleert de vereiste toestemming en levert de gegevens.
5. De datagebruiker toont de gegevens aan de zorgverlener.

Nog uit te werken voor de pilot:

- welke Medicom-gegevens (profielen) beschikbaar zijn (zie [Dataset](dataset.html)).
