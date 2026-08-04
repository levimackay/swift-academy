import Testing
@testable import Chapter03

// Test names describe the behavior, not the exercise number, so a red line
// in the output tells you what is wrong without opening this file.

@Suite("03.1 Basket")
struct BasketTests {
    @Test("stocking an item puts it at the end of the lines")
    func stockAppendsInOrder() {
        var basket = Basket()
        basket.stock("apples")
        basket.stock("bread")
        #expect(basket.lines == ["apples", "bread"])
    }

    @Test("keeps a repeated item twice rather than collapsing it")
    func keepsDuplicates() {
        var basket = Basket(lines: ["milk"])
        basket.stock("milk")
        #expect(basket.lines == ["milk", "milk"])
    }

    @Test("a copy taken before the change does not see the change")
    func copyTakenBeforeIsUnaffected() {
        var original = Basket(lines: ["salt"])
        let copy = original
        original.stock("pepper")
        #expect(copy.lines == ["salt"])
        #expect(original.lines == ["salt", "pepper"])
    }

    @Test("a copy taken after the change carries it and then diverges")
    func copyTakenAfterDiverges() {
        var first = Basket(lines: ["salt"])
        first.stock("pepper")
        var second = first
        second.stock("cumin")
        #expect(first.lines == ["salt", "pepper"])
        #expect(second.lines == ["salt", "pepper", "cumin"])
    }

    @Test("the nonmutating form leaves its receiver alone")
    func stockingDoesNotTouchTheReceiver() {
        let start = Basket(lines: ["rice"])
        let extended = start.stocking("beans")
        #expect(start.lines == ["rice"])
        #expect(extended.lines == ["rice", "beans"])
    }

    @Test("two nonmutating calls on one basket do not stack on each other")
    func stockingTwiceFromOneBasketDoesNotAccumulate() {
        let start = Basket(lines: ["rice"])
        let left = start.stocking("beans")
        let right = start.stocking("corn")
        #expect(left.lines == ["rice", "beans"])
        #expect(right.lines == ["rice", "corn"])
    }

    @Test("a basket built with no lines starts empty")
    func startsEmpty() {
        #expect(Basket().lines == [])
    }
}

@Suite("03.2 Roster")
struct RosterTests {
    @Test("enrolling into a team that does not exist yet creates it")
    func createsTheTeamOnFirstEnrollment() {
        var roster = Roster()
        roster.enroll("ada", in: "blue")
        #expect(roster.byTeam == ["blue": ["ada"]])
    }

    @Test("keeps players in enrollment order within a team")
    func keepsEnrollmentOrder() {
        var roster = Roster()
        roster.enroll("ada", in: "blue")
        roster.enroll("grace", in: "blue")
        roster.enroll("alan", in: "blue")
        #expect(roster.byTeam["blue"] == ["ada", "grace", "alan"])
    }

    @Test("enrolling the same player twice on one team changes nothing")
    func refusesADuplicateOnTheSameTeam() {
        var roster = Roster()
        roster.enroll("ada", in: "blue")
        roster.enroll("ada", in: "blue")
        #expect(roster.byTeam["blue"] == ["ada"])
    }

    @Test("the same player may be on two different teams")
    func onePlayerTwoTeams() {
        var roster = Roster()
        roster.enroll("ada", in: "blue")
        roster.enroll("ada", in: "red")
        #expect(roster.byTeam["blue"] == ["ada"])
        #expect(roster.byTeam["red"] == ["ada"])
    }

    @Test("releasing a player reports true and removes only that player")
    func releaseRemovesOnePlayer() {
        var roster = Roster(byTeam: ["blue": ["ada", "grace"]])
        #expect(roster.release("ada", from: "blue") == true)
        #expect(roster.byTeam["blue"] == ["grace"])
    }

    @Test("releasing a player who is not on that team reports false")
    func releaseOfAnAbsentPlayerReportsFalse() {
        var roster = Roster(byTeam: ["blue": ["ada"]])
        #expect(roster.release("grace", from: "blue") == false)
        #expect(roster.byTeam["blue"] == ["ada"])
    }

    @Test("releasing from a team that does not exist reports false")
    func releaseFromAnUnknownTeamReportsFalse() {
        var roster = Roster()
        #expect(roster.release("ada", from: "green") == false)
        #expect(roster.byTeam.isEmpty)
    }

    @Test("emptying a team drops the key instead of leaving an empty array")
    func emptyingATeamDropsTheKey() {
        var roster = Roster(byTeam: ["blue": ["ada"], "red": ["grace"]])
        #expect(roster.release("ada", from: "blue") == true)
        #expect(roster.byTeam.keys.contains("blue") == false)
        #expect(roster.byTeam == ["red": ["grace"]])
    }

    @Test("a copy of a roster does not see later enrollments")
    func copyIsIndependent() {
        var original = Roster(byTeam: ["blue": ["ada"]])
        let copy = original
        original.enroll("grace", in: "blue")
        original.enroll("alan", in: "red")
        #expect(copy.byTeam == ["blue": ["ada"]])
    }
}

@Suite("03.3 SeatCode")
struct SeatCodeTests {
    @Test("two spellings of one seat compare equal")
    func differentSpellingsAreOneSeat() {
        #expect(SeatCode(raw: "  4a ") == SeatCode(raw: "4A"))
    }

    @Test("two different seats compare unequal")
    func differentSeatsAreNotEqual() {
        #expect(SeatCode(raw: "4A") != SeatCode(raw: "4B"))
    }

    @Test("inner spaces are part of the seat and are not normalized away")
    func innerSpacesStillMatter() {
        #expect(SeatCode(raw: "4 A") != SeatCode(raw: "4A"))
    }

