import Testing

@testable import Chapter13

@MainActor
@Suite("13 TapCounter")
struct TapCounterTests {
    @Test("count starts at zero and rises by one per tap")
    func countRisesOncePerTap() {
        let counter = TapCounter(limit: 10)
        #expect(counter.count == 0)
        counter.tap()
        counter.tap()
        counter.tap()
        #expect(counter.count == 3)
    }

    @Test("tap stops at the limit instead of passing it")
    func tapStopsAtTheLimit() {
        let counter = TapCounter(limit: 2)
        for _ in 0..<5 { counter.tap() }
        #expect(counter.count == 2)
    }

    @Test("isAtLimit is true only once a further tap would do nothing")
    func isAtLimitTracksTheRemainingTaps() {
        let counter = TapCounter(limit: 2)
        #expect(counter.isAtLimit == false)
        counter.tap()
        #expect(counter.isAtLimit == false)
        counter.tap()
        #expect(counter.isAtLimit == true)
    }

    @Test("a counter with a limit of zero is at its limit before the first tap")
    func zeroLimitCounterIsImmediatelyAtItsLimit() {
        let counter = TapCounter(limit: 0)
        #expect(counter.isAtLimit == true)
        counter.tap()
        #expect(counter.count == 0)
    }

    @Test("reset returns the count to zero and leaves the limit alone")
    func resetClearsTheCountOnly() {
        let counter = TapCounter(limit: 2)
        counter.tap()
        counter.tap()
        counter.reset()
        #expect(counter.count == 0)
        #expect(counter.limit == 2)
        counter.tap()
        #expect(counter.count == 1)
    }
}
