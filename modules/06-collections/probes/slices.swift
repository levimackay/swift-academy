// A slice shares its base collection's indices. That one sentence is the
// entire bug, and this file is what makes it stop being surprising.
//
//     make probe CH=06 P=slices
//
// Python's list[1:3] is a fresh, zero indexed copy. Swift's base[1..<3] is a
// view whose startIndex is 1, because the point of a slice is to name a
// region of something that already exists without copying it.

let base = [10, 20, 30, 40, 50]
let middle = base[1..<4]

print("base:              \(base)")
print("middle:            \(middle)")
print("middle.count:      \(middle.count)")
print("middle.startIndex: \(middle.startIndex)")
print("middle.endIndex:   \(middle.endIndex)")
print("middle.first:      \(middle.first as Any)")
print("middle[1]:         \(middle[1])")

// So the safe habits are: first, last, and offsets measured from startIndex.
let secondOfSlice = middle[middle.index(middle.startIndex, offsetBy: 1)]
print("second of slice:   \(secondOfSlice)")

// firstIndex returns an index in the base's coordinate system, so subtracting
// startIndex is what turns it into a position within the slice.
if let found = middle.firstIndex(of: 30) {
    print("index of 30:       \(found)")
    print("offset of 30:      \(found - middle.startIndex)")
}

// THE TRAP, which is a run time fatal error rather than a diagnostic. Row 8
// of the chapter table came from uncommenting this and running the file.
//
// print(middle[0])
//
// Swift/SliceBuffer.swift:307: Fatal error: Index out of bounds

// The second cost has no error message at all. A slice keeps its base alive,
// so holding one small slice of a large array retains the whole array. The
// fix at the boundary is to build a fresh collection, which also reindexes
// from zero.
let copied = Array(middle)
print("")
print("copied:            \(copied)")
print("copied.startIndex: \(copied.startIndex)")
print("copied[0]:         \(copied[0])")

// The same shape, one level up: a Substring is String's slice, it shares the
// parent's storage and indices, and String(substring) is the boundary.
let sentence = "collections and transformations"
let firstWord = sentence.prefix(while: { $0 != " " })
print("")
print("type of firstWord: \(type(of: firstWord))")
print("firstWord:         \(firstWord)")
print("as a String:       \(String(firstWord))")
