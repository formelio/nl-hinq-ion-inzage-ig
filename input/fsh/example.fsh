// Example Patient for the HINQ ION Inzage IG
Instance: PatientExample
InstanceOf: http://nictiz.nl/fhir/StructureDefinition/nl-core-Patient
Usage: #example
Title: "Patient Example - Maria van den Berg"
Description: "Illustrative example of a patient with a BSN identifier, as found by the BSN-based Patient search. Patients returned by the data holder are converted from STU3 and do not necessarily conform to nl-core-Patient or contain all elements of this example."

* identifier[bsn].use = #official
* identifier[bsn].system = "http://fhir.nl/fhir/NamingSystem/bsn"
* identifier[bsn].value = "123456782"

* name.use = #official
* name.text = "Maria Anna van den Berg"
* name.family = "van den Berg"
// nl-core-NameInformation requires each given part to carry the iso21090-EN-qualifier
// extension (BR = given name, IN = initial).
* name.given[0] = "Maria"
* name.given[0].extension[0].url = "http://hl7.org/fhir/StructureDefinition/iso21090-EN-qualifier"
* name.given[0].extension[0].valueCode = #BR
* name.given[1] = "Anna"
* name.given[1].extension[0].url = "http://hl7.org/fhir/StructureDefinition/iso21090-EN-qualifier"
* name.given[1].extension[0].valueCode = #BR

* gender = #female
* birthDate = "1985-03-15"

* address.use = #home
* address.line = "Hoofdstraat 123"
* address.city = "Amsterdam"
* address.postalCode = "1011 AB"
* address.country = "NL"

* telecom[0].system = #phone
* telecom[0].value = "+31612345678"
* telecom[0].use = #mobile

* telecom[1].system = #email
* telecom[1].value = "maria.vandenberg@example.nl"
* telecom[1].use = #home

* active = true
