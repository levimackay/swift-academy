import Foundation

public struct StoredNote: Equatable, Sendable, Identifiable {
    public let id: UUID
    public var title: String
    public var isArchived: Bool
    public var updatedAt: Date

    public init(id: UUID, title: String, isArchived: Bool = false, updatedAt: Date) {
        self.id = id
        self.title = title
        self.isArchived = isArchived
        self.updatedAt = updatedAt
    }
}

/// The persistence seam. A SwiftData backed implementation of this protocol
/// holds a `ModelContext` and does nothing else; the in memory one a test
/// hands you holds an array. This is the one place in the chapter where a
/// protocol is the right seam rather than a closure, and the rule is written
/// down in the chapter: a protocol earns its keep when two real
/// implementations exist, and here they do.
@MainActor
public protocol NoteStorage: AnyObject {
    func fetchAll() -> [StoredNote]
    func upsert(_ note: StoredNote)
    func remove(id: UUID)
}

/// Exercise 4. The query and mutation rules a screen actually needs, written
/// once, above the storage, so that they are testable without a database.
///
/// The rules:
///
/// - `file(_:)` stores a note, replacing any note already stored under the
///   same identity. It never produces two notes with one id.
/// - `archive(id:)` marks a stored note archived and leaves it in storage.
///   Archiving something that is not there changes nothing.
/// - `discard(id:)` removes it. Discarding something that is not there
///   changes nothing, and touches no other note.
/// - `visible(matching:)` is the list the screen renders:
///   archived notes are excluded; a query that is empty or only whitespace
///   matches every unarchived note; otherwise the title must contain the
///   query, ignoring case; and the result is ordered newest `updatedAt`
///   first, with ties broken by title, ascending.
///
/// The tie break is not decoration. Two notes saved in the same batch carry
/// the same timestamp, and a sort that leaves their order to chance produces
/// a list that reshuffles itself while the user is reading it.
@MainActor
public final class NoteLibrary {
    private let storage: any NoteStorage

    public init(storage: any NoteStorage) {
        self.storage = storage
    }

    public func file(_ note: StoredNote) {
        // TODO: store it, without creating a duplicate identity.
    }

    public func archive(id: UUID) {
        // TODO: find it, mark it, put it back.
    }

    public func discard(id: UUID) {
        // TODO: remove exactly one note.
    }

    public func visible(matching query: String) -> [StoredNote] {
        // TODO: filter, then order.
        []
    }
}
