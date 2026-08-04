import SwiftUI
import Testing

@testable import Chapter13

/// Stands in for whatever owns the state in a real screen. The test builds a
/// binding over this box, hands it to `Percent.binding(over:)`, and then
/// checks the box to see whether the write travelled the whole way back.
@MainActor
private final class Source {
    var fraction: Double

    init(_ fraction: Double) {
        self.fraction = fraction
    }

    var binding: Binding<Double> {
        Binding(get: { self.fraction }, set: { self.fraction = $0 })
    }
}

@MainActor
@Suite("13 Percent binding")
struct PercentBindingTests {
    @Test("reading reports the fraction as a whole percent")
    func readingReportsAWholePercent() {
        #expect(Percent.binding(over: Source(0.25).binding).wrappedValue == 25)
        #expect(Percent.binding(over: Source(0.5).binding).wrappedValue == 50)
    }

    @Test("reading rounds to the nearest percent rather than truncating")
    func readingRoundsRatherThanTruncates() {
        #expect(Percent.binding(over: Source(0.256).binding).wrappedValue == 26)
        #expect(Percent.binding(over: Source(0.014).binding).wrappedValue == 1)
    }

    @Test("reading clamps a fraction that sits outside zero to one")
    func readingClampsOutOfRangeFractions() {
        #expect(Percent.binding(over: Source(1.4).binding).wrappedValue == 100)
        #expect(Percent.binding(over: Source(-0.2).binding).wrappedValue == 0)
    }

    @Test("writing travels back to the source of truth")
    func writingReachesTheSource() {
        let source = Source(0.1)
        let percent = Percent.binding(over: source.binding)
        percent.wrappedValue = 40
        #expect(abs(source.fraction - 0.4) < 1e-9)
        percent.wrappedValue = 75
        #expect(abs(source.fraction - 0.75) < 1e-9)
    }

    @Test("writing clamps before the value reaches the source")
    func writingClampsBeforeItReachesTheSource() {
        let source = Source(0.5)
        let percent = Percent.binding(over: source.binding)
        percent.wrappedValue = 150
        #expect(abs(source.fraction - 1.0) < 1e-9)
        percent.wrappedValue = -10
        #expect(abs(source.fraction - 0.0) < 1e-9)
    }
}
