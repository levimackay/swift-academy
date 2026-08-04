import Foundation

/// The route values this chapter's app pushes. Nothing here is a view, and
/// that is the whole point: a route is data, so it can be compared, stored,
/// written to disk, and asserted on in a test that never builds a screen.
///
/// You do not write this type. You write the codec below it.
public enum AppRoute: Hashable, Codable, Sendable {
    case inbox
    case entry(id: UUID)
    case tag(name: String)
}

/// The modal routes. A sheet and a full screen cover are navigation state
/// too, so they get the same treatment as a push instead of a scattering of
/// `Bool` flags.
public enum ModalRoute: Hashable, Codable, Sendable {
    case composer
    case onboarding
}

/// Exercise 1. State restoration, which is the payoff for making a route a
/// value rather than a view.
///
/// The rules:
///
/// - `encode(_:)` turns a path into bytes. Order matters and repeats matter:
///   `[.inbox, .inbox]` is a two deep stack, not a one deep one.
/// - `encode(_:)` called twice on equal paths produces equal bytes, so a
///   caller can compare the encoded form to decide whether to write it.
/// - `decode(_:)` is the inverse for anything `encode(_:)` produced.
/// - `decode(_:)` never throws and never traps. Saved navigation state is the
///   least important thing your app owns: when the bytes are truncated, from
///   an older build, or simply not yours, the honest answer is an empty path,
///   which lands the user at the root screen.
public enum RoutePath {
    public static func encode(_ routes: [AppRoute]) throws -> Data {
        // TODO: encode the path so that decode(_:) can return exactly it.
        Data()
    }

    public static func decode(_ data: Data) -> [AppRoute] {
        // TODO: decode, and answer with an empty path rather than a failure
        // when the bytes are not a path this build understands.
        []
    }
}
