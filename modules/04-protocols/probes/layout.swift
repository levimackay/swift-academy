// What an existential costs, measured rather than asserted.
//
//     make probe CH=04 P=layout
//
// A value held as `any Sample` is not the value. It is a box: three words of
// inline storage, one pointer to the type's metadata, and one pointer to the
// witness table for each protocol in the composition. Anything that does not
// fit in the three inline words is allocated on the heap and the box holds a
// pointer to it instead.

protocol Sample {
    var reading: Double { get }
}

protocol Stamped {
    var stampedAt: Int { get }
}

struct Small: Sample {
    var reading: Double
}

struct Wide: Sample, Stamped {
    var reading: Double
    var second: Double
    var third: Double
    var fourth: Double
    var stampedAt: Int
}

func row(_ label: String, _ size: Int, _ stride: Int) {
    let padded = label + String(repeating: " ", count: max(0, 26 - label.count))
    print("  \(padded) size \(size)  stride \(stride)")
}

print("concrete values")
row("Small", MemoryLayout<Small>.size, MemoryLayout<Small>.stride)
row("Wide", MemoryLayout<Wide>.size, MemoryLayout<Wide>.stride)

print("boxed values")
row("any Sample", MemoryLayout<any Sample>.size, MemoryLayout<any Sample>.stride)
row("any Sample & Stamped", MemoryLayout<any Sample & Stamped>.size, MemoryLayout<any Sample & Stamped>.stride)
row("[any Sample] element", MemoryLayout<[any Sample]>.size, MemoryLayout<[any Sample]>.stride)

print("word size on this target: \(MemoryLayout<Int>.size)")
print("Small fits inline. Wide is \(MemoryLayout<Wide>.size) bytes, which is more")
print("than three words, so boxing it costs a heap allocation as well.")
