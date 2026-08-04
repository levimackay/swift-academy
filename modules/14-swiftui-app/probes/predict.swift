// Navigation state is data, so every question about it is answerable on the
// command line with no simulator and no Xcode. That is the argument for value
// based routing compressed into one file.
//
// Write your answer on the PREDICT line above each block, then run it:
//
//     make probe CH=14 P=predict
//
// Nothing here is graded and no answer key exists in this repository. The
// toolchain is the answer key.
//
// SwiftUI is deliberately not imported. `NavigationPath` is a type erased
// `[AnyHashable]` with a `Codable` escape hatch, and `Trail` below is that
// idea with the interesting parts left in, so the file runs under the plain
// interpreter rather than needing a linked SwiftUI.

import Foundation

enum Hop: Hashable, Codable {
    case list
    case detail(id: Int)
    case tagged(String)
}

struct Trail {
    private var legs: [AnyHashable] = []
    var count: Int { legs.count }
    mutating func append(_ leg: some Hashable) { legs.append(AnyHashable(leg)) }
    mutating func removeLast() { legs.removeLast() }
}

let encoder = JSONEncoder()
let decoder = JSONDecoder()

print("--- 1. a path is a stack, not a set")

var trail = Trail()
trail.append(Hop.list)
trail.append(Hop.detail(id: 7))
trail.append(Hop.list)

// PREDICT: trail.count is
print("count:", trail.count)

trail.removeLast()
// PREDICT: after one pop, count is
print("after one pop:", trail.count)

print("\n--- 2. what a route looks like written down")

let saved = try encoder.encode([Hop.detail(id: 7), Hop.tagged("field")])

// PREDICT: the JSON, and whether encoding it twice gives the same bytes
print("json:", String(decoding: saved, as: UTF8.self))
print("stable:", saved == (try encoder.encode([Hop.detail(id: 7), Hop.tagged("field")])))

print("\n--- 3. yesterday's saved path, today's build")

// Last week's build wrote a case this build no longer has.
let lastWeek = Data(#"[{"archived":{"_0":3}}]"#.utf8)

// PREDICT: does this print restored, or the error branch
do {
    let restored = try decoder.decode([Hop].self, from: lastWeek)
    print("restored:", restored)
} catch {
    print("could not read the saved path")
}

print("\n--- 4. type erasure keeps the type")

let boxedLeg = AnyHashable(Hop.detail(id: 7))
let boxedInt = AnyHashable(7)

// PREDICT: the two answers
print(boxedLeg == boxedInt, Set([boxedLeg, boxedInt, AnyHashable(7)]).count)

print("\n--- 5. a route is a value, so equality is structural")

let a = Hop.tagged("field")
let b = Hop.tagged("field")
let c = Hop.tagged("Field")

// PREDICT: the three answers
print(a == b, a == c, Set([a, b, c]).count)
