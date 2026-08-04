import Testing
@testable import Chapter07

// Test names describe the behavior, not the exercise number, so a red line
// in the output tells you what is wrong without opening this file.

@Suite("07.1 firstRepeated(in:)")
struct FirstRepeatedTests {
    @Test("finds the element whose repeat appears earliest")
    func findsEarliestRepeat() {
        #expect(firstRepeated(in: [3, 1, 3, 1]) == 3)
    }

    @Test("reports the value at the position where the repeat is detected")
    func reportsTheDetectedValue() {
        #expect(firstRepeated(in: [7, 4, 9, 4, 7]) == 4)
    }

    @Test("returns nil when every element is distinct")
    func nilWhenAllDistinct() {
        #expect(firstRepeated(in: [1, 2, 3]) == nil)
    }

    @Test("returns nil for an empty collection")
    func nilWhenEmpty() {
        #expect(firstRepeated(in: [Int]()) == nil)
    }

    @Test("works on a string, where the elements are characters")
    func worksOnCharacters() {
        #expect(firstRepeated(in: "swift academy") == "a")
    }

    @Test("works on a slice, which is a different type from an array")
    func worksOnASlice() {
        #expect(firstRepeated(in: [9, 1, 2, 1].dropFirst()) == 1)
    }
}

@Suite("07.2 extremes(of:)")
struct ExtremesTests {
    @Test("reports the smallest and the largest of several values")
    func reportsBothEnds() {
        let result = extremes(of: [3, 1, 4, 1, 5])
        #expect(result?.low == 1)
        #expect(result?.high == 5)
    }

    @Test("reports one element as both ends of its own range")
    func singleElementIsBothEnds() {
        let result = extremes(of: [7])
        #expect(result?.low == 7)
        #expect(result?.high == 7)
    }

    @Test("returns nil for an empty sequence")
    func nilWhenEmpty() {
        #expect(extremes(of: [Double]()) == nil)
    }

    @Test("handles negative values rather than assuming a zero floor")
    func handlesNegatives() {
        let result = extremes(of: [-4, -9, -1])
        #expect(result?.low == -9)
        #expect(result?.high == -1)
    }

    @Test("accepts a sequence that is not a collection")
    func acceptsASequenceOnly() {
        let result = extremes(of: stride(from: 10, to: 0, by: -3))
        #expect(result?.low == 1)
        #expect(result?.high == 10)
    }

    @Test("compares strings lexicographically, not by length")
    func comparesStrings() {
        let result = extremes(of: ["pear", "fig", "apricot"])
        #expect(result?.low == "apricot")
        #expect(result?.high == "pear")
    }
}

@Suite("07.3 Tally")
struct TallyTests {
    @Test("counts repeated records of the same item")
    func countsRepeats() {
        var tally = Tally<String>()
        tally.record("ada")
        tally.record("ada")
        tally.record("grace")
        #expect(tally.count(of: "ada") == 2)
        #expect(tally.count(of: "grace") == 1)
    }

    @Test("reports zero for an item that was never recorded")
    func zeroForUnknownItem() {
        var tally = Tally<String>()
        tally.record("ada")
        #expect(tally.count(of: "linus") == 0)
    }

    @Test("counts distinct items rather than total records")
    func countsDistinctItems() {
        var tally = Tally<Int>()
        for value in [4, 4, 4, 9] { tally.record(value) }
        #expect(tally.distinctCount == 2)
    }

    @Test("has no leader before anything is recorded")
    func emptyTallyHasNoLeader() {
        let tally = Tally<Int>()
        #expect(tally.leader == nil)
        #expect(tally.distinctCount == 0)
        #expect(tally.count(of: 1) == 0)
    }

    @Test("names the most recorded item")
    func namesTheMostRecorded() {
        var tally = Tally<String>()
        for word in ["b", "a", "b", "c", "b"] { tally.record(word) }
        #expect(tally.leader == "b")
    }

    @Test("breaks a tie in favour of whichever item reached the count first")
    func breaksTiesByWhoGotThereFirst() {
        var tally = Tally<String>()
        for word in ["a", "a", "b", "b"] { tally.record(word) }
        #expect(tally.leader == "a")
    }

    @Test("breaks the same tie the other way when the order is reversed")
    func tieBreakFollowsTheOrderOfRecording() {
        var tally = Tally<String>()
        for word in ["b", "b", "a", "a"] { tally.record(word) }
        #expect(tally.leader == "b")
    }

    @Test("is independent per instance, because it is a value type")
    func instancesAreIndependent() {
        var first = Tally<Int>()
        first.record(1)
        var second = first
        second.record(1)
        #expect(first.count(of: 1) == 1)
        #expect(second.count(of: 1) == 2)
    }
}

@Suite("07.4 evenlySpaced(from:step:count:)")
struct EvenlySpacedTests {
    @Test("walks forward from the start by the step")
    func walksForward() {
        #expect(Array(evenlySpaced(from: 5, step: 3, count: 4)) == [5, 8, 11, 14])
    }

    @Test("walks backward when the step is negative")
    func walksBackward() {
        #expect(Array(evenlySpaced(from: 0, step: -2, count: 3)) == [0, -2, -4])
    }

