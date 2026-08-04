import Observation
import SwiftUI

/// Exercise 4. Handing a child view write access to one element of the
/// parent's state, without handing it a copy.
///
/// The store owns the array. A row view needs to edit one note and must not
/// be given a copy of it, because a copy is a second source of truth. It gets
/// a `Binding<Note>` that finds the note again on every read and every write.
///
/// The rules:
///
/// - `binding(forNoteWithID:)` returns nil when the store holds no note with
///   that identity.
/// - Reading through the returned binding reports the note as it is right
///   now, including edits made through some other path.
/// - Writing through the returned binding replaces the note with that
///   identity, wherever it currently sits in `notes`.
@Observable
@MainActor
public final class NoteStore {
    public var notes: [Note]

    public init(notes: [Note]) {
        self.notes = notes
    }

    public func binding(forNoteWithID id: Note.ID) -> Binding<Note>? {
        // TODO: build a binding that looks the note up by identity, both when
        // it is read and when it is written.
        nil
    }
}
