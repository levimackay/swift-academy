import Foundation
import Observation

public struct Entry: Equatable, Sendable, Identifiable {
    public let id: UUID
    public let title: String

    public init(id: UUID, title: String) {
        self.id = id
        self.title = title
    }
}

/// Five states, not a `Bool` and an optional array. Two of the five are the
/// ones people collapse into one and then cannot render differently: a
/// successful load that found nothing is not the same screen as a load that
/// has not happened, and neither is a failure.
public enum LoadState: Equatable, Sendable {
    case idle
    case loading
    case empty
    case loaded([Entry])
    case failed(String)
}

/// Exercise 3. The dependency injection seam.
///
/// The model does not know what a network is. It is handed one closure and it
/// calls it, so the test suite hands it a closure that returns a literal, and
/// the app hands it one that talks to a server. Nothing in the view changes
/// between those two worlds, which is the property that makes the seam worth
/// having.
///
/// The rules:
///
/// - `reload()` puts the model in `.loading` **before** it awaits, so a view
///   that is already on screen can show a spinner while the work runs.
/// - A fetch that returns entries lands in `.loaded`, in the order the fetch
///   returned them.
/// - A fetch that returns nothing lands in `.empty`, never `.loaded([])`.
/// - A fetch that throws lands in `.failed`, carrying the error's
///   `localizedDescription`.
/// - `reload()` calls the injected closure exactly once per call, and a later
///   reload replaces the state rather than merging into it. A failure is not
///   sticky.
@Observable
@MainActor
public final class EntryList {
    public private(set) var state: LoadState = .idle

    private let fetch: @Sendable () async throws -> [Entry]

    public init(fetch: @escaping @Sendable () async throws -> [Entry]) {
        self.fetch = fetch
    }

    public func reload() async {
        // TODO: announce that work started, run the injected closure, and
        // land in exactly one of the three end states.
    }
}
