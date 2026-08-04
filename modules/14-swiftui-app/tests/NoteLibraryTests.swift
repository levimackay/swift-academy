import Foundation
import Testing

@testable import Chapter14

/// The second implementation of the seam, and the reason a protocol is the
/// right shape here. The first one holds a `ModelContext` and lives in the
/// app. This one holds an array and lives in a test, so nothing below runs a
/// database, opens a file, or needs Xcode.
@MainActor
private final class Shelf: NoteStorage {
    private var rows: [StoredNote] = []

    init(_ rows: [StoredNote]) { self.rows = rows }

    func fetchAll() -> [StoredNote] { rows }

    func upsert(_ note: StoredNote) {
        if let index = rows.firstIndex(where: { $0.id == note.id }) {
            rows[index] = note
        } else {
            rows.append(note)
        }
    }

    func remove(id: UUID) {
        rows.removeAll { $0.id == id }
    }
}

@MainActor
@Suite("14 Library over a storage seam")
struct NoteLibraryTests {
    private let epoch = Date(timeIntervalSince1970: 1_700_000_000)

    private func at(_ offset: TimeInterval) -> Date {
        epoch.addingTimeInterval(offset)
    }

    private let milkID = UUID()
    private let oatsID = UUID()
    private let saltID = UUID()

    private func stocked() -> (NoteLibrary, Shelf) {
        let shelf = Shelf([
            StoredNote(id: milkID, title: "Buy milk", updatedAt: at(30)),
            StoredNote(id: oatsID, title: "Buy oats", updatedAt: at(20)),
            StoredNote(id: saltID, title: "Call the vet", updatedAt: at(10)),
        ])
        return (NoteLibrary(storage: shelf), shelf)
    }

    @Test("the newest note is listed first")
    func theNewestNoteIsListedFirst() {
        let (library, _) = stocked()
        let listed = library.visible(matching: "")
        #expect(listed.map(\.title) == ["Buy milk", "Buy oats", "Call the vet"])
        #expect(listed.count == 3)
    }

    @Test("two notes saved in the same second are ordered by title, not by luck")
    func notesWithTheSameTimestampAreOrderedByTitle() {
        let shelf = Shelf([
            StoredNote(id: milkID, title: "Zebra", updatedAt: at(50)),
            StoredNote(id: oatsID, title: "Apple", updatedAt: at(50)),
            StoredNote(id: saltID, title: "Mango", updatedAt: at(50)),
        ])
        let library = NoteLibrary(storage: shelf)
        #expect(library.visible(matching: "").map(\.title) == ["Apple", "Mango", "Zebra"])
    }

    @Test("searching ignores the case the user typed")
    func searchingIgnoresCase() {
        let (library, _) = stocked()
        #expect(library.visible(matching: "buy").map(\.title) == ["Buy milk", "Buy oats"])
        #expect(library.visible(matching: "CALL").map(\.title) == ["Call the vet"])
        #expect(library.visible(matching: "zzz").isEmpty)
    }

    @Test("a search box holding only spaces is not a search")
    func aQueryOfOnlySpacesMatchesEverything() {
        let (library, _) = stocked()
        #expect(library.visible(matching: "   ").count == 3)
        #expect(library.visible(matching: "\n\t").count == 3)
    }

    @Test("an archived note leaves the list but stays in storage")
    func anArchivedNoteLeavesTheListButStaysStored() {
        let (library, shelf) = stocked()
        library.archive(id: oatsID)
        #expect(library.visible(matching: "").map(\.title) == ["Buy milk", "Call the vet"])
        #expect(shelf.fetchAll().count == 3)
        #expect(shelf.fetchAll().filter(\.isArchived).map(\.title) == ["Buy oats"])
    }

    @Test("archiving something that was never stored changes nothing")
    func archivingAnUnknownIdentityChangesNothing() {
        let (library, shelf) = stocked()
        library.archive(id: UUID())
        #expect(shelf.fetchAll().count == 3)
        #expect(library.visible(matching: "").count == 3)
    }

    @Test("filing a note under an identity that is already stored replaces it")
    func filingAnExistingIdentityReplacesIt() {
        let (library, shelf) = stocked()
        library.file(StoredNote(id: milkID, title: "Buy oat milk", updatedAt: at(60)))
        #expect(shelf.fetchAll().count == 3)
        #expect(library.visible(matching: "milk").map(\.title) == ["Buy oat milk"])
    }

    @Test("filing a new identity adds one note")
    func filingANewIdentityAddsOne() {
        let (library, shelf) = stocked()
        library.file(StoredNote(id: UUID(), title: "Book a table", updatedAt: at(5)))
        #expect(shelf.fetchAll().count == 4)
        #expect(library.visible(matching: "").last?.title == "Book a table")
    }

    @Test("discarding removes one note and leaves its neighbours alone")
    func discardingRemovesExactlyOne() {
        let (library, shelf) = stocked()
        library.discard(id: oatsID)
        #expect(shelf.fetchAll().map(\.title) == ["Buy milk", "Call the vet"])
        library.discard(id: UUID())
        #expect(shelf.fetchAll().count == 2)
    }
}
