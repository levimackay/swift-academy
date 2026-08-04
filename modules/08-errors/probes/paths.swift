// Every way out of a scope, run past the same deferred block, so you can
// read the ordering rather than take it on trust.
//
//   make probe CH=08 P=paths
//
// The claim being checked is that `defer` is attached to a scope and not to
// a function, and that it fires on the normal return, the early return, the
// thrown exit, and the loop iteration alike, in reverse order of
// declaration.

enum GateError: Error, Equatable {
    case jammed(String)
    case locked
}

// MARK: - 1. Reverse order, on the ordinary path

func reverseOrder() {
    defer { print("   first declared, last to run") }
    defer { print("   second declared, second to run") }
    defer { print("   third declared, first to run") }
    print("   body")
}

print("1. reverse order of declaration")
reverseOrder()

// MARK: - 2. Every exit path

/// Returns a description, leaving by a different route for each input, and
/// prints from a deferred block on the way out of each one.
func routeOut(_ code: Int) -> String {
    defer { print("   cleanup for \(code)") }
    if code == 0 { return "early return" }
    if code == 1 {
        do { throw GateError.locked } catch { return "caught \(error)" }
    }
    return "ordinary return"
}

print("2. one deferred block, three routes out")
for code in 0...2 { print("   ->", routeOut(code)) }

// MARK: - 3. The scope is the braces, not the function

/// The deferred block belongs to one turn of the loop, so it runs twice, and
/// it runs before the next iteration begins rather than at the end.
func perIteration() {
    for gate in ["north", "south"] {
        defer { print("   close \(gate)") }
        print("   open \(gate)")
    }
    print("   loop finished")
}

print("3. a defer inside a loop body")
perIteration()

// MARK: - 4. The throwing path, across two frames

/// Throws after registering cleanup, so the cleanup runs before the caller's
/// `catch` body does. There is no unwinding here: `raise` returns, `pass`
/// returns, and each deferred block runs as its own frame leaves.
func raise() throws(GateError) -> Int {
    defer { print("   raise cleanup") }
    throw GateError.jammed("north")
}

func pass() throws(GateError) -> Int {
    defer { print("   pass cleanup") }
    return try raise()
}

print("4. cleanup ordering across a throw")
do {
    print("   got", try pass())
} catch {
    print("   catch body sees \(error)")
}

// MARK: - 5. The same failure in all three shapes

/// One failure, expressed as an optional, as a throw, and as a `Result`, so
/// the differences are side by side rather than three sections apart.
func asOptional(_ open: Bool) -> Int? {
    open ? 7 : nil
}

func asThrow(_ open: Bool) throws(GateError) -> Int {
    guard open else { throw GateError.locked }
    return 7
}

let stored: Result<Int, GateError> = .failure(.locked)

print("5. the same failure in three shapes")
print("   optional:", asOptional(false) as Any)
print("   throw:   ", (try? asThrow(false)) as Any)
print("   result:  ", stored)
print("   and the Result still knows why, which the optional does not")

// `get()` turns the stored failure back into a throw, which is the direction
// that has a shortcut. The other direction does not, and that is exercise 5.
do {
    print("   thawed:  ", try stored.get())
} catch {
    print("   thawed:  ", "threw \(error) again")
}
