# Chapter 13 preview app

The exercises run headless, because everything they test (`Binding`,
`@Observable`, identity as a set operation) is ordinary Swift. Two things in
this chapter are not visible from a test, and this is where you look at them:
state that survives a rebuild, and state that does not survive an identity
change.

No project is committed here. You build it, once, and it is throwaway.

## Setup

```bash
sudo xcode-select -s /Applications/Xcode.app/Contents/Developer
xcode-select -p
```

New Xcode project, iOS App, SwiftUI interface, run on the iPhone 17 Pro
simulator. Nothing from the root package is imported: retype what you need.

## What to build

One screen, a `List` of notes, each row a separate view with two things in it:
a `TextField` bound into the store, and a `@State private var isExpanded`
that the row owns and nobody else can see.

Above the list, three buttons: shuffle the notes, rename the first note, and
replace every note with a fresh one carrying the same titles.

## What to observe, in this order

1. Expand two rows, then shuffle. Which rows stay expanded, and does the
   expansion follow the row or stay at the position.
2. Rename the first note while its `TextField` has focus. Watch where the
   focus goes.
3. Change `Note.id` from a stored `UUID` to a computed `var id: String
   { title }`, rebuild, and repeat step 2. The rename now changes the row's
   identity, and the screen tells you exactly what that costs.
4. Press replace all. The titles are unchanged and every identity is new.
   Predict what happens to the expanded rows before you press it.

## Done

You have seen `@State` survive a rebuild and die with an identity, and you can
say which of the two the framework decided. Write the sentence in
`PROGRESS.md`. Then delete the project.
