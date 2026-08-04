// Chapter 12 exercises. Fill in the bodies marked TODO. Do not change the
// declarations, the types above them, or the test file: the suite in
// ../tests is what grades you and it calls these exact signatures.
//
// Run: swift test --filter Chapter12Tests
//
// Everything above the first MARK is scaffolding, not homework. `CallLog`
// and `StationFeed` exist so the suite can ask a question that a sequential
// implementation cannot answer: how many of these calls were in flight at
// the same moment. Read them, do not edit them.

import Dispatch

// MARK: - Scaffolding you are given

/// Records what a `StationFeed` did, so a test can distinguish work that ran
/// concurrently from work that ran one call after another. An actor because
/// several child tasks write to it at once, which chapter 11 covers.
public actor CallLog {
    private var inFlight = 0
    private var peak = 0
    private var completed: [String] = []
    private var abandoned: [String] = []

    public init() {}

    public func began(_ label: String) {
        inFlight += 1
        peak = max(peak, inFlight)
    }

    public func finished(_ label: String) {
        inFlight -= 1
        completed.append(label)
    }

    public func gaveUp(_ label: String) {
        inFlight -= 1
        abandoned.append(label)
    }

    /// The largest number of calls that overlapped. 1 means nothing ever
    /// overlapped, which is what a chain of sequential awaits produces.
    public var peakInFlight: Int { peak }

    /// Labels of calls that ran to completion, in completion order.
    public var completedLabels: [String] { completed }

    /// Labels of calls whose sleep was interrupted by cancellation.
    public var abandonedLabels: [String] { abandoned }
}

/// A fake weather service. Every call takes a measurable amount of time, so
/// overlapping calls are visible in the log.
public struct StationFeed: Sendable {
    public let log: CallLog

    private let temperatureByStation: [String: Int]
    private let windByStation: [String: Int]
    private let rainfallByStation: [String: Int]
    private let sampleValues: [Int]

    public init(
        temperatures: [String: Int] = [:],
        winds: [String: Int] = [:],
        rainfall: [String: Int] = [:],
        samples: [Int] = []
    ) {
        self.log = CallLog()
        self.temperatureByStation = temperatures
        self.windByStation = winds
        self.rainfallByStation = rainfall
        self.sampleValues = samples
    }

    /// Degrees Celsius, or 0 for a station this feed has never heard of.
    public func temperature(at station: String) async -> Int {
        await measure("temperature:\(station)", sleepingFor: .milliseconds(40))
        return temperatureByStation[station] ?? 0
    }

    /// Wind speed, or 0 for an unknown station.
    public func wind(at station: String) async -> Int {
        await measure("wind:\(station)", sleepingFor: .milliseconds(40))
        return windByStation[station] ?? 0
    }

    /// Millimetres of rain, or 0 for an unknown station.
    public func rainfall(at station: String) async -> Int {
        await measure("rainfall:\(station)", sleepingFor: .milliseconds(40))
        return rainfallByStation[station] ?? 0
    }

    /// The sample at `index`, wrapping around the configured samples. Slow
    /// enough that a cancelled reader stops well short of the end.
    public func sample(_ index: Int) async -> Int {
        await measure("sample:\(index)", sleepingFor: .milliseconds(25))
        guard !sampleValues.isEmpty else { return 0 }
        return sampleValues[index % sampleValues.count]
    }

    /// Like `temperature(at:)`, but throws `FeedError` for a station it does
    /// not know, and it finds out faster than a known station answers.
    public func strictTemperature(at station: String) async throws -> Int {
        let known = temperatureByStation[station] != nil
        let label = "strict:\(station)"
        await log.began(label)
        do {
            try await Task.sleep(for: known ? .milliseconds(80) : .milliseconds(10))
        } catch {
            await log.gaveUp(label)
            throw error
        }
        await log.finished(label)
        guard let reading = temperatureByStation[station] else {
            throw FeedError(station: station)
        }
        return reading
    }

    private func measure(_ label: String, sleepingFor duration: Duration) async {
        await log.began(label)
        do {
            try await Task.sleep(for: duration)
        } catch {
            await log.gaveUp(label)
            return
        }
        await log.finished(label)
    }
}

/// Thrown by `strictTemperature(at:)` for a station the feed does not carry.
public struct FeedError: Error, Equatable {
    public let station: String

    public init(station: String) {
        self.station = station
    }
}

/// A callback based instrument, of the kind you meet at the edge of any real
/// codebase. It answers on some other thread, once, and it knows nothing
/// about `async`.
public final class LegacyBarometer: Sendable {
    private let millibars: Int

    public init(millibars: Int) {
        self.millibars = millibars
    }

    public func read(_ completion: @escaping @Sendable (Int) -> Void) {
        let value = millibars
        DispatchQueue.global().asyncAfter(deadline: .now() + 0.02) {
            completion(value)
        }
    }
}

// MARK: - 1. Two independent fetches, one wait

/// A one line report for `station`, in exactly this shape:
///
///     "Nome: 3C wind 11"
///
/// The temperature and the wind are independent, so the whole call must take
/// about as long as one of them, not both. The suite checks that by asking
/// `feed.log` how many calls overlapped.
public func stationSummary(for station: String, from feed: StationFeed) async -> String {
    ""  // TODO: start both fetches before awaiting either
}

// MARK: - 2. A number of fetches you do not know until run time

/// The total rainfall across every station in `stations`, fetched
/// concurrently. An empty list totals 0, and no station is fetched twice.
///
/// `async let` cannot express this, because the number of children is a
/// property of the argument and not of the source text.
public func totalRainfall(across stations: [String], from feed: StationFeed) async -> Int {
    0  // TODO: one child task per station, summed as the results arrive
}

// MARK: - 3. Stopping when you are asked to

/// Reads samples 0 through `count - 1` in order and returns them.
///
/// Nothing kills this function. If the surrounding task is cancelled it must
/// notice and return the samples it has, which will be fewer than `count`.
/// It never throws: a partial answer is the answer.
public func collectSamples(count: Int, from feed: StationFeed) async -> [Int] {
    []  // TODO: check for cancellation before each read
}

// MARK: - 4. Bringing a callback into async

/// The barometer's reading, awaited rather than delivered to a closure.
///
/// The rule you are implementing has no compiler check behind it: the
/// continuation must be resumed exactly once. Not zero times, not twice.
public func currentPressure(from barometer: LegacyBarometer) async -> Int {
    0  // TODO: suspend until the callback fires, then resume with its value
}

// MARK: - 5. Consuming a stream

/// The first value in `readings` greater than `threshold`, or nil if the
/// stream ends without one. Values after the answer are not waited for.
public func firstReading(above threshold: Int, in readings: AsyncStream<Int>) async -> Int? {
    nil  // TODO: iterate the stream and stop at the first match
}

// MARK: - 6. All of it, or none of it

/// Every station's temperature, keyed by station, fetched concurrently.
///
/// If any station is unknown, `strictTemperature(at:)` throws `FeedError`
/// and this function throws it onward with nothing partial returned. The
/// suite checks that the other stations were started anyway, because the
/// point of a group is that one failure does not mean the siblings never
/// ran: it means they were cancelled.
public func temperatures(
    for stations: [String],
    from feed: StationFeed
) async throws -> [String: Int] {
    [:]  // TODO: a throwing group, collecting (station, reading) pairs
}
