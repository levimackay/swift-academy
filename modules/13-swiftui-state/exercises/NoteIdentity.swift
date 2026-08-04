import Foundation

/// A row in a list. `id` is stored, never derived from the contents, so
/// editing a title does not change which row this is.
public struct Note: Identifiable, Equatable, Sendable {
    public let id: UUID
    public var title: String

    public init(id: UUID, title: String) {
        self.id = id
        self.title = title
    }
}

/// Exercise 3. Reading the view tree the way SwiftUI does.
///
/// SwiftUI decides what to keep and what to throw away by identity, not by
/// value. A row whose identity is present in both the old and the new data
/// keeps its `@State`, its focus, and its animation state, however much its
/// contents changed. A row whose identity is new is built from scratch.
public enum ViewIdentity {
    /// The identities in `new` that were not in `old`. These are exactly the
    /// rows SwiftUI would build fresh, discarding any state the screen had
    /// been holding for them.
    public static func freshIdentities(movingFrom old: [Note], to new: [Note]) -> Set<Note.ID> {
        // TODO: compare identities, not contents.
        []
    }
}
