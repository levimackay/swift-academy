// The chapter 12 gate. Run it with:
//
//     swift test --filter Chapter12Tests
//
// Every suite carries a time limit. An async exercise fails in two ways: it
// returns the wrong value, or it never returns at all. A continuation that
// is never resumed is the second kind, and without a limit that is a hung
// process rather than a red test.

import Testing

@testable import Chapter12

// MARK: - 1. Two independent fetches, one wait

@Suite("12 async let", .timeLimit(.minutes(1)))
struct StationSummaryTests {
    @Test("the summary carries this station's own temperature and wind")
    func summaryReportsTheRequestedStation() async {
        let feed = StationFeed(
            temperatures: ["Nome": 3, "Barrow": -18],
            winds: ["Nome": 11, "Barrow": 4]
        )
        #expect(await stationSummary(for: "Nome", from: feed) == "Nome: 3C wind 11")
    }

    @Test("a second station reports its own numbers, not the first one's")
    func summaryDiffersPerStation() async {
        let feed = StationFeed(
            temperatures: ["Nome": 3, "Barrow": -18],
            winds: ["Nome": 11, "Barrow": 4]
        )
        #expect(await stationSummary(for: "Barrow", from: feed) == "Barrow: -18C wind 4")
    }

    @Test("an unknown station still produces a report, with zeroes")
    func unknownStationReportsZeroes() async {
        let feed = StationFeed(temperatures: ["Nome": 3], winds: ["Nome": 11])
        #expect(await stationSummary(for: "Sitka", from: feed) == "Sitka: 0C wind 0")
    }

    @Test("the temperature and the wind are fetched at the same time")
    func bothFetchesOverlap() async {
        let feed = StationFeed(temperatures: ["Nome": 3], winds: ["Nome": 11])
        _ = await stationSummary(for: "Nome", from: feed)
        #expect(await feed.log.peakInFlight == 2)
        #expect(await feed.log.completedLabels.count == 2)
    }
}

// MARK: - 2. A number of fetches you do not know until run time

@Suite("12 task group", .timeLimit(.minutes(1)))
struct TotalRainfallTests {
    private static let feedValues = ["Nome": 12, "Barrow": 5, "Sitka": 40, "Juneau": 3]

    @Test("no stations totals nothing")
    func emptyListTotalsZero() async {
        let feed = StationFeed(rainfall: Self.feedValues)
        #expect(await totalRainfall(across: [], from: feed) == 0)
        #expect(await feed.log.completedLabels.isEmpty)
    }

    @Test("one station totals that station")
    func singleStationTotalsItself() async {
        let feed = StationFeed(rainfall: Self.feedValues)
        #expect(await totalRainfall(across: ["Sitka"], from: feed) == 40)
    }

    @Test("three stations total to their sum whatever order they answer in")
    func threeStationsTotalTheirSum() async {
        let feed = StationFeed(rainfall: Self.feedValues)
        #expect(await totalRainfall(across: ["Nome", "Barrow", "Sitka"], from: feed) == 57)
    }

    @Test("a repeated station is fetched once per entry and counted once per entry")
    func repeatedStationCountsEachTime() async {
        let feed = StationFeed(rainfall: Self.feedValues)
        #expect(await totalRainfall(across: ["Juneau", "Juneau", "Juneau"], from: feed) == 9)
        #expect(await feed.log.completedLabels.count == 3)
    }

    @Test("four stations are in flight together rather than one after another")
    func stationsAreFetchedConcurrently() async {
        let feed = StationFeed(rainfall: Self.feedValues)
        _ = await totalRainfall(across: ["Nome", "Barrow", "Sitka", "Juneau"], from: feed)
        #expect(await feed.log.peakInFlight >= 2)
    }
}

// MARK: - 3. Stopping when you are asked to

@Suite("12 cancellation", .timeLimit(.minutes(1)))
struct CollectSamplesTests {
    @Test("an uncancelled read returns every sample in order")
    func uncancelledReadReturnsEverything() async {
        let feed = StationFeed(samples: [4, 8, 15, 16])
        #expect(await collectSamples(count: 4, from: feed) == [4, 8, 15, 16])
    }

    @Test("asking for more samples than exist wraps around the ring")
    func readingPastTheEndWrapsAround() async {
        let feed = StationFeed(samples: [4, 8])
        #expect(await collectSamples(count: 5, from: feed) == [4, 8, 4, 8, 4])
    }

    @Test("a cancelled read gives back a prefix instead of the whole run")
    func cancelledReadStopsEarly() async {
        let feed = StationFeed(samples: [4, 8, 15, 16, 23, 42])
        let reader = Task { () -> [Int] in
            // Interrupted the moment cancel() lands, whichever order the
            // two lines below actually happen in.
            try? await Task.sleep(for: .seconds(60))
            return await collectSamples(count: 6, from: feed)
        }
        reader.cancel()
        let collected = await reader.value
        #expect(collected.count < 6)
        #expect(collected == Array([4, 8, 15, 16, 23, 42].prefix(collected.count)))
    }

