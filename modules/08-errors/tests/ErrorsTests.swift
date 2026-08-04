import Testing
@testable import Chapter08

// Test names describe the behavior, not the exercise number, so a red line
// in the output tells you what is wrong without opening this file.
//
// Nothing in here asserts on compiler diagnostic text. Wording drifts between
// toolchain releases, and the diagnostics this chapter cares about live in
// probes/errors.swift and in the chapter table built from it.

// MARK: - 1. ticketCount(from:)

@Suite("08.1 ticketCount(from:)")
struct TicketCountTests {
    @Test("reads a quantity in the middle of the allowed range")
    func readsMidRange() throws {
        #expect(try ticketCount(from: "4") == 4)
    }

    @Test("accepts both ends of the allowed range")
    func acceptsBothEnds() throws {
        #expect(try ticketCount(from: "1") == 1)
        #expect(try ticketCount(from: "10") == 10)
    }

    @Test("treats surrounding whitespace as noise rather than as an error")
    func ignoresSurroundingWhitespace() throws {
        #expect(try ticketCount(from: "  4 ") == 4)
        #expect(try ticketCount(from: "\t7\n") == 7)
    }

    @Test("reports an empty field as blank, not as an unparseable one")
    func reportsEmptyAsBlank() {
        #expect(throws: TicketError.blank) { try ticketCount(from: "") }
    }

    @Test("reports a whitespace only field as blank")
    func reportsWhitespaceAsBlank() {
        #expect(throws: TicketError.blank) { try ticketCount(from: "   ") }
    }

    @Test("quotes the trimmed text back when the field is not a number")
    func quotesTrimmedTextWhenNotANumber() {
        #expect(throws: TicketError.notANumber("two")) {
            try ticketCount(from: "two")
        }
        #expect(throws: TicketError.notANumber("4x")) {
            try ticketCount(from: "  4x ")
        }
    }

    @Test("separates a number it will not sell from a number it cannot read")
    func separatesOutOfRangeFromUnreadable() {
        #expect(throws: TicketError.outOfRange(0)) { try ticketCount(from: "0") }
        #expect(throws: TicketError.outOfRange(11)) { try ticketCount(from: "11") }
    }

    @Test("carries a rejected negative quantity in the payload")
    func carriesNegativeQuantity() {
        #expect(throws: TicketError.outOfRange(-3)) { try ticketCount(from: "-3") }
    }
}

// MARK: - 2. knownShelves(in:)

@Suite("08.2 knownShelves(in:)")
struct KnownShelvesTests {
    @Test("keeps the shelves that resolve and drops the codes that do not")
    func keepsResolvableCodes() {
        #expect(knownShelves(in: ["A1", "!!", "B2"]) == [1, 2])
    }

    @Test("preserves the order it was given rather than sorting")
    func preservesGivenOrder() {
        #expect(knownShelves(in: ["C9", "A1", "B5"]) == [9, 1, 5])
    }

    @Test("drops an unknown aisle as readily as an unreadable code")
    func dropsUnknownAisle() {
        #expect(knownShelves(in: ["Z9", "A3"]) == [3])
    }

    @Test("returns nothing when nothing resolves")
    func returnsNothingWhenNothingResolves() {
        #expect(knownShelves(in: ["", "!!", "Q7", "A"]) == [])
    }

    @Test("returns nothing for an empty input")
    func returnsNothingForEmptyInput() {
        #expect(knownShelves(in: []) == [])
    }

    @Test("keeps a repeated shelf twice instead of collapsing it")
    func keepsRepeatedShelf() {
        #expect(knownShelves(in: ["A2", "B2"]) == [2, 2])
    }
}

// MARK: - 3. shelfReport(for:)

@Suite("08.3 shelfReport(for:)")
struct ShelfReportTests {
    @Test("names the shelf when the code resolves")
    func namesShelfOnSuccess() {
        #expect(shelfReport(for: "B14") == "shelf 14")
        #expect(shelfReport(for: "A7") == "shelf 7")
    }

    @Test("quotes an unreadable code back to the operator")
    func quotesUnreadableCode() {
        #expect(shelfReport(for: "!!") == "cannot read !!")
    }

    @Test("treats an empty code as unreadable rather than as an aisle")
    func treatsEmptyCodeAsUnreadable() {
        #expect(shelfReport(for: "") == "cannot read ")
    }

    @Test("names the missing aisle when only the letter is wrong")
    func namesMissingAisle() {
        #expect(shelfReport(for: "Z9") == "no aisle Z")
        #expect(shelfReport(for: "Q1") == "no aisle Q")
    }

    @Test("gives the two failure cases two different wordings")
    func distinguishesTheTwoFailures() {
        #expect(shelfReport(for: "Z9") != shelfReport(for: "ZZ"))
    }
}

// MARK: - 4. auditedShelves(in:into:)

@Suite("08.4 auditedShelves(in:into:)")
struct AuditedShelvesTests {
    @Test("closes a code it opened even when the lookup failed")
    func closesAfterFailure() {
        var log: [String] = []
        _ = auditedShelves(in: ["!!"], into: &log)
        #expect(log == ["open !!", "skip !!", "close !!"])
    }

