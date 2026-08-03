import Testing
@testable import ValuesAndOptionals

@Test func safeDivideReturnsQuotient() {
    #expect(Problems.safeDivide(10, by: 2) == 5)
    #expect(Problems.safeDivide(7, by: 2) == 3)
    #expect(Problems.safeDivide(-9, by: 3) == -3)
}

@Test func safeDivideByZeroIsNil() {
    #expect(Problems.safeDivide(10, by: 0) == nil)
}

@Test func firstNonEmptyFindsIt() {
    #expect(Problems.firstNonEmpty(["", "", "swift", "python"]) == "swift")
    #expect(Problems.firstNonEmpty(["first"]) == "first")
}

@Test func firstNonEmptyIsNilWhenAllEmpty() {
    #expect(Problems.firstNonEmpty([]) == nil)
    #expect(Problems.firstNonEmpty(["", ""]) == nil)
}

@Test func parseAgeAcceptsValidAges() {
    #expect(Problems.parseAge("0") == 0)
    #expect(Problems.parseAge("21") == 21)
    #expect(Problems.parseAge("130") == 130)
}

@Test func parseAgeRejectsInvalidInput() {
    #expect(Problems.parseAge("abc") == nil)
    #expect(Problems.parseAge("") == nil)
    #expect(Problems.parseAge("-1") == nil)
    #expect(Problems.parseAge("131") == nil)
    #expect(Problems.parseAge("21.5") == nil)
}

@Test func describeHandlesBothCases() {
    #expect(Problems.describe(42) == "got 42")
    #expect(Problems.describe(0) == "got 0")
    #expect(Problems.describe(nil) == "got nothing")
}

@Test func initialsFromNames() {
    #expect(Problems.initials(from: "levi mackay") == "LM")
    #expect(Problems.initials(from: "Ada Lovelace") == "AL")
    #expect(Problems.initials(from: "  ada  lovelace ") == "AL")
    #expect(Problems.initials(from: "cher") == "C")
    #expect(Problems.initials(from: "") == "")
}

@Test func clampConstrainsValue() {
    #expect(Problems.clamp(5, lower: 0, upper: 10) == 5)
    #expect(Problems.clamp(-3, lower: 0, upper: 10) == 0)
    #expect(Problems.clamp(99, lower: 0, upper: 10) == 10)
    #expect(Problems.clamp(7, lower: 7, upper: 7) == 7)
}
