import Testing

@testable import Chapter11

// MARK: - 1. An actor owns its state

@Suite("11 seat book")
struct SeatBookTests {
    @Test("the first caller takes the seat and the second is refused")
    func firstCallerWins() async {
        let book = SeatBook()
        #expect(await book.reserve("4A") == true)
        #expect(await book.reserve("4A") == false)
    }

    @Test("seat labels differing only in case are the same seat")
    func seatLabelsAreCaseInsensitive() async {
        let book = SeatBook()
        #expect(await book.reserve("12b") == true)
        #expect(await book.reserve("12B") == false)
        #expect(await book.bookedSeats() == ["12B"])
    }

    @Test("booked seats come back uppercased and sorted, not in booking order")
    func bookedSeatsAreSortedAndUppercased() async {
        let book = SeatBook()
        _ = await book.reserve("9c")
        _ = await book.reserve("1a")
        _ = await book.reserve("4A")
        #expect(await book.bookedSeats() == ["1A", "4A", "9C"])
    }

    @Test("an untouched chart has no booked seats")
    func emptyChartHasNoSeats() async {
        let book = SeatBook()
        #expect(await book.bookedSeats() == [])
    }
}

// MARK: - 2. Invariants have to hold at every await

/// Everything the audit hook wants to remember. It is an actor because the
/// hook is `@Sendable` and runs in whatever domain the ledger releases it
/// into.
actor AuditNotes {
    private(set) var calls = 0
    private(set) var audited: [Int] = []
    private(set) var observedFunds: [Int] = []
    private(set) var reentrantResults: [Bool] = []
    private var alreadyReentered = false

    func firstCall() -> Bool {
        if alreadyReentered { return false }
        alreadyReentered = true
        return true
    }

    func record(_ amount: Int) {
        calls += 1
        audited.append(amount)
    }

    func observe(_ funds: Int) {
        observedFunds.append(funds)
    }

    func addReentrant(_ result: Bool) {
        reentrantResults.append(result)
    }
}

@Suite("11 guarded ledger")
struct GuardedLedgerTests {
    @Test("a withdrawal that fits succeeds and one that does not is refused")
    func refusesWhatItCannotCover() async {
        let ledger = GuardedLedger(available: 100)
        #expect(await ledger.withdraw(80) == true)
        #expect(await ledger.availableFunds() == 20)
        #expect(await ledger.withdraw(80) == false)
        #expect(await ledger.availableFunds() == 20)
    }

    @Test("zero and negative amounts are refused and change nothing")
    func refusesNonPositiveAmounts() async {
        let ledger = GuardedLedger(available: 50)
        let notes = AuditNotes()
        await ledger.auditWith { amount in await notes.record(amount) }
        #expect(await ledger.withdraw(0) == false)
        #expect(await ledger.withdraw(-10) == false)
        #expect(await ledger.availableFunds() == 50)
        #expect(await notes.calls == 0)
    }

    @Test("the audit hook runs once per successful withdrawal with its amount")
    func auditsEverySuccessOnce() async {
        let ledger = GuardedLedger(available: 100)
        let notes = AuditNotes()
        await ledger.auditWith { amount in await notes.record(amount) }
        _ = await ledger.withdraw(30)
        _ = await ledger.withdraw(1000)
        _ = await ledger.withdraw(7)
        #expect(await notes.calls == 2)
        #expect(await notes.audited == [30, 7])
    }

    @Test("the balance an auditor sees mid withdrawal is already the new one")
    func fundsAreSettledBeforeTheAuditRuns() async {
        let ledger = GuardedLedger(available: 100)
        let notes = AuditNotes()
        await ledger.auditWith { _ in await notes.observe(await ledger.availableFunds()) }
        #expect(await ledger.withdraw(80) == true)
        #expect(await notes.observedFunds == [20])
    }

