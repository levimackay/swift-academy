// Everything that runs here compiles, and half of it looks like it should
// not.
//
//     make probe CH=11 P=regions
//
// The naive rule you will read on the internet is "a non-Sendable value may
// not cross an isolation boundary". That rule is wrong on this toolchain.
// The real rule is about regions: the compiler tracks which values could
// reach each other, and a whole region may be handed over exactly once. The
// two blocks at the bottom are the same values with one extra line, and
// that line is the whole difference.

/// Not Sendable, and never becomes Sendable in this file.
final class Pallet {
    var items = 0
    var attached: Pallet?
}

/// A region of exactly one value, created and given away in the same
/// breath. Nothing else can reach it, so nothing else can race with it.
func sendFresh() async -> Int {
    let pallet = Pallet()
    pallet.items = 1
    return await Task { pallet.items }.value
}

/// Two values that never touch are two regions, and both may go.
func sendTwoRegions() async -> Int {
    let left = Pallet()
    left.items = 1
    let right = Pallet()
    right.items = 2
    async let first = Task { left.items }.value
    async let second = Task { right.items }.value
    return await first + second
}

/// Storing one inside the other merges them into a single region. That is
/// still legal, because the region leaves as a unit.
func sendMergedRegion() async -> Int {
    let outer = Pallet()
    let inner = Pallet()
    inner.items = 2
    outer.attached = inner
    return await Task { outer.items + (outer.attached?.items ?? 0) }.value
}

// A. Use after transfer. The value went, and then the caller read it.
//
// func useAfterSend() async -> Int {
//     let pallet = Pallet()
//     let sent = Task { pallet.items }
//     pallet.items = 9
//     return await sent.value
// }
//
// error: sending value of non-Sendable type '() async -> Int' risks causing
// data races [#SendingRisksDataRace]
// note: Passing value of non-Sendable type '() async -> Int' as a 'sending'
// argument to initializer 'init(name:priority:operation:)' risks causing
// races in between local and caller code
// note: access can happen concurrently

// B. Same diagnostic, one level deeper. `inner` was never sent anywhere,
//    but it merged into `outer`'s region on the line above, so touching it
//    counts as touching the region that left.
//
// func useSiblingAfterSend() async -> Int {
//     let outer = Pallet()
//     let inner = Pallet()
//     outer.attached = inner
//     let sent = Task { outer.items }
//     inner.items = 7
//     return await sent.value
// }
//
// error: sending value of non-Sendable type '() async -> Int' risks causing
// data races [#SendingRisksDataRace]
// note: Passing value of non-Sendable type '() async -> Int' as a 'sending'
// argument to initializer 'init(name:priority:operation:)' risks causing
// races in between local and caller code
// note: access can happen concurrently

print("fresh:", await sendFresh())
print("two regions:", await sendTwoRegions())
print("merged region:", await sendMergedRegion())