    @Test("records open, outcome, and close for a code that resolves")
    func recordsFullTrailOnSuccess() {
        var log: [String] = []
        _ = auditedShelves(in: ["A1"], into: &log)
        #expect(log == ["open A1", "shelf 1", "close A1"])
    }

    @Test("finishes one code entirely before opening the next")
    func doesNotInterleaveCodes() {
        var log: [String] = []
        _ = auditedShelves(in: ["A1", "!!", "C3"], into: &log)
        #expect(log == [
            "open A1", "shelf 1", "close A1",
            "open !!", "skip !!", "close !!",
            "open C3", "shelf 3", "close C3",
        ])
    }

    @Test("returns the shelves it resolved, in order")
    func returnsResolvedShelves() {
        var log: [String] = []
        #expect(auditedShelves(in: ["C3", "!!", "A1"], into: &log) == [3, 1])
    }

    @Test("appends to a log that already had entries in it")
    func appendsToExistingLog() {
        var log = ["shift start"]
        _ = auditedShelves(in: ["B2"], into: &log)
        #expect(log == ["shift start", "open B2", "shelf 2", "close B2"])
    }

    @Test("writes nothing at all when there are no codes")
    func writesNothingForEmptyInput() {
        var log: [String] = []
        #expect(auditedShelves(in: [], into: &log) == [])
        #expect(log == [])
    }
}

// MARK: - 5. shelfResults(for:)

@Suite("08.5 shelfResults(for:)")
struct ShelfResultsTests {
    @Test("returns exactly one outcome per code, failures included")
    func returnsOneOutcomePerCode() {
        #expect(shelfResults(for: ["A1", "!!", "Z9"]).count == 3)
        #expect(shelfResults(for: ["A1"]).count == 1)
    }

    @Test("carries the shelf number in the success case")
    func carriesShelfNumberOnSuccess() throws {
        let outcomes = shelfResults(for: ["B14", "A7"])
        try #require(outcomes.count == 2)
        #expect(try outcomes[0].get() == 14)
        #expect(try outcomes[1].get() == 7)
    }

    @Test("keeps the failure instead of discarding it")
    func keepsTheFailure() {
        #expect(shelfResults(for: ["!!"]) == [.failure(.malformed("!!"))])
    }

    @Test("distinguishes the two failure cases in the stored error")
    func distinguishesStoredFailures() {
        #expect(shelfResults(for: ["Z9", "!!"]) == [
            .failure(.unknownAisle("Z")),
            .failure(.malformed("!!")),
        ])
    }

    @Test("keeps successes and failures in the order the codes arrived")
    func preservesOrderAcrossMixedOutcomes() {
        #expect(shelfResults(for: ["A1", "!!", "C3"]) == [
            .success(1),
            .failure(.malformed("!!")),
            .success(3),
        ])
    }

    @Test("returns nothing for an empty input")
    func returnsNothingForEmptyInput() {
        #expect(shelfResults(for: []) == [])
    }
}

// MARK: - 6. firstShelf(in:using:)

/// An error type this chapter's exercises never mention, used to prove that
/// `firstShelf(in:using:)` propagates the caller's error type rather than
/// one it chose for itself.
private enum ForkliftError: Error, Equatable {
    case batteryFlat
}

@Suite("08.6 firstShelf(in:using:)")
struct FirstShelfTests {
    @Test("returns nothing for an empty list of codes")
    func returnsNothingForEmptyInput() throws {
        #expect(try firstShelf(in: [], using: shelfNumber(of:)) == nil)
    }

    @Test("answers with the first code, not the last and not the smallest")
    func answersWithTheFirstCode() throws {
        #expect(try firstShelf(in: ["C9", "A1"], using: shelfNumber(of:)) == 9)
        #expect(try firstShelf(in: ["A1", "C9"], using: shelfNumber(of:)) == 1)
    }

    @Test("consults the lookup once, however long the list is")
    func consultsTheLookupOnce() {
        var calls = 0
        let shelf = firstShelf(in: ["A9", "B7", "C3"]) { code in
            calls += 1
            return Int(code.dropFirst()) ?? -1
        }
        #expect(shelf == 9)
        #expect(calls == 1)
    }

    @Test("does not consult the lookup at all when there is nothing to look up")
    func consultsTheLookupNeverWhenEmpty() {
        var calls = 0
        _ = firstShelf(in: []) { code in
            calls += 1
            return code.count
        }
        #expect(calls == 0)
    }

    @Test("propagates the caller's own error type unchanged")
    func propagatesCallersErrorType() {
        #expect(throws: ForkliftError.batteryFlat) {
            try firstShelf(in: ["A1"]) { (_: String) throws(ForkliftError) -> Int in
                throw ForkliftError.batteryFlat
            }
        }
    }

    @Test("propagates the bin error when the built in lookup is the one failing")
    func propagatesBinError() {
        #expect(throws: BinError.unknownAisle("Z")) {
            try firstShelf(in: ["Z9", "A1"], using: shelfNumber(of:))
        }
    }
}
