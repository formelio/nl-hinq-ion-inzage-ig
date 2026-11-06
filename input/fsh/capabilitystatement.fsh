// Requirements CapabilityStatement for the HINQ ION Inzage data holder (server).
// It is the machine-readable counterpart of transactions.md and dataset.md. Keep them in sync.
// This is the complete list of allowed search parameters: `patient` (or `identifier` on Patient)
// is required (SHALL); the parameters marked MAY are optional. Other parameters are not allowed.

RuleSet: Expectation(code)
* extension[0].url = "http://hl7.org/fhir/StructureDefinition/capabilitystatement-expectation"
* extension[0].valueCode = {code}

// A patient-scoped search on one resource type, with `patient` as the required parameter.
RuleSet: PatientScopedSearch(type)
* rest.resource[+].type = {type}
* rest.resource[=] insert Expectation(#SHALL)
* rest.resource[=].interaction[0].code = #search-type
* rest.resource[=].interaction[0] insert Expectation(#SHALL)
* rest.resource[=].searchParam[0].name = "patient"
* rest.resource[=].searchParam[0].definition = "http://hl7.org/fhir/SearchParameter/clinical-patient"
* rest.resource[=].searchParam[0].type = #reference
* rest.resource[=].searchParam[0].documentation = "Required. The logical id of the patient from the patient search."
* rest.resource[=].searchParam[0] insert Expectation(#SHALL)

Instance: HINQIONDataHolder
InstanceOf: CapabilityStatement
Usage: #definition
Title: "HINQ ION Inzage Data Holder CapabilityStatement"
Description: "Requirements for the HINQ ION Inzage data holder: a BSN-based Patient search to resolve the patient's logical id, followed by patient-scoped searches for the huisarts dataset."

* url = "https://formelio.github.io/nl-hinq-ion-inzage-ig/CapabilityStatement/HINQIONDataHolder"
* name = "HINQIONDataHolder"
* title = "HINQ ION Inzage Data Holder CapabilityStatement"
* status = #draft
* experimental = true
* date = "2026-11-06"
* publisher = "HINQ"
* kind = #requirements
* fhirVersion = #4.0.1
* format[0] = #json
* format[+] = #xml

* rest.mode = #server
* rest.documentation = "All requests are patient-scoped. The data holder enforces the access rules and the consent check of the Exchange Architecture page. Resources are converted from STU3 and need not conform to nl-core profiles. Clients must not rely on _profile or meta.profile. Only the search parameters and includes listed here are allowed, plus the paging parameters in next links that the server returns."
* rest.security.description = "Mutual TLS with PKIoverheid certificates. A DPoP-bound access token from the Nuts authorization server with scope ion_inzage. Every request carries a new DPoP proof."

// Patient: POST-based search on BSN per IHE PDQm ITI-78
* rest.resource[0].type = #Patient
* rest.resource[=] insert Expectation(#SHALL)
* rest.resource[=].documentation = """
POST-based search on BSN per IHE PDQm ITI-78. GET-based search is not allowed. The BSN must be the BSN the access token is bound to.

**Includes**

- `_include=Patient:general-practitioner`: also returns the huisarts and the huisartsenpraktijk.
"""
* rest.resource[=].interaction[0].code = #search-type
* rest.resource[=].interaction[0] insert Expectation(#SHALL)
* rest.resource[=].searchParam[0].name = "identifier"
* rest.resource[=].searchParam[0].definition = "http://hl7.org/fhir/SearchParameter/Patient-identifier"
* rest.resource[=].searchParam[0].type = #token
* rest.resource[=].searchParam[0].documentation = "Required. The BSN, with system http://fhir.nl/fhir/NamingSystem/bsn."
* rest.resource[=].searchParam[0] insert Expectation(#SHALL)
* rest.resource[=].searchInclude[0] = "Patient:general-practitioner"
* rest.resource[=].searchInclude[0] insert Expectation(#SHALL)

// Huisarts data. One patient-scoped search per resource type.
* insert PatientScopedSearch(#EpisodeOfCare)
* rest.resource[=].documentation = "Episodes."

* insert PatientScopedSearch(#Flag)
* rest.resource[=].documentation = "Attention flags."

* insert PatientScopedSearch(#MedicationRequest)
* rest.resource[=].documentation = """
Medication agreements, current and past.

**Includes**

- `_include=MedicationRequest:medication`: also returns the referenced Medication resources.
"""
* rest.resource[=].searchInclude[0] = "MedicationRequest:medication"
* rest.resource[=].searchInclude[0] insert Expectation(#SHALL)

* insert PatientScopedSearch(#AllergyIntolerance)
* rest.resource[=].documentation = "Medication allergies."

* insert PatientScopedSearch(#Observation)
* rest.resource[=].documentation = "Measurements, diagnostic and laboratory results, and the lines of SOEP reports."
* rest.resource[=].searchParam[+].name = "code"
* rest.resource[=].searchParam[=].definition = "http://hl7.org/fhir/SearchParameter/clinical-code"
* rest.resource[=].searchParam[=].type = #token
* rest.resource[=].searchParam[=] insert Expectation(#MAY)
* rest.resource[=].searchParam[+].name = "category"
* rest.resource[=].searchParam[=].definition = "http://hl7.org/fhir/SearchParameter/Observation-category"
* rest.resource[=].searchParam[=].type = #token
* rest.resource[=].searchParam[=] insert Expectation(#MAY)

* insert PatientScopedSearch(#Composition)
* rest.resource[=].documentation = "SOEP reports. Only the E and P lines are returned."

* insert PatientScopedSearch(#Encounter)
* rest.resource[=].documentation = "Contacts."
