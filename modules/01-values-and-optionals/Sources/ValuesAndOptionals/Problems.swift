/// Module 01 — Values, Types, and Optionals
///
/// Implement each function below. Replace the `fatalError` with real code.
/// Run `swift test` from this directory to check your work.
///
/// Rules: you type every line. Ask for hints, not answers.

public enum Problems {

    /// Return `a / b`, or `nil` if `b` is zero.
    ///
    /// In Python you might raise ZeroDivisionError. In C# you'd throw or use
    /// `int?`. Swift's answer is the Optional — the absence is in the type.
    public static func safeDivide(_ a: Int, by b: Int) -> Int? {
        fatalError("TODO: implement safeDivide")
    }

    /// Return the first string that is not empty, or `nil` if there isn't one.
    public static func firstNonEmpty(_ strings: [String]) -> String? {
        fatalError("TODO: implement firstNonEmpty")
    }

    /// Parse `input` as an age. Return `nil` unless it is a whole number
    /// between 0 and 130 inclusive.
    ///
    /// `Int("abc")` returns `Int?` — conversion that can fail says so.
    public static func parseAge(_ input: String) -> Int? {
        fatalError("TODO: implement parseAge")
    }

    /// Describe an optional Int.
    /// - `42`   -> "got 42"
    /// - `nil`  -> "got nothing"
    public static func describe(_ value: Int?) -> String {
        fatalError("TODO: implement describe")
    }

    /// Return uppercase initials for a full name.
    /// - "levi mackay"      -> "LM"
    /// - "  ada  lovelace " -> "AL"
    /// - ""                 -> ""
    ///
    /// Careful: a Swift `String` is not an array of characters you can index
    /// with `name[0]`. This one is meant to trip you up.
    public static func initials(from fullName: String) -> String {
        fatalError("TODO: implement initials")
    }

    /// Constrain `value` to the range `lower...upper`.
    /// Assume `lower <= upper`.
    public static func clamp(_ value: Int, lower: Int, upper: Int) -> Int {
        fatalError("TODO: implement clamp")
    }
}
