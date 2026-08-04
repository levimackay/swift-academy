import Testing
@testable import Chapter02

// Test names describe the behavior, not the exercise number, so a red line in
// the output tells you what is wrong without opening this file.

@Suite("02.1 initials(of:separatedBy:)")
struct InitialsTests {
    @Test("joins one initial per word with a dot by default")
    func joinsWithDefaultSeparator() {
        #expect(initials(of: "Levi Mackay") == "L.M")
    }

    @Test("uses the separator it was handed")
    func usesGivenSeparator() {
        #expect(initials(of: "Ada Lovelace", separatedBy: "-") == "A-L")
    }

    @Test("uppercases initials that arrive lowercase")
    func uppercasesEachInitial() {
        #expect(initials(of: "grace brewster hopper") == "G.B.H")
    }

    @Test("collapses runs of spaces instead of emitting empty initials")
    func collapsesRunsOfSpaces() {
        #expect(initials(of: "  ada   lovelace ") == "A.L")
    }

    @Test("returns a bare initial for a single word, with no separator")
    func singleWordHasNoSeparator() {
        #expect(initials(of: "prince") == "P")
    }

    @Test("returns the empty string when there are no words at all")
    func noWordsProducesEmptyString() {
        #expect(initials(of: "   ") == "")
        #expect(initials(of: "") == "")
    }
}

@Suite("02.2 spread(of:)")
struct SpreadTests {
    @Test("measures the distance between the largest and smallest value")
    func measuresDistance() {
        #expect(spread(of: 3, 9, 4) == 6)
    }

    @Test("measures a different distance for a different set")
    func measuresAnotherDistance() {
        #expect(spread(of: 100, 40) == 60)
    }

    @Test("handles values that are all negative")
    func handlesNegatives() {
        #expect(spread(of: -10, -3) == 7)
    }

    @Test("a single value spans nothing")
    func singleValueSpansNothing() {
        #expect(spread(of: 5) == 0)
    }

    @Test("no values at all is a legal call and spans nothing")
    func zeroArgumentsIsLegal() {
        #expect(spread() == 0)
    }
}

@Suite("02.3 clamp(_:into:)")
struct ClampTests {
    @Test("raises a value that sits below the range")
    func raisesBelowRange() {
        var value = -5
        clamp(&value, into: 0...10)
        #expect(value == 0)
    }

    @Test("lowers a value that sits above the range")
    func lowersAboveRange() {
        var value = 42
        clamp(&value, into: 0...10)
        #expect(value == 10)
    }

    @Test("leaves a value that is already inside the range alone")
    func leavesInsideValueAlone() {
        var value = 7
        clamp(&value, into: 0...10)
        #expect(value == 7)
    }

    @Test("treats both bounds as inside the range")
    func boundsAreInside() {
        var lower = 3
        var upper = 8
        clamp(&lower, into: 3...8)
        clamp(&upper, into: 3...8)
        #expect(lower == 3)
        #expect(upper == 8)
    }

    @Test("works on a range holding exactly one value")
    func singleValueRange() {
        var value = 99
        clamp(&value, into: 4...4)
        #expect(value == 4)
    }

    @Test("clamps into a range that is entirely negative")
    func negativeRange() {
        var value = 0
        clamp(&value, into: (-9)...(-2))
        #expect(value == -2)
    }
}

@Suite("02.4 makeAccumulator(startingAt:)")
struct MakeAccumulatorTests {
    @Test("returns the running total after each call")
    func returnsRunningTotal() {
        let add = makeAccumulator()
        #expect(add(3) == 3)
        #expect(add(4) == 7)
        #expect(add(-10) == -3)
    }

    @Test("starts from the value it was given")
    func startsFromGivenValue() {
        let add = makeAccumulator(startingAt: 100)
        #expect(add(1) == 101)
        #expect(add(1) == 102)
    }

    @Test("two accumulators never share a total")
    func accumulatorsAreIndependent() {
        let left = makeAccumulator()
        let right = makeAccumulator(startingAt: 50)
        #expect(left(5) == 5)
        #expect(right(5) == 55)
        #expect(left(5) == 10)
        #expect(right(5) == 60)
    }
}

@Suite("02.5 either(_:or:)")
struct EitherTests {
    @Test("returns the preferred value when there is one")
    func returnsPreferred() {
        #expect(either(7, or: 99) == 7)
    }

    @Test("returns the fallback when the preferred value is absent")
    func returnsFallback() {
        #expect(either(nil, or: 99) == 99)
    }

    @Test("never evaluates the fallback expression when it is not needed")
    func fallbackIsNotEvaluatedWhenUnused() {
        var evaluations = 0
        func expensive() -> Int {
            evaluations += 1
            return -1
        }
        let result = either(7, or: expensive())
        #expect(result == 7)
        #expect(evaluations == 0)
    }

    @Test("evaluates the fallback expression exactly once when it is needed")
    func fallbackIsEvaluatedOnce() {
        var evaluations = 0
        func expensive() -> Int {
            evaluations += 1
            return 5
        }
        let result = either(nil, or: expensive())
        #expect(result == 5)
        #expect(evaluations == 1)
    }
}

@Suite("02.6 Dispatcher")
struct DispatcherTests {
    @Test("returns nil for a name nobody registered")
    func unknownNameReturnsNil() {
        let dispatcher = Dispatcher()
        #expect(dispatcher.send("double", value: 4) == nil)
    }

    @Test("routes a value to the handler registered under that name")
    func routesToTheRightHandler() {
        var dispatcher = Dispatcher()
        dispatcher.on("double") { $0 * 2 }
        dispatcher.on("negate") { -$0 }
        #expect(dispatcher.send("double", value: 4) == 8)
        #expect(dispatcher.send("negate", value: 4) == -4)
    }

    @Test("keeps the later handler when a name is registered twice")
    func laterRegistrationWins() {
        var dispatcher = Dispatcher()
        dispatcher.on("apply") { $0 + 1 }
        dispatcher.on("apply") { $0 + 1000 }
        #expect(dispatcher.send("apply", value: 1) == 1001)
        #expect(dispatcher.registeredNames == ["apply"])
    }

    @Test("lists every registered name in ascending order")
    func listsNamesInOrder() {
        var dispatcher = Dispatcher()
        dispatcher.on("zulu") { $0 }
        dispatcher.on("alpha") { $0 }
        dispatcher.on("mike") { $0 }
        #expect(dispatcher.registeredNames == ["alpha", "mike", "zulu"])
    }

    @Test("lists nothing before anything is registered")
    func listsNothingWhenEmpty() {
        #expect(Dispatcher().registeredNames == [])
    }

    @Test("a stored handler sees a later write to a variable it captured")
    func storedHandlerCapturesTheVariable() {
        var offset = 10
        var dispatcher = Dispatcher()
        dispatcher.on("shift") { $0 + offset }
        offset = 1000
        #expect(dispatcher.send("shift", value: 1) == 1001)
    }

    @Test("distinguishes the empty string from an unregistered name")
    func emptyStringIsAnOrdinaryName() {
        var dispatcher = Dispatcher()
        dispatcher.on("") { $0 * 3 }
        #expect(dispatcher.send("", value: 2) == 6)
        #expect(dispatcher.send(" ", value: 2) == nil)
    }
}
