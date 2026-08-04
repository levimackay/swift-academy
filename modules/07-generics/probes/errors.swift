// This file compiles as written. Every commented block below is a real
// mistake with the diagnostic it produced on the toolchain in the chapter
// front matter, pasted verbatim. Uncomment one block at a time and read the
// wording yourself:
//
//     make probe CH=07 P=errors
//
// The chapter's "Where it goes wrong" table is blocks 1 through 8. Blocks 9
// through 11 are the same three ideas one step further on, and they are here
// because each one costs an afternoon the first time.
//
// When a diagnostic in here costs you more than ten minutes anywhere else,
// paste it verbatim into NOTES/errors.md with what you thought it meant.

// 1. An unconstrained type parameter can do almost nothing. `>` is not a
//    builtin, it is a requirement of Comparable, and T does not have it.
//
// func biggest<T>(_ a: T, _ b: T) -> T { a > b ? a : b }
//
// error: referencing operator function '>' on 'Comparable' requires that 'T' conform to 'Comparable'
// note: where 'Self' = 'T'

// 2. A constraint on a generic type is checked where the type is named, not
//    where a member is called.
//
// struct Bag<Item: Hashable> { var items: [Item] = [] }
// struct Note { let text: String }
// let bag = Bag<Note>()
//
// error: type 'Note' does not conform to protocol 'Hashable'

// 3. `some` promises exactly one concrete type for every path through the
//    body. Two returns of two types is two promises.
//
// protocol Shape { func area() -> Double }
// struct Circle: Shape { func area() -> Double { 3.14 } }
// struct Square: Shape { func area() -> Double { 1.0 } }
// func pick(_ flag: Bool) -> some Shape { flag ? Circle() : Square() }
//
// error: result values in '? :' expression have mismatching types 'Circle' and 'Square'

// 4. A box is not a conformer. `any Shape` is a type that holds a Shape and
//    is not itself one, so it cannot satisfy `S: Shape`.
//
// protocol Shape { func area() -> Double }
// struct Circle: Shape { func area() -> Double { 3.14 } }
// struct Square: Shape { func area() -> Double { 1.0 } }
// let shapes: [any Shape] = [Circle(), Square()]
// func widest<S: Shape>(_ items: [S]) -> S? { items.first }
// _ = widest(shapes)
//
// note: required by global function 'widest' where 'S' = 'any Shape'
// error: type 'any Shape' cannot conform to 'Shape' [#ProtocolTypeNonConformance]
// note: only concrete types such as structs, enums and classes can conform to protocols

// 5. An associated type in parameter position cannot be reached through a
//    box, because the box does not say which Item it will accept.
//
// protocol Container {
//     associatedtype Item
//     var items: [Item] { get }
//     mutating func add(_ item: Item)
// }
// struct Bin: Container {
//     var items: [Int]
//     mutating func add(_ item: Int) { items.append(item) }
// }
// var box: any Container = Bin(items: [1])
// box.add(7)
//
// error: member 'add' cannot be used on value of type 'any Container'; consider using a generic constraint instead [#ExistentialMemberAccess]

// 6. A Self requirement is the same wall from the other side. Two boxes may
//    hold two types, so there is no single Self for == to be about.
//
// let scores: [any Equatable] = [1, "a"]
// let same = scores[0] == scores[1]
//
// error: binary operator '==' cannot be applied to two 'any Equatable' operands
// note: candidate requires that 'any Equatable' conform to 'Equatable' (requirement specified as 'Self' : 'Equatable')

// 7. Constraining an existential in angle brackets works only for a protocol
//    that declared which associated type is the primary one.
//
// protocol Store { associatedtype Value }
// struct Cell<T>: Store { typealias Value = T }
// let s: any Store<Int> = Cell<Int>()
//
// error: protocol 'Store' does not have primary associated types that can be constrained

// 8. The existential has to be spelled out. Verified on this toolchain: this
//    is a warning here and a warning under `swift build` too, with the same
//    wording, even though every target in Package.swift enables the
//    ExistentialAny upcoming feature. Treat it as an error anyway. It is one
//    in the language mode this repo is preparing you for, and the whole
//    point of the flag is that you never write the unspelled form again.
//
// protocol Keyed { associatedtype Tag }
// struct Note: Keyed { typealias Tag = Int }
// let notes: [Keyed] = [Note()]
//
// warning: use of protocol 'Keyed' as a type must be written 'any Keyed'; this will be an error in a future Swift language mode [#ExistentialAny]

// 9. The caller of an opaque return type knows there is one concrete type
//    and does not get to know which one. This is the deal, not a bug.
//
// protocol Shape { func area() -> Double }
// struct Circle: Shape { func area() -> Double { 3.14 } }
// func makeShape() -> some Shape { Circle() }
// let c: Circle = makeShape()
//
// error: cannot convert value of type 'some Shape' to specified type 'Circle'

// 10. Inference runs from the arguments and from the context inward. A
//     parameter that appears only in the return type has neither.
//
// func decoded<T: RangeReplaceableCollection>() -> T { T() }
// let value = decoded()
//
// error: generic parameter 'T' could not be inferred
// note: in call to function 'decoded()'

// 11. Conditional conformance is checked as a whole. Constraining one of two
//     parameters leaves the other one unconstrained, and synthesis needs
//     both. The error is followed by a dozen notes about unrelated protocols
//     the compiler also tried; the last one is the useful one.
//
// struct Pair<A, B> { let a: A; let b: B }
// extension Pair: Equatable where A: Equatable {}
//
// error: type 'Pair<A, B>' does not conform to protocol 'Equatable'
// note: protocol requires function '==' with type '(Pair<A, B>, Pair<A, B>) -> Bool'

print("errors.swift compiles. Uncomment one block at a time.")
