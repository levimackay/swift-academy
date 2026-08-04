import Foundation
import Testing
@testable import Chapter09

// Test names describe the behavior, not the exercise number, so a red line
// in the output tells you what is wrong without opening this file.
//
// Fixtures are written as raw string literals and turned into `Data` at the
// point of use, because a decoder takes bytes and the bytes are the thing
// under test.

private func bytes(_ text: String) -> Data {
    Data(text.utf8)
}

@Suite("09.1 Departure")
struct DepartureTests {
    @Test("reads the wire names route_id and minutes_away")
    func readsRenamedKeys() throws {
        let json = bytes(#"{"route_id":"L","minutes_away":4,"platform":"2"}"#)
        let departure = try JSONDecoder().decode(Departure.self, from: json)
        #expect(departure == Departure(routeID: "L", minutesAway: 4, platform: "2"))
    }

    @Test("reads a second document with different values")
    func readsASecondDocument() throws {
        let json = bytes(#"{"route_id":"G","minutes_away":11,"platform":"7A"}"#)
        let departure = try JSONDecoder().decode(Departure.self, from: json)
        #expect(departure == Departure(routeID: "G", minutesAway: 11, platform: "7A"))
    }

    @Test("treats an absent platform key as no platform")
    func absentPlatformDecodesAsNil() throws {
        let json = bytes(#"{"route_id":"G","minutes_away":11}"#)
        let departure = try JSONDecoder().decode(Departure.self, from: json)
        #expect(departure.platform == nil)
        #expect(departure.minutesAway == 11)
    }

    @Test("treats an explicit null platform as no platform")
    func nullPlatformDecodesAsNil() throws {
        let json = bytes(#"{"route_id":"L","minutes_away":2,"platform":null}"#)
        let departure = try JSONDecoder().decode(Departure.self, from: json)
        #expect(departure.platform == nil)
    }

    @Test("encodes back to the wire names, not to the Swift names")
    func encodesToWireNames() throws {
        let encoder = JSONEncoder()
        encoder.outputFormatting = [.sortedKeys]
        let encoded = try encoder.encode(Departure(routeID: "L", minutesAway: 4, platform: "2"))
        #expect(String(decoding: encoded, as: UTF8.self)
                == #"{"minutes_away":4,"platform":"2","route_id":"L"}"#)
    }

    @Test("omits the platform key entirely rather than writing a null")
    func omitsAbsentPlatformWhenEncoding() throws {
        let encoder = JSONEncoder()
        encoder.outputFormatting = [.sortedKeys]
        let encoded = try encoder.encode(Departure(routeID: "G", minutesAway: 11, platform: nil))
        #expect(String(decoding: encoded, as: UTF8.self)
                == #"{"minutes_away":11,"route_id":"G"}"#)
    }

    @Test("still fails when a required key is absent")
    func missingRequiredKeyStillThrows() {
        let json = bytes(#"{"minutes_away":4}"#)
        #expect(throws: (any Error).self) {
            try JSONDecoder().decode(Departure.self, from: json)
        }
    }
}

@Suite("09.2 ServiceLevel")
struct ServiceLevelTests {
    @Test("decodes a value the operator documented")
    func decodesKnownValue() throws {
        let level = try JSONDecoder().decode(ServiceLevel.self, from: bytes(#""delayed""#))
        #expect(level == .delayed)
    }

    @Test("decodes a second documented value")
    func decodesASecondKnownValue() throws {
        let level = try JSONDecoder().decode(ServiceLevel.self, from: bytes(#""suspended""#))
        #expect(level == .suspended)
    }

    @Test("falls back instead of throwing on a value nobody announced")
    func unknownValueFallsBack() throws {
        let level = try JSONDecoder().decode(ServiceLevel.self, from: bytes(#""meteor_shower""#))
        #expect(level == .unrecognized)
    }

    @Test("one unknown element does not fail the whole array")
    func unknownElementDoesNotFailTheDocument() throws {
        let json = bytes(#"["normal","meteor_shower","suspended"]"#)
        let levels = try JSONDecoder().decode([ServiceLevel].self, from: json)
        #expect(levels == [.normal, .unrecognized, .suspended])
    }

    @Test("a number where a string belongs is still an error")
    func wrongTypeStillThrows() {
        #expect(throws: (any Error).self) {
            try JSONDecoder().decode(ServiceLevel.self, from: bytes("7"))
        }
    }
}

@Suite("09.3 StopSnapshot")
struct StopSnapshotTests {
    @Test("flattens two nested objects into one value")
    func flattensNestedObjects() throws {
        let json = bytes(#"{"stop":{"name":"Union Square","code":"US1"},"crowding":{"level":3}}"#)
        let snapshot = try JSONDecoder().decode(StopSnapshot.self, from: json)
        #expect(snapshot == StopSnapshot(name: "Union Square", code: "US1", crowdingLevel: 3))
    }

    @Test("flattens a second document with different values")
    func flattensASecondDocument() throws {
        let json = bytes(#"{"stop":{"name":"Marine Park","code":"MP4"},"crowding":{"level":0}}"#)
        let snapshot = try JSONDecoder().decode(StopSnapshot.self, from: json)
        #expect(snapshot == StopSnapshot(name: "Marine Park", code: "MP4", crowdingLevel: 0))
    }

    @Test("ignores keys the document carries and the type does not want")
    func ignoresUnusedKeys() throws {
        let json = bytes(
            #"{"stop":{"name":"Union Square","code":"US1","zone":2},"crowding":{"level":1,"asOf":9}}"#
        )
        let snapshot = try JSONDecoder().decode(StopSnapshot.self, from: json)
        #expect(snapshot.crowdingLevel == 1)
        #expect(snapshot.code == "US1")
    }

    @Test("fails when the nested level is absent")
    func missingNestedValueThrows() {
        let json = bytes(#"{"stop":{"name":"Union Square","code":"US1"},"crowding":{}}"#)
        #expect(throws: (any Error).self) {
            try JSONDecoder().decode(StopSnapshot.self, from: json)
        }
    }

    @Test("fails when the nesting itself is missing")
    func flatDocumentThrows() {
        let json = bytes(#"{"name":"Union Square","code":"US1","crowdingLevel":3}"#)
        #expect(throws: (any Error).self) {
            try JSONDecoder().decode(StopSnapshot.self, from: json)
        }
    }
}

@Suite("09.4 SensorSample")
struct SensorSampleTests {
    @Test("reads a battery percentage that is present")
    func readsAPresentPercentage() throws {
        let sample = try JSONDecoder().decode(
            SensorSample.self, from: bytes(#"{"id":"s1","battery":87}"#))
        #expect(sample == SensorSample(id: "s1", battery: .percent(87)))
    }

    @Test("reads a second percentage, so zero is not a special case")
    func readsZeroAsAPercentage() throws {
        let sample = try JSONDecoder().decode(
            SensorSample.self, from: bytes(#"{"id":"s2","battery":0}"#))
        #expect(sample == SensorSample(id: "s2", battery: .percent(0)))
    }

    @Test("reports an absent key as missing")
    func absentKeyIsMissing() throws {
        let sample = try JSONDecoder().decode(
            SensorSample.self, from: bytes(#"{"id":"s3"}"#))
        #expect(sample.battery == .missing)
    }

    @Test("reports a key holding null as null, not as missing")
    func explicitNullIsNotMissing() throws {
        let sample = try JSONDecoder().decode(
            SensorSample.self, from: bytes(#"{"id":"s4","battery":null}"#))
        #expect(sample.battery == .reportedNull)
    }

    @Test("a battery that is neither null nor a number is still an error")
    func wrongTypeThrows() {
        #expect(throws: (any Error).self) {
            try JSONDecoder().decode(
                SensorSample.self, from: bytes(#"{"id":"s5","battery":"full"}"#))
        }
    }
}

@Suite("09.5 makeArrivalDecoder()")
struct ArrivalDecoderTests {
    @Test("reads snake case keys and an RFC 3339 timestamp")
    func readsTheOperatorsDocument() throws {
        let json = bytes(
            #"{"stop_id":"US1","departed_at":"2026-08-03T09:15:00Z","stop_count":11}"#)
        let log = try makeArrivalDecoder().decode(ArrivalLog.self, from: json)
        #expect(log == ArrivalLog(
            stopID: "US1",
            departedAt: Date(timeIntervalSince1970: 1_785_748_500),
            stopCount: 11))
    }

    @Test("reads a second row with a different timestamp")
    func readsASecondRow() throws {
        let json = bytes(
            #"{"stop_id":"MP4","departed_at":"2026-12-25T00:00:00Z","stop_count":3}"#)
        let log = try makeArrivalDecoder().decode(ArrivalLog.self, from: json)
        #expect(log == ArrivalLog(
            stopID: "MP4",
            departedAt: Date(timeIntervalSince1970: 1_798_156_800),
            stopCount: 3))
    }

    @Test("keeps the acronym in stopID rather than renaming the property")
    func acronymPropertyStillDecodes() throws {
        let json = bytes(
            #"{"stop_id":"QB2","departed_at":"2026-08-03T09:15:00Z","stop_count":1}"#)
        let log = try makeArrivalDecoder().decode(ArrivalLog.self, from: json)
        #expect(log.stopID == "QB2")
    }

    @Test("rejects a timestamp that is not a timestamp")
    func badTimestampThrows() {
        let json = bytes(#"{"stop_id":"US1","departed_at":"yesterday","stop_count":11}"#)
        #expect(throws: (any Error).self) {
            try makeArrivalDecoder().decode(ArrivalLog.self, from: json)
        }
    }
}

@Suite("09.6 describeFailure(decoding:)")
struct DescribeFailureTests {
    @Test("says ok when the document decodes")
    func reportsSuccess() {
        #expect(describeFailure(decoding: bytes(#"{"routes":[{"routeID":"L","minutesAway":4}]}"#))
                == "ok")
    }

    @Test("says ok for an empty routes array, which is a valid board")
    func reportsSuccessForAnEmptyArray() {
        #expect(describeFailure(decoding: bytes(#"{"routes":[]}"#)) == "ok")
    }

    @Test("names the absent key and the container that lacked it")
    func reportsAMissingKey() {
        #expect(describeFailure(decoding: bytes(#"{"routes":[{"minutesAway":4}]}"#))
                == "missing key routeID at routes/0")
    }

    @Test("writes an array index as a number rather than as its key name")
    func reportsAnIndexAsANumber() {
        let json = bytes(
            #"{"routes":[{"routeID":"L","minutesAway":4},{"routeID":"G","minutesAway":"soon"}]}"#)
        #expect(describeFailure(decoding: json) == "wrong type at routes/1/minutesAway")
    }

    @Test("separates a null value from a wrong type")
    func reportsANullValue() {
        let json = bytes(#"{"routes":[{"routeID":"L","minutesAway":null}]}"#)
        #expect(describeFailure(decoding: json) == "null at routes/0/minutesAway")
    }

    @Test("writes an empty coding path as root")
    func reportsAnEmptyPathAsRoot() {
        #expect(describeFailure(decoding: bytes("not json at all")) == "corrupt at <root>")
    }

    @Test("reports a wrong shaped root at root")
    func reportsAWrongRootShape() {
        #expect(describeFailure(decoding: bytes("[]")) == "wrong type at <root>")
    }

    @Test("stops at the container that was the wrong shape")
    func reportsAWrongShapedBranch() {
        #expect(describeFailure(decoding: bytes(#"{"routes":{"routeID":"L"}}"#))
                == "wrong type at routes")
    }

    @Test("reports a top level key that is absent")
    func reportsAMissingTopLevelKey() {
        #expect(describeFailure(decoding: bytes("{}")) == "missing key routes at <root>")
    }
}
