// Eager versus lazy, shown as evaluation order rather than as a paragraph.
// Both pipelines below are spelled almost identically and both answer 36.
// The interleaving in the output is the whole difference.
//
//     make probe CH=06 P=lazy
//
// Read the eager block first. Every "square" line prints before any "check"
// line, because map ran to completion and built an array before first(where:)
// was handed anything at all.

let inputs = Array(1...8)

func squared(_ value: Int) -> Int {
    print("  square \(value)")
    return value * value
}

func isBigEnough(_ value: Int) -> Bool {
    print("  check  \(value)")
    return value > 30
}

print("eager: inputs.map(squared).first(where: isBigEnough)")
let eagerAnswer = inputs.map(squared).first(where: isBigEnough)
print("answer: \(eagerAnswer as Any)")

print("")
print("lazy: inputs.lazy.map(squared).first(where: isBigEnough)")
let lazyAnswer = inputs.lazy.map(squared).first(where: isBigEnough)
print("answer: \(lazyAnswer as Any)")

// Count the work. Eager squares all eight and checks until it finds one.
// Lazy squares one, checks it, squares the next, and stops the instant the
// predicate is satisfied. Nothing after the sixth element is ever touched.

// The trap worth internalising: .lazy is not sticky, and a contextual type
// silently undoes it. Both lines below compile.
let stillLazy = inputs.lazy.map { $0 * 2 }
let notLazyAnyMore: [Int] = inputs.lazy.map { $0 * 2 }

print("")
print("type of stillLazy:       \(type(of: stillLazy))")
print("type of notLazyAnyMore:  \(type(of: notLazyAnyMore))")

// Asking for [Int] made the compiler pick Sequence.map, which returns an
// array, over LazyMapSequence's own map, which returns a view. The laziness
// did not warn you that it left. It just left.

// Where laziness actually pays, and where it costs. Three cases:
//
//   pays:    a long or infinite source with an early exit
//   pays:    a chain of several transforms where only a prefix is consumed
//   costs:   a short source consumed in full, where the view's per element
//            closure calls are pure overhead against one tight loop
//
// An infinite source is the case where lazy is not an optimisation but a
// correctness requirement. Drop the .lazy from the next line and the program
// does not run slower, it never finishes.
let firstCubeOverAThousand = sequence(first: 1) { $0 + 1 }
    .lazy
    .map { $0 * $0 * $0 }
    .first { $0 > 1000 }

print("")
print("first cube over 1000: \(firstCubeOverAThousand as Any)")
