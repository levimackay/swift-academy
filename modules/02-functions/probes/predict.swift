// Write your prediction in the comment above each `print`, then run:
//
//     make probe CH=02 P=predict
//
// The toolchain is the answer key. There is no other one in this repository.

// 1. Defaults are expressions, evaluated per call, at the call site.
func defaultsPerCall() -> (String, String, String, Int) {
    var stampCount = 0
    func stamp() -> Int {
        stampCount += 1
        return stampCount
    }
    func tagged(_ text: String, id: Int = stamp()) -> String { "\(text)#\(id)" }
    return (tagged("a"), tagged("b"), tagged("c", id: 0), stampCount)
}

// prediction:
print(defaultsPerCall())

// 2. Two variadic parameters in one signature, and a variadic called with
//    nothing at all.
func widths(of leading: Int..., and trailing: Int...) -> (Int, Int) {
    (leading.count, trailing.count)
}

// prediction:
print(widths(of: 1, 2, 3, and: 4), widths())

// 3. inout is copy in, copy out, not an alias or a pointer. Hand it a
//    computed property and the two halves become audible.
struct Meter {
    var raw: Int
    var doubled: Int {
        get {
            print("   get")
            return raw * 2
        }
        set {
            print("   set")
            raw = newValue / 2
        }
    }
}
func addTwo(_ value: inout Int) { value += 2 }
func inoutOnAComputedProperty() -> Int {
    var meter = Meter(raw: 5)
    addTwo(&meter.doubled)
    return meter.raw
}

// prediction, including how many lines print and in what order:
print(inoutOnAComputedProperty())

// 4. Overloading on argument labels alone. These are three functions, and
//    the third one takes no label at all.
func area(width: Double, height: Double) -> String { "rectangle" }
func area(height: Double, width: Double) -> String { "transposed" }
func area(_ side: Double) -> String { "square" }

// prediction:
print(area(width: 2, height: 3), area(height: 3, width: 2), area(2))

// 5. A method reference is a value, and so is an operator.
let lengths = ["swift", "go", "rust"].map(\.count)
let joinTwo: (String, String) -> String = (+)

// prediction:
print(lengths, joinTwo("a", "b"), lengths.reduce(0, +))
