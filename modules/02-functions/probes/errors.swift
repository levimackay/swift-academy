// This file compiles as written. Every commented block below is a real
// mistake with the diagnostic it produced on the toolchain in the chapter
// front matter, pasted verbatim. Uncomment one block at a time and read the
// wording yourself:
//
//     make probe CH=02 P=errors
//
// The chapter's "Where it goes wrong" table is built from this file, one row
// per block, in this order. The file stays green on purpose: a probe that
// compiles today and stops compiling after a toolchain upgrade tells you the
// wording drifted, and a probe that never compiled cannot tell you anything.
//
// Blocks 5 and 7 are not type errors. They come from a later pass that
// reasons about exclusive access and about closure lifetime, which is why an
// editor that only type checks can show those two lines green.
//
// When a diagnostic in here costs you more than ten minutes anywhere else,
// paste it verbatim into NOTES/errors.md with what you thought it meant.

// 1. Labels are part of the name, so a call without them names nothing.
//
// func move(from source: Int, to destination: Int) -> Int { source + destination }
// _ = move(1, 2)
//
// error: missing argument labels 'from:to:' in call

// 2. Order is part of the name too. Same labels, wrong sequence.
//
// func move(from source: Int, to destination: Int) -> Int { source + destination }
// _ = move(to: 1, from: 2)
//
// error: argument 'from' must precede argument 'to'

// 3. A function type has no labels, so the value you assigned dropped them.
//
// func move(from source: Int, to destination: Int) -> Int { source + destination }
// let f: (Int, Int) -> Int = move
// _ = f(from: 1, to: 2)
//
// error: extraneous argument labels 'from:to:' in call

// 4. inout is visible at the call site, always.
//
// func bump(_ value: inout Int) { value += 1 }
// var count = 0
// bump(count)
//
// error: passing value of type 'Int' to an inout parameter requires explicit '&'

// 5. Copy in, copy out, so two inout arguments cannot name one variable.
//
// func exchange(_ left: inout Int, _ right: inout Int) {
//     let temporary = left
//     left = right
//     right = temporary
// }
// func demo() {
//     var value = 1
//     exchange(&value, &value)
// }
//
// error: inout arguments are not allowed to alias each other
// note: previous aliasing argument
// error: overlapping accesses to 'value', but modification requires exclusive
// access; consider copying to a local variable
// note: conflicting access is here

// 6. A closure parameter is non escaping by default, and storing it escapes.
//
// var stored: [() -> Void] = []
// func register(_ handler: () -> Void) { stored.append(handler) }
//
// error: converting non-escaping parameter 'handler' to generic parameter
// 'Element' may allow it to escape

// 7. A returned closure escapes, and a value type's self cannot outlive the
//    call that is mutating it.
//
// struct Counter {
//     var total = 0
//     mutating func delayedBump() -> () -> Void {
//         return { self.total += 1 }
//     }
// }
//
// error: escaping closure captures mutating 'self' parameter
// note: captured here

// 8. Shorthand argument names are checked against the parameter list.
//
// func run(_ body: () -> Int) -> Int { body() }
// let value = run { $0 + 1 }
//
// error: contextual closure type '() -> Int' expects 0 arguments, but 1 was
// used in closure body

print("errors.swift compiles clean. Uncomment one block above and rerun.")