    @Test("repeats the start when the step is zero")
    func repeatsOnZeroStep() {
        #expect(Array(evenlySpaced(from: 7, step: 0, count: 3)) == [7, 7, 7])
    }

    @Test("produces nothing for a count of zero")
    func emptyForZeroCount() {
        #expect(evenlySpaced(from: 5, step: 3, count: 0).isEmpty)
    }

    @Test("produces nothing for a negative count rather than trapping")
    func emptyForNegativeCount() {
        #expect(evenlySpaced(from: 5, step: 3, count: -2).isEmpty)
    }

    @Test("reports its own length without being converted to an array")
    func reportsItsLength() {
        #expect(evenlySpaced(from: 1, step: 1, count: 6).count == 6)
    }

    @Test("includes the start exactly once for a count of one")
    func singleValue() {
        #expect(Array(evenlySpaced(from: -3, step: 9, count: 1)) == [-3])
    }
}

@Suite("07.5 AnyGauge")
struct AnyGaugeTests {
    /// A gauge whose reading never changes.
    struct FixedGauge: Gauge {
        let label: String
        let value: Int
        func read() -> Int { value }
    }

    /// A gauge whose reading changes on every read. Erasing a type has to
    /// keep the call, not the first answer it gave.
    final class TickingGauge: Gauge {
        let label: String
        private var reads = 0
        init(label: String) { self.label = label }
        func read() -> Int {
            reads += 1
            return reads
        }
    }

    @Test("forwards the label of the gauge it wraps")
    func forwardsLabel() {
        let erased = AnyGauge(FixedGauge(label: "pier", value: 4))
        #expect(erased.label == "pier")
    }

    @Test("forwards a different label for a different gauge")
    func forwardsADifferentLabel() {
        let erased = AnyGauge(FixedGauge(label: "dock", value: 9))
        #expect(erased.label == "dock")
        #expect(erased.read() == 9)
    }

    @Test("calls through on every read instead of caching the first answer")
    func readsThroughEveryTime() {
        let erased = AnyGauge(TickingGauge(label: "counter"))
        #expect(erased.read() == 1)
        #expect(erased.read() == 2)
        #expect(erased.read() == 3)
    }

    @Test("stores gauges of different concrete types in one array")
    func holdsSeveralConcreteTypes() {
        let gauges: [AnyGauge<Int>] = [
            AnyGauge(FixedGauge(label: "fixed", value: 10)),
            AnyGauge(TickingGauge(label: "ticking")),
        ]
        #expect(gauges.map(\.label) == ["fixed", "ticking"])
        #expect(gauges.map { $0.read() } == [10, 1])
    }

    @Test("erases a gauge whose value type is not Int")
    func erasesAnotherValueType() {
        struct NameGauge: Gauge {
            let label: String
            func read() -> String { "steady" }
        }
        let erased = AnyGauge(NameGauge(label: "name"))
        #expect(erased.read() == "steady")
        #expect(erased.label == "name")
    }
}

@Suite("07.6 mergeSorted(_:_:)")
struct MergeSortedTests {
    /// Compares on `rank` alone, so two cards can be equal without being the
    /// same card. That is what makes the ordering of equals observable.
    struct Card: Comparable, Equatable {
        let rank: Int
        let suit: String
        static func < (lhs: Card, rhs: Card) -> Bool { lhs.rank < rhs.rank }
    }

    @Test("interleaves two sorted arrays")
    func interleavesTwoArrays() {
        #expect(mergeSorted([1, 3, 5], [2, 4, 6]) == [1, 2, 3, 4, 5, 6])
    }

    @Test("keeps duplicates from both sides")
    func keepsDuplicates() {
        #expect(mergeSorted([1, 2, 2], [2, 3]) == [1, 2, 2, 2, 3])
    }

    @Test("returns the other side unchanged when one side is empty")
    func handlesEmptyInputs() {
        #expect(mergeSorted([], [4, 8]) == [4, 8])
        #expect(mergeSorted([4, 8], []) == [4, 8])
        #expect(mergeSorted([Int](), [Int]()) == [])
    }

    @Test("accepts two different sequence types with the same element type")
    func acceptsDifferentSequenceTypes() {
        #expect(mergeSorted([1, 3, 5], 2...4) == [1, 2, 3, 3, 4, 5])
    }

    @Test("merges characters as readily as numbers")
    func mergesCharacters() {
        #expect(mergeSorted("ace", "bd") == Array("abcde"))
    }

    @Test("merges rather than sorts, so unsorted input stays unsorted")
    func mergesInsteadOfSorting() {
        #expect(mergeSorted([3, 1], [2]) == [2, 3, 1])
    }

    @Test("takes the equal element from the first sequence first")
    func equalElementsFavourTheFirstSequence() {
        let left = [Card(rank: 2, suit: "clubs"), Card(rank: 5, suit: "clubs")]
        let right = [Card(rank: 2, suit: "hearts"), Card(rank: 5, suit: "hearts")]
        let merged = mergeSorted(left, right)
        #expect(merged.map(\.suit) == ["clubs", "hearts", "clubs", "hearts"])
    }
}
