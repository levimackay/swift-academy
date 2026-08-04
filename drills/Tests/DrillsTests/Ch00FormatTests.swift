import Testing

@testable import Drills

// Four assertions, four distinct expected values, so no constant return can
// pass. Two of them catch a plausible first pass rather than an empty one:
// a limit below one, and a limit that is itself even.
@Suite("Ch00Format")
struct Ch00FormatDrills {
    @Test("sums the even numbers up to an odd limit")
    func oddLimit() {
        #expect(formatDemoEvenSum(upTo: 9) == 20)
    }

    @Test("includes a limit that is itself even")
    func evenLimit() {
        #expect(formatDemoEvenSum(upTo: 10) == 30)
    }

    @Test("an empty range sums to zero")
    func belowOne() {
        #expect(formatDemoEvenSum(upTo: 0) == 0)
        #expect(formatDemoEvenSum(upTo: -4) == 0)
    }

    @Test("the smallest nonempty even sum")
    func two() {
        #expect(formatDemoEvenSum(upTo: 2) == 2)
    }
}
