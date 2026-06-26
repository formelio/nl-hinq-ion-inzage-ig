// Minimal CapabilityStatement for the HINQ ION Inzage data holder (server).
// The authorisation policy requires conformance to a CapabilityStatement to be evaluated for
// FHIR endpoint requests (see the Exchange Architecture volume).
Instance: HINQIONDataHolder
InstanceOf: CapabilityStatement
Usage: #definition
Title: "HINQ ION Inzage Data Holder CapabilityStatement"
Description: "Capabilities a data holder exposes in the HINQ ION Inzage pull flow: BSN-based Patient search to resolve the patient's technical identifier, followed by patient-scoped data requests."

* url = "https://formelio.github.io/nl-hinq-ion-inzage-ig/CapabilityStatement/HINQIONDataHolder"
* name = "HINQIONDataHolder"
* title = "HINQ ION Inzage Data Holder CapabilityStatement"
* status = #draft
* experimental = true
* date = "2026-06-25"
* publisher = "HINQ"
* kind = #requirements
* fhirVersion = #4.0.1
* format[0] = #json
* format[+] = #xml

* rest.mode = #server
* rest.documentation = "All interactions are patient-scoped and protected by Nuts-based authentication, policy-based authorisation and an explicit consent check."

// Patient: BSN-based POST search to obtain the technical identifier
* rest.resource[0].type = #Patient
* rest.resource[=].documentation = "POST-based search on BSN (identifier.system = http://fhir.nl/fhir/NamingSystem/bsn) per IHE PDQm ITI-78. GET-based search is not allowed."
* rest.resource[=].interaction[0].code = #search-type
* rest.resource[=].searchParam[0].name = "identifier"
* rest.resource[=].searchParam[=].type = #token
