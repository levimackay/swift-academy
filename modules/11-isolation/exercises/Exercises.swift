// Chapter 11 exercises. Fill in the bodies marked TODO. Do not change the
// declarations, the types above them, or the test file: the suite in
// ../tests is what grades you and it calls these exact signatures.
//
// Run: swift test --filter Chapter11Tests
//
// Nothing here needs a lock, a queue, or a semaphore. If you reach for one,
// the isolation is in the wrong place.

// MARK: - 1. An actor owns its state

/// A seating chart that two ticket desks share. Seat labels are compared
/// without regard to case, so `4a` and `4A` are the same seat.
public actor SeatBook {
    private var booked: Set<String> = []

    public init() {}

    /// Takes `seat` when it is free. Returns `true` only for the call that
    /// actually took it, and `false` for every later attempt on the same
    /// seat.
    public func reserve(_ seat: String) -> Bool {
        false  // TODO: take the seat, and report whether this call took it
    }

    /// Every seat currently booked, uppercased, in ascending order.
    public func bookedSeats() -> [String] {
        []  // TODO: report the booked seats
    }
}

// MARK: - 2. Invariants have to hold at every await

/// A balance that an auditor is allowed to inspect, and to spend from,
/// while the withdrawal that called it is still suspended.
///
/// The audit hook is `async`, so awaiting it releases the actor. Whatever
/// this type promises about `available` has to be true at that moment, not
/// only at the end of the method.
public actor GuardedLedger {
    private var available: Int
    private var onAudit: (@Sendable (Int) async -> Void)?

    public init(available: Int) {
        self.available = available
    }

    /// Installs the hook run once per successful withdrawal, with the
    /// amount that was withdrawn.
    public func auditWith(_ audit: @escaping @Sendable (Int) async -> Void) {
        onAudit = audit
    }

    /// What is left. Never negative, at any point any caller can observe.
    public func availableFunds() -> Int {
        available
    }

    /// Withdraws `amount` and returns `true`, or refuses and returns
    /// `false`. It refuses when `amount` is not positive, and when
    /// `amount` is more than is available. A successful withdrawal runs the
    /// audit hook exactly once, after which `available` must already be
    /// correct for every other caller.
    public func withdraw(_ amount: Int) async -> Bool {
        false  // TODO: withdraw, audit, and never overdraw
    }
}

// MARK: - 3. Global actor isolation, and stepping out of it

/// A screen that only the main actor may touch, except for the one member
/// that provably needs nothing from it.
@MainActor
public final class Dashboard {
    /// Fixed at init, so it belongs to no isolation domain.
    public nonisolated let deviceID: String

    public private(set) var marquee = ""

    private var shown: [String] = []

    public init(deviceID: String) {
        self.deviceID = deviceID
    }

    /// Makes `text` the marquee and remembers it.
    public func show(_ text: String) {
        // TODO: set the marquee and record it
    }

    /// The most recent marquee texts, newest first, at most `keep` of them.
    /// A `keep` of zero or less yields an empty array.
    public func recent(_ keep: Int) -> [String] {
        []  // TODO: newest first, capped at keep
    }

    /// `"dash-"` followed by the device id. Callable from any isolation
    /// domain with no `await`, which is only possible if it reads nothing
    /// the main actor owns.
    public nonisolated func tag() -> String {
        ""  // TODO: build the tag without touching isolated state
    }
}

// MARK: - 4. Handing a value across a boundary

/// A snapshot that is safe to send anywhere, because every part of it is.
public struct ShipmentManifest: Sendable, Equatable {
    public let trackingID: String
    public let stops: [String]
    public let scanCount: Int

    public init(trackingID: String, stops: [String], scanCount: Int) {
        self.trackingID = trackingID
        self.stops = stops
        self.scanCount = scanCount
    }
}

/// Mutable state behind an actor, plus one immutable field outside it.
public actor ShipmentTracker {
    public nonisolated let trackingID: String

    private var scanned: [String] = []

    public init(trackingID: String) {
        self.trackingID = trackingID
    }

    /// Records that the parcel was seen at `location`. The same location
    /// can be scanned more than once, and every scan counts.
    public func scan(_ location: String) {
        // TODO: record the scan
    }

    /// A sendable view of this tracker. `stops` holds each distinct
    /// location once, in the order it was first scanned. `scanCount`
    /// counts every scan, repeats included.
    public func manifest() -> ShipmentManifest {
        ShipmentManifest(trackingID: "", stops: [], scanCount: 0)  // TODO
    }
}
