// Chapter 03 exercises, part one.
//
// Every member below returns or does a compiling wrong thing so that the
// suite runs and reports a score instead of aborting. Replace each body.
//
//   swift test --filter Chapter03Tests
//
// Nothing in this file needs a `class`. If you reach for one, say out loud
// which of chapter 10's three reasons you are invoking, and if you cannot
// name one, you wanted a struct.

// MARK: - 1. Basket

/// A shopping basket. Two baskets that were copied from one another are
/// independent from the moment of the copy: nothing you do to one may show
/// up in the other.
struct Basket {
    /// Items in the order they were stocked. Duplicates are allowed.
    private(set) var lines: [String] = []

    /// Adds `item` to the end of `lines`, changing this basket in place.
    mutating func stock(_ item: String) {
        // TODO: replace this.
    }

    /// Returns a new basket carrying `item` at the end. The basket the
    /// method was called on is not changed, which is why it is not
    /// `mutating`.
    func stocking(_ item: String) -> Basket {
        // TODO: replace this.
        return Basket()
    }
}

// MARK: - 2. Roster

/// Players grouped by team name.
struct Roster {
    /// The players on each team, in enrollment order. A team with no
    /// players has no key at all, so this dictionary never holds an empty
    /// array as a value.
    private(set) var byTeam: [String: [String]] = [:]

    /// Appends `player` to `team`, creating the team when it is new. A
    /// player already on that team is not added a second time.
    mutating func enroll(_ player: String, in team: String) {
        // TODO: replace this.
    }

    /// Removes `player` from `team` and reports whether anything was
    /// removed. Removing the last player removes the team's key as well.
    mutating func release(_ player: String, from team: String) -> Bool {
        // TODO: replace this.
        return false
    }
}

// MARK: - 3. SeatCode

/// A seat on an aircraft, as printed on a boarding pass.
///
/// Two seat codes name the same seat when they differ only in letter case
/// and in leading or trailing spaces, so `"  4a "` and `"4A"` are one seat.
/// `raw` keeps whatever was typed; equality and hashing do not.
///
/// The stub below compiles because the compiler synthesizes both `==` and
/// `hash(into:)` from `raw`, which is the wrong rule. Replace the rule, and
/// keep the two halves agreeing with each other: equal values must hash
/// equal, or a `Set` and a `Dictionary` will quietly lose entries.
struct SeatCode: Hashable {
    let raw: String

    // TODO: replace the synthesized conformance with the rule above.
}

// MARK: - 5. Panel and Move

/// One edit to a panel: add `delta` to the cell at `index`.
struct Move {
    let index: Int
    let delta: Int
}

/// A fixed length row of counters.
struct Panel: Equatable {
    /// The counters, left to right.
    private(set) var cells: [Int]

    /// Adds `move.delta` to the cell at `move.index`. An index outside
    /// `cells` changes nothing and is not an error.
    mutating func perform(_ move: Move) {
        // TODO: replace this.
    }
}

/// Returns one panel per move: element `i` is the panel as it stands after
/// moves `0` through `i` have been performed in order, on top of `start`.
///
/// An empty `moves` array produces an empty array of snapshots. `start` is
/// still `start` when this function returns, and the caller's copy of it is
/// too. That is the whole point of the exercise: nothing here needs a
/// defensive copy, because there is no way to hand out a shared one.
func snapshots(of start: Panel, applying moves: [Move]) -> [Panel] {
    // TODO: replace this.
    return []
}
