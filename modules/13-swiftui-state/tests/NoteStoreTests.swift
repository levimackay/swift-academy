import Foundation
import Testing

@testable import Chapter13

@MainActor
@Suite("13 Note store bindings")
struct NoteStoreTests {
    private let first = Note(id: UUID(), title: "buy milk")
    private let second = Note(id: UUID(), title: "call ada")
    private let third = Note(id: UUID(), title: "read SE-0258")

    private func store() -> NoteStore {
        NoteStore(notes: [first, second, third])
    }

    @Test("no binding is produced for an identity the store does not hold")
    func unknownIdentityProducesNoBinding() {
        #expect(store().binding(forNoteWithID: UUID()) == nil)
        #expect(store().binding(forNoteWithID: second.id) != nil)
    }

    @Test("writing through the binding updates the store")
    func writingUpdatesTheStore() throws {
        let store = store()
        let binding = try #require(store.binding(forNoteWithID: second.id))
        binding.wrappedValue.title = "call grace"
        #expect(store.notes[1].title == "call grace")
        #expect(store.notes.count == 3)
    }

    @Test("writing through the binding leaves the other notes alone")
    func writingTouchesOneNoteOnly() throws {
        let store = store()
        let binding = try #require(store.binding(forNoteWithID: first.id))
        binding.wrappedValue.title = "buy oat milk"
        #expect(store.notes[1].title == "call ada")
        #expect(store.notes[2].title == "read SE-0258")
    }

    @Test("reading through the binding sees an edit made somewhere else")
    func readingSeesLaterEdits() throws {
        let store = store()
        let binding = try #require(store.binding(forNoteWithID: third.id))
        store.notes[2].title = "read SE-0258 twice"
        #expect(binding.wrappedValue.title == "read SE-0258 twice")
    }

    @Test("the binding follows its note across a reorder")
    func bindingFollowsItsNoteAcrossAReorder() throws {
        let store = store()
        let binding = try #require(store.binding(forNoteWithID: third.id))
        store.notes.reverse()
        binding.wrappedValue.title = "read it again"
        #expect(store.notes[0].title == "read it again")
        #expect(store.notes[2].title == "buy milk")
    }
}