    @Test("the raw spelling is preserved for display")
    func rawTextSurvives() {
        #expect(SeatCode(raw: "  4a ").raw == "  4a ")
    }

    @Test("equal seats hash equally, so a set collapses them")
    func setCollapsesEqualSeats() {
        let seats: Set<SeatCode> = [
            SeatCode(raw: "4A"),
            SeatCode(raw: "4a"),
            SeatCode(raw: " 4A"),
            SeatCode(raw: "12C"),
        ]
        #expect(seats.count == 2)
    }

    @Test("a dictionary finds a seat stored under a different spelling")
    func dictionaryLookupCrossesSpellings() {
        let occupants = [SeatCode(raw: "4a"): "ada"]
        #expect(occupants[SeatCode(raw: " 4A ")] == "ada")
        #expect(occupants[SeatCode(raw: "4B")] == nil)
    }
}

@Suite("03.4 Ledger")
struct LedgerTests {
    @Test("posting an amount appends it")
    func postAppends() {
        var ledger = Ledger(amounts: [10])
        ledger.post(20)
        #expect(ledger.amounts == [10, 20])
    }

    @Test("a ledger nobody else holds never copies its buffer")
    func uniquelyHeldLedgerNeverCopies() {
        var ledger = Ledger(amounts: [1])
        ledger.post(2)
        ledger.post(3)
        ledger.post(4)
        #expect(ledger.amounts == [1, 2, 3, 4])
        #expect(ledger.copiesMade == 0)
    }

    @Test("a shared ledger copies exactly once, on the first write")
    func sharedLedgerCopiesOnceOnFirstWrite() {
        var writer = Ledger(amounts: [1])
        let reader = writer
        writer.post(2)
        writer.post(3)
        #expect(writer.copiesMade == 1)
        #expect(reader.copiesMade == 0)
    }

    @Test("the ledger that was copied from keeps the amounts it had")
    func theOtherSideIsUnchanged() {
        var writer = Ledger(amounts: [1])
        let reader = writer
        writer.post(2)
        #expect(reader.amounts == [1])
        #expect(writer.amounts == [1, 2])
    }

    @Test("both sides of a copy can write without seeing each other")
    func bothSidesCanWrite() {
        var left = Ledger(amounts: [0])
        var right = left
        left.post(1)
        right.post(2)
        #expect(left.amounts == [0, 1])
        #expect(right.amounts == [0, 2])
    }

    @Test("a copy of a copy still splits cleanly")
    func threeWaySplit() {
        var first = Ledger(amounts: [5])
        var second = first
        let third = second
        second.post(6)
        first.post(7)
        #expect(first.amounts == [5, 7])
        #expect(second.amounts == [5, 6])
        #expect(third.amounts == [5])
    }

    @Test("passing a ledger to a function cannot change the caller's copy")
    func callBoundaryIsACopy() {
        func extended(_ ledger: Ledger) -> Ledger {
            var local = ledger
            local.post(99)
            return local
        }
        var held = Ledger(amounts: [1])
        held.post(2)
        let returned = extended(held)
        #expect(held.amounts == [1, 2])
        #expect(returned.amounts == [1, 2, 99])
    }

    @Test("an empty ledger posts its first amount without copying")
    func emptyLedgerPosts() {
        var ledger = Ledger(amounts: [])
        ledger.post(1)
        #expect(ledger.amounts == [1])
        #expect(ledger.copiesMade == 0)
    }
}

@Suite("03.5 snapshots(of:applying:)")
struct SnapshotsTests {
    @Test("produces one snapshot per move")
    func oneSnapshotPerMove() {
        let start = Panel(cells: [0, 0, 0])
        let moves = [Move(index: 0, delta: 1), Move(index: 2, delta: 5)]
        #expect(snapshots(of: start, applying: moves).count == 2)
    }

    @Test("each snapshot carries every move up to and including its own")
    func snapshotsAccumulate() {
        let start = Panel(cells: [0, 0])
        let moves = [
            Move(index: 0, delta: 1),
            Move(index: 1, delta: 2),
            Move(index: 0, delta: 3),
        ]
        #expect(snapshots(of: start, applying: moves) == [
            Panel(cells: [1, 0]),
            Panel(cells: [1, 2]),
            Panel(cells: [4, 2]),
        ])
    }

    @Test("leaves the panel it was handed exactly as it was")
    func startIsUntouched() {
        let start = Panel(cells: [9, 9])
        _ = snapshots(of: start, applying: [Move(index: 0, delta: -9)])
        #expect(start.cells == [9, 9])
    }

    @Test("no moves means no snapshots, not one snapshot of the start")
    func emptyMovesProduceNoSnapshots() {
        #expect(snapshots(of: Panel(cells: [1]), applying: []).isEmpty)
    }

    @Test("an out of range move still produces a snapshot, unchanged")
    func outOfRangeMoveIsRecordedButChangesNothing() {
        let start = Panel(cells: [1, 1])
        let moves = [
            Move(index: 7, delta: 100),
            Move(index: -1, delta: 100),
            Move(index: 1, delta: 4),
        ]
        #expect(snapshots(of: start, applying: moves) == [
            Panel(cells: [1, 1]),
            Panel(cells: [1, 1]),
            Panel(cells: [1, 5]),
        ])
    }

    @Test("a negative delta subtracts")
    func negativeDeltaSubtracts() {
        let result = snapshots(of: Panel(cells: [3]), applying: [Move(index: 0, delta: -10)])
        #expect(result == [Panel(cells: [-7])])
    }

    @Test("performing a move in place changes only the addressed cell")
    func performTouchesOneCell() {
        var panel = Panel(cells: [1, 2, 3])
        panel.perform(Move(index: 1, delta: 10))
        #expect(panel.cells == [1, 12, 3])
    }
}
