import Foundation
import Testing

@testable import Chapter14

/// The failure the fake fetch throws. It is the suite's own error type, which
/// is what a test is allowed to assert on: the toolchain's wording for
/// anything else drifts between releases.
private struct RadioOff: LocalizedError {
    var errorDescription: String? { "the radio is off" }
}

/// Somewhere for the injected closure to record what it saw. It is on the
/// main actor because the model is, so reading the model's state from inside
/// the fetch is a hop rather than a race.
@MainActor
private final class Ledger {
    var list: EntryList?
    var statesDuringFetch: [LoadState] = []
    var calls = 0
}

@MainActor
@Suite("14 Injected loading")
struct EntryListTests {
    private let milk = Entry(id: UUID(), title: "buy milk")
    private let oats = Entry(id: UUID(), title: "buy oats")

    @Test("a fetch that finds rows lands in loaded, in the order it returned them")
    func aFetchThatFindsRowsLandsInLoaded() async {
        let first = milk
        let second = oats
        let list = EntryList(fetch: { [first, second] })
        await list.reload()
        #expect(list.state == .loaded([milk, oats]))
        #expect(list.state != .loaded([oats, milk]))
    }

    @Test("a fetch that finds nothing is a different screen from a fetch that found rows")
    func aFetchThatFindsNothingIsEmpty() async {
        let list = EntryList(fetch: { [] })
        await list.reload()
        #expect(list.state == .empty)
    }

    @Test("a fetch that throws reports what went wrong")
    func aFetchThatThrowsReportsIt() async {
        let list = EntryList(fetch: { throw RadioOff() })
        await list.reload()
        #expect(list.state == .failed("the radio is off"))
    }

    @Test("the model says it is working before it starts waiting")
    func theModelAnnouncesWorkBeforeAwaiting() async {
        let ledger = Ledger()
        let found = milk
        let list = EntryList(fetch: {
            await MainActor.run {
                if let observed = ledger.list { ledger.statesDuringFetch.append(observed.state) }
            }
            return [found]
        })
        ledger.list = list
        #expect(list.state == .idle)
        await list.reload()
        #expect(ledger.statesDuringFetch == [.loading])
        #expect(list.state == .loaded([milk]))
    }

    @Test("one reload runs the injected work exactly once")
    func oneReloadRunsTheWorkOnce() async {
        let ledger = Ledger()
        let list = EntryList(fetch: {
            await MainActor.run { ledger.calls += 1 }
            return []
        })
        await list.reload()
        #expect(ledger.calls == 1)
        await list.reload()
        #expect(ledger.calls == 2)
    }

    @Test("a failure is not sticky, and a later success clears it")
    func aFailureIsNotSticky() async {
        let ledger = Ledger()
        let recovered = oats
        let list = EntryList(fetch: {
            let attempt = await MainActor.run { () -> Int in
                ledger.calls += 1
                return ledger.calls
            }
            if attempt == 1 { throw RadioOff() }
            return [recovered]
        })
        await list.reload()
        #expect(list.state == .failed("the radio is off"))
        await list.reload()
        #expect(list.state == .loaded([oats]))
    }
}
