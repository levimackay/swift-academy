// Three snippets. Write your prediction in the comment above each one
// before you run the file. The toolchain is the answer key, and there is
// no answer key anywhere in this repository.
//
//   make probe CH=01 P=predict
//
// or, without make:
//
//   swift -swift-version 6 modules/01-optionals/probes/predict.swift

// 1. Two double optionals. One is built from the `nil` literal, the other
//    from `.some(nil)`. Predict both printed values.
//
// prediction:

let a: String?? = nil
let b: String?? = .some(nil)
print("1:", a == nil, b == nil)

// 2. The same dictionary lookup, once through optional chaining and once
//    through `map`. Predict both printed types.
//
// prediction:

let scores: [String: [Int]] = ["ada": [7, 8]]
let viaChain = scores["ada"]?.first
let viaMap = scores["ada"].map { $0.first }
print("2:", type(of: viaChain), type(of: viaMap))

// 3. A dictionary whose values are themselves optional. One key is present
//    and stores nil, the other key is absent. Predict both printed values.
//
// prediction:

let readings: [String: Int?] = ["pier": nil]
print("3:", readings["pier"] as Any, readings["dock"] as Any)
