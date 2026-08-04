// Every pattern form the chapter names, in one runnable file.
//
//   make probe CH=05 P=matching
//
// Read it top to bottom once, then come back to it when a pattern in an
// exercise will not compile and you want to see the shape that does.

enum Packet {
    case heartbeat
    case telemetry(sensor: String, value: Double)
    case command(name: String, argument: String?)
    case failure(code: Int, retryable: Bool)
}

let feed: [Packet] = [
    .heartbeat,
    .telemetry(sensor: "hull", value: 12.5),
    .telemetry(sensor: "hull", value: -0.5),
    .command(name: "reboot", argument: nil),
    .command(name: "seek", argument: "0.75"),
    .failure(code: 503, retryable: true),
    .failure(code: 401, retryable: false),
]

// 1. Value binding, one `let` per payload. The bindings are constants and
//    they exist only inside their own case body.
print("1. value binding")
for packet in feed {
    switch packet {
    case .heartbeat:
        print("   heartbeat")
    case .telemetry(let sensor, let value):
        print("   \(sensor) reads \(value)")
    case .command(let name, let argument):
        print("   command \(name), argument \(argument ?? "none")")
    case .failure(let code, let retryable):
        print("   failure \(code), retryable \(retryable)")
    }
}

// 2. `case let` hoists the `let` to the front when every binding is a let.
//    Identical meaning, fewer keywords. Mixing is legal and rarely useful.
print("")
print("2. case let, hoisted")
for packet in feed {
    switch packet {
    case let .telemetry(sensor, value):
        print("   \(sensor) \(value)")
    default:
        break
    }
}

// 3. A `where` clause filters a case after its bindings exist, so the order
//    of cases starts to matter: the first match wins.
print("")
print("3. where clauses, first match wins")
for packet in feed {
    switch packet {
    case .telemetry(let sensor, let value) where value < 0:
        print("   \(sensor) is below zero, ignoring")
    case .telemetry(let sensor, _):
        print("   \(sensor) is in range")
    default:
        break
    }
}

// 4. Nested patterns. The payload of `.command` is itself an Optional, which
//    is an enum, so its cases can be matched in the same pattern.
print("")
print("4. nested patterns")
for packet in feed {
    switch packet {
    case .command(let name, .none):
        print("   \(name) takes no argument")
    case .command(let name, .some(let argument)):
        print("   \(name) takes \(argument)")
    default:
        break
    }
}

// 5. Tuple patterns. Switching on a pair matches both halves at once, which
//    is how a transition table stops being nested ifs.
print("")
print("5. tuple patterns")
func summary(_ first: Packet, _ second: Packet) -> String {
    switch (first, second) {
    case (.heartbeat, .heartbeat):
        return "idle"
    case (.failure(let code, true), _), (_, .failure(let code, true)):
        return "retry after \(code)"
    case (.failure(let code, false), _), (_, .failure(let code, false)):
        return "give up after \(code)"
    default:
        return "traffic"
    }
}
print("   " + summary(.heartbeat, .heartbeat))
print("   " + summary(.heartbeat, .failure(code: 503, retryable: true)))
print("   " + summary(.failure(code: 401, retryable: false), .heartbeat))

// 6. `if case` is a one case switch as an expression position statement, and
//    `guard case` is the same match that binds for the rest of the scope.
print("")
print("6. if case and guard case")
func retryDelay(_ packet: Packet) -> Int? {
    guard case .failure(let code, true) = packet else { return nil }
    return code >= 500 ? 2 : 30
}
for packet in feed {
    if case .failure = packet {
        print("   failure, delay \(retryDelay(packet).map(String.init) ?? "none")")
    }
}

// 7. `for case` filters while it iterates. No optional survives the loop,
//    and no `if` appears in the body.
print("")
print("7. for case")
var sensorTotal = 0.0
for case .telemetry(_, let value) in feed {
    sensorTotal += value
}
print("   telemetry sums to \(sensorTotal)")

for case .failure(let code, retryable: true) in feed {
    print("   retryable failure \(code)")
}

// 8. Raw values are a separate feature from payloads, and CaseIterable only
//    exists for an enum whose cases take no arguments.
print("")
print("8. raw values and CaseIterable")
enum Band: Int, CaseIterable {
    case low = 2
    case mid = 5
    case high = 8
}
print("   allCases in declaration order: \(Band.allCases.map(\.rawValue))")
print("   Band(rawValue: 5) is \(String(describing: Band(rawValue: 5)))")
print("   Band(rawValue: 6) is \(String(describing: Band(rawValue: 6)))")

// 9. `indirect` boxes the recursive payload so the enum has a fixed size.
print("")
print("9. indirect")
indirect enum Filter {
    case tag(String)
    case not(Filter)
    case any([Filter])
}

func matches(_ filter: Filter, tags: [String]) -> Bool {
    switch filter {
    case .tag(let name):
        return tags.contains(name)
    case .not(let inner):
        return !matches(inner, tags: tags)
    case .any(let filters):
        return filters.contains { matches($0, tags: tags) }
    }
}

let rule = Filter.any([.tag("urgent"), .not(.tag("archived"))])
print("   urgent only: \(matches(rule, tags: ["urgent"]))")
print("   archived only: \(matches(rule, tags: ["archived"]))")
