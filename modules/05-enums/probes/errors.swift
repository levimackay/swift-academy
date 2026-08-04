// This file compiles as written. Every commented block below is a real
// mistake with the diagnostic it produced on the toolchain named in the
// chapter front matter, pasted verbatim. Uncomment one block at a time and
// check the wording yourself:
//
//     make probe CH=05 P=errors
//
// The chapter's "Where it goes wrong" table is built from this file. The
// file stays green on purpose: a probe that compiles today and stops
// compiling after a toolchain upgrade tells you the wording drifted, and a
// probe that never compiled cannot tell you anything.
//
// Uncomment exactly one block. Two blocks at once gives you two failures
// interleaved, and the first one usually explains the second.
//
// When a diagnostic in here costs you more than ten minutes anywhere else,
// paste it verbatim into NOTES/errors.md with what you thought it meant.

// 1. A switch over an enum you own covers every case or it does not compile,
//    and the note writes the missing case out for you, bindings included.
//
// enum Aperture {
//     case closed
//     case slot(width: Double)
//     case iris(radius: Double, blades: Int)
// }
// func opening(_ a: Aperture) -> Double {
//     switch a {
//     case .closed: return 0
//     case .slot(let width): return width
//     }
// }
//
// error: switch must be exhaustive
// note: add missing case: '.iris(radius: let radius, blades: let blades)'

// 2. A `where` clause narrows a case, so the compiler stops believing that
//    case is covered at all. Both cases come back as missing.
//
// enum Alarm {
//     case low(Int)
//     case high(Int)
// }
// func siren(_ a: Alarm) -> String {
//     switch a {
//     case .low(let n) where n > 0: return "low"
//     case .high(let n) where n > 0: return "high"
//     }
// }
//
// error: switch must be exhaustive
// note: add missing case: '.low(_)'
// note: add missing case: '.high(_)'
// note: add missing cases

// 3. An associated value is not a stored property. The payload label names
//    an argument, not a member, and there is nothing to dot into.
//
// enum Hatch {
//     case sealed
//     case ajar(gap: Double)
// }
// let hatch = Hatch.ajar(gap: 1.5)
// print(hatch.gap)
//
// error: value of type 'Hatch' has no member 'gap'

// 4. A case with a payload is a function from the payload to the enum, so
//    naming it without calling it is naming a function.
//
// enum Slot {
//     case blank
//     case filled(String)
// }
// let slot: Slot = .filled
//
// error: member 'filled' expects argument of type 'String'

// 5. A bare name inside a pattern is matched against, not bound. Binding
//    takes `let`, and forgetting it looks like a scope error.
//
// enum Glyph {
//     case mark(String)
//     case count(Int)
// }
// let glyph = Glyph.mark("*")
// switch glyph {
// case .mark(symbol): print(symbol)
// case .count(let n): print(n)
// }
//
// error: cannot find 'symbol' in scope

// 6. Raw values and associated values are exclusive. A raw value is one
//    constant chosen per case at compile time; a payload is per instance.
//
// enum Verb: String {
//     case go = "GO"
//     case send(payload: String)
// }
//
// error: enum with raw type cannot have cases with arguments
// note: declared raw type 'String' here
//
// The second error is the first one's fallout, and it names a protocol you
// never wrote:
//
// error: 'Verb' declares raw type 'String', but does not conform to
// RawRepresentable and conformance could not be synthesized

// 7. Two cases cannot share a raw value, because `init?(rawValue:)` would
//    have two answers and no way to choose.
//
// enum Tally: Int {
//     case one = 1
//     case uno = 1
// }
//
// error: raw value for enum case is not unique
// note: raw value previously used here

// 8. A case that holds the enum itself makes the size of the enum depend on
//    itself. `indirect` boxes the payload and breaks the cycle.
//
// enum Segment {
//     case stop
//     case link(Segment, Segment)
// }
//
// error: recursive enum 'Segment' is not marked 'indirect'
// note: cycle beginning here: (Segment, Segment) -> (.0: Segment)

// 9. Equality is synthesized for a payload free enum and not for one with
//    associated values, because the compiler will not assume the payloads
//    are comparable.
//
// enum Gauge {
//     case dry
//     case depth(Double)
// }
// let left = Gauge.depth(1)
// let right = Gauge.depth(1)
// print(left == right)
//
// error: binary operator '==' cannot be applied to two 'Gauge' operands
// note: binary operator '==' cannot be synthesized for enums with associated values

// 10. CaseIterable can only list cases it can construct with no arguments,
//     so a payload case kills the synthesis for the whole type.
//
// enum Beacon: CaseIterable {
//     case ping
//     case burst(Int)
// }
//
// error: type 'Beacon' does not conform to protocol 'CaseIterable'
// note: add stubs for conformance
// note: protocol requires property 'allCases' with type '[Beacon]'

// 11. A binding pulled out of a pattern is a copy, and a `let` copy. Writing
//     through it does not write back into the value you matched.
//
// enum Meter {
//     case ticks(Int)
// }
// let meter = Meter.ticks(1)
// switch meter {
// case .ticks(let n):
//     n += 1
//     print(n)
// }
//
// error: left side of mutating operator isn't mutable: 'n' is immutable

// 12. `guard case` is still a `guard`, so it still owes an `else` that
//     leaves the scope.
//
// enum Vault {
//     case empty
//     case full(Int)
// }
// func unpack(_ v: Vault) -> Int {
//     guard case .full(let n) = v
//     return n
// }
//
// error: expected 'else' after 'guard' condition

print("errors.swift compiles clean. Uncomment one block above and rerun.")
