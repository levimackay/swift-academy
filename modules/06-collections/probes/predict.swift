// Write your prediction in the comment above each print, then run:
//
//     make probe CH=06 P=predict
//
// The toolchain is the answer key, and no answer key exists in this
// repository. The ones you get right cost you a minute. The ones you get
// wrong are each a place where Index, Element, or evaluation order is not
// what a Python instinct says it is.

// 1. Two collections built from the same six strings. What does each print,
//    and is either one stable if you run the file again?
// prediction:
let words = ["fig", "date", "plum", "kiwi", "pear", "lime"]
print(Set(words).first as Any)
print(Dictionary(grouping: words, by: \.count).keys.sorted())

// 2. One of these two lines is a Dictionary and one is not. Which, and what
//    is the Element type of each?
// prediction:
let lengths = ["fig": 3, "date": 4]
print(type(of: lengths.mapValues { $0 * 2 }))
print(type(of: lengths.map { $0.value * 2 }))

// 3. A default subscript on a value that is present, and on one that is not.
//    Does either line insert a key?
// prediction:
var stock = ["fig": 2]
print(stock["fig", default: 0], stock["plum", default: 0])
print(stock.keys.sorted())

// 4. Value semantics and copy on write. How many of these print the mutation?
// prediction:
var original = [1, 2, 3]
let alias = original
original.append(4)
print(original.count, alias.count)

// 5. zip stops at the shorter one, and prefix does not complain about a
//    number larger than the collection. What comes out?
// prediction:
print(Array(zip([1, 2, 3], ["a", "b"])))
print(Array([1, 2].prefix(10)), Array([1, 2].dropFirst(10)))

// 6. compactMap over a sequence of optionals, and the same call spelled with
//    a transform that cannot fail.
// prediction:
let maybeNumbers: [Int?] = [1, nil, 3]
print(maybeNumbers.compactMap { $0 })
print(["1", "x", "3"].compactMap(Int.init))

// 7. reduce with an initial result, and reduce(into:) with an inout body.
//    Same answer? Same number of intermediate arrays?
// prediction:
let pairs = [("a", 1), ("b", 2), ("a", 3)]
print(pairs.reduce(into: [String: Int]()) { $0[$1.0, default: 0] += $1.1 })

// 8. flatMap over an array of arrays, and first(where:) on a chain that
//    cannot be satisfied.
// prediction:
print([[1, 2], [], [3]].flatMap { $0 })
print([1, 2, 3].first { $0 > 99 } as Any)

// 9. The one that catches everyone. What is the count, and what is the type
//    of the thing sliced out of it?
// prediction:
let label = "Levi \u{1F468}\u{200D}\u{1F469}\u{200D}\u{1F467}"
print(label.count, label.utf8.count)
print(type(of: label.dropLast(1)))
