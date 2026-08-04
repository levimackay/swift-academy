// Chapter 05 exercises.
//
// Every function below returns a compiling wrong value so that the suite
// runs and reports a score instead of aborting. Replace each body.
//
//   swift test --filter Chapter05Tests
//
// House rule for this chapter, checked by the last item of the Done when
// list: no `default` in any switch over an enum declared in this file. Every
// one of these enums is yours, so the compiler is willing to tell you when
// you miss a case. A `default` throws that away.

// MARK: - 1. scaleFactor(forSymbol:)

/// SI multiplier prefixes, in increasing order of magnitude. The raw value
/// is the printed symbol, which is case sensitive: `M` is mega, and `m`
/// would be milli, which this enum does not model.
enum Prefix: String, CaseIterable {
    case kilo = "k"
    case mega = "M"
    case giga = "G"
}

/// Returns the multiplier a symbol stands for: 1e3 for `k`, 1e6 for `M`,
/// 1e9 for `G`. Any other string, including the empty string, the case name
/// spelled out, and a symbol in the wrong case, is nil.
func scaleFactor(forSymbol symbol: String) -> Double? {
    // TODO: replace this.
    return nil
}

// MARK: - 2. symbols(upTo:)

/// Returns the symbols of every prefix from the smallest through `prefix`
/// inclusive, in declaration order. `symbols(upTo: .kilo)` is `["k"]`.
func symbols(upTo prefix: Prefix) -> [String] {
    // TODO: replace this.
    return []
}

// MARK: - 3. statusLine(for:)

/// Where a parcel is. Every case carries exactly what that situation needs
/// and nothing it does not, which is why there is no `carrier` field on a
/// parcel that has not shipped.
enum Shipment {
    case pending
    case inTransit(carrier: String, daysOut: Int)
    case delivered(on: String, signedBy: String?)
    case lost(reason: String)
}

/// One line of customer facing text:
///
///   .pending                                  -> "not shipped yet"
///   .inTransit, daysOut <= 0                  -> "arriving today via UPS"
///   .inTransit, daysOut == 1                  -> "1 day out via UPS"
///   .inTransit, daysOut > 1                   -> "4 days out via UPS"
///   .delivered(on: "May 2", signedBy: nil)    -> "delivered May 2, unsigned"
///   .delivered(on: "May 2", signedBy: "Ada")  -> "delivered May 2, signed by Ada"
///   .lost(reason: "flood")                    -> "lost: flood"
func statusLine(for shipment: Shipment) -> String {
    // TODO: replace this.
    return ""
}

// MARK: - 4. totalPaid(in:)

/// One line on a statement. Amounts are in whole cents and are never
/// negative; the direction of the money is the case, not the sign.
enum Transaction {
    case payment(cents: Int)
    case refund(cents: Int)
    case failed(code: Int)
}

/// The net amount collected, in cents: payments minus refunds. A `.failed`
/// line moved no money and contributes nothing, whatever its code says.
/// An empty statement collected zero.
func totalPaid(in transactions: [Transaction]) -> Int {
    // TODO: replace this.
    return -1
}

// MARK: - 5. evaluate(_:)

/// An arithmetic expression as a tree. Precedence and grouping are already
/// resolved by the shape of the tree, so there is nothing to parse.
indirect enum Expression {
    case literal(Int)
    case negate(Expression)
    case add(Expression, Expression)
    case multiply(Expression, Expression)
}

/// The value of the expression. Every node is evaluated; there is no short
/// circuit, and multiplying by a literal zero still walks the other side.
func evaluate(_ expression: Expression) -> Int {
    // TODO: replace this.
    return -1
}

// MARK: - 6. advance(_:on:)

/// The state of one outbound connection. `attempt` counts dial attempts
/// starting at 1, and `sessionID` only exists once a session does.
enum Connection: Equatable {
    case idle
    case dialing(attempt: Int)
    case open(sessionID: String)
    case closed(code: Int)
}

/// Something that happened to a connection.
enum Event: Equatable {
    case dial
    case connected(sessionID: String)
    case rejected
    case hangUp(code: Int)
}

/// The transition table, as a function.
///
///   .idle          + .dial              -> .dialing(attempt: 1)
///   .dialing(n)    + .connected(id)     -> .open(sessionID: id)
///   .dialing(n)    + .rejected, n < 3   -> .dialing(attempt: n + 1)
///   .dialing(n)    + .rejected, n >= 3  -> .closed(code: 504)
///   .open          + .hangUp(code)      -> .closed(code: code)
///
/// Every other pair is an event that does not apply in that state, and an
/// event that does not apply changes nothing: return the state unchanged.
/// `.closed` is terminal, so nothing reopens it.
func advance(_ state: Connection, on event: Event) -> Connection {
    // TODO: replace this.
    return .closed(code: -1)
}
