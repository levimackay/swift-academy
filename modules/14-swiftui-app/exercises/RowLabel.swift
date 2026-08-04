import Foundation

/// Exercise 5. Accessibility, as a function you can test.
///
/// A list row draws a title, a coloured dot, and a relative date in three
/// separate views. VoiceOver, left alone, reads three fragments in whatever
/// order the layout put them. What it should read is one sentence, and a
/// sentence is a `String`, which means the interesting part of accessibility
/// is ordinary logic with a test around it rather than a modifier you either
/// remembered or did not.
///
/// `spoken(for:dueInDays:)` returns the sentence, with the parts separated by
/// a comma and a space.
///
/// The rules:
///
/// - An archived note reads as its title then `archived`, and says nothing
///   about dates. It is off the list; when it is due is no longer news.
/// - `nil` days reads as `no due date`.
/// - `0` reads as `due today`, `1` as `due tomorrow`, anything larger as
///   `due in 4 days`.
/// - `-1` reads as `overdue by 1 day`, anything smaller as
///   `overdue by 3 days`.
///
/// So `spoken(for: milk, dueInDays: 2)` is `"Buy milk, due in 2 days"`.
///
/// Singular and plural are the point of the exercise, on both sides of zero.
/// "overdue by 1 days" is the single most common accessibility defect in a
/// shipping app, and it is audible rather than visible, which is exactly why
/// nobody catches it by looking at the screen.
public enum RowLabel {
    public static func spoken(for note: StoredNote, dueInDays days: Int?) -> String {
        // TODO: build the one sentence VoiceOver should read.
        ""
    }
}