    @Test("a cancelled read returns rather than throwing")
    func cancelledReadDoesNotThrow() async {
        let feed = StationFeed(samples: [4, 8, 15])
        let reader = Task { () -> [Int] in
            try? await Task.sleep(for: .seconds(60))
            return await collectSamples(count: 3, from: feed)
        }
        reader.cancel()
        let collected = await reader.value
        #expect(collected.count <= 3)
    }
}

// MARK: - 4. Bringing a callback into async

@Suite("12 continuations", .timeLimit(.minutes(1)))
struct CurrentPressureTests {
    @Test("the awaited value is the reading the instrument reported")
    func pressureMatchesTheInstrument() async {
        #expect(await currentPressure(from: LegacyBarometer(millibars: 1013)) == 1013)
    }

    @Test("a different instrument reports a different number")
    func aSecondInstrumentReportsItsOwnReading() async {
        #expect(await currentPressure(from: LegacyBarometer(millibars: 977)) == 977)
    }

    @Test("the same instrument can be read twice in a row")
    func repeatedReadsBothArrive() async {
        let barometer = LegacyBarometer(millibars: 1004)
        let first = await currentPressure(from: barometer)
        let second = await currentPressure(from: barometer)
        #expect(first == 1004)
        #expect(second == 1004)
    }

    @Test("two readings taken concurrently both come back")
    func concurrentReadsBothArrive() async {
        async let low = currentPressure(from: LegacyBarometer(millibars: 950))
        async let high = currentPressure(from: LegacyBarometer(millibars: 1030))
        let pair = await (low, high)
        #expect(pair.0 == 950)
        #expect(pair.1 == 1030)
    }
}

// MARK: - 5. Consuming a stream

@Suite("12 async sequences", .timeLimit(.minutes(1)))
struct FirstReadingTests {
    private func stream(of values: [Int]) -> AsyncStream<Int> {
        AsyncStream { continuation in
            for value in values {
                continuation.yield(value)
            }
            continuation.finish()
        }
    }

    @Test("the first value over the threshold wins, not the largest one")
    func firstMatchWinsOverLargest() async {
        #expect(await firstReading(above: 4, in: stream(of: [1, 5, 9])) == 5)
    }

    @Test("a threshold nothing reaches yields nothing")
    func noMatchYieldsNil() async {
        #expect(await firstReading(above: 100, in: stream(of: [1, 5, 9])) == nil)
    }

    @Test("an empty stream yields nothing")
    func emptyStreamYieldsNil() async {
        #expect(await firstReading(above: 0, in: stream(of: [])) == nil)
    }

    @Test("the comparison is strictly greater than, so the threshold itself is not a match")
    func thresholdItselfIsNotAMatch() async {
        #expect(await firstReading(above: 7, in: stream(of: [7, 7, 8])) == 8)
    }

    @Test("a negative reading can be the answer")
    func negativeValuesCompareNormally() async {
        #expect(await firstReading(above: -10, in: stream(of: [-40, -3, 12])) == -3)
    }
}

// MARK: - 6. All of it, or none of it

@Suite("12 throwing groups", .timeLimit(.minutes(1)))
struct TemperaturesTests {
    private static let known = ["Nome": 3, "Barrow": -18, "Sitka": 7]

    @Test("every requested station appears in the result under its own key")
    func allStationsAreKeyed() async throws {
        let feed = StationFeed(temperatures: Self.known)
        let readings = try await temperatures(for: ["Nome", "Sitka"], from: feed)
        #expect(readings == ["Nome": 3, "Sitka": 7])
    }

    @Test("no stations means an empty dictionary and no work")
    func emptyRequestDoesNothing() async throws {
        let feed = StationFeed(temperatures: Self.known)
        #expect(try await temperatures(for: [], from: feed).isEmpty)
        #expect(await feed.log.completedLabels.isEmpty)
    }

    @Test("one unknown station fails the whole call")
    func unknownStationThrows() async {
        let feed = StationFeed(temperatures: Self.known)
        await #expect(throws: FeedError(station: "Yakutat")) {
            try await temperatures(for: ["Yakutat", "Nome", "Sitka"], from: feed)
        }
    }

    @Test("the siblings of a failing station were started and then cancelled")
    func siblingsStartAndThenGetCancelled() async {
        let feed = StationFeed(temperatures: Self.known)
        _ = try? await temperatures(for: ["Yakutat", "Nome", "Sitka"], from: feed)
        #expect(await feed.log.peakInFlight >= 2)
        #expect(await feed.log.abandonedLabels.isEmpty == false)
    }

    @Test("the successful path leaves nothing abandoned")
    func successfulPathAbandonsNothing() async throws {
        let feed = StationFeed(temperatures: Self.known)
        _ = try await temperatures(for: ["Nome", "Barrow", "Sitka"], from: feed)
        #expect(await feed.log.abandonedLabels.isEmpty)
        #expect(await feed.log.completedLabels.count == 3)
    }
}
