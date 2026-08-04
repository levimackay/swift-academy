// This file compiles as written. Every commented block below is a real
// mistake with the diagnostic it produced on the toolchain in the chapter
// front matter, pasted verbatim. Uncomment one block at a time and check the
// wording yourself:
//
//     make probe CH=14 P=errors
//
// The chapter's "Where it goes wrong" table is built from this file. The file
// stays green on purpose: a probe that compiles today and stops compiling
// after a toolchain upgrade tells you the wording drifted, and a probe that
// never compiled cannot tell you anything.
//
// One block is different from every other probe in this repository. Block 1
// fails for a reason that is about your machine rather than about your code,
// and it is the first thing this chapter asks you to fix.

import Foundation
import SwiftUI

// 1. The macro plugin that expands @Model ships with Xcode and not with the
//    Command Line Tools. SwiftData itself is in the SDK, so `import SwiftData`
//    resolves and the type checker gets all the way to the macro before it
//    fails, which is why the message names a plugin and not a framework.
//
// import SwiftData
//
// @Model
// final class Sighting {
//     var name: String
//     init(name: String) { self.name = name }
// }
//
// error: external macro implementation type
// 'SwiftDataMacros.PersistentModelMacro' could not be found for macro
// 'Model()'; plugin for module 'SwiftDataMacros' not found
//
// The fix is not a code change:
//     sudo xcode-select -s /Applications/Xcode.app
//     xcode-select -p

// 2. An App's body is a Scene, not a View. Windows are not views, and the
//    distinction is what lets one App declare several kinds of window on
//    macOS while an iPhone shows one.
//
// struct FieldNotesApp: App {
//     var body: some View { Text("notes") }
// }
//
// error: type 'FieldNotesApp' does not conform to protocol 'App'
// note: candidate can not infer 'Body' = 'some View' because 'some View' is
// not a nominal type and so can't conform to 'Scene'

// 3. A path holds route values. Pushing a view onto it is the reflex from
//    every pre iOS 16 tutorial, and the compiler answers with the constraint
//    that makes value based navigation work at all.
//
// struct SightingDetail: View { var body: some View { Text("one sighting") } }
//
// func push(into path: inout NavigationPath) {
//     path.append(SightingDetail())
// }
//
// error: instance method 'append' requires that 'SightingDetail' conform to
// 'Hashable'

// 4. A route's payload has to be as ordinary as the route. Hang one
//    non Hashable field off a case and the whole enum stops being pushable,
//    which is the compiler telling you that a route is an identifier and not
//    a place to smuggle a model object.
//
// struct Attachment { var bytes: Int }
//
// enum Waypoint: Hashable, Codable {
//     case attachment(Attachment)
// }
//
// error: type 'Waypoint' does not conform to protocol 'Hashable'
// note: associated value type 'Attachment' does not conform to protocol
// 'Hashable', preventing synthesized conformance of 'Waypoint' to 'Hashable'

// 5. A sheet driven by an optional value needs to know which sheet it is
//    showing across a rebuild, so the value is Identifiable rather than only
//    Hashable. `sheet(isPresented:)` asks for nothing, which is exactly why
//    it drifts out of step with the value it was supposed to be showing.
//
// struct Composer: Hashable { var draft: String }
//
// struct InboxScreen: View {
//     @State private var composing: Composer?
//     var body: some View {
//         Text("inbox").sheet(item: $composing) { draft in Text(draft.draft) }
//     }
// }
//
// error: instance method 'sheet(item:onDismiss:content:)' requires that
// 'Composer' conform to 'Identifiable'

// 6. NavigationPath is type erased. It knows how deep it is and it can be
//    written to disk, and that is all: there is no element to read back out.
//    An array of your own route type is the version you can inspect, and it
//    is the one to reach for until you need to mix route types.
//
// struct DepthLabel: View {
//     @State private var trail = NavigationPath()
//     var body: some View {
//         Button("depth") { print(trail[0]) }
//     }
// }
//
// error: referencing subscript 'subscript(_:)' requires wrapper
// 'Binding<NavigationPath>'
// error: referencing subscript 'subscript(_:)' on 'Binding' requires that
// 'NavigationPath' conform to 'MutableCollection'

// 7. The environment can carry a model down the tree, and the thing it
//    carries has to be observable or nothing downstream would ever redraw.
//    The top line names nothing you wrote, so read the note under it.
//
// @MainActor
// final class Almanac { var entries: [String] = [] }
//
// struct AlmanacScreen: View {
//     @Environment(Almanac.self) private var almanac
//     var body: some View { Text("\(almanac.entries.count)") }
// }
//
// error: no exact matches in call to initializer
// note: candidate requires that 'Almanac' conform to 'Observable'
// (requirement specified as 'Value' : 'Observable')

// 8. Watching scenePhase to save on the way to the background is the whole
//    point of scenePhase, and the one parameter closure every article about
//    it uses was deprecated four releases ago. The two parameter form hands
//    you the old value as well, which is what you usually needed.
//
// struct SaveOnBackground: View {
//     @Environment(\.scenePhase) private var phase
//     var body: some View {
//         Text("notes").onChange(of: phase) { newPhase in
//             print(newPhase)
//         }
//     }
// }
//
// warning: 'onChange(of:perform:)' was deprecated in macOS 14.0: Use
// `onChange` with a two or zero parameter action closure instead.
// [#DeprecatedDeclaration]

print("errors.swift compiles clean. Uncomment one block above and rerun.")
