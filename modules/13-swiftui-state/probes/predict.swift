// Write your prediction on the PREDICT line above each block before you run
// this. Then run it. The toolchain is the answer key and nothing else in this
// repository is.
//
//   make probe CH=13 P=predict
//
// SwiftUI is deliberately not imported. Every mechanism below is the one
// SwiftUI is built on, and all of it runs on the command line tools.

import Observation

@Observable
@MainActor
final class Profile {
    var name = "levi"
    var unreadCount = 0
}

@MainActor
final class Ticker {
    var fired = 0
}

// A Binding is a pair of closures over storage somebody else owns. This is a
// hand rolled one so the mechanism is visible with no framework in the way.
struct Handle<Value> {
    var read: @MainActor () -> Value
    var write: @MainActor (Value) -> Void
}

@MainActor
func blockOne() {
    let profile = Profile()
    let tally = Ticker()

    withObservationTracking {
        _ = profile.name
    } onChange: {
        MainActor.assumeIsolated { tally.fired += 1 }
    }

    profile.unreadCount = 7
    profile.name = "ada"
    profile.name = "grace"

    // PREDICT: tally.fired is
    print("block one:", tally.fired)
}

@MainActor
func blockTwo() {
    let profile = Profile()
    let handle = Handle(read: { profile.name }, write: { profile.name = $0 })
    var snapshot = profile.name

    profile.name = "ada"
    snapshot = snapshot.uppercased()
    handle.write("grace")

    // PREDICT: these three print
    print("block two:", handle.read(), snapshot, profile.name)
}

struct Row: Equatable {
    var title: String
}

@MainActor
func blockThree() {
    let a = Profile()
    let b = Profile()
    b.name = a.name

    var rows = [Row(title: "one"), Row(title: "two")]
    let taken = rows[0]
    rows[0].title = "edited"

    // PREDICT: these three print
    print("block three:", a === b, a.name == b.name, taken.title)
}

MainActor.assumeIsolated {
    blockOne()
    blockTwo()
    blockThree()
}
