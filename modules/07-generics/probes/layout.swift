// The numbers behind this chapter's diagram, measured rather than recalled.
//
//     make probe CH=07 P=layout
//
// Nothing here is a trick. It is three MemoryLayout reads and one identity
// check, and every number the chapter prints in "The model" came out of this
// file on the toolchain named in the chapter front matter.

protocol Pulse {
    func level() -> Double
}

/// One word of payload, so it fits the existential box's inline buffer.
struct Tick: Pulse {
    var ticks: Int
    func level() -> Double { Double(ticks) }
}

/// Four words of payload, so it does not fit and has to be heap allocated
/// when it is boxed.
struct Wave: Pulse {
    var a, b, c, d: Double
    func level() -> Double { a + b + c + d }
}

print("Tick        ", MemoryLayout<Tick>.size)
print("Wave        ", MemoryLayout<Wave>.size)
print("any Pulse   ", MemoryLayout<any Pulse>.size)
print("[Tick]      ", MemoryLayout<[Tick]>.size)
print("[any Pulse] ", MemoryLayout<[any Pulse]>.size)

// Passing an existential to a generic function opens the box: inside the
// callee there is exactly one concrete type again, and P names it. This is
// implicit existential opening, and it is why so few APIs need to take
// `any P` at all.
func nameOfParameter<P: Pulse>(_ value: P) -> String { "\(P.self)" }
func nameAtRuntime(_ value: any Pulse) -> String { "\(type(of: value))" }

let boxed: any Pulse = Wave(a: 1, b: 2, c: 3, d: 4)
print("opened as   ", nameOfParameter(boxed))
print("dynamic name", nameAtRuntime(boxed))

// Opaque return types keep identity across calls, which is the whole
// difference between `some` and `any` in one line.
func hidden() -> some Pulse { Tick(ticks: 1) }
func alsoHidden() -> some Pulse { Tick(ticks: 2) }
print("same opaque type twice:", type(of: hidden()) == type(of: alsoHidden()))

let mixed: [any Pulse] = [Tick(ticks: 1), Wave(a: 1, b: 1, c: 1, d: 1)]
print("distinct dynamic types in the array:",
      Set(mixed.map { "\(type(of: $0))" }).count)
