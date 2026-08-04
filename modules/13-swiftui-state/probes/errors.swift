// This file compiles as written. Every commented block below is a real
// mistake with the diagnostic it produced on the toolchain in the chapter
// front matter, pasted verbatim. Uncomment one block at a time and check the
// wording yourself:
//
//     make probe CH=13 P=errors
//
// The chapter's "Where it goes wrong" table is built from this file. The file
// stays green on purpose: a probe that compiles today and stops compiling
// after a toolchain upgrade tells you the wording drifted, and a probe that
// never compiled cannot tell you anything.
//
// Everything here builds with xcode-select pointing at CommandLineTools.
// SwiftUI and Observation ship in the macOS SDK, so none of this needs Xcode.

import Observation
import SwiftUI

// 1. A View is a struct, and body is a nonmutating computed property, so it
//    cannot write to a stored property of the view.
//
// struct TapRow: View {
//     var count = 0
//     var body: some View {
//         Button("Tap") { count += 1 }
//     }
// }
//
// error: left side of mutating operator isn't mutable: 'self' is immutable

// 2. A child that declares @Binding wants the projected value, not the value.
//
// struct NameField: View {
//     @Binding var name: String
//     var body: some View { TextField("Name", text: $name) }
// }
//
// struct NameScreen: View {
//     @State private var name = "levi"
//     var body: some View { NameField(name: name) }
// }
//
// error: cannot convert value 'name' of type 'String' to expected type
// 'Binding<String>', use wrapper instead

// 3. @Observable rewrites stored properties into computed ones, and that is
//    only meaningful for a type with a single shared instance.
//
// @Observable
// struct Preferences {
//     var isCompact = false
// }
//
// error: '@Observable' cannot be applied to struct type 'Preferences'
// (from macro 'Observable')
// error: expansion of macro 'ObservationTracked()' did not produce a
// non-observing accessor (such as 'get') as expected

// 4. @Bindable projects bindings out of an Observable reference model, and
//    this class is not one.
//
// final class PlainSession {
//     var name = "levi"
// }
//
// struct SessionEditor: View {
//     @Bindable var session: PlainSession
//     var body: some View { TextField("Name", text: $session.name) }
// }
//
// error: 'init(wrappedValue:)' is unavailable: The wrapped value must be an
// object that conforms to Observable

// 5. The Combine era wrappers still exist and still demand the Combine era
//    protocol. Mixing the two mechanisms is the most common thing an old
//    tutorial will make you do.
//
// struct BasketScreen: View {
//     @StateObject private var basket = Basket()
//     var body: some View { Text("\(basket.itemCount)") }
// }
//
// error: generic struct 'StateObject' requires that 'Basket' conform to
// 'ObservableObject'

@Observable
final class Basket {
    var itemCount = 0
}

// 6. UI state is main actor isolated, and that isolation is checked at every
//    call site rather than asserted in a comment.
//
// nonisolated func summary(of cart: Cart) -> String {
//     "total is \(cart.total)"
// }
//
// error: main actor-isolated property 'total' can not be referenced from a
// nonisolated context

@Observable
@MainActor
final class Cart {
    var total = 0
}

// 7. Identity in a ForEach is a value you supply, never one SwiftUI infers.
//
// struct ReminderList: View {
//     let reminders: [Reminder]
//     var body: some View {
//         ForEach(reminders) { reminder in Text(reminder.title) }
//     }
// }
//
// error: referencing initializer 'init(_:content:)' on 'ForEach' requires
// that 'Reminder' conform to 'Identifiable'

struct Reminder {
    var title: String
}

// 8. @Environment reads a value out of the tree. It does not own it, so there
//    is nothing to project a binding from.
//
// struct AccentField: View {
//     @Environment(Theme.self) private var theme
//     var body: some View { TextField("Accent", text: $theme.accent) }
// }
//
// error: cannot find '$theme' in scope

@Observable
final class Theme {
    var accent = "blue"
}

print("errors.swift compiles clean. Uncomment one block above and rerun.")
