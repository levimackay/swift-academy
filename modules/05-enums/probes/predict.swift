// Three snippets. Write your prediction in the comment above each one
// before you run the file. The toolchain is the answer key, and there is
// no answer key anywhere in this repository.
//
//   make probe CH=05 P=predict
//
// or, without make:
//
//   swift -swift-version 6 modules/05-enums/probes/predict.swift

// 1. A payload case named without being called. Predict the printed type,
//    and predict whether the second line compiles at all.
//
// prediction:

enum Pulse {
    case quiet
    case beat(Int)
}
let maker = Pulse.beat
print("1:", type(of: maker), type(of: maker(3)))

// 2. Two cases, one `where` clause, and an argument that satisfies both
//    patterns. Predict which branch runs, and predict what happens if you
//    swap the two cases.
//
// prediction:

func band(_ pulse: Pulse) -> String {
    switch pulse {
    case .beat(let n) where n > 100: return "fast"
    case .beat(let n) where n > 60: return "normal"
    case .beat: return "slow"
    case .quiet: return "none"
    }
}
print("2:", band(.beat(120)), band(.beat(61)), band(.beat(60)))

// 3. A raw value round trip through a gap in the range, and the count of a
//    CaseIterable enum whose raw values are not contiguous. Predict both.
//
// prediction:

enum Step: Int, CaseIterable {
    case first = 1
    case third = 3
    case fourth
}
print("3:", Step.allCases.count, Step.fourth.rawValue,
      String(describing: Step(rawValue: 2)))
