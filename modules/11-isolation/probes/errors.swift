// This file compiles as written. Every commented block below is a real
// mistake with the diagnostic it produced on the toolchain in the chapter
// front matter, pasted verbatim. Uncomment one block at a time and check the
// wording yourself:
//
//     make probe CH=11 P=errors
//
// The chapter's "Where it goes wrong" table is built from this file. If a
// future toolchain changes the wording, fix it here first.
//
// One thing to know before you start. Region based isolation runs in a
// compiler pass that -typecheck does not reach, so `swift build` and
// `make probe` are the source of truth and an editor squiggle is not.

/// Shared mutable storage with no synchronization. Nothing here is safe to
/// hand to a second isolation domain, and the compiler is about to say so
/// nine different ways.
final class Tripmeter {
    var miles = 0
}

actor Vault {
    var balance = 0
    func deposit(_ amount: Int) { balance += amount }
    func peek() -> Int { balance }
}

@MainActor
final class Console {
    var banner = ""
}

// 1. A class can promise Sendable only if nobody can subclass it and break
//    the promise later.
//
// class Tripmeter: Sendable { let miles = 0 }
//
// error: non-final class 'Tripmeter' cannot conform to 'Sendable'; use
// '@unchecked Sendable'

// 2. Making it final is not enough, because the mutable property is the
//    actual hazard.
//
// final class Tripmeter: Sendable { var miles = 0 }
//
// error: stored property 'miles' of 'Sendable'-conforming class 'Tripmeter'
// is mutable

// 3. A struct is Sendable only when every stored property is. Composition
//    is checked, not assumed.
//
// struct Parcel: Sendable { let tripmeter: Tripmeter }
//
// error: stored property 'tripmeter' of 'Sendable'-conforming struct
// 'Parcel' has non-Sendable type 'Tripmeter'

// 4. A @Sendable closure may capture Sendable values only. Capturing the
//    class would smuggle shared storage across the boundary.
//
// func schedule(_ work: @Sendable @escaping () -> Void) { work() }
// func wire() {
//     let tripmeter = Tripmeter()
//     schedule { tripmeter.miles += 1 }
// }
//
// error: capture of 'tripmeter' with non-Sendable type 'Tripmeter' in a
// '@Sendable' closure [#SendableClosureCaptures]

// 5. Reading actor state from outside is the whole point of an actor, and
//    the reason it cannot be a plain read.
//
// func audit(_ v: Vault) -> Int { v.balance }
//
// error: actor-isolated property 'balance' can not be referenced from a
// nonisolated context

// 6. Calling an isolated method from outside is a hop, not a call.
//
// func spend(_ v: Vault) async { v.deposit(5) }
//
// error: actor-isolated instance method 'deposit' cannot be called from
// outside of the actor

// 7. A global actor isolates every member of the type it is written on.
//
// func offMain(_ c: Console) { c.banner = "ready" }
//
// error: main actor-isolated property 'banner' can not be mutated from a
// nonisolated context

// 8. A static var is a global with a longer name, and a global that anyone
//    can write is a data race waiting for a second thread.
//
// enum Metrics { static var requestCount = 0 }
//
// error: static property 'requestCount' is not concurrency-safe because it
// is nonisolated global shared mutable state [#MutableGlobalVariable]

// 9. Regions, not types. This value is not Sendable and the transfer is
//    still allowed, right up until the caller touches it again.
//
// func handOff(_ o: sending Tripmeter) {}
// func drive() {
//     let tripmeter = Tripmeter()
//     handOff(tripmeter)
//     tripmeter.miles += 1
// }
//
// error: sending 'tripmeter' risks causing data races
// [#SendingRisksDataRace]
// note: 'tripmeter' used after being passed as a 'sending' parameter; Later
// uses could race
// note: access can happen concurrently

// What does compile, so that the file has something to run.

func compiles() async {
    let vault = Vault()
    await vault.deposit(40)
    await vault.deposit(2)
    print("vault balance:", await vault.peek())

    let tripmeter = Tripmeter()
    tripmeter.miles = 12
    print("tripmeter miles:", tripmeter.miles)

    // Handing the region away and never touching it again is accepted.
    let parting = Tripmeter()
    parting.miles = 3
    Task { print("moved tripmeter:", parting.miles) }.cancel()
}

await compiles()
