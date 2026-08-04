import Testing
@testable import Chapter05

// Test names describe the behavior, not the exercise number, so a red line
// in the output tells you what is wrong without opening this file.

@Suite("05.1 scaleFactor(forSymbol:)")
struct ScaleFactorTests {
    @Test("maps the kilo symbol to a thousand")
    func mapsKilo() {
        #expect(scaleFactor(forSymbol: "k") == 1_000)
    }

    @Test("maps the mega symbol to a million")
    func mapsMega() {
        #expect(scaleFactor(forSymbol: "M") == 1_000_000)
    }

    @Test("maps the giga symbol to a billion")
    func mapsGiga() {
        #expect(scaleFactor(forSymbol: "G") == 1_000_000_000)
    }

    @Test("is case sensitive, because a lowercase m is a different prefix")
    func isCaseSensitive() {
        #expect(scaleFactor(forSymbol: "m") == nil)
    }

    @Test("rejects the case name spelled out")
    func rejectsCaseName() {
        #expect(scaleFactor(forSymbol: "kilo") == nil)
    }

    @Test("rejects the empty string")
    func rejectsEmptyString() {
        #expect(scaleFactor(forSymbol: "") == nil)
    }
}

@Suite("05.2 symbols(upTo:)")
struct SymbolsUpToTests {
    @Test("stops at the first prefix when asked for the smallest")
    func stopsAtFirst() {
        #expect(symbols(upTo: .kilo) == ["k"])
    }

    @Test("includes everything up to and including the one asked for")
    func includesUpToAndIncluding() {
        #expect(symbols(upTo: .mega) == ["k", "M"])
    }

    @Test("returns declaration order, which is not alphabetical order")
    func returnsDeclarationOrder() {
        #expect(symbols(upTo: .giga) == ["k", "M", "G"])
    }

    @Test("lists every prefix exactly once when asked for the largest")
    func listsEveryPrefixOnce() {
        let all = symbols(upTo: .giga)
        #expect(all.count == 3)
        #expect(all.filter { $0 == "M" }.count == 1)
    }
}

@Suite("05.3 statusLine(for:)")
struct StatusLineTests {
    @Test("says nothing about carriers before a parcel ships")
    func describesPending() {
        #expect(statusLine(for: .pending) == "not shipped yet")
    }

    @Test("counts days out in the plural")
    func describesMultipleDaysOut() {
        #expect(statusLine(for: .inTransit(carrier: "UPS", daysOut: 4))
                == "4 days out via UPS")
    }

    @Test("uses the singular for exactly one day out")
    func describesOneDayOut() {
        #expect(statusLine(for: .inTransit(carrier: "DHL", daysOut: 1))
                == "1 day out via DHL")
    }

    @Test("treats zero and negative days out as arriving today")
    func describesArrivingToday() {
        #expect(statusLine(for: .inTransit(carrier: "USPS", daysOut: 0))
                == "arriving today via USPS")
        #expect(statusLine(for: .inTransit(carrier: "USPS", daysOut: -2))
                == "arriving today via USPS")
    }

    @Test("names the signer when there is one")
    func describesSignedDelivery() {
        #expect(statusLine(for: .delivered(on: "May 2", signedBy: "Ada"))
                == "delivered May 2, signed by Ada")
    }

    @Test("says unsigned rather than printing an optional")
    func describesUnsignedDelivery() {
        #expect(statusLine(for: .delivered(on: "May 2", signedBy: nil))
                == "delivered May 2, unsigned")
    }

    @Test("quotes the reason a parcel was lost")
    func describesLoss() {
        #expect(statusLine(for: .lost(reason: "flood")) == "lost: flood")
    }
}

@Suite("05.4 totalPaid(in:)")
struct TotalPaidTests {
    @Test("collects nothing from an empty statement")
    func emptyStatementCollectsNothing() {
        #expect(totalPaid(in: []) == 0)
    }

    @Test("adds payments together")
    func addsPayments() {
        #expect(totalPaid(in: [.payment(cents: 250), .payment(cents: 175)]) == 425)
    }

    @Test("subtracts refunds from payments")
    func subtractsRefunds() {
        #expect(totalPaid(in: [.payment(cents: 500), .refund(cents: 125)]) == 375)
    }

    @Test("goes negative when refunds exceed payments")
    func refundsCanExceedPayments() {
        #expect(totalPaid(in: [.payment(cents: 100), .refund(cents: 300)]) == -200)
    }

