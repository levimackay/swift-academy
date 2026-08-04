// Five hostile documents against one honest type, so that you have read a
// real DecodingError before you are asked to handle one:
//
//     make probe CH=09 P=failures
//
// Nothing here is caught by kind. The point is what the value already tells
// you when you simply print it, and how much of that survives the trip
// through localizedDescription, which is the string most people log.

import Foundation

struct Passenger: Decodable {
    var name: String
    var seat: Int
}

struct Manifest: Decodable {
    var flight: String
    var passengers: [Passenger]
}

let documents: [(label: String, json: String)] = [
    ("a key the document never had",
     #"{"flight":"BA22","passengers":[{"seat":14}]}"#),
    ("a string where a number belongs",
     #"{"flight":"BA22","passengers":[{"name":"Ada","seat":14},{"name":"Levi","seat":"aisle"}]}"#),
    ("an explicit null where a value is required",
     #"{"flight":"BA22","passengers":[{"name":"Ada","seat":null}]}"#),
    ("an array where an object belongs",
     #"{"flight":"BA22","passengers":{"name":"Ada","seat":14}}"#),
    ("bytes that are not JSON at all",
     "flight BA22, one passenger"),
]

for document in documents {
    print("----", document.label)
    do {
        let manifest = try JSONDecoder().decode(Manifest.self, from: Data(document.json.utf8))
        print("decoded \(manifest.passengers.count) passengers on \(manifest.flight)")
    } catch {
        print("printed:      \(error)")
        print("localized:    \(error.localizedDescription)")
    }
}

// The last line is the one to remember. Every failure above is a different
// document defect, and every localizedDescription is close to the same
// sentence. Log the error, not its localizedDescription.
