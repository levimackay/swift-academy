// Chapter 01 exercises.
//
// Every function below returns a compiling wrong value so that the suite
// runs and reports a score instead of aborting. Replace each body.
//
//   swift test --filter 01
//
// House rule for this chapter, checked by the last item of the Done when
// list: no `!` anywhere in this directory. Force unwrap has its own probe,
// and that is the only place it belongs.

// MARK: - 1. displayName(for:fallback:)

/// Returns the nickname when it holds a non empty string, and the fallback
/// otherwise. A nickname of `""` counts as absent.
func displayName(for nickname: String?, fallback: String) -> String {
    // TODO: replace this.
    return nickname ?? fallback
}

// MARK: - 2. firstInitial(of:)

/// Returns the first `Character` of the name, or nil when the name is
/// absent or empty. A multi scalar emoji is one `Character`.
func firstInitial(of name: String?) -> Character? {
    // TODO: replace this.
    return nil
}

// MARK: - 3. parsedPort(from:)

/// Parses `text` as a TCP port. Valid ports are 1 through 65535 inclusive.
/// Anything else, including absent text and text that is not a number,
/// is nil.
func parsedPort(from text: String?) -> Int? {
    // TODO: replace this.
    return nil
}

// MARK: - 4. label(for:)

/// Describes a score:
///   absent    -> "unrated"
///   negative  -> "invalid"
///   zero      -> "zero"
///   otherwise -> "rated 42" for a score of 42
func label(for score: Int?) -> String {
    // TODO: replace this.
    return ""
}

// MARK: - 5. absenceKind(of:)

/// Distinguishes the two levels of an `Int??`:
///   .none            -> "missing"
///   .some(.none)     -> "null"
///   .some(.some(7))  -> "value 7"
func absenceKind(of value: Int??) -> String {
    // TODO: replace this.
    return ""
}

// MARK: - 6. summarize(_:)

/// One temperature reading from one station. A station that failed to
/// report has a nil `celsius`.
struct Reading {
    let station: String
    let celsius: Double?
}

/// The result of folding a batch of readings.
///
/// - `reported`: how many readings carried a temperature.
/// - `missing`: how many did not.
/// - `warmest`: the station with the highest temperature, nil when nothing
///   reported. On a tie the earliest reading in the array wins.
/// - `averageCelsius`: the mean of the reported temperatures, nil when
///   nothing reported.
struct Report: Equatable {
    let reported: Int
    let missing: Int
    let warmest: String?
    let averageCelsius: Double?
}

/// Folds a batch of readings into one report.
func summarize(_ readings: [Reading]) -> Report {
    // TODO: replace this.
    return Report(reported: -1, missing: -1, warmest: nil, averageCelsius: nil)
}
