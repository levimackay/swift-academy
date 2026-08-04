// Copy on write, made visible, using nothing but the standard library.
//
//     make probe CH=03 P=cow
//
// The chapter's "The model" filmstrip is this file's output. Rerun it after
// a toolchain upgrade: if the booleans move, the filmstrip is stale.
//
// The addresses themselves are different on every run, so nothing here
// prints one. Every line prints whether two arrays currently name the same
// buffer, which is the only part that is stable.

/// True when both arrays are currently backed by the same heap buffer.
/// `withUnsafeBufferPointer` hands you the base address of the storage an
/// array is using right now, and two arrays sharing a buffer report the
/// same one.
func sameBuffer(_ left: [Int], _ right: [Int]) -> Bool {
    let l = left.withUnsafeBufferPointer { $0.baseAddress }
    let r = right.withUnsafeBufferPointer { $0.baseAddress }
    return l == r
}

print("--- an Array is a struct, and a struct copies ---")

var left = [1, 2, 3]
var right = left
print("1. after `var right = left`   shared:", sameBuffer(left, right))

right.append(4)
print("2. after `right.append(4)`    shared:", sameBuffer(left, right))
print("   left:", left, " right:", right)

// The copy happened on the write, not on the assignment. Assignment cost a
// retain. The 4 element buffer was allocated inside `append`, and only
// because two names were looking at the three element one.

left.append(99)
print("3. after `left.append(99)`    shared:", sameBuffer(left, right))
print("   left:", left, " right:", right)

// Passing to a function is the same event as assignment: the callee gets a
// name for the same buffer, and writing through it is what splits them.

func longerByOne(_ values: [Int]) -> [Int] {
    var copy = values
    copy.append(0)
    return copy
}

let original = [7, 8]
let extended = longerByOne(original)
print("4. across a call boundary     shared:", sameBuffer(original, extended))
print("   original:", original, " extended:", extended)

print("")
print("--- the question a copy on write type asks before it writes ---")

// `isKnownUniquelyReferenced` is what `Array` consults internally. It takes
// an inout reference to a class instance and answers whether exactly one
// strong reference to that instance exists right now. It refuses to compile
// for a struct, because a struct has no reference count to read.

final class Token {}

var token = Token()
print("5. one name for the token    unique:", isKnownUniquelyReferenced(&token))

let second = token
print("6. two names for the token   unique:", isKnownUniquelyReferenced(&token))

_ = second
