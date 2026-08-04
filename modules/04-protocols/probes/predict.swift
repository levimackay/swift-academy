// Three snippets. Write your prediction in the comment above each one before
// you run the file. The toolchain is the answer key, and there is no answer
// key anywhere in this repository.
//
//   make probe CH=04 P=predict

// 1. Two extensions on one protocol supply the same member, one of them
//    behind a constraint that this type satisfies. Predict both printed
//    strings, and say which extension each one came from.
//
// prediction:

protocol Beacon {}

extension Beacon {
    var pulse: String { "plain" }
}

extension Beacon where Self: Equatable {
    var pulse: String { "equatable" }
}

struct Lamp: Beacon, Equatable {}

let lamp = Lamp()
let boxedLamp: any Beacon = lamp
print("1:", lamp.pulse, boxedLamp.pulse)

// 2. `Chime` declares one requirement and the extension supplies a default
//    for it, so `Bell` compiles without writing it. Predict what a value of
//    `Bell` prints, and what the same value prints once it is an element of
//    an array declared as `[any Chime]`.
//
// prediction:

protocol Chime {
    var toneName: String { get }
}

extension Chime {
    var toneName: String { "default" }
}

struct Bell: Chime {
    var toneName: String { "bell" }
}

struct Gong: Chime {}

let ringers: [any Chime] = [Bell(), Gong()]
print("2:", Bell().toneName, ringers.map(\.toneName))

// 3. One value, three questions asked of the box. Predict all three printed
//    values, including whether the composition check succeeds.
//
// prediction:

protocol Cooled {}
protocol Sealed {}
struct Vial: Cooled, Sealed {}

let sample: any Cooled = Vial()
print("3:", sample is Vial, sample is any Sealed, (sample as? any Sealed) != nil)