    @Test("ignores a failed line even when its code looks like an amount")
    func ignoresFailedLines() {
        let statement: [Transaction] = [
            .payment(cents: 1_000),
            .failed(code: 402),
            .failed(code: 51),
        ]
        #expect(totalPaid(in: statement) == 1_000)
    }

    @Test("collects nothing from a statement of failures alone")
    func failuresAloneCollectNothing() {
        #expect(totalPaid(in: [.failed(code: 402), .failed(code: 402)]) == 0)
    }
}

@Suite("05.5 evaluate(_:)")
struct EvaluateTests {
    @Test("evaluates a bare literal")
    func evaluatesLiteral() {
        #expect(evaluate(.literal(7)) == 7)
    }

    @Test("negates its operand")
    func negates() {
        #expect(evaluate(.negate(.literal(7))) == -7)
    }

    @Test("cancels a double negation")
    func doubleNegationCancels() {
        #expect(evaluate(.negate(.negate(.literal(5)))) == 5)
    }

    @Test("takes grouping from the shape of the tree, not from precedence")
    func groupingComesFromTheTree() {
        // 2 + (3 * 4) is 14, and (2 + 3) * 4 is 20. Same three literals.
        let sumOfProduct = Expression.add(
            .literal(2),
            .multiply(.literal(3), .literal(4))
        )
        let productOfSum = Expression.multiply(
            .add(.literal(2), .literal(3)),
            .literal(4)
        )
        #expect(evaluate(sumOfProduct) == 14)
        #expect(evaluate(productOfSum) == 20)
    }

    @Test("walks both sides of a multiplication by zero")
    func multiplyingByZeroStillWalksTheOtherSide() {
        #expect(evaluate(.multiply(.literal(0), .negate(.literal(9)))) == 0)
    }

    @Test("recurses to the bottom of a deep tree")
    func recursesThroughDeepTrees() {
        var tree = Expression.literal(0)
        for _ in 1...200 {
            tree = .add(tree, .literal(1))
        }
        #expect(evaluate(tree) == 200)
    }
}

@Suite("05.6 advance(_:on:)")
struct AdvanceTests {
    /// Feeds a sequence of events through the machine, starting from idle.
    private func run(_ events: [Event], from start: Connection = .idle) -> Connection {
        events.reduce(start) { advance($0, on: $1) }
    }

    @Test("starts dialling on the first dial event")
    func dialsFromIdle() {
        #expect(advance(.idle, on: .dial) == .dialing(attempt: 1))
    }

    @Test("counts a rejection as another attempt rather than a failure")
    func rejectionIncrementsTheAttempt() {
        #expect(run([.dial, .rejected]) == .dialing(attempt: 2))
        #expect(run([.dial, .rejected, .rejected]) == .dialing(attempt: 3))
    }

    @Test("gives up on the third rejection with a gateway timeout")
    func thirdRejectionCloses() {
        #expect(run([.dial, .rejected, .rejected, .rejected]) == .closed(code: 504))
    }

    @Test("opens a session and keeps its identifier")
    func connectingOpensASession() {
        #expect(run([.dial, .connected(sessionID: "s-91")])
                == .open(sessionID: "s-91"))
    }

    @Test("closes with the code the hang up carried")
    func hangUpCarriesItsCode() {
        #expect(run([.dial, .connected(sessionID: "s-91"), .hangUp(code: 200)])
                == .closed(code: 200))
    }

    @Test("ignores an event that does not apply in the current state")
    func inapplicableEventsChangeNothing() {
        #expect(advance(.idle, on: .rejected) == .idle)
        #expect(advance(.idle, on: .hangUp(code: 200)) == .idle)
        #expect(advance(.open(sessionID: "s-1"), on: .dial) == .open(sessionID: "s-1"))
    }

    @Test("treats closed as terminal, whatever arrives next")
    func closedIsTerminal() {
        let closed = Connection.closed(code: 504)
        #expect(advance(closed, on: .dial) == closed)
        #expect(advance(closed, on: .connected(sessionID: "s-2")) == closed)
        #expect(advance(closed, on: .rejected) == closed)
    }

    @Test("restarts the attempt count on a fresh dial after a success")
    func attemptCountIsPerDialingRun() {
        let opened = run([.dial, .rejected, .connected(sessionID: "s-3")])
        #expect(opened == .open(sessionID: "s-3"))
        #expect(advance(.idle, on: .dial) == .dialing(attempt: 1))
    }
}
