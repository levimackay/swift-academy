// This file compiles as written. Every commented block below is a real
// mistake with the diagnostic it produced on the toolchain in the chapter
// front matter, pasted verbatim. Uncomment one block at a time and check the
// wording yourself:
//
//     make probe CH=09 P=errors
//
// The chapter's "Where it goes wrong" table is built from this file. If a
// future toolchain changes the wording, fix it here first.
//
// Each block quotes the error line and the note under it, because for
// Codable the error line is nearly always the same sentence and the note is
// the entire diagnosis.

import Foundation

struct Show: Codable, Equatable {
    var title: String
    var episodeCount: Int
}

// 1. Synthesis is recursive, so one part that cannot decode stops the whole
//    type. The note names the part, and the error names the type.
//
// struct Runtime { var seconds: Int }
// struct Promo: Codable {
//     var title: String
//     var length: Runtime
// }
//
// error: type 'Promo' does not conform to protocol 'Decodable'
// note: cannot automatically synthesize 'Decodable' because 'Runtime' does
// not conform to 'Decodable'

// 2. Declaring CodingKeys replaces the synthesized key set rather than
//    adding to it, so a property left out of it has nowhere to come from.
//
// struct Listing: Codable {
//     var title: String
//     var episodeCount: Int
//     enum CodingKeys: String, CodingKey {
//         case title
//     }
// }
//
// error: type 'Listing' does not conform to protocol 'Decodable'
// note: cannot automatically synthesize 'Decodable' because 'episodeCount'
// does not have a matching CodingKey and does not have a default value

// 3. The name CodingKeys is not magic on its own. The conformance is.
//
// struct Archive: Codable {
//     var title: String
//     enum CodingKeys: String {
//         case title
//     }
// }
//
// error: type 'Archive' does not conform to protocol 'Decodable'
// note: cannot automatically synthesize 'Decodable' because 'CodingKeys'
// does not conform to CodingKey

// 4. A let with an initial value is already decided, so the decoder is not
//    allowed to overwrite it. This one compiles, which is why it costs a
//    morning.
//
// struct Bookmark: Codable {
//     let id: Int = 0
//     var position: Double
// }
//
// warning: immutable property will not be decoded because it is declared
// with an initial value which cannot be overwritten
// note: set the initial value via the initializer or explicitly define a
// CodingKeys enum including a 'id' case to silence this warning
// note: make the property mutable instead

// 5. Decoding needs to know which init(from:) to call, and a protocol has no
//    single one. This is the wall in front of a heterogeneous array.
//
// protocol Item: Codable { var id: String { get } }
// struct Clip: Item { var id: String }
// let payload = Data("{}".utf8)
// let item = try JSONDecoder().decode((any Item).self, from: payload)
//
// error: type 'any Item' cannot conform to 'Decodable'
// [#ProtocolTypeNonConformance]
// note: only concrete types such as structs, enums and classes can conform
// to protocols

// 6. CodingKeys is synthesized as part of a synthesized conformance. Write
//    init(from:) yourself and nothing is synthesized, including the keys.
//
// struct Trailer: Decodable {
//     var title: String
//     init(from decoder: any Decoder) throws {
//         let container = try decoder.container(keyedBy: CodingKeys.self)
//         title = try container.decode(String.self, forKey: .title)
//     }
// }
//
// error: cannot find 'CodingKeys' in scope
// error: generic parameter 'Key' could not be inferred

// 7. decodeIfPresent answers a question with two answers, so its result is
//    an Optional whatever the property is.
//
// struct Rating: Decodable {
//     var stars: Int
//     enum CodingKeys: String, CodingKey { case stars }
//     init(from decoder: any Decoder) throws {
//         let container = try decoder.container(keyedBy: CodingKeys.self)
//         stars = try container.decodeIfPresent(Int.self, forKey: .stars)
//     }
// }
//
// error: value of optional type 'Int?' must be unwrapped to a value of type
// 'Int'
// note: coalesce using '??' to provide a default when the optional value
// contains 'nil'

// 8. A single value container holds one scalar and has no keys to ask for.
//
// struct Slug: Decodable {
//     var text: String
//     enum CodingKeys: String, CodingKey { case text }
//     init(from decoder: any Decoder) throws {
//         let container = try decoder.singleValueContainer()
//         text = try container.decode(String.self, forKey: .text)
//     }
// }
//
// error: extra argument 'forKey' in call

let show = Show(title: "Signals", episodeCount: 12)
let encoded = try JSONEncoder().encode(show)
let round = try JSONDecoder().decode(Show.self, from: encoded)
print("errors.swift compiles when every block above stays commented out")
print("round trip preserved the value:", round == show)
