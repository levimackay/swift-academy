import Testing
@testable import Chapter06

// Test names describe the behavior, not the exercise number, so a red line in
// the output tells you what is wrong without opening this file.
//
// Nothing here asserts on Dictionary or Set iteration order. Swift seeds the
// hash per process, so element order is different on the next run, and a test
// that pinned it would be flaky rather than strict. Where order matters, the
// thing being ordered is an Array.

@Suite("06.1 uniqueInOrder(_:)")
struct UniqueInOrderTests {
    @Test("keeps the first occurrence and drops the later ones")
    func keepsFirstOccurrence() {
        #expect(uniqueInOrder(["fig", "date", "fig", "plum"]) == ["fig", "date", "plum"])
    }

    @Test("preserves arrival order rather than any sorted order")
    func preservesArrivalOrder() {
        #expect(uniqueInOrder(["plum", "date", "fig"]) == ["plum", "date", "fig"])
    }

    @Test("returns an empty array for an empty input")
    func emptyInput() {
        #expect(uniqueInOrder([]) == [])
    }

    @Test("compares exactly, so two casings are two values")
    func comparesExactly() {
        #expect(uniqueInOrder(["Fig", "fig", "Fig"]) == ["Fig", "fig"])
    }

    @Test("keeps a value that reappears after another value")
    func reappearanceIsStillADuplicate() {
        #expect(uniqueInOrder(["a", "b", "a", "c", "b"]) == ["a", "b", "c"])
    }
}

@Suite("06.2 parsedReadings(from:)")
struct ParsedReadingsTests {
    @Test("drops absent lines and unparsable lines, keeping the rest in order")
    func dropsAbsentAndUnparsable() {
        #expect(parsedReadings(from: ["1", nil, "x", "-3"]) == [1, -3])
    }

    @Test("keeps a negative reading rather than treating the sign as junk")
    func keepsNegative() {
        #expect(parsedReadings(from: ["-12", "-1"]) == [-12, -1])
    }

    @Test("rejects a decimal, because a reading is a whole number")
    func rejectsDecimal() {
        #expect(parsedReadings(from: ["3.5", "4"]) == [4])
    }

    @Test("keeps zero, which is a reading and not an absence")
    func keepsZero() {
        #expect(parsedReadings(from: ["0"]) == [0])
    }

    @Test("returns nothing when every line is absent")
    func allAbsent() {
        #expect(parsedReadings(from: [nil, nil]) == [])
    }
}

@Suite("06.3 wordCounts(in:)")
struct WordCountsTests {
    @Test("counts a repeated word once per appearance")
    func countsRepeats() {
        #expect(wordCounts(in: ["fig", "date", "fig"]) == ["fig": 2, "date": 1])
    }

    @Test("counts three appearances of a single word")
    func countsThree() {
        #expect(wordCounts(in: ["a", "a", "a"]) == ["a": 3])
    }

    @Test("returns an empty dictionary for an empty input")
    func emptyInput() {
        #expect(wordCounts(in: []) == [:])
    }

    @Test("has no key at all for a word that never appeared")
    func absentWordHasNoKey() {
        #expect(wordCounts(in: ["fig"])["date"] == nil)
    }
}

@Suite("06.4 groupedByInitial(_:)")
struct GroupedByInitialTests {
    @Test("groups names under their first character")
    func groupsByFirstCharacter() {
        #expect(groupedByInitial(["ada", "levi", "alan"])
                == ["a": ["ada", "alan"], "l": ["levi"]])
    }

    @Test("keeps arrival order inside a group")
    func keepsOrderInsideAGroup() {
        #expect(groupedByInitial(["alan", "ada"]) == ["a": ["alan", "ada"]])
    }

    @Test("gives an empty name no group at all")
    func emptyNameIsNotAGroup() {
        #expect(groupedByInitial(["", "ada"]) == ["a": ["ada"]])
    }

    @Test("treats a family emoji as one initial, not as its first scalar")
    func multiScalarGraphemeIsOneInitial() {
        #expect(groupedByInitial(["\u{1F468}\u{200D}\u{1F469}\u{200D}\u{1F467} household"])
                == ["\u{1F468}\u{200D}\u{1F469}\u{200D}\u{1F467}": ["\u{1F468}\u{200D}\u{1F469}\u{200D}\u{1F467} household"]])
    }

    @Test("returns an empty dictionary for an empty input")
    func emptyInput() {
        #expect(groupedByInitial([]) == [:])
    }
}

