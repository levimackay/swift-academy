// Chapter 02 exercises.
//
// Every declaration below compiles and returns a wrong value on purpose, so
// the suite runs and reports a score instead of aborting. Replace each body.
//
//     swift test --filter Chapter02Tests
//
// House rule, same as chapter 01: no `!` anywhere in this directory. Nothing
// here needs one.

// MARK: - 1. initials(of:separatedBy:)

/// Builds the initials of a name: the first character of every whitespace
/// separated word, uppercased, joined by `separator`.
///
///   initials(of: "Levi Mackay")                  -> "L.M"
///   initials(of: "ada  lovelace", separatedBy: "-") -> "A-L"
///   initials(of: "   ")                          -> ""
///
/// Runs of spaces do not produce empty initials, and a name with no words
/// produces the empty string rather than a lone separator.
func initials(of fullName: String, separatedBy separator: String = ".") -> String {
    // TODO: replace this.
    return ""
}

// MARK: - 2. spread(of:)

/// The distance between the largest and smallest argument.
///
///   spread(of: 3, 9, 4)   -> 6
///   spread(of: -10, -3)   -> 7
///   spread(of: 5)         -> 0
///   spread()              -> 0
///
/// A variadic parameter accepts zero arguments, so the empty case is a call
/// the compiler will let through and the tests will ask about.
func spread(of values: Int...) -> Int {
    // TODO: replace this.
    return -1
}

// MARK: - 3. clamp(_:into:)

/// Moves `value` into `limits` in place. A value already inside the range is
/// left exactly as it is, including when it sits on either bound.
///
/// This one returns nothing, so the only observable effect is on the
/// caller's variable. That is the point of `inout`.
func clamp(_ value: inout Int, into limits: ClosedRange<Int>) {
    // TODO: replace this.
}

// MARK: - 4. makeAccumulator(startingAt:)

/// Returns a function that keeps a running total. Each call adds its
/// argument to the total and returns the new total.
///
///   let add = makeAccumulator()
///   add(3)   // 3
///   add(4)   // 7
///
/// Two accumulators made by two calls never share a total.
func makeAccumulator(startingAt start: Int = 0) -> (Int) -> Int {
    // TODO: replace this.
    return { _ in -1 }
}

// MARK: - 5. either(_:or:)

/// Returns `preferred` when it holds a value, and otherwise the value of the
/// `fallback` expression. This is `??` written out by hand.
///
/// The `@autoclosure` is load bearing: the caller writes an expression, not a
/// closure, and that expression must not be evaluated when `preferred` is
/// present. One test measures exactly that.
func either(_ preferred: Int?, or fallback: @autoclosure () -> Int) -> Int {
    // TODO: replace this.
    return -1
}

// MARK: - 6. Dispatcher

/// A table of named handlers, each a function from `Int` to `Int`.
///
/// The integrative exercise. It needs storage, which is not declared for you,
/// and the signature of `on(_:run:)` below is incomplete: it compiles as
/// written and stops compiling the moment you store `handler`. The
/// diagnostic names the keyword that is missing, and row 6 of the chapter's
/// "Where it goes wrong" table explains why the compiler has to ask.
struct Dispatcher {
    /// Registers `handler` under `name`. Registering a name twice keeps the
    /// later handler and discards the earlier one.
    mutating func on(_ name: String, run handler: (Int) -> Int) {
        // TODO: replace this.
    }

    /// Runs the handler registered under `name`, or returns nil when there
    /// is none. Nothing is registered for the empty string unless you
    /// registered it.
    func send(_ name: String, value: Int) -> Int? {
        // TODO: replace this.
        return nil
    }

    /// Every registered name, in ascending order, with no duplicates.
    var registeredNames: [String] {
        // TODO: replace this.
        return []
    }
}
