// Write your prediction on the PREDICTION line above each numbered print,
// then run it. The toolchain is the answer key and no answer key is
// committed anywhere in this repository.
//
//     make probe CH=07 P=predict

protocol Signal {
    func value() -> Double
}

struct Blip: Signal {
    var raw: Int
    func value() -> Double { Double(raw) }
}

struct Burst: Signal {
    var a, b, c, d: Double
    func value() -> Double { a + b + c + d }
}

// 1. Two concrete sizes and the size of the box they both fit into.
//
// PREDICTION:
print(MemoryLayout<Blip>.size,
      MemoryLayout<Burst>.size,
      MemoryLayout<any Signal>.size)                            // 1

// 2. `probe` is declared `any Signal`. What does the generic function see?
//
// PREDICTION:
func typeSeen<R: Signal>(_ value: R) -> String { "\(R.self)" }
let probe: any Signal = Burst(a: 1, b: 2, c: 3, d: 4)
print(typeSeen(probe))                                           // 2

// 3. Two functions, the same declared return type, the same body shape.
//    This print compares their dynamic types. Predict it, then predict
//    whether the type checker lets you assign one result to a variable
//    holding the other.
//
// PREDICTION:
func hiddenA() -> some Signal { Blip(raw: 1) }
func hiddenB() -> some Signal { Blip(raw: 2) }
print(type(of: hiddenA()) == type(of: hiddenB()))                // 3

// 4. Inference through a constrained generic. What is the static type of
//    each of these two results?
//
// PREDICTION:
func firstOrNil<C: Collection>(_ items: C) -> C.Element? { items.first }
let boxes: [any Signal] = [Blip(raw: 1), Burst(a: 0, b: 0, c: 0, d: 0)]
let plain = [Blip(raw: 9)]
print(type(of: firstOrNil(boxes)), type(of: firstOrNil(plain)))  // 4

// 5. `Sequence` has `Element` as a primary associated type, so it can be
//    constrained in angle brackets. What does the constrained existential
//    let you call, and what does the array's own type become?
//
// PREDICTION:
let numbers: any Sequence<Int> = [3, 1, 2]
print(numbers.reduce(0, +), type(of: numbers))                   // 5
