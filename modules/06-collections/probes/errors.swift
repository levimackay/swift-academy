// This file compiles as written. Every commented block below is a real
// mistake with the diagnostic it produced on the toolchain in the chapter
// front matter, pasted verbatim. Uncomment one block at a time and read the
// wording yourself:
//
//     make probe CH=06 P=errors
//
// The chapter's "Where it goes wrong" table is built from this file. The file
// stays green on purpose: a probe that compiles today and stops compiling
// after a toolchain upgrade tells you the wording drifted, and a probe that
// never compiled cannot tell you anything.
//
// Row 8 of the table is not here, because it is a run time trap rather than a
// diagnostic. It lives in slices.swift.
//
// When a diagnostic in here costs you more than ten minutes anywhere else,
// paste it verbatim into NOTES/errors.md with what you thought it meant.

// 1. A String position is not a number, and the standard library says so with
//    an unavailable overload rather than by leaving the subscript out.
//
// let name = "Levi"
// print(name[0])
//
// error: 'subscript(_:)' is unavailable: cannot subscript String with an Int, use a String.Index instead.
// note: 'subscript(_:)' has been explicitly marked unavailable here

// 2. String.Index is an opaque type. It is not a distance from the start and
//    it does not convert to one.
//
// let name = "Levi"
// let position: Int = name.firstIndex(of: "v") ?? name.startIndex
// print(position)
//
// error: cannot convert value of type 'String.Index' to specified type 'Int'

// 3. A slice is its own type, and it is not the array it came from.
//
// let base = [1, 2, 3, 4]
// let middle: [Int] = base[1..<3]
// print(middle)
//
// error: cannot convert value of type 'ArraySlice<Int>' to specified type '[Int]'

// 4. sorted takes a two argument predicate, not Python's key extractor.
//
// struct Entry { var plays: Int }
// let entries = [Entry(plays: 3)]
// print(entries.sorted { $0.plays })
//
// error: contextual closure type '(Entry, Entry) throws -> Bool' expects 2 arguments, but 1 was used in closure body
// error: cannot convert value of type 'Int' to closure result type 'Bool'

// 5. Dictionary lookup returns an Optional, so compound assignment has
//    nothing to add to. The note offering ! is the trap, not the fix.
//
// var tally: [String: Int] = [:]
// tally["ada"] += 1
// print(tally)
//
// error: value of optional type 'Int?' must be unwrapped to a value of type 'Int'
// note: force-unwrap using '!' to abort execution if the optional value contains 'nil'

// 6. Set and Dictionary key membership is decided by Hashable, and Hashable
//    is synthesised only when every stored property already has it.
//
// struct Point { var x: Int }
// let corners: Set<Point> = [Point(x: 1)]
// print(corners)
//
// error: type 'Point' does not conform to protocol 'Hashable'

// 7. Slicing a String yields a Substring, and the conversion at the boundary
//    is a real initialiser call rather than a coercion.
//
// let name = "Levi"
// let tail = name[name.index(after: name.startIndex)...]
// print(tail as String)
//
// error: cannot convert value of type 'String.SubSequence' (aka 'Substring') to type 'String' in coercion

print("errors.swift compiles clean. Uncomment one block above and rerun.")
