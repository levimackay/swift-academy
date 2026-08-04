import Testing
@testable import Chapter04

// Test names describe the behavior, not the exercise number, so a red line in
// the output tells you what is wrong without opening this file.

@Suite("04.1 TrackID")
struct TrackIDTests {
    @Test("treats the same side and position as equal")
    func equalWhenSameSideAndPosition() {
        #expect(TrackID(side: "a", position: 3) == TrackID(side: "a", position: 3))
    }

    @Test("ignores the case of the side letter when comparing")
    func sideCaseDoesNotAffectEquality() {
        #expect(TrackID(side: "a", position: 3) == TrackID(side: "A", position: 3))
    }

    @Test("separates two positions on one side")
    func differentPositionsAreNotEqual() {
        #expect(TrackID(side: "a", position: 3) != TrackID(side: "a", position: 4))
    }

    @Test("hashes equal values into one Set slot")
    func hashingAgreesWithEquality() {
        let ids: Set<TrackID> = [
            TrackID(side: "a", position: 1),
            TrackID(side: "A", position: 1),
            TrackID(side: "b", position: 1),
        ]
        #expect(ids.count == 2)
    }

    @Test("sorts by side before position")
    func sortsBySideThenPosition() {
        let sorted = [
            TrackID(side: "B", position: 1),
            TrackID(side: "a", position: 9),
            TrackID(side: "A", position: 2),
        ].sorted()
        #expect(sorted.map(\.position) == [2, 9, 1])
    }

    @Test("is never less than itself")
    func isIrreflexive() {
        let one = TrackID(side: "c", position: 7)
        #expect(!(one < one))
    }

    @Test("hands the other three operators back from Comparable's extension")
    func derivedOperatorsFollowFromLessThan() {
        let early = TrackID(side: "a", position: 1)
        let late = TrackID(side: "a", position: 2)
        #expect(early <= late)
        #expect(late > early)
        #expect(max(early, late) == late)
    }
}

@Suite("04.2 Tagged")
struct TaggedTests {
    @Test("trims the stencil down to the tag text")
    func trimsSurroundingSpaces() {
        #expect(MarkedCrate(stencil: "  Bordeaux Reserve  ").tagText == "Bordeaux Reserve")
    }

    @Test("keeps a stencil that has nothing to trim")
    func leavesTrimmedStencilAlone() {
        #expect(MarkedCrate(stencil: "Hokkaido").tagText == "Hokkaido")
    }

    @Test("falls back to the extension's short tag when the type declares none")
    func usesExtensionShortTagByDefault() {
        #expect(MarkedCrate(stencil: " Bordeaux Reserve ").shortTag == "bor")
    }

    @Test("prefers the type's own short tag when the static type is the type")
    func concreteShortTagWins() {
        #expect(StencilledCrate(stencil: " Bordeaux Reserve ").shortTag == "BR")
    }

    @Test("initials one word down to one letter")
    func oneWordGivesOneInitial() {
        #expect(StencilledCrate(stencil: "hokkaido").shortTag == "H")
    }

    @Test("loses the type's own short tag once the value is an any Tagged")
    func existentialFallsBackToTheExtension() {
        let boxed: any Tagged = StencilledCrate(stencil: "Bordeaux Reserve")
        #expect(boxed.shortTag == "bor")
    }

    @Test("still dispatches the requirement dynamically through the box")
    func requirementStillDispatchesDynamically() {
        let boxed: any Tagged = StencilledCrate(stencil: "  Hokkaido  ")
        #expect(boxed.tagText == "Hokkaido")
    }
}

@Suite("04.3 Reel")
struct ReelTests {
    /// Deliberately not `Equatable`. A `Reel` of these has to keep compiling,
    /// which is the whole claim conditional conformance makes.
    struct Splice {
        let note: String
    }

    @Test("compares equal reels of equatable frames")
    func equalFramesInOrder() {
        #expect(Reel([1, 2, 3]) == Reel([1, 2, 3]))
    }

    @Test("treats order as part of the value")
    func orderMatters() {
        #expect(Reel([1, 2, 3]) != Reel([3, 2, 1]))
    }

    @Test("treats a shorter reel as different")
    func lengthMatters() {
        #expect(Reel([1, 2]) != Reel([1, 2, 3]))
    }

    @Test("compares two empty reels of the same frame type as equal")
    func emptyReelsAreEqual() {
        #expect(Reel<Int>([]) == Reel<Int>([]))
    }

    @Test("nests, because a reel of equatable frames is itself equatable")
    func conformanceComposesWithItself() {
        #expect(Reel([Reel([1]), Reel([2])]) == Reel([Reel([1]), Reel([2])]))
        #expect(Reel([Reel([1])]) != Reel([Reel([2])]))
    }

    @Test("still holds frames that are not equatable at all")
    func nonEquatableFramesStillCompile() {
        let reel = Reel([Splice(note: "cut"), Splice(note: "fade")])
        #expect(reel.frames.map(\.note) == ["cut", "fade"])
    }

