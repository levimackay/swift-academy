import Testing

@testable import Chapter10

@Suite("10 identity")
struct IdentityTests {
    @Test("the same instance listed three times counts once")
    func repeatedInstanceCountsOnce() {
        let one = Registration(attendee: "levi")
        #expect(distinctRegistrationCount(in: [one, one, one]) == 1)
    }

    @Test("two equal registrations that are different objects count twice")
    func equalButDistinctInstancesCountTwice() {
        let first = Registration(attendee: "levi")
        let second = Registration(attendee: "levi")
        #expect(first == second)
        #expect(distinctRegistrationCount(in: [first, second]) == 2)
    }

    @Test("an empty list has no instances")
    func emptyListCountsZero() {
        #expect(distinctRegistrationCount(in: []) == 0)
    }

    @Test("a mix of aliases and distinct objects counts the objects")
    func mixedListCountsObjects() {
        let alias = Registration(attendee: "ada")
        let other = Registration(attendee: "ada")
        let third = Registration(attendee: "grace")
        let list = [alias, other, alias, third, other]
        #expect(distinctRegistrationCount(in: list) == 3)
    }
}

@Suite("10 capture")
struct ObserveUploadsTests {
    @Test("every completed id is recorded on the screen in order")
    func recordsEachCompletedIDInOrder() {
        let screen = UploadScreen()
        observeUploads(on: screen)
        screen.uploader.complete("a")
        #expect(screen.completedIDs == ["a"])
        screen.uploader.complete("b")
        #expect(screen.completedIDs == ["a", "b"])
    }

    @Test("the screen deallocates after the last strong reference goes away")
    func screenDeallocatesAfterScopeExit() {
        weak var observed: UploadScreen?
        do {
            let screen = UploadScreen()
            observeUploads(on: screen)
            screen.uploader.complete("a")
            observed = screen
            #expect(observed != nil)
        }
        #expect(observed == nil)
    }

    @Test("recording survives a completion delivered after wiring twice")
    func rewiringDoesNotLoseRecording() {
        let screen = UploadScreen()
        observeUploads(on: screen)
        observeUploads(on: screen)
        screen.uploader.complete("only")
        #expect(screen.completedIDs == ["only"])
    }
}

@Suite("10 weak registry")
struct LivingListenersTests {
    @Test("all listeners are returned while they are all alive")
    func returnsEveryLiveListener() {
        let kept = Listener(name: "kept")
        let alsoKept = Listener(name: "alsoKept")
        let boxes = [WeakListenerBox(kept), WeakListenerBox(alsoKept)]
        #expect(livingListeners(in: boxes).map(\.name) == ["kept", "alsoKept"])
    }

    @Test("a listener that deallocated is dropped and order is preserved")
    func dropsDeallocatedListener() {
        let kept = Listener(name: "kept")
        let tail = Listener(name: "tail")
        var boxes: [WeakListenerBox] = []
        do {
            let temporary = Listener(name: "temporary")
            boxes = [
                WeakListenerBox(kept),
                WeakListenerBox(temporary),
                WeakListenerBox(tail),
            ]
            #expect(livingListeners(in: boxes).count == 3)
        }
        #expect(livingListeners(in: boxes).map(\.name) == ["kept", "tail"])
    }

    @Test("the returned listeners are the same objects, not copies")
    func returnsTheSameObjects() {
        let kept = Listener(name: "kept")
        let survivors = livingListeners(in: [WeakListenerBox(kept)])
        #expect(survivors.count == 1)
        #expect(survivors.first === kept)
    }

    @Test("no boxes means no listeners")
    func emptyRegistryReturnsNothing() {
        #expect(livingListeners(in: []).isEmpty)
    }
}

@Suite("10 mixed value and reference")
struct RetitledTests {
    @Test("the copy carries the new title and the original keeps its own")
    func copyCarriesNewTitleAndOriginalIsUnchanged() {
        let original = Document(title: "draft", author: Author(name: "levi"))
        let renamed = retitled(original, to: "final")
        #expect(renamed.title == "final")
        #expect(original.title == "draft")
    }

    @Test("the copy reports the same author object, not a duplicate")
    func copySharesTheAuthorInstance() {
        let author = Author(name: "levi")
        let original = Document(title: "draft", author: author)
        let renamed = retitled(original, to: "final")
        #expect(renamed.author === author)
        #expect(renamed.author === original.author)
    }

    @Test("retitling twice keeps every intermediate document intact")
    func retitlingTwiceLeavesEachStageIntact() {
        let first = Document(title: "one", author: Author(name: "ada"))
        let second = retitled(first, to: "two")
        let third = retitled(second, to: "three")
        #expect([first.title, second.title, third.title] == ["one", "two", "three"])
        #expect(third.author === first.author)
    }

    @Test("an empty new title is still applied")
    func emptyTitleIsApplied() {
        let original = Document(title: "draft", author: Author(name: "levi"))
        #expect(retitled(original, to: "").title.isEmpty)
    }
}
