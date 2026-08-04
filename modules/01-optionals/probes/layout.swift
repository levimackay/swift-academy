// The numbers behind the diagram in the chapter's "The model" section.
//
//   make probe CH=01 P=layout
//
// If Optional were an annotation the compiler erased, every pair below
// would print the same two numbers. Two of them do not.

func report<T>(_ label: String, _ type: T.Type) {
    let padded = label + String(repeating: " ", count: max(0, 10 - label.count))
    print(padded, "size", MemoryLayout<T>.size, "stride", MemoryLayout<T>.stride)
}

report("String", String.self)
report("String?", String?.self)
report("String??", String??.self)
print("")
report("Int", Int.self)
report("Int?", Int?.self)
report("Int??", Int??.self)
print("")
report("Bool", Bool.self)
report("Bool?", Bool?.self)
report("Bool?????", Bool?????.self)
