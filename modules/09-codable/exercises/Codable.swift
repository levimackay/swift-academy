// Chapter 09 exercises.
//
// Every declaration below compiles and is wrong, so the suite runs and
// reports a score instead of aborting. Replace the marked parts.
//
//   swift test --filter Chapter09Tests
//
// House rule for this chapter, checked by the last item of the Done when
// list: nothing here decodes into `[String: Any]` and then reads fields out
// of it. If a payload is worth decoding it is worth a type.

import Foundation

// MARK: - 1. Departure

/// One arriving train, decoded from a departure board document.
///
/// The wire keys are `route_id`, `minutes_away`, and `platform`. The Swift
/// names stay as they are: renaming a property to match a server is how a
/// domain type ends up shaped like someone else's database.
///
/// `platform` is absent from the document for a train that has not been
/// assigned one yet, and the encoded form must leave the key out again
/// rather than write a null.
struct Departure: Codable, Equatable {
    var routeID: String
    var minutesAway: Int
    var platform: String?

    // TODO: the wire keys above do not match these property names.
}

// MARK: - 2. ServiceLevel

/// How a line is running. The operator adds new values to this field without
/// announcing them, so an unrecognized string must decode as
/// `.unrecognized` rather than fail the document it arrived in.
///
/// `.unrecognized` is never produced by the operator, so it has no wire
/// spelling of its own to defend.
enum ServiceLevel: String, Decodable, Equatable {
    case normal
    case delayed
    case suspended
    case unrecognized

    // TODO: an unknown raw value currently throws. Make it fall back.
}

// MARK: - 3. StopSnapshot

/// A flat view of a document that is not flat.
///
///     {"stop": {"name": "Union Square", "code": "US1"},
///      "crowding": {"level": 3}}
///
/// becomes `StopSnapshot(name: "Union Square", code: "US1",
/// crowdingLevel: 3)`. There is no `Stop` type and no `Crowding` type in the
/// answer: the nesting belongs to the document, not to your domain.
///
/// A missing `level`, or a `crowding` object that is not an object, throws.
struct StopSnapshot: Decodable, Equatable {
    var name: String
    var code: String
    var crowdingLevel: Int

    // TODO: this shape is two levels deep on the wire and one level deep here.
}

// MARK: - 4. SensorSample

/// The three way answer to "what did the document say about the battery".
///
/// - `missing`: the key was not in the object at all.
/// - `reportedNull`: the key was there, holding JSON `null`.
/// - `percent`: the key was there, holding a number.
///
/// `Int?` cannot hold this, which is the point of the exercise. Two of the
/// three collapse onto `nil` and the sensor that stopped reporting becomes
/// indistinguishable from the sensor that was never asked.
enum BatteryReading: Equatable {
    case missing
    case reportedNull
    case percent(Int)
}

/// One reading from one trackside sensor.
struct SensorSample: Decodable, Equatable {
    var id: String
    var battery: BatteryReading

    enum CodingKeys: String, CodingKey {
        case id
        case battery
    }
}

// The decoding initializer lives in an extension so that the memberwise
// `SensorSample(id:battery:)` survives for the tests to build expectations
// with. Writing `init(from:)` inside the braces above would replace it.
extension SensorSample {
    init(from decoder: any Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decode(String.self, forKey: .id)
        // TODO: replace this. All three inputs currently answer .missing.
        battery = .missing
    }
}

// MARK: - 5. makeArrivalDecoder()

/// One row of an arrivals log, as the operator publishes it:
///
///     {"stop_id": "US1",
///      "departed_at": "2026-08-03T09:15:00Z",
///      "stop_count": 11}
///
/// Every key in this document is snake case and every timestamp is RFC 3339,
/// so this is a decoder wide problem rather than a per property one. Exactly
/// one of these three properties still needs help after the decoder is
/// configured, and finding out which one is the exercise.
struct ArrivalLog: Decodable, Equatable {
    var stopID: String
    var departedAt: Date
    var stopCount: Int
}

/// Returns a decoder that reads the document above.
func makeArrivalDecoder() -> JSONDecoder {
    // TODO: replace this. A default decoder matches keys literally and
    // refuses to turn a string into a Date.
    return JSONDecoder()
}

// MARK: - 6. describeFailure(decoding:)

/// One leg of a departure board. Given, not part of the exercise.
struct Leg: Decodable, Equatable {
    var routeID: String
    var minutesAway: Int
}

/// A whole departure board. Given, not part of the exercise.
struct Board: Decodable, Equatable {
    var routes: [Leg]
}

/// Decodes `json` as a `Board` and reports what happened in one line.
///
/// Success is `"ok"`. A failure is described by its kind and by the location
/// the decoder reached, written as coding path components joined with `/`,
/// where an array index appears as its number:
///
///     ok
///     missing key routeID at routes/0
///     wrong type at routes/1/minutesAway
///     null at routes/0/minutesAway
///     corrupt at <root>
///
/// An empty coding path is written `<root>`. The four kinds are spelled
/// `missing key <name> at <path>`, `wrong type at <path>`, `null at <path>`,
/// and `corrupt at <path>`. Anything that is not a `DecodingError` is
/// `unknown`, with no path.
///
/// The coding path of a missing key stops at the container that lacked it,
/// so the key name has to come from somewhere else in the error.
func describeFailure(decoding json: Data) -> String {
    // TODO: replace this.
    return ""
}
