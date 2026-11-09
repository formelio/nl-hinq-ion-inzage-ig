This page describes the data that a data user can retrieve, and the request for each data element.
How the requests are authorized is described in [Exchange Architecture](exchange.html). Example
requests and responses are in [Transactions](transactions.html). The
[CapabilityStatement](CapabilityStatement-HINQIONDataHolder.html) lists all allowed requests in a
machine-readable form.

### Overview

In this pilot stage, the data made available through HINQ ION originates from the **Medicom**
source system. Medicom is a huisartsinformatiesysteem, so the dataset consists of huisarts data.

Medicom provides the data as FHIR STU3 resources, following the MedMij information standard
[Huisartsgegevens 2.0](https://informatiestandaarden.nictiz.nl/wiki/MedMij:V2020.01/FHIR_GP_Data).
Its profiles are in the [`nictiz.fhir.nl.stu3.zib2017`](https://simplifier.net/packages/nictiz.fhir.nl.stu3.zib2017)
package. There is no R4 version of this information standard yet.

The HINQ ION service converts the STU3 resources to FHIR R4 and returns them to the data user. The
R4 resources contain the data of the STU3 resources. They do not necessarily conform to the R4
nl-core profiles.

### Data Elements

| Data element | Zib | R4 resource | STU3 source profile |
|--------------|-----|-------------|---------------------|
| Patient | Patient | `Patient` | `nl-core-patient` |
| Huisarts | Zorgverlener | `Practitioner` | `nl-core-practitioner` |
| Huisartsenpraktijk | Zorgaanbieder | `Organization` | `nl-core-organization` |
| Episodes | ZorgEpisode | `EpisodeOfCare` | `nl-core-episodeofcare` |
| Attention flags | Alert | `Flag` | `zib-Alert` |
| Medication agreements | MedicatieAfspraak | `MedicationRequest` | `zib-MedicationAgreement` |
| Medication allergies | AllergieIntolerantie | `AllergyIntolerance` | `zib-AllergyIntolerance` |
| Measurements | Bloeddruk, Lichaamsgewicht, Lichaamslengte, Lichaamstemperatuur, Hartfrequentie, Polsfrequentie, O2Saturatie | `Observation` | `zib-BloodPressure`, `zib-BodyWeight`, `zib-BodyHeight`, `zib-BodyTemperature`, `zib-HeartRate`, `zib-PulseRate`, `zib-O2Saturation` |
| Diagnostic and laboratory results | LaboratoriumUitslag | `Observation` | `gp-DiagnosticResult`, `gp-LaboratoryResult` |
| SOEP reports | No zib | `Composition`, `Observation` | `gp-EncounterReport`, `gp-JournalEntry` |
| Contacts | Contact | `Encounter` | `gp-Encounter` |

The `nl-core-*` source profiles start with `http://fhir.nl/fhir/StructureDefinition/`. The other
source profiles start with `http://nictiz.nl/fhir/StructureDefinition/`.

### Requests

Every request below follows the rules of [Transactions](transactions.html). `{id}` is the
patient's logical id from the patient search.

The requests are generic. They select data by resource type and patient. Because the R4 resources
are converted, a data user **MUST NOT** rely on `_profile` or `meta.profile` to select or recognize
data. A data user **MAY** add the optional search parameters listed in the
[CapabilityStatement](CapabilityStatement-HINQIONDataHolder.html). Other search parameters are not
allowed.

| Data element | Request |
|--------------|---------|
| Patient | `POST {fhir_base}/Patient/_search` with `identifier=http://fhir.nl/fhir/NamingSystem/bsn\|{bsn}` |
| Huisarts and huisartsenpraktijk | Add `_include=Patient:general-practitioner` to the patient search |
| Episodes | `GET {fhir_base}/EpisodeOfCare?patient={id}` |
| Attention flags | `GET {fhir_base}/Flag?patient={id}` |
| Medication agreements | `GET {fhir_base}/MedicationRequest?patient={id}&_include=MedicationRequest:medication` |
| Medication allergies | `GET {fhir_base}/AllergyIntolerance?patient={id}` |
| Measurements and results | `GET {fhir_base}/Observation?patient={id}` |
| SOEP reports | `GET {fhir_base}/Composition?patient={id}` |
| Contacts | `GET {fhir_base}/Encounter?patient={id}` |

#### Patient

The patient search returns the patient. With `_include=Patient:general-practitioner`, it also
returns the huisarts and the huisartsenpraktijk that `Patient.generalPractitioner` references:

```http
POST {fhir_base}/Patient/_search HTTP/1.1
Content-Type: application/x-www-form-urlencoded

identifier=http://fhir.nl/fhir/NamingSystem/bsn|{bsn}&_include=Patient:general-practitioner
```

#### Medication Agreements

The response contains all medication agreements of the patient, current and past. Selecting the
current medication is up to the data user, for example by the period of use. With
`_include=MedicationRequest:medication`, the response also contains the `Medication` resources that
the agreements reference.

#### Measurements and Results

The measurements and the diagnostic and laboratory results are all `Observation` resources. A data
user can tell them apart by `Observation.code`. It **MAY** narrow the request with the `code` or
`category` search parameters.

#### SOEP Reports

A SOEP report is a `Composition`. Its lines are `Observation` resources that the `Composition`
references.

A SOEP report has four lines: S for Subjectief, O for Objectief, E for Evaluatie and P for Plan.
The E line holds the conclusion of the consult. The P line holds the agreed actions and any next
steps.

The data holder **MUST** only return the E and P lines. It **MUST NOT** return the S and O lines.
This follows the MedMij information standard Huisartsgegevens 2.0.
