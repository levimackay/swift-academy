import Observation

/// Exercise 2. Navigation as one piece of owned state.
///
/// A `NavigationStack` is bound to a path. Whoever owns that path decides what
/// is on screen, so a deep link, a push, a back button, and a modal are all
/// edits to one value rather than five booleans that can disagree with each
/// other.
///
/// The rules, in the order they are easy to get wrong:
///
/// - `go(to:)` pushes. Pushing the same route twice leaves two entries,
///   because a stack that silently deduplicates cannot represent
///   inbox to tag to inbox.
/// - `back()` pops one entry. On an empty path it does nothing at all: there
///   is no such thing as a negative depth, and a crash here is a crash on the
///   swipe back gesture.
/// - `backToRoot()` empties the path and dismisses whatever is presented.
///   Landing at the root screen underneath a stale sheet is the bug this
///   rule exists to prevent.
/// - `present(_:)` sets the presented modal, replacing any modal already up.
/// - `dismiss()` clears it, and does nothing when nothing is presented.
/// - `follow(_:)` is the deep link. It replaces the whole path rather than
///   appending to it, and it dismisses any modal, because a link that lands
///   you three screens deep under someone else's sheet is not a deep link.
/// - `depth` is how many screens are stacked above the root.
@Observable
@MainActor
public final class AppRouter {
    public private(set) var path: [AppRoute] = []
    public private(set) var presented: ModalRoute?

    public init() {}

    public var depth: Int {
        // TODO: report how deep the stack currently is.
        -1
    }

    public func go(to route: AppRoute) {
        // TODO: push.
    }

    public func back() {
        // TODO: pop one, and survive being called at the root.
    }

    public func backToRoot() {
        // TODO: unwind everything, including anything presented.
    }

    public func present(_ modal: ModalRoute) {
        // TODO: present, replacing whatever was up.
    }

    public func dismiss() {
        // TODO: dismiss.
    }

    public func follow(_ deepLink: [AppRoute]) {
        // TODO: replace the path, do not append to it.
    }
}
