import Foundation
import Testing

@testable import Chapter13

@Suite("13 View identity")
struct ViewIdentityTests {
    private let first = Note(id: UUID(), title: "buy milk")
    private let second = Note(id: UUID(), title: "call ada")
    private let third = Note(id: UUID(), title: "read SE-0258")

    @Test("reordering rows creates no fresh identities")
    func reorderingKeepsEveryIdentity() {
        #expect(
            ViewIdentity.freshIdentities(
                movingFrom: [first, second, third],
                to: [third, first, second]
            ).isEmpty
        )
        #expect(
            ViewIdentity.freshIdentities(
                movingFrom: [first, second],
                to: [second, third, first]
            ) == [third.id]
        )
    }

    @Test("editing a title in place creates no fresh identity")
    func editingContentsKeepsIdentity() {
        var edited = second
        edited.title = "call grace instead"
        #expect(
            ViewIdentity.freshIdentities(
                movingFrom: [first, second],
                to: [first, edited]
            ).isEmpty
        )
        let renamedCopy = Note(id: UUID(), title: second.title)
        #expect(
            ViewIdentity.freshIdentities(
                movingFrom: [first, second],
                to: [first, renamedCopy]
            ) == [renamedCopy.id]
        )
    }

    @Test("an inserted row is the only fresh identity")
    func insertionReportsOnlyTheInsertedRow() {
        let fresh = ViewIdentity.freshIdentities(
            movingFrom: [first, second],
            to: [first, third, second]
        )
        #expect(fresh == [third.id])
    }

    @Test("removing a row creates no fresh identities")
    func removalReportsNothing() {
        #expect(
            ViewIdentity.freshIdentities(
                movingFrom: [first, second, third],
                to: [first]
            ).isEmpty
        )
        #expect(
            ViewIdentity.freshIdentities(
                movingFrom: [first, second, third],
                to: [first, third]
            ).isEmpty
        )
        #expect(
            ViewIdentity.freshIdentities(
                movingFrom: [first, second],
                to: [third]
            ) == [third.id]
        )
    }

    @Test("replacing every row makes every identity fresh")
    func replacementReportsEveryRow() {
        let replacementA = Note(id: UUID(), title: "buy milk")
        let replacementB = Note(id: UUID(), title: "call ada")
        let fresh = ViewIdentity.freshIdentities(
            movingFrom: [first, second],
            to: [replacementA, replacementB]
        )
        #expect(fresh == [replacementA.id, replacementB.id])
        #expect(fresh.count == 2)
    }
}