@Suite("06.5 offsetOfPeak(in:)")
struct OffsetOfPeakTests {
    @Test("counts from the start of the slice, not from the start of the base array")
    func countsFromSliceStart() {
        let base = [10, 20, 30, 40, 50]
        #expect(offsetOfPeak(in: base[1..<4]) == 2)
    }

    @Test("agrees with the base index only when the slice starts at zero")
    func sliceStartingAtZero() {
        let base = [5, 7, 6]
        #expect(offsetOfPeak(in: base[0...]) == 1)
    }

    @Test("picks the earliest of two tied peaks")
    func earliestOfATie() {
        let base = [3, 8, 8]
        #expect(offsetOfPeak(in: base[0...]) == 1)
    }

    @Test("finds a peak that sits at the very end of the slice")
    func peakAtTheEnd() {
        let base = [9, 1, 2, 3]
        #expect(offsetOfPeak(in: base[1...]) == 2)
    }

    @Test("has no answer for an empty slice")
    func emptySlice() {
        let base = [1, 2, 3]
        #expect(offsetOfPeak(in: base[2..<2]) == nil)
    }
}

@Suite("06.6 truncatedDisplayName(_:limit:)")
struct TruncatedDisplayNameTests {
    @Test("leaves a name that already fits completely alone")
    func leavesShortNameAlone() {
        #expect(truncatedDisplayName("Levi Mackay", limit: 20) == "Levi Mackay")
    }

    @Test("measures the limit in characters, so a six character name with an emoji fits")
    func measuresInCharacters() {
        let name = "Levi \u{1F468}\u{200D}\u{1F469}\u{200D}\u{1F467}"
        #expect(truncatedDisplayName(name, limit: 6) == name)
    }

    @Test("never cuts a family emoji in half")
    func keepsAGraphemeWhole() {
        let name = "Ada \u{1F468}\u{200D}\u{1F469}\u{200D}\u{1F467} Lovelace"
        #expect(truncatedDisplayName(name, limit: 6)
                == "Ada \u{1F468}\u{200D}\u{1F469}\u{200D}\u{1F467}\u{2026}")
    }

    @Test("counts the ellipsis against the limit")
    func ellipsisCountsAgainstTheLimit() {
        let name = "Ada \u{1F468}\u{200D}\u{1F469}\u{200D}\u{1F467} Lovelace"
        #expect(truncatedDisplayName(name, limit: 6).count == 6)
    }

    @Test("drops a trailing space before adding the ellipsis")
    func dropsTrailingSpace() {
        let name = "Ada \u{1F468}\u{200D}\u{1F469}\u{200D}\u{1F467} Lovelace"
        #expect(truncatedDisplayName(name, limit: 5) == "Ada\u{2026}")
    }

    @Test("cuts inside a word when the word is what is left")
    func cutsInsideAWord() {
        #expect(truncatedDisplayName("Lovelace", limit: 3) == "Lo\u{2026}")
    }

    @Test("returns nothing at all for a limit of zero")
    func zeroLimit() {
        #expect(truncatedDisplayName("Lovelace", limit: 0) == "")
    }

    @Test("returns the ellipsis alone for a limit of one")
    func limitOfOne() {
        #expect(truncatedDisplayName("Lovelace", limit: 1) == "\u{2026}")
    }
}