    @Test("joins the titles of a string reel")
    func joinsTitles() {
        #expect(Reel(["Ada", "Grace"]).joinedTitles == "Ada / Grace")
    }

    @Test("names the empty case rather than joining nothing")
    func emptyStringReelIsNamed() {
        #expect(Reel<String>([]).joinedTitles == "empty reel")
    }
}

@Suite("04.4 Compact")
struct CompactTests {
    @Test("leaves a number under a thousand as digits")
    func smallIntegerKeepsItsDigits() {
        #expect((999).compactText == "999")
        #expect((0).compactText == "0")
    }

    @Test("switches to thousands at exactly one thousand")
    func thousandIsTheBoundary() {
        #expect((1000).compactText == "1.0k")
    }

    @Test("truncates rather than rounds the tenths digit")
    func truncatesTowardZero() {
        #expect((1999).compactText == "1.9k")
        #expect((12345).compactText == "12.3k")
    }

    @Test("keeps the sign on a negative thousand")
    func negativeThousandsKeepTheirSign() {
        #expect((-2500).compactText == "-2.5k")
        #expect((-999).compactText == "-999")
    }

    @Test("leaves a short string alone")
    func shortStringIsUnchanged() {
        #expect("Ada Lovelace".compactText == "Ada Lovelace")
    }

    @Test("truncates a long string to eleven characters and an ellipsis")
    func longStringIsTruncated() {
        #expect("Grace Brewster Murray Hopper".compactText == "Grace Brews…")
    }

    @Test("counts a multi scalar emoji as one character")
    func graphemesNotBytes() {
        #expect("👨‍👩‍👧👨‍👩‍👧👨‍👩‍👧".compactText == "👨‍👩‍👧👨‍👩‍👧👨‍👩‍👧")
    }

    @Test("joins an array of compact things")
    func arrayJoinsItsElements() {
        #expect([1500, 42].compactText == "1.5k, 42")
        #expect(["Ada", "Grace Brewster Murray Hopper"].compactText == "Ada, Grace Brews…")
    }

    @Test("names the empty array rather than joining nothing")
    func emptyArrayIsNamed() {
        #expect([Int]().compactText == "none")
    }

    @Test("nests, because an array of compact things is itself compact")
    func arrayOfArraysIsCompact() {
        #expect([[1000], [7, 8]].compactText == "1.0k, 7, 8")
    }
}

@Suite("04.5 loadPlan(for:)")
struct LoadPlanTests {
    struct Crate: Weighed, Labeled {
        let kilograms: Double
        let stowLabel: String
    }

    struct Barrel: Weighed, Labeled {
        let kilograms: Double
        let stowLabel: String
    }

    @Test("reports an empty hold as empty rather than as a mistake")
    func emptyHold() {
        let plan = loadPlan(for: [])
        #expect(plan == LoadPlan(
            pieceCount: 0,
            totalKilograms: 0,
            heaviestLabel: nil,
            isOverweight: false
        ))
    }

    @Test("counts and sums every piece regardless of its concrete type")
    func countsAndSumsAcrossTypes() {
        let plan = loadPlan(for: [
            Crate(kilograms: 12.5, stowLabel: "crate A"),
            Barrel(kilograms: 10, stowLabel: "barrel B"),
            Crate(kilograms: 3.25, stowLabel: "crate C"),
        ])
        #expect(plan.pieceCount == 3)
        #expect(plan.totalKilograms == 25.75)
    }

    @Test("names the heaviest piece, not the last one")
    func namesTheHeaviest() {
        let plan = loadPlan(for: [
            Crate(kilograms: 2.5, stowLabel: "crate A"),
            Barrel(kilograms: 9, stowLabel: "barrel B"),
            Crate(kilograms: 0.5, stowLabel: "crate C"),
        ])
        #expect(plan.heaviestLabel == "barrel B")
    }

    @Test("keeps the earlier piece when two weigh the same")
    func tiesGoToTheEarlierPiece() {
        let plan = loadPlan(for: [
            Crate(kilograms: 4, stowLabel: "crate A"),
            Barrel(kilograms: 4, stowLabel: "barrel B"),
        ])
        #expect(plan.heaviestLabel == "crate A")
    }

    @Test("calls twenty five kilograms exactly not overweight")
    func limitIsNotInclusive() {
        let plan = loadPlan(for: [Crate(kilograms: 25, stowLabel: "crate A")])
        #expect(plan.isOverweight == false)
        #expect(plan.totalKilograms == 25)
    }

    @Test("calls anything above twenty five kilograms overweight")
    func aboveTheLimitIsOverweight() {
        let plan = loadPlan(for: [
            Crate(kilograms: 25, stowLabel: "crate A"),
            Barrel(kilograms: 0.5, stowLabel: "barrel B"),
        ])
        #expect(plan.isOverweight)
    }
}
