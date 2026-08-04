// This file compiles as written. Every commented block below is a real
// mistake with the diagnostic it produced on the toolchain in the chapter
// front matter, pasted verbatim. Uncomment one block at a time and check the
// wording yourself:
//
//     make probe CH=10 P=errors
//
// The chapter's "Where it goes wrong" table is built from this file. If a
// future toolchain changes the wording, fix it here first.

final class Session {
    let id: Int
    init(id: Int) { self.id = id }
}

struct Ticket: Equatable {
    let seat: String
}

// 1. A weak reference can become nil, so its type must say so.
//
// final class HolderA { weak var session: Session }
//
// error: 'weak' variable should have optional type 'Session?'

// 2. Same reason, applied to mutability.
//
// final class HolderB { weak let session: Session? = nil }
//
// error: 'weak' must be a mutable variable, because it may change at runtime

// 3. There is no reference to zero out when the type is a value type.
//
// final class HolderC { weak var seat: Ticket? }
//
// error: 'weak' may only be applied to class and class-bound protocol types,
// not 'Ticket'

// 4. Identity comparison needs an identity to compare.
//
// let sameSeat = Ticket(seat: "4A") === Ticket(seat: "4A")
//
// error: argument type 'Ticket' expected to be an instance of a class or
// class-constrained type

// 5. The capture of self must be written down, because it is an ownership
//    decision and not a spelling convenience.
//
// final class LoaderA {
//     var total = 0
//     var onFinish: (() -> Void)?
//     func wire() { onFinish = { total += 1 } }
// }
//
// error: reference to property 'total' in closure requires explicit use of
// 'self' to make capture semantics explicit

// 6. Having captured weakly, self is an Optional inside the body.
//
// final class LoaderB {
//     var total = 0
//     var onFinish: (() -> Void)?
//     func wire() { onFinish = { [weak self] in self.total += 1 } }
// }
//
// error: value of optional type 'LoaderB?' must be unwrapped to refer to
// member 'total' of wrapped base type 'LoaderB'

// 7. A copyable struct has no single moment of death to hook.
//
// struct Buffer {
//     var bytes: [UInt8] = []
//     deinit { print("gone") }
// }
//
// error: deinitializer cannot be declared in struct 'Buffer' that conforms
// to 'Copyable'

print("errors.swift compiles when every block above stays commented out")
print("Session \(Session(id: 1).id), Ticket \(Ticket(seat: "4A").seat)")
