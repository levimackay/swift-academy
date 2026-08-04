// Chapter 10 exercises. Fill in the bodies marked TODO. Do not change the
// declarations, the types above them, or the test file: the suite in
// ../tests is what grades you and it calls these exact signatures.
//
// Run: swift test --filter 10

// MARK: - 1. Identity, not equality

/// Two registrations for the same attendee are equal. They are not the same
/// object, and the difference is the exercise.
public final class Registration: Equatable {
    public let attendee: String

    public init(attendee: String) {
        self.attendee = attendee
    }

    public static func == (lhs: Registration, rhs: Registration) -> Bool {
        lhs.attendee == rhs.attendee
    }
}

/// The number of distinct instances in `registrations`, counted by object
/// identity rather than by value. The same instance listed three times
/// counts once.
public func distinctRegistrationCount(in registrations: [Registration]) -> Int {
    0  // TODO: count instances, not equal values
}

// MARK: - 2. Wire a callback without owning the thing you call back into

/// Owned by the screen it reports to. Calling `complete` runs the stored
/// closure, if there is one.
public final class Uploader {
    public var onComplete: ((String) -> Void)?

    public init() {}

    public func complete(_ id: String) {
        onComplete?(id)
    }
}

/// Owns its uploader, which is what closes the loop when the closure you
/// install refers back here.
public final class UploadScreen {
    public let uploader = Uploader()
    public private(set) var completedIDs: [String] = []

    public init() {}

    public func record(_ id: String) {
        completedIDs.append(id)
    }
}

/// Install a closure on `screen.uploader` so that every completed id is
/// recorded on `screen`, and the screen still deallocates when the last
/// reference to it goes out of scope.
public func observeUploads(on screen: UploadScreen) {
    // TODO: set screen.uploader.onComplete
}

// MARK: - 3. A registry that does not keep its members alive

public final class Listener {
    public let name: String

    public init(name: String) {
        self.name = name
    }
}

/// A box that refers to a listener without owning it.
public struct WeakListenerBox {
    public weak var listener: Listener?

    public init(_ listener: Listener) {
        self.listener = listener
    }
}

/// The listeners still alive, in the order their boxes appear. Boxes whose
/// listener has deallocated are dropped.
public func livingListeners(in boxes: [WeakListenerBox]) -> [Listener] {
    []  // TODO: keep the boxes whose listener survived
}

// MARK: - 4. A value type holding a reference type

public final class Author {
    public let name: String

    public init(name: String) {
        self.name = name
    }
}

public struct Document {
    public var title: String
    public let author: Author

    public init(title: String, author: Author) {
        self.title = title
        self.author = author
    }
}

/// A copy of `document` carrying `newTitle`. The original is unchanged, and
/// the returned document reports the same author object, not a duplicate of
/// it.
public func retitled(_ document: Document, to newTitle: String) -> Document {
    document  // TODO: return the retitled copy
}
