// Write your prediction on the PREDICTION line above each snippet, then run
// the file and read the answers off the toolchain:
//
//     make probe CH=09 P=predict
//
// There is no answer key in this repository. The ones you get right cost you
// a minute. The ones you get wrong are each a place where the JSON you
// imagine and the JSON Foundation produces are different documents.

import Foundation

let encoder = JSONEncoder()
let decoder = JSONDecoder()

func line(_ number: Int, _ text: String) {
    print("\(number). \(text)")
}

// 1. A Date, encoded by a decoder you did not configure.
//
// PREDICTION:
struct Marker: Codable {
    var at: Date
}

let marker = Marker(at: Date(timeIntervalSince1970: 0))
line(1, String(decoding: try encoder.encode(marker), as: UTF8.self))

// 2. Two dictionaries, one keyed by Int and one keyed by an enum with String
//    raw values. Both are Codable. Are both objects?
//
// PREDICTION:
enum Gate: String, Codable {
    case north
    case south
}

let byNumber: [Int: String] = [1: "north"]
let byGate: [Gate: String] = [.north: "open"]
line(2, String(decoding: try encoder.encode(byNumber), as: UTF8.self)
        + " " + String(decoding: try encoder.encode(byGate), as: UTF8.self))

// 3. An optional property holding nil, encoded by the synthesized
//    encode(to:), and the same property written by hand.
//
// PREDICTION:
struct Slot: Encodable {
    var index: Int
    var label: String?
}

struct LoudSlot: Encodable {
    var index: Int
    var label: String?

    enum CodingKeys: String, CodingKey {
        case index
        case label
    }

    func encode(to encoder: any Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(index, forKey: .index)
        try container.encode(label, forKey: .label)
    }
}

line(3, String(decoding: try encoder.encode(Slot(index: 1, label: nil)), as: UTF8.self)
        + " " + String(decoding: try encoder.encode(LoudSlot(index: 1, label: nil)), as: UTF8.self))

// 4. Three JSON numbers arriving where the Swift property is an Int. Which
//    of them decode, and what kind of error is the one that does not?
//
// PREDICTION:
struct Count: Decodable {
    var n: Int
}

for text in ["261", "261.0", "261.5"] {
    let json = Data(#"{"n": \#(text)}"#.utf8)
    do {
        line(4, "\(text) decoded as \(try decoder.decode(Count.self, from: json).n)")
    } catch {
        line(4, "\(text) failed with \(error)")
    }
}

// 5. One key, twice, in the same object. JSON says nothing useful about
//    this and every parser picks a side.
//
// PREDICTION:
struct Tags: Decodable {
    var tags: [String]
}

let repeated = Data(#"{"tags": ["a"], "tags": ["b", "c"]}"#.utf8)
line(5, "\(try decoder.decode(Tags.self, from: repeated).tags)")

// 6. A top level scalar, with no object around it, and a Set built from an
//    array that repeats itself.
//
// PREDICTION:
line(6, "\(try decoder.decode(Int.self, from: Data("7".utf8)))"
        + " " + "\(try decoder.decode(Set<Int>.self, from: Data("[1,2,2,3]".utf8)).count)")
