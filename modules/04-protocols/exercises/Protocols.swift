// Chapter 04 exercises.
//
// Every declaration below compiles and every body returns a wrong value, so
// the suite runs and reports a score instead of aborting. Replace the bodies,
// and where a comment says so, add a declaration.
//
//   swift test --filter Chapter04Tests
//
// House rule for this chapter, checked by the last item of the Done when
// list: no reference types and no inheritance. Every shared behavior in this
// file is bought with a constraint.

// MARK: - 1. TrackID, ordered and hashed by hand

/// One track on a two sided record. `side` is a single letter and the letter
/// is not case sensitive: side `"a"` and side `"A"` name the same side.
struct TrackID {
    let side: Character
    let position: Int
}

extension TrackID: Equatable {
    /// Two track ids are equal when they name the same side, ignoring case,
    /// and the same position.
    static func == (lhs: TrackID, rhs: TrackID) -> Bool {
        // TODO: replace this.
        return false
    }
}

extension TrackID: Hashable {
    /// Must agree with `==`: two values that compare equal have to feed the
    /// hasher the same way, or a `Set` will hold both of them.
    func hash(into hasher: inout Hasher) {
        // TODO: replace this.
        hasher.combine(0)
    }
}

extension TrackID: Comparable {
    /// Sorts by side first, ignoring case, then by position ascending.
    /// `Comparable` needs only `<`; the other three operators arrive from the
    /// standard library's protocol extension once this one is right.
    static func < (lhs: TrackID, rhs: TrackID) -> Bool {
        // TODO: replace this.
        return false
    }
}

// MARK: - 2. Tagged, and which member wins

/// `tagText` is a protocol requirement, so it dispatches through the witness
/// table and a conforming type's own version always wins.
protocol Tagged {
    var tagText: String { get }
}

extension Tagged {
    /// Declared only here and never in the protocol body, so this one is
    /// statically dispatched. Do not move it into the protocol.
    var shortTag: String {
        String(tagText.prefix(3)).lowercased()
    }
}

/// A crate that carries only what the stencil says.
struct MarkedCrate: Tagged {
    let stencil: String

    /// The stencil with leading and trailing spaces removed, and nothing else
    /// changed. `"  Bordeaux Reserve  "` becomes `"Bordeaux Reserve"`.
    var tagText: String {
        // TODO: replace this.
        return ""
    }
}

/// The same crate, plus a stencilled short code of its own.
///
/// `tagText` trims exactly the way `MarkedCrate` does. Then give this type a
/// `shortTag` returning the initials of every space separated word in
/// `tagText`, uppercased: `"Bordeaux Reserve"` becomes `"BR"` and
/// `"hokkaido"` becomes `"H"`.
///
/// Add that declaration to this struct only. Adding `shortTag` to the
/// `Tagged` protocol is the one move the tests forbid, and the suite will
/// tell you why.
struct StencilledCrate: Tagged {
    let stencil: String

    var tagText: String {
        // TODO: replace this.
        return ""
    }

    // TODO: declare shortTag here.
}

// MARK: - 3. Reel, conformance that arrives with a condition

/// An ordered run of frames. The element type is deliberately unconstrained,
/// so a `Reel` of anything at all can be built.
struct Reel<Element> {
    var frames: [Element]

    init(_ frames: [Element]) {
        self.frames = frames
    }
}

extension Reel: Equatable where Element: Equatable {
    /// Equal when the two reels hold the same frames in the same order.
    static func == (lhs: Reel, rhs: Reel) -> Bool {
        // TODO: replace this.
        return false
    }
}

extension Reel where Element == String {
    /// The frames joined with `" / "`, or `"empty reel"` when there are none.
    /// This member exists only for `Reel<String>` and must not be reachable
    /// on any other reel.
    var joinedTitles: String {
        // TODO: replace this.
        return ""
    }
}

// MARK: - 4. Compact, bolted onto types you do not own

/// A short form suitable for a narrow column.
protocol Compact {
    var compactText: String { get }
}

extension Int: Compact {
    /// Below one thousand in magnitude, the digits unchanged: `999` is
    /// `"999"`. At one thousand or above, thousands with exactly one digit
    /// after the point, truncated toward zero, and a `"k"` suffix: `1000` is
    /// `"1.0k"`, `1999` is `"1.9k"`, `12345` is `"12.3k"`, `-2500` is
    /// `"-2.5k"`.
    var compactText: String {
        // TODO: replace this.
        return ""
    }
}

extension String: Compact {
    /// Twelve characters or fewer, unchanged. Longer than that, the first
    /// eleven characters followed by `"…"`. Characters, not bytes: a family
    /// emoji is one character however many scalars it took to build.
    var compactText: String {
        // TODO: replace this.
        return ""
    }
}

extension Array: Compact where Element: Compact {
    /// Every element's `compactText`, joined with `", "`. An empty array is
    /// `"none"`.
    var compactText: String {
        // TODO: replace this.
        return ""
    }
}

// MARK: - 5. loadPlan(for:), composed rather than inherited

/// Anything that has a mass.
protocol Weighed {
    var kilograms: Double { get }
}

/// Anything that prints on a manifest.
protocol Labeled {
    var stowLabel: String { get }
}

/// The summary a loader reads before closing the hold.
struct LoadPlan: Equatable {
    let pieceCount: Int
    let totalKilograms: Double
    let heaviestLabel: String?
    let isOverweight: Bool
}

/// Summarizes a hold. The parameter names two capabilities at once and asks
/// for nothing else, which is the point of the exercise: no base type, no
/// shared hierarchy, nothing but the two constraints.
///
///   - `pieceCount` is how many items there are.
///   - `totalKilograms` is their sum, and `0` for an empty hold.
///   - `heaviestLabel` is the `stowLabel` of the heaviest item, nil for an
///     empty hold, and the earliest of the tied items when two weigh the same.
///   - `isOverweight` is true when the total is strictly above `25`.
func loadPlan(for items: [any Weighed & Labeled]) -> LoadPlan {
    // TODO: replace this.
    return LoadPlan(
        pieceCount: -1,
        totalKilograms: -1,
        heaviestLabel: nil,
        isOverweight: false
    )
}