    @Test("a withdrawal issued from inside the audit hook cannot overdraw")
    func reentrantWithdrawalCannotOverdraw() async {
        let ledger = GuardedLedger(available: 100)
        let notes = AuditNotes()
        await ledger.auditWith { _ in
            if await notes.firstCall() {
                await notes.addReentrant(await ledger.withdraw(80))
            }
        }
        #expect(await ledger.withdraw(80) == true)
        #expect(await notes.reentrantResults == [false])
        #expect(await ledger.availableFunds() == 20)
    }
}

// MARK: - 3. Global actor isolation, and stepping out of it

@Suite("11 dashboard")
@MainActor
struct DashboardTests {
    @Test("showing text replaces the marquee")
    func marqueeIsTheLastThingShown() {
        let dashboard = Dashboard(deviceID: "kiosk-2")
        dashboard.show("booting")
        #expect(dashboard.marquee == "booting")
        dashboard.show("ready")
        #expect(dashboard.marquee == "ready")
    }

    @Test("recent marquee texts come back newest first")
    func recentIsNewestFirst() {
        let dashboard = Dashboard(deviceID: "kiosk-2")
        dashboard.show("one")
        dashboard.show("two")
        dashboard.show("three")
        #expect(dashboard.recent(2) == ["three", "two"])
        #expect(dashboard.recent(9) == ["three", "two", "one"])
    }

    @Test("asking for zero or fewer marquee texts yields none")
    func recentClampsAtZero() {
        let dashboard = Dashboard(deviceID: "kiosk-2")
        dashboard.show("one")
        #expect(dashboard.recent(0) == [])
        #expect(dashboard.recent(-3) == [])
    }
}

@Suite("11 nonisolated tag")
struct DashboardTagTests {
    /// This suite is deliberately not `@MainActor`. If `tag()` reads
    /// anything the main actor owns, the exercise file stops compiling.
    @Test("the tag is readable off the main actor with no await")
    func tagNeedsNoIsolation() async {
        let dashboard = await Dashboard(deviceID: "kiosk-2")
        #expect(dashboard.tag() == "dash-kiosk-2")
        let other = await Dashboard(deviceID: "till-11")
        #expect(other.tag() == "dash-till-11")
    }
}

// MARK: - 4. Handing a value across a boundary

@Suite("11 shipment manifest")
struct ShipmentTrackerTests {
    @Test("a repeated location appears once in stops and twice in the count")
    func repeatsCountButDoNotRepeatAsStops() async {
        let tracker = ShipmentTracker(trackingID: "SB-1")
        await tracker.scan("dock")
        await tracker.scan("hub")
        await tracker.scan("dock")
        let manifest = await tracker.manifest()
        #expect(manifest.stops == ["dock", "hub"])
        #expect(manifest.scanCount == 3)
        #expect(manifest.trackingID == "SB-1")
    }

    @Test("stops keep first seen order rather than any sorted order")
    func stopsKeepFirstSeenOrder() async {
        let tracker = ShipmentTracker(trackingID: "SB-2")
        for stop in ["zulu", "alpha", "zulu", "mike", "alpha"] {
            await tracker.scan(stop)
        }
        let manifest = await tracker.manifest()
        #expect(manifest.stops == ["zulu", "alpha", "mike"])
        #expect(manifest.scanCount == 5)
    }

    @Test("an unscanned parcel still reports its tracking id")
    func unscannedParcelIsEmptyButIdentified() async {
        let tracker = ShipmentTracker(trackingID: "SB-3")
        let manifest = await tracker.manifest()
        #expect(manifest == ShipmentManifest(trackingID: "SB-3", stops: [], scanCount: 0))
    }

    @Test("a manifest survives being sent into another isolation domain")
    func manifestCrossesABoundaryUnchanged() async {
        let tracker = ShipmentTracker(trackingID: "SB-4")
        await tracker.scan("yard")
        await tracker.scan("yard")
        let manifest = await tracker.manifest()
        let echoed = await Task { manifest }.value
        #expect(echoed == manifest)
        #expect(echoed.scanCount == 2)
        #expect(echoed.stops == ["yard"])
    }
}
