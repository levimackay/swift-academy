// Chapter 07 exercises.
//
// Every declaration below compiles and returns a wrong answer, so the suite
// runs and reports a score instead of aborting. Replace each body.
//
//     swift test --filter Chapter07Tests
//
// House rule for this chapter: no `any` in any signature you write here.
// Every exercise is solvable with a generic parameter, a `some` type, or a
// constrained associated type, and the last item of the Done when list
// greps for it.

// MARK: - 1. firstRepeated(in:)

/// Returns the first element that appears more than once, scanning left to
/// right, or nil when every element is distinct. "First" means the first
/// position at which a repeat is detected, so in `[3, 1, 3, 1]` the answer
/// is `3` and not `1`.
///
/// The parameter is a Collection whose Element can go in a Set, which is
/// what lets one implementation serve arrays, slices, and strings.
func firstRepeated<C: Collection>(in items: C) -> C.Element?
where C.Element: Hashable {
    // TODO: replace this.
    return nil
}

// MARK: - 2. extremes(of:)

/// Returns the smallest and largest element of a sequence in one pass, or
/// nil when the sequence is empty. On a tie either matching element is
/// correct, because they compare equal.
///
/// Note the constraint is on `Sequence`, not on `Collection`: this has to
/// work for something you can only walk once.
func extremes<S: Sequence>(of values: S) -> (low: S.Element, high: S.Element)?
where S.Element: Comparable {
    // TODO: replace this.
    return nil
}

// MARK: - 3. Tally

/// Counts how many times each item has been recorded. The constraint on
/// `Item` is the exercise: pick the smallest one that lets the type do its
/// job, and put it in the declaration rather than on each method.
///
/// - `record(_:)` records one occurrence.
/// - `count(of:)` is how many times that item was recorded, zero if never.
/// - `distinctCount` is how many different items were recorded.
/// - `leader` is the item recorded most often, nil when nothing was
///   recorded. On a tie, the item that reached its count first wins, which
///   for `a a b b` means `a`.
struct Tally<Item: Hashable> {
    init() {
        // TODO: replace this if your storage needs setting up.
    }

    mutating func record(_ item: Item) {
        // TODO: replace this.
    }

    func count(of item: Item) -> Int {
        // TODO: replace this.
        return -1
    }

    var distinctCount: Int {
        // TODO: replace this.
        return -1
    }

    var leader: Item? {
        // TODO: replace this.
        return nil
    }
}

// MARK: - 4. evenlySpaced(from:step:count:)

/// Returns `count` values beginning at `start`, each `step` further on than
/// the last. A `count` of zero or less is an empty result. `step` may be
/// negative and may be zero.
///
/// The return type is opaque on purpose. The caller may iterate it, count
/// it, and subscript it, and may not name it, so you are free to change what
/// you return without changing any caller.
func evenlySpaced(from start: Int, step: Int, count: Int) -> some Collection<Int> {
    // TODO: replace this.
    return [Int]()
}

// MARK: - 5. Gauge and AnyGauge

/// Something that can be read repeatedly, producing a value whose type is up
/// to the conforming type.
protocol Gauge<Value> {
    associatedtype Value
    var label: String { get }
    func read() -> Value
}

/// The type eraser. It forwards to whatever `Gauge` it was built from, so
/// gauges of several concrete types with the same `Value` can be stored
/// together in one `[AnyGauge<Int>]`.
///
/// The stub below is the first implementation almost everyone writes, and it
/// is wrong in a way the tests will show you: erasing a type means keeping
/// the ability to call `read()` later, not calling it once now.
struct AnyGauge<Value>: Gauge {
    let label: String
    private let captured: Value

    init<G: Gauge>(_ base: G) where G.Value == Value {
        // TODO: replace this, and change the stored properties to match.
        self.label = ""
        self.captured = base.read()
    }

    func read() -> Value {
        // TODO: replace this.
        return captured
    }
}

// MARK: - 6. mergeSorted(_:_:)

/// Interleaves two sequences into one array, always taking from `first`
/// while its next element is less than or equal to `second`'s next element.
///
/// This is the integrative exercise. Three things about it are load bearing.
///
/// 1. The two sequences may be different concrete types, so long as their
///    elements are the same type. That is what the `where` clause says.
/// 2. It merges, it does not sort. Given `[3, 1]` and `[2]` it takes 2, then
///    finds `second` exhausted, then appends the rest of `first` in order,
///    producing `[2, 3, 1]`. Sorting the concatenation would answer
///    `[1, 2, 3]` and is wrong here.
/// 3. Equal elements come from `first` before `second`, which is visible
///    when the element type compares equal without being identical.
func mergeSorted<A: Sequence, B: Sequence>(_ first: A, _ second: B) -> [A.Element]
where A.Element == B.Element, A.Element: Comparable {
    // TODO: replace this.
    return []
}
