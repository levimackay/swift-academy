// This file compiles as written. Every commented block below is a real
// mistake with the diagnostic it produced on the toolchain in the chapter
// front matter, pasted verbatim. Uncomment one block at a time and check the
// wording yourself:
//
//     make probe CH=01 P=errors
//
// The chapter's "Where it goes wrong" table is built from this file. The file
// stays green on purpose: a probe that compiles today and stops compiling
// after a toolchain upgrade tells you the wording drifted, and a probe that
// never compiled cannot tell you anything.
//
// Row 6 of the table is not here. It lives in guardfall.swift, and that file
// explains why it has to.
//
// When a diagnostic in here costs you more than ten minutes anywhere else,
// paste it verbatim into NOTES/errors.md with what you thought it meant.

// 1. String and String? are different types, so nil is not a String.
//
// var name: String = "Levi"
// name = nil
//
// error: 'nil' cannot be assigned to type 'String'

// 2. Arithmetic on the wrapper, not on the payload.
//
// let n: Int? = 3
// let m: Int = n + 1
//
// error: value of optional type 'Int?' must be unwrapped to a value of type 'Int'
// note: coalesce using '??' to provide a default when the optional value contains 'nil'
// note: force-unwrap using '!' to abort execution if the optional value contains 'nil'

// 3. There is no truthiness, and Bool? is not Bool.
//
// let flag: Bool? = nil
// if flag { print("on") }
//
// error: value of optional type 'Bool?' must be unwrapped to a value of type 'Bool'

// 4. Member access reaches for a member of the payload's type.
//
// let s: String? = "a"
// print(s.count)
//
// error: value of optional type 'String?' must be unwrapped to refer to member
// 'count' of wrapped base type 'String'

// 5. Conditional binding needs something to unwrap.
//
// let certain: String = "a"
// if let bound = certain { print(bound) }
//
// error: initializer for conditional binding must have Optional type, not 'String'

// 7. A warning, not an error. It compiles and prints the wrong thing.
//
// let nickname: String? = "Lev"
// print("hello \(nickname)")
//
// warning: string interpolation produces a debug description for an optional
// value; did you mean to make this explicit?

print("errors.swift compiles clean. Uncomment one block above and rerun.")
