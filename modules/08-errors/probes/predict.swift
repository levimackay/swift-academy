// Three snippets. Write your prediction in the comment above each one
// before you run the file. The toolchain is the answer key, and there is
// no answer key anywhere in this repository.
//
//   make probe CH=08 P=predict
//
// The declarations below are the ones the chapter's "Swift's answer"
// section uses, repeated here so the file stands alone.

enum BuoyError: Error, Equatable {
    case offline
    case badRow(String)
    case stale(seconds: Int)
}

func windSpeed(fromRow row: String) throws(BuoyError) -> Int {
    let parts = row.split(separator: ",")
    guard parts.count == 2, let knots = Int(parts[1]) else {
        throw BuoyError.badRow(row)
    }
    return knots
}

// 1. One row parses and one does not. Predict the printed type of each
//    expression before you predict the values, and predict what happened
//    to the `.badRow` payload.
//
// prediction:

let parsed = try? windSpeed(fromRow: "buoy,12")
let failed = try? windSpeed(fromRow: "buoy")
print("1:", parsed as Any, failed as Any)

// 2. Two deferred appends and a return of the thing they append to. Predict
//    how many elements the caller sees, and say in one sentence what that
//    tells you about when the return value is decided.
//
// prediction:

func trace() -> [String] {
    var marks = ["a"]
    defer { marks.append("b") }
    defer { marks.append("c") }
    return marks
}
print("2:", trace())

// 3. A `defer` written inside a loop body. Predict the interleaving of the
//    six lines, not just their set.
//
// prediction:

func loop() {
    for n in 1...2 {
        defer { print("   close \(n)") }
        print("   open \(n)")
    }
}
print("3:")
loop()

// 4. A throw crossing two frames, with a deferred block in each. Predict the
//    order of the three printed lines, and predict whether the innermost
//    deferred block runs before or after the `catch` body.
//
// prediction:

func inner() throws(BuoyError) -> Int {
    defer { print("   inner cleanup") }
    throw BuoyError.stale(seconds: 90)
}

func outer() -> String {
    defer { print("   outer cleanup") }
    do {
        return "\(try inner())"
    } catch {
        print("   caught \(error)")
        return "gave up"
    }
}
print("4:", outer())
