// Four snippets. Write your prediction in the comment above each one
// before you run the file. The toolchain is the answer key, and there is
// no answer key anywhere in this repository.
//
//   make probe CH=03 P=predict
//
// The first three are in the chapter. The fourth is only here, because it
// needs a class next to a struct to make its point.

// 1. Two array bindings and one append. Predict both counts, and then say
//    out loud how many heap buffers existed at each of the three lines.
//
// prediction:

var earlier = [1, 2, 3]
var later = earlier
later.append(4)
print("1:", earlier.count, later.count)

// 2. A struct with two stored properties: one Int, one reference to a
//    class. `two` is a copy of `one`, and both properties are written
//    through the copy. Predict both printed values.
//
// prediction:

final class Dial { var ticks = 0 }
struct Cluster {
    var dial = Dial()
    var scale = 1
}

var one = Cluster()
var two = one
two.scale = 5
two.dial.ticks = 7
print("2:", one.scale, one.dial.ticks)

// 3. `Pin` declares `==` by hand and lets the compiler synthesize the rest
//    of Hashable from the stored properties. Predict both booleans, and say
//    which of the two rules the compiler was never told about.
//
// prediction:

struct Pin: Hashable {
    let mark: String
    let visits: Int

    static func == (lhs: Pin, rhs: Pin) -> Bool {
        lhs.mark == rhs.mark
    }
}

let leftPin = Pin(mark: "a", visits: 1)
let rightPin = Pin(mark: "a", visits: 2)
print("3:", leftPin == rightPin, leftPin.hashValue == rightPin.hashValue)

// 3b. The same two pins, put into a Set. Run this file three times before
//     you decide what the answer is. `Hasher` is seeded once per process, so
//     whether these two land in one bucket is decided fresh on every launch.
//     An inconsistent conformance does not buy you a wrong answer, it buys
//     you a different answer per run, which is the expensive kind.
//
// prediction:

print("3b:", Set([leftPin, rightPin]).count)

// 4. Both bindings below are `let`. One of the two writes compiles.
//    Predict which, and predict what the print produces.
//
// prediction:

final class Lamp { var lit = false }
struct Bulb { var lit = false }

let lamp = Lamp()
lamp.lit = true

let bulb = Bulb()
// bulb.lit = true      // uncomment me, then read errors.swift block 1

print("4:", lamp.lit, bulb.lit)
