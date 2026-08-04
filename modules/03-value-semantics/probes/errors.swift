// This file compiles as written. Every commented block below is a real
// mistake with the diagnostic it produced on the toolchain in the chapter
// front matter, pasted verbatim. Uncomment one block at a time and check the
// wording yourself:
//
//     make probe CH=03 P=errors
//
// The chapter's "Where it goes wrong" table is built from this file. The file
// stays green on purpose: a probe that compiles today and stops compiling
// after a toolchain upgrade tells you the wording drifted, and a probe that
// never compiled cannot tell you anything.
//
// Blocks 1, 2, and 3 are the same rule seen from three sides, which is why
// they are worth uncommenting in order rather than skimming.
//
// When a diagnostic in here costs you more than ten minutes anywhere else,
// paste it verbatim into NOTES/errors.md with what you thought it meant.

// 1. `let` on a struct freezes the whole value, not just the binding.
//
// struct Crate { var count = 0 }
// let crate = Crate()
// crate.count = 1
//
// error: cannot assign to property: 'crate' is a 'let' constant

// 2. The same freeze, reached through a method instead of a property.
//
// struct Crate {
//     var count = 0
//     mutating func bump() { count += 1 }
// }
// let crate = Crate()
// crate.bump()
//
// error: cannot use mutating member on immutable value: 'crate' is a 'let' constant

// 3. And the same rule from inside the type, when `mutating` is missing.
//
// struct Crate {
//     var count = 0
//     func bump() { count += 1 }
// }
//
// error: left side of mutating operator isn't mutable: 'self' is immutable
// note: mark method 'mutating' to make 'self' mutable

// 4. A class has nothing to mark, because `self` is a reference either way.
//
// final class Crate {
//     var count = 0
//     mutating func bump() { count += 1 }
// }
//
// error: 'mutating' is not valid on instance methods in classes

// 5. Writing any initializer in the struct body withdraws the memberwise one.
//
// struct Crate {
//     var count = 0
//     init() { count = 0 }
// }
// let crate = Crate(count: 3)
//
// error: argument passed to call that takes no arguments

// 6. Equatable is synthesized from the stored properties, so one property
//    that cannot answer the question sinks the whole conformance.
//
// final class Marker {}
// struct Crate: Equatable {
//     var count = 0
//     var marker = Marker()
// }
//
// error: type 'Crate' does not conform to protocol 'Equatable'
// note: stored property type 'Marker' does not conform to protocol 'Equatable', preventing synthesized conformance of 'Crate' to 'Equatable'
//
// The compiler then lists every overload of `==` in the standard library
// that would have matched if `Crate` had conformed to something else. Read
// the first error line and the note above it, and ignore the rest.

// 7. A mutating method holds `self` as inout, so nothing outliving the call
//    is allowed to capture it.
//
// func later(_ run: @escaping () -> Void) { run() }
// struct Crate {
//     var count = 0
//     mutating func bump() { later { self.count += 1 } }
// }
//
// error: escaping closure captures mutating 'self' parameter
// note: captured here

// 8. The forward preview. A struct is Sendable only when every stored
//    property is, and a plain class is not.
//
// final class Marker {}
// struct Crate: Sendable {
//     var marker = Marker()
// }
//
// error: stored property 'marker' of 'Sendable'-conforming struct 'Crate' has non-Sendable type 'Marker'
// note: class 'Marker' does not conform to the 'Sendable' protocol

print("errors.swift compiles clean. Uncomment one block above and rerun.")
