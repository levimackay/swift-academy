# Chapter 14 preview app

Most of chapter 14 runs headless, for the same reason chapter 13's does: a
route is a value, a router is a pure function from a value to a screen name,
and a model with an injected dependency is ordinary Swift. Verified: an
`@Observable` `@MainActor` model taking an injected
`@Sendable () async throws -> [Row]` closure passes both its success and
failure tests under plain `swift test` with `xcode-select` pointing at
CommandLineTools.

Four things in this chapter are not visible from a test, and this is where you
look at them: navigation state surviving a background and relaunch, a
`NavigationStack` push driven by a value rather than by a boolean, a SwiftData
write appearing in a second view without either view knowing about the other,
and what `@Query` in a deeply nested view does to your ability to test that
view.

No project is committed here. You build it, once, and it is throwaway.

## Setup

```bash
sudo xcode-select -s /Applications/Xcode.app/Contents/Developer
xcode-select -p
```

New Xcode project, iOS App, SwiftUI interface, SwiftData storage, run on the
iPhone 17 Pro simulator. Nothing from the root package is imported: retype
what you need. Retyping is the point.

## What to build

Two screens and a model.

- A list screen backed by SwiftData, and a detail screen it pushes to.
- A `NavigationStack` bound to a `NavigationPath` that your model owns, not
  one the view invents.
- The route as a `Codable` value type, so the path can be written to disk and
  read back.
- One dependency injected into the model as a closure, with a second
  implementation that fails, so you can flip between them at the call site.

Nothing else. No tab bar, no search, no settings screen.

## What to observe, in this order

1. Push two levels deep, background the app, kill it from the app switcher,
   relaunch. Whether you land where you were is a question about whether you
   persisted the path, and the answer will be no the first time.
2. Encode the path yourself and print it. Look at what a `NavigationPath` is
   actually made of, and notice that it round trips only if every element is
   `Codable` and its type is still resolvable.
3. Replace the value based `navigationDestination` with a
   `NavigationLink(destination:)` that builds the destination view eagerly.
   Push into a list of two hundred rows and watch when the destinations get
   built. This is the reason the value based form exists.
4. Move a `@Query` from the list screen into a row subview. It still works.
   Then try to write a test for that row, and notice what you now have to
   stand up to do it. That is the coupling the chapter warns about, and it is
   only obvious once you have felt it.
5. Swap the injected dependency for the failing one without touching the view.
   If you have to touch the view, the seam is in the wrong place.

## Done

You can say out loud what the difference is between navigation as state and
navigation as a pile of booleans, and you have one sentence on why `@Query`
belongs near the top of a view tree. Write both in `PROGRESS.md`. Then delete
the project.

Related: [../README.md](../README.md), and
[../../13-swiftui-state/preview-app/README.md](../../13-swiftui-state/preview-app/README.md),
which is the model this page follows.
