// What a closure actually holds, run rather than argued about.
//
//     make probe CH=02 P=capture
//
// Four questions, four printed answers. Read the answer before you read the
// comment under it, and if the Python version of any of these would print
// something else, that is the row worth writing down.

// 1. A closure captures the variable, not the value. Both names below refer
//    to one piece of storage, and either side can write to it.
func sharedStorage() -> Int {
    var tally = 0
    let bump = { tally += 1 }
    bump()
    bump()
    tally += 10
    return tally
}
print("1. shared storage:", sharedStorage())
// 12. Two writes through the closure and one write through the name landed
// in the same box. This is why capture is not an implicit copy.

// 2. A `for` loop binds a fresh constant per iteration, so three closures
//    built in a loop see three different values.
func builtInALoop() -> [Int] {
    var built: [() -> Int] = []
    for step in 1...3 {
        built.append { step * 10 }
    }
    return built.map { $0() }
}
print("2. built in a loop:", builtInALoop())
// [10, 20, 30]. The equivalent Python comprehension over `lambda: i * 10`
// prints [30, 30, 30], because Python looks the name up when the lambda runs
// and the loop variable is one variable. Swift's loop variable is a new
// constant each time around.

// 3. A capture list entry evaluates at closure creation, so it snapshots.
//    The capture list itself is chapter 10's subject, because that is where
//    the `[weak self]` form becomes load bearing. This is only the preview.
func snapshotVersusLive() -> (Int, Int) {
    var reading = 1
    let live = { reading }
    let frozen = { [reading] in reading }
    reading = 99
    return (live(), frozen())
}
print("3. live then frozen:", snapshotVersusLive())
// (99, 1). Same two lines of closure body, two different answers, and the
// only difference is four characters of capture list.

// 4. A non escaping closure may write to the caller's local variable,
//    because the call is guaranteed to be over before the caller resumes.
//    `runs` never leaves the stack frame here.
func twice(_ body: () -> Void) {
    body()
    body()
}
func countedRuns() -> Int {
    var runs = 0
    twice { runs += 1 }
    return runs
}
print("4. non escaping writes:", countedRuns())
// 2. Mark `body` as `@escaping` and this still compiles, but `runs` is no
// longer a stack slot: the compiler promotes it to a heap box so the closure
// can outlive `countedRuns`. Nothing in the source says so, which is the
// reason the annotation exists at all.
