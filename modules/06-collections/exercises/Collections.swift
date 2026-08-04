// Chapter 06 exercises.
//
// Every function below returns a compiling wrong value so that the suite
// runs and reports a score instead of aborting. Replace each body.
//
//   swift test --filter Chapter06Tests
//
// House rules for this chapter. Both are checked by the last two items of
// the Done when list:
//
//   1. No force unwrap anywhere in this directory.
//   2. No building an array of Characters out of a String. Doing that to get
//      integer indexing back is the workaround this chapter exists to make
//      unnecessary, and it costs O(n) memory to avoid learning the model.

// MARK: - 1. uniqueInOrder(_:)

/// Returns the values with later duplicates removed, keeping the first
/// occurrence of each and the order they arrived in. Comparison is exact:
/// `"Fig"` and `"fig"` are two different values.
func uniqueInOrder(_ values: [String]) -> [String] {
    // TODO: replace this.
    return []
}

// MARK: - 2. parsedReadings(from:)

/// Parses each line as a whole `Int`, dropping both the lines that are absent
/// and the lines that are present but not a whole number. A leading minus
/// sign is part of the number, `"3.5"` is not a whole number, and `"0"` is a
/// reading rather than an absence. Order is preserved.
func parsedReadings(from lines: [String?]) -> [Int] {
    // TODO: replace this.
    return []
}

// MARK: - 3. wordCounts(in:)

/// Counts how many times each word appears. An empty input gives an empty
/// dictionary, and a word that never appears has no key at all rather than a
/// key holding zero.
func wordCounts(in words: [String]) -> [String: Int] {
    // TODO: replace this.
    return [:]
}

// MARK: - 4. groupedByInitial(_:)

/// Groups the names by their first `Character`. A name with no characters
/// belongs to no group and appears nowhere in the result. Within a group,
/// names keep the order they arrived in.
func groupedByInitial(_ names: [String]) -> [Character: [String]] {
    // TODO: replace this.
    return [:]
}

// MARK: - 5. offsetOfPeak(in:)

/// Returns how many elements come before the largest value in the slice,
/// counting from the start of the slice and not from the start of whatever
/// array the slice was cut out of. On a tie, the earliest of the tied values
/// wins. An empty slice has no peak.
func offsetOfPeak(in samples: ArraySlice<Int>) -> Int? {
    // TODO: replace this.
    return nil
}

// MARK: - 6. truncatedDisplayName(_:limit:)

/// Shortens `name` so that it is at most `limit` characters long, where a
/// character is what a reader sees rather than a byte or a scalar.
///
///   - A name already within the limit comes back untouched.
///   - A longer name is cut and given a trailing "…", and the "…" counts
///     toward the limit.
///   - The cut never lands inside a character, so a family emoji is either
///     wholly present or wholly absent.
///   - Trailing spaces are removed before the "…" is added, so the result
///     may end up shorter than the limit.
///   - A limit of zero or less gives an empty string.
func truncatedDisplayName(_ name: String, limit: Int) -> String {
    // TODO: replace this.
    return ""
}
