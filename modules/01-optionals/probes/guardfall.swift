// This file compiles as written, and it lives apart from errors.swift on
// purpose. The diagnostic below comes from a pass that runs after type
// checking, so a file that already has type errors never gets far enough to
// report it. Put it in errors.swift alongside the others, uncomment several
// blocks, and it never fires.
//
//     make probe CH=01 P=guardfall
//
// Verified on this toolchain, and worth knowing for its own sake:
//
//     swiftc -swift-version 6 -typecheck   reports nothing at all
//     swiftc -swift-version 6 -c           reports the error below
//
// So an editor that only type checks shows a clean file that `swift build`
// rejects. That is the same lesson chapter 11 repeats about the Sendable
// diagnostics, and this is the cheapest place to meet it first. `make probe`
// runs the interpreter, which does the full compile, so it reports it.

// 6. A guard binds for the rest of the scope, so its else branch must leave.
//
// func describe(_ value: String?) {
//     guard let value else { print("absent") }
//     print(value)
// }
//
// error: 'guard' body must not fall through, consider using a 'return' or
// 'throw' to exit the scope

func describe(_ value: String?) {
    guard let value else {
        print("absent")
        return
    }
    print(value)
}

describe("Levi")
describe(nil)

print("guardfall.swift compiles clean. Uncomment the block above and rerun.")
