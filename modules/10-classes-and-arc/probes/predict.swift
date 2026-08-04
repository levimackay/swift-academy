// Run: make probe CH=10 P=predict
//
// Write your prediction in the blank comment above each print, then run the
// file. The toolchain is the answer key. No answers live in this repo.

final class Meter {
    var reading = 0
    let label: String
    init(label: String) { self.label = label }
    deinit { print("deinit \(label)") }
}

// 1. A `let` binding to a class instance.
let fixed = Meter(label: "fixed")
let alias = fixed
alias.reading = 7
// prediction:
print("1:", fixed.reading, fixed === alias)

// 2. Capture list versus capture. One of these snapshots, one does not.
var pending = 1
let snapshot = { [pending] in pending }
let live = { pending }
pending = 99
// prediction:
print("2:", snapshot(), live())

// 3. Two objects that point at each other, inside a scope that ends.
final class Ring {
    var partner: Ring?
    let name: String
    init(name: String) { self.name = name }
    deinit { print("deinit \(name)") }
}

func makeRing() {
    let left = Ring(name: "left")
    let right = Ring(name: "right")
    left.partner = right
    right.partner = left
    print("3: scope about to end")
}
// prediction: which deinit lines print, and in what order
makeRing()
print("3: scope ended")

// 4. Same shape, one edge changed. Compare the output to snippet 3.
final class Anchor {
    var held: Buoy?
    let name: String
    init(name: String) { self.name = name }
    deinit { print("deinit \(name)") }
}
final class Buoy {
    weak var anchor: Anchor?
    let name: String
    init(name: String) { self.name = name }
    deinit { print("deinit \(name)") }
}

func makeMoored() {
    let a = Anchor(name: "anchor")
    let f = Buoy(name: "buoy")
    a.held = f
    f.anchor = a
    print("4: scope about to end")
}
// prediction:
makeMoored()
print("4: scope ended")
