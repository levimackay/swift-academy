// Chapter 08 exercises.
//
// Every function below returns a compiling wrong value so that the suite
// runs and reports a score instead of aborting. Replace each body.
//
//   swift test --filter Chapter08Tests
//
// Two house rules for this chapter, both checked by the last item of the
// Done when list.
//
//   1. No `try!` anywhere. It is force unwrap with a different spelling.
//   2. No `default:` in any switch over an error type declared in this file.
//      Both error types here are yours and both are closed, so the compiler
//      is willing to tell you when you miss a case. A `default` throws that
//      away, and typed throws exists precisely so it does not have to.

// MARK: - Provided

/// What can go wrong reading a warehouse bin code.
///
/// `Equatable` is here so the test suite can assert on the payload and not
/// only on the case, which is the whole reason a payload is worth carrying.
enum BinError: Error, Equatable {
    /// The code is not `<letter><digits>` at all: empty, no leading letter,
    /// no digits after the letter, a non digit in the tail, or a number too
    /// large to be an `Int`.
    case malformed(String)

    /// The shape was right but the aisle letter is not one this warehouse
    /// has. The warehouse has aisles A, B, and C.
    case unknownAisle(Character)
}

/// Written for you, and not an exercise. Reads a bin code such as `"B14"`
/// and returns the shelf number, here 14.
///
/// The shape check happens first, so `"Z9"` is `.unknownAisle("Z")` while
/// `"ZZ"` is `.malformed("ZZ")`. Leading zeros are allowed: `"A007"` is 7.
///
/// This is the throwing function exercises 2 through 6 call. Read its
/// signature before you start: `throws(BinError)` promises that `BinError`
/// is the only thing that can come out of it, which is what lets a `catch`
/// over it be exhaustive with no `default`.
func shelfNumber(of code: String) throws(BinError) -> Int {
    guard let aisle = code.first, aisle.isLetter else {
        throw BinError.malformed(code)
    }
    let tail = code.dropFirst()
    guard !tail.isEmpty, tail.allSatisfy(\.isNumber), let shelf = Int(tail) else {
        throw BinError.malformed(code)
    }
    guard "ABC".contains(aisle) else {
        throw BinError.unknownAisle(aisle)
    }
    return shelf
}

// MARK: - 1. ticketCount(from:)

/// What can go wrong reading an order quantity off a form.
enum TicketError: Error, Equatable {
    /// The field held nothing at all once surrounding whitespace is removed.
    case blank

    /// The field held something, but not a whole number. The payload is the
    /// trimmed text, so an error message can quote what the human typed.
    case notANumber(String)

    /// It parsed, and it is not a quantity this box office will sell. The
    /// payload is the number that was rejected.
    case outOfRange(Int)
}

/// Parses one order quantity. A valid order is a whole number from 1 through
/// 10 inclusive.
///
/// Surrounding whitespace is not an error: `"  4 "` is 4. A field that is
/// empty, or holds only whitespace, is `.blank`. Anything that is not a whole
/// number is `.notANumber` carrying the trimmed text. A whole number outside
/// 1 through 10, including 0 and negatives, is `.outOfRange` carrying the
/// number.
func ticketCount(from text: String) throws(TicketError) -> Int {
    // TODO: replace this.
    return 0
}

// MARK: - 2. knownShelves(in:)

/// Returns the shelf number of every code that resolves, in the order the
/// codes were given, skipping the ones that do not.
///
/// `knownShelves(in: ["A1", "!!", "B2"])` is `[1, 2]`. An array with nothing
/// resolvable in it gives `[]`, and so does an empty array. The reason a code
/// failed is deliberately not reported here: this is the case where the
/// caller has nothing to do with it.
func knownShelves(in codes: [String]) -> [Int] {
    // TODO: replace this.
    return []
}

// MARK: - 3. shelfReport(for:)

/// One line of operator facing text for a single code.
///
///   "B14"  -> "shelf 14"
///   "!!"   -> "cannot read !!"
///   "Z9"   -> "no aisle Z"
///
/// Every failure case gets its own wording, which means this function has to
/// distinguish them rather than collapsing them into one string.
func shelfReport(for code: String) -> String {
    // TODO: replace this.
    return ""
}

// MARK: - 4. auditedShelves(in:into:)

/// Resolves every code and writes an audit trail into `log`, then returns the
/// shelves it found, in order.
///
/// For each code, in this order and with nothing interleaved from another
/// code:
///
///   "open A1"     always, before the lookup
///   "shelf 1"     only when the lookup succeeded
///   "skip !!"     only when the lookup failed
///   "close A1"    always, after either of the two above
///
/// So `auditedShelves(in: ["A1", "!!"], into: &log)` returns `[1]` and leaves
/// `log` holding, in order: "open A1", "shelf 1", "close A1", "open !!",
/// "skip !!", "close !!".
///
/// `log` is appended to, never cleared, so whatever it already held stays at
/// the front.
func auditedShelves(in codes: [String], into log: inout [String]) -> [Int] {
    // TODO: replace this.
    return []
}

// MARK: - 5. shelfResults(for:)

/// Returns one `Result` per code, in order, keeping the failure instead of
/// discarding it. The returned array always has exactly as many elements as
/// the input.
///
/// Note the failure type. `Result { try shelfNumber(of: code) }` builds a
/// `Result<Int, any Error>` no matter what you annotate the destination
/// with, so that shortcut will not typecheck against this signature.
func shelfResults(for codes: [String]) -> [Result<Int, BinError>] {
    // TODO: replace this.
    return []
}

// MARK: - 6. firstShelf(in:using:)

/// Returns the shelf of the first code in `codes`, or nil when `codes` is
/// empty, propagating whatever `lookUp` throws.
///
/// The error type is the caller's, not this function's: no concrete error
/// type is named in the signature and none should be named in the body.
/// Passing `shelfNumber(of:)` makes this throw `BinError`; passing a closure
/// that throws something else makes it throw that instead.
///
/// It also looks at no more of the array than it has to. `lookUp` is called
/// exactly once for a non empty array, and not at all for an empty one, which
/// matters when the lookup is expensive or has side effects.
func firstShelf<E: Error>(
    in codes: [String],
    using lookUp: (String) throws(E) -> Int
) throws(E) -> Int? {
    // TODO: replace this.
    return nil
}
