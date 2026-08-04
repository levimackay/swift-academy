// The chapter's table of five calls against three documents, run rather
// than asserted:
//
//     make probe CH=09 P=threeway
//
// One key, named n, and three documents: the key absent, the key holding
// null, and the key holding a number. Every call below is made against the
// same keyed container, in that order, so the table in the chapter is this
// output transposed.

import Foundation

struct Interrogation: Decodable {
    enum CodingKeys: String, CodingKey {
        case n
    }

    init(from decoder: any Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)

        print("  contains(.n)                  ", container.contains(.n))

        do {
            print("  decodeNil(forKey: .n)         ", try container.decodeNil(forKey: .n))
        } catch {
            print("  decodeNil(forKey: .n)          threw \(kind(of: error))")
        }

        do {
            let value = try container.decode(Int?.self, forKey: .n)
            print("  decode(Int?.self, forKey: .n) ", String(describing: value))
        } catch {
            print("  decode(Int?.self, forKey: .n)  threw \(kind(of: error))")
        }

        do {
            let value = try container.decodeIfPresent(Int.self, forKey: .n)
            print("  decodeIfPresent(Int.self)     ", String(describing: value))
        } catch {
            print("  decodeIfPresent(Int.self)      threw \(kind(of: error))")
        }

        do {
            print("  decode(Int.self, forKey: .n)  ", try container.decode(Int.self, forKey: .n))
        } catch {
            print("  decode(Int.self, forKey: .n)   threw \(kind(of: error))")
        }
    }
}

/// The case name only, because the payload is the chapter's other lesson and
/// this file is about which of the five calls survive.
func kind(of error: any Error) -> String {
    switch error {
    case DecodingError.keyNotFound: return "keyNotFound"
    case DecodingError.valueNotFound: return "valueNotFound"
    case DecodingError.typeMismatch: return "typeMismatch"
    case DecodingError.dataCorrupted: return "dataCorrupted"
    default: return "\(error)"
    }
}

for document in ["{}", #"{"n": null}"#, #"{"n": 5}"#] {
    print("document \(document)")
    _ = try JSONDecoder().decode(Interrogation.self, from: Data(document.utf8))
}
