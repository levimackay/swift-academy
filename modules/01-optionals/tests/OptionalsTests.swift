import Testing
@testable import Chapter01

// Test names describe the behavior, not the exercise number, so a red line
// in the output tells you what is wrong without opening this file.

@Suite("01.1 displayName(for:fallback:)")
struct DisplayNameTests {
    @Test("uses the nickname when it holds text")
    func usesNickname() {
        #expect(displayName(for: "Lev", fallback: "anonymous") == "Lev")
    }

    @Test("uses the fallback when the nickname is absent")
    func usesFallbackWhenAbsent() {
        #expect(displayName(for: nil, fallback: "anonymous") == "anonymous")
    }

    @Test("treats a present but empty nickname as absent")
    func treatsEmptyAsAbsent() {
        #expect(displayName(for: "", fallback: "friend") == "friend")
    }

    @Test("does not trim, so a single space is a real nickname")
    func doesNotTrim() {
        #expect(displayName(for: " ", fallback: "friend") == " ")
    }
}

@Suite("01.2 firstInitial(of:)")
struct FirstInitialTests {
    @Test("returns the first character of a name")
    func returnsFirstCharacter() {
        #expect(firstInitial(of: "Levi") == "L")
    }

    @Test("returns nil when the name is absent")
    func nilWhenAbsent() {
        #expect(firstInitial(of: nil) == nil)
    }

    @Test("returns nil when the name is present but empty")
    func nilWhenEmpty() {
        #expect(firstInitial(of: "") == nil)
    }

    @Test("treats a multi scalar emoji as a single character")
    func multiScalarGraphemeIsOneCharacter() {
        #expect(firstInitial(of: "👨‍👩‍👧 Ada") == "👨‍👩‍👧")
    }
}

@Suite("01.3 parsedPort(from:)")
struct ParsedPortTests {
    @Test("parses a port inside the valid range")
    func parsesValidPort() {
        #expect(parsedPort(from: "8080") == 8080)
    }

    @Test("accepts the highest valid port")
    func acceptsUpperBound() {
        #expect(parsedPort(from: "65535") == 65535)
    }

    @Test("rejects one past the highest valid port")
    func rejectsAboveUpperBound() {
        #expect(parsedPort(from: "65536") == nil)
    }

    @Test("rejects zero, because port zero is not assignable")
    func rejectsZero() {
        #expect(parsedPort(from: "0") == nil)
    }

    @Test("rejects a negative number")
    func rejectsNegative() {
        #expect(parsedPort(from: "-1") == nil)
    }

    @Test("returns nil for text that is not a number")
    func nilForNonNumericText() {
        #expect(parsedPort(from: "http") == nil)
    }

    @Test("returns nil for absent text")
    func nilForAbsentText() {
        #expect(parsedPort(from: nil) == nil)
    }
}

@Suite("01.4 label(for:)")
struct LabelTests {
    @Test("calls an absent score unrated")
    func absentIsUnrated() {
        #expect(label(for: nil) == "unrated")
    }

    @Test("calls a negative score invalid")
    func negativeIsInvalid() {
        #expect(label(for: -1) == "invalid")
    }

    @Test("calls zero zero, not rated 0")
    func zeroIsItsOwnCase() {
        #expect(label(for: 0) == "zero")
    }

    @Test("interpolates any other score")
    func otherScoresAreInterpolated() {
        #expect(label(for: 42) == "rated 42")
    }
}

@Suite("01.5 absenceKind(of:)")
struct AbsenceKindTests {
    @Test("reports the outer none as missing")
    func outerNoneIsMissing() {
        #expect(absenceKind(of: nil) == "missing")
    }

    @Test("reports a present inner none as null")
    func innerNoneIsNull() {
        #expect(absenceKind(of: .some(nil)) == "null")
    }

    @Test("reports a fully present value")
    func fullyPresentValue() {
        #expect(absenceKind(of: .some(.some(7))) == "value 7")
    }

    @Test("a plain literal promotes through both levels")
    func literalPromotesThroughBothLevels() {
        #expect(absenceKind(of: 7) == "value 7")
    }
}

@Suite("01.6 summarize(_:)")
struct SummarizeTests {
    @Test("reports nothing for an empty batch, without dividing by zero")
    func emptyBatch() {
        let report = summarize([])
        #expect(report == Report(reported: 0, missing: 0, warmest: nil, averageCelsius: nil))
    }

    @Test("counts missing readings separately from reported ones")
    func countsBothKinds() {
        let readings = [
            Reading(station: "pier", celsius: 4.0),
            Reading(station: "dock", celsius: nil),
            Reading(station: "buoy", celsius: -1.0),
        ]
        let report = summarize(readings)
        #expect(report.reported == 2)
        #expect(report.missing == 1)
    }

    @Test("has no average and no warmest when every reading is missing")
    func allMissing() {
        let readings = [
            Reading(station: "pier", celsius: nil),
            Reading(station: "dock", celsius: nil),
        ]
        let report = summarize(readings)
        #expect(report == Report(reported: 0, missing: 2, warmest: nil, averageCelsius: nil))
    }

    @Test("averages only the readings that carried a value")
    func averagesReportedOnly() {
        let readings = [
            Reading(station: "pier", celsius: 1.0),
            Reading(station: "dock", celsius: nil),
            Reading(station: "buoy", celsius: 2.0),
        ]
        #expect(summarize(readings).averageCelsius == 1.5)
    }

    @Test("finds the warmest station when every temperature is below zero")
    func warmestAmongNegatives() {
        let readings = [
            Reading(station: "pier", celsius: -10.0),
            Reading(station: "dock", celsius: -3.5),
            Reading(station: "buoy", celsius: -40.0),
        ]
        #expect(summarize(readings).warmest == "dock")
    }

    @Test("breaks a tie for warmest in favor of the earlier reading")
    func tieGoesToTheEarlierReading() {
        let readings = [
            Reading(station: "pier", celsius: 12.0),
            Reading(station: "dock", celsius: 12.0),
        ]
        #expect(summarize(readings).warmest == "pier")
    }
}
