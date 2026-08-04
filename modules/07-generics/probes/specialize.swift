// What the box costs, measured on your machine rather than asserted.
//
//     make probe CH=07 P=specialize
//     make probe CH=07 P=specialize ARGS=2000000
//
// The same summation runs three ways over the same values:
//
//   concrete    a plain [Wave] and a non generic loop
//   generic     <T: Pulse>, one type per call, chosen by the caller
//   existential [any Pulse], where every element is a box and every call
//               goes through that element's witness table
//
// Read the shape, never the digits. Timings differ on every run, on every
// machine, and above all with the optimization level.
//
// 1. `make probe` builds unoptimized. At -Onone the three summing rows sit
//    close together, and that is the correct observation rather than a
//    broken probe. Specialization is an optimizer transform, so asking for
//    it at -Onone and concluding it is a myth is the wrong experiment.
//    Built with optimization on the machine this chapter was written on,
//    the concrete and generic rows fall to a rounding error while the
//    existential row still costs per element, because the loop that knows
//    its element type can be inlined and unrolled and the loop reading a
//    witness table per element cannot.
//
// 2. Boxing is a real, separate, unavoidable line item, and it is the one
//    cost that survives every optimization level. `Wave` is four words and
//    the existential's inline buffer is three, so each element gets a heap
//    allocation on the way into `[any Pulse]`. Nothing in the source of
//    that conversion says "allocate five hundred thousand times".

import Foundation

protocol Pulse {
    func level() -> Double
}

/// Four words of payload, which is one more than the box holds inline.
struct Wave: Pulse {
    var a, b, c, d: Double
    func level() -> Double { a + b + c + d }
}

let iterations = Int(CommandLine.arguments.dropFirst().first ?? "") ?? 500_000
let waves = (0..<iterations).map {
    Wave(a: Double($0 % 7), b: 1, c: 1, d: 1)
}

func timed<T>(_ label: String, _ body: () -> T) -> T {
    let padded = label.padding(toLength: 24, withPad: " ", startingAt: 0)
    let start = Date()
    let result = body()
    let elapsed = Date().timeIntervalSince(start)
    print(padded, String(format: "%8.4fs", elapsed))
    return result
}

func sumConcrete(_ values: [Wave]) -> Double {
    var total = 0.0
    for value in values { total += value.level() }
    return total
}

func sumGeneric<T: Pulse>(_ values: [T]) -> Double {
    var total = 0.0
    for value in values { total += value.level() }
    return total
}

func sumExistential(_ values: [any Pulse]) -> Double {
    var total = 0.0
    for value in values { total += value.level() }
    return total
}

print("elements:", iterations)
let boxed = timed("boxing into [any Pulse]") { waves as [any Pulse] }
_ = timed("sum, concrete") { sumConcrete(waves) }
_ = timed("sum, generic") { sumGeneric(waves) }
_ = timed("sum, existential") { sumExistential(boxed) }

// The three summing functions are character for character identical below
// their signatures. Only the signatures differ, and only the third one
// required a 40 byte box per element with the payload spilled to the heap.
print("Wave size     ", MemoryLayout<Wave>.size)
print("any Pulse size", MemoryLayout<any Pulse>.size)
