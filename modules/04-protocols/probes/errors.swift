// This file compiles as written. Every commented block below is a real
// mistake with the diagnostic it produced on the toolchain in the chapter
// front matter, pasted verbatim. Uncomment one block at a time and check the
// wording yourself:
//
//     make probe CH=04 P=errors
//
// The chapter's "Where it goes wrong" table is built from this file, with one
// exception the table names: the ExistentialAny warning needs the package
// setting and cannot be produced by running a loose file.

protocol Vessel {
    var litres: Double { get }
    func rinsed() -> Self
}

struct Flask: Vessel {
    let litres: Double
    func rinsed() -> Flask { Flask(litres: 0) }
}

// 1. A conformance is a promise, and the compiler reads the whole promise.
//    The error names the type, and the notes name each unmet requirement.
//
// struct Carafe: Vessel {
//     let capacity: Double
// }
//
// error: type 'Carafe' does not conform to protocol 'Vessel'
// note: protocol requires property 'litres' with type 'Double'
// note: protocol requires function 'rinsed()' with type '() -> Carafe'
// note: add stubs for conformance

// 2. Mutation is part of the requirement, not an implementation detail. A
//    protocol that does not say 'mutating' has ruled it out for every
//    conforming value type.
//
// protocol Meter { func bump() }
// struct Dial: Meter {
//     var ticks = 0
//     mutating func bump() { ticks += 1 }
// }
//
// error: type 'Dial' does not conform to protocol 'Meter'
// note: protocol requires function 'bump()' with type '() -> ()'
// note: candidate is marked 'mutating' but protocol does not allow it
// note: add stubs for conformance

// 3. An extension adds behavior and never storage, because adding a stored
//    property would change the size of a type someone else already compiled.
//
// extension Vessel { var fillCount = 0 }
//
// error: extensions must not contain stored properties

// 4. A conformance is declared once. Twice is a question about which one is
//    real, and there is no answer to it.
//
// extension Flask: Vessel {}
//
// error: redundant conformance of 'Flask' to protocol 'Vessel'
// note: 'Flask' declares conformance to protocol 'Vessel' here

// 5. Conditional conformance means the conformance is not always there, and
//    the note tells you which condition failed.
//
// struct Crest<Element> { var parts: [Element] }
// extension Crest: Equatable where Element: Equatable {
//     static func == (lhs: Crest, rhs: Crest) -> Bool { lhs.parts == rhs.parts }
// }
// struct Sigil {}
// let crest = Crest(parts: [Sigil()])
// print(crest == crest)
//
// error: operator function '==' requires that 'Sigil' conform to 'Equatable'
// note: requirement from conditional conformance of 'Crest<Sigil>' to 'Equatable'

// 6. A protocol with an associated type is a family of types. Boxing one
//    erases which member of the family it was, so any member whose signature
//    mentions the associated type is unreachable through the box.
//
// protocol Rack {
//     associatedtype Slot
//     func accepts(_ slot: Slot) -> Bool
// }
// struct IntRack: Rack {
//     func accepts(_ slot: Int) -> Bool { true }
// }
// let anyRack: any Rack = IntRack()
// print(anyRack.accepts(3))
//
// error: member 'accepts' cannot be used on value of type 'any Rack'; consider
// using a generic constraint instead [#ExistentialMemberAccess]

// 7. Retroactive conformance: your module owns neither the type nor the
//    protocol, so a future release of theirs can collide with yours and no
//    one downstream can fix it.
//
// extension Int: Error {}
//
// warning: extension declares a conformance of imported type 'Int' to imported
// protocol 'Error'; this will not behave correctly if the owners of 'Swift'
// introduce this conformance in the future
// note: add '@retroactive' to silence this warning

// 8. The ExistentialAny row in the chapter table. Every target in this package
//    enables the upcoming feature, and `make probe` deliberately does not, so
//    this one is reproduced by pasting the line into an exercise file and
//    running `make test CH=04`.
//
// let vessel: Vessel = Flask(litres: 1)
//
// warning: use of protocol 'Vessel' as a type must be written 'any Vessel';
// this will be an error in a future Swift language mode [#ExistentialAny]

let flask = Flask(litres: 1.5)
let rinsed: any Vessel = flask.rinsed()
print("errors.swift compiles when every block above stays commented out")
print("Flask \(flask.litres) litres, rinsed to \(rinsed.litres)")
