import Observation

/// Exercise 1. A model that is the single source of truth for one screen.
///
/// `count` is `private(set)` on purpose: a view may read it and may never
/// assign to it. Every change goes through a method that can enforce the
/// rule, which is what makes "single source of truth" a compiler checked
/// property rather than a convention.
///
/// The rules:
///
/// - `count` starts at zero.
/// - `tap()` raises `count` by one, and does nothing at all once the counter
///   has reached `limit`.
/// - `isAtLimit` is true exactly when a further `tap()` would do nothing.
/// - `reset()` returns `count` to zero and leaves `limit` alone.
@Observable
@MainActor
public final class TapCounter {
    public let limit: Int
    public private(set) var count: Int = 0

    public init(limit: Int) {
        self.limit = limit
    }

    public var isAtLimit: Bool {
        // TODO: true exactly when tap() would have no effect.
        false
    }

    public func tap() {
        // TODO: raise count by one, unless the counter is already at its limit.
    }

    public func reset() {
        // TODO: return count to zero. limit does not change.
    }
}
