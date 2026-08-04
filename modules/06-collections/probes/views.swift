// The four views of one string, printed side by side. This file is what the
// diagram in the chapter's "The model" section was built from, so if a
// toolchain upgrade ever changes one of these numbers, the diagram is the
// thing that is now wrong.
//
//     make probe CH=06 P=views
//
// The string is a five character name, a space, and one family emoji built
// from three people joined by two zero width joiners.

let name = "Levi \u{1F468}\u{200D}\u{1F469}\u{200D}\u{1F467}"

print("the string:      \(name)")
print("Character:       \(name.count)")
print("unicodeScalars:  \(name.unicodeScalars.count)")
print("utf8:            \(name.utf8.count)")
print("utf16:           \(name.utf16.count)")

// Each view is a real Collection with its own Element type, so each one can
// be iterated, filtered, and indexed on its own terms.
print("")
print("Element of the String:      \(type(of: name.first))")
print("Element of unicodeScalars:  \(type(of: name.unicodeScalars.first))")
print("Element of utf8:            \(type(of: name.utf8.first))")
print("Element of utf16:           \(type(of: name.utf16.first))")

// Canonical equivalence: two different scalar sequences, one Character, and
// == says they are the same string. This is the reason count is not a byte
// count and can never be one.
let composed = "\u{E9}"          // one scalar, LATIN SMALL LETTER E WITH ACUTE
let decomposed = "e\u{301}"      // two scalars, e followed by COMBINING ACUTE

print("")
print("composed == decomposed:  \(composed == decomposed)")
print("counts:                  \(composed.count) and \(decomposed.count)")
print("scalar counts:           \(composed.unicodeScalars.count) and \(decomposed.unicodeScalars.count)")
print("utf8 counts:             \(composed.utf8.count) and \(decomposed.utf8.count)")

// String is BidirectionalCollection, not RandomAccessCollection. That single
// fact is the whole reason integer subscripting is unavailable rather than
// merely missing: there is no constant time way to serve it.
func conformances<C: Collection>(_ collection: C) -> String {
    let forward = collection is any BidirectionalCollection
    let random = collection is any RandomAccessCollection
    return "bidirectional \(forward), random access \(random)"
}

print("")
print("String:  \(conformances(name))")
print("Array:   \(conformances([1, 2, 3]))")

// An index is produced by the string, and advancing one is a walk, not an
// addition. This is the only index arithmetic the chapter needs.
let fifth = name.index(name.startIndex, offsetBy: 5)
print("character at offset 5:  \(name[fifth])")
