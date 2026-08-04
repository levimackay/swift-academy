import SwiftUI

/// Exercise 2. A derived binding.
///
/// A `Binding<Value>` is a read closure and a write closure over storage
/// somebody else owns. Nothing is copied, so a binding you derive from
/// another binding still writes all the way back to the original source of
/// truth. That is the whole reason a child view takes a binding instead of a
/// value.
///
/// The rules:
///
/// - Reading gives the fraction as a whole percent, rounded to nearest, and
///   clamped to `0...100`.
/// - Writing clamps the incoming percent to `0...100`, then stores it back
///   through `fraction` as a value in `0...1`.
public enum Percent {
    public static func binding(over fraction: Binding<Double>) -> Binding<Int> {
        // TODO: derive a binding that reads and writes through `fraction`.
        .constant(0)
    }
}
