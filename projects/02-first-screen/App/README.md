# Project 02 app target

The Xcode project lives here and is not committed. You create it, you build it,
and it stays local. Nothing in this repository generates it for you, on
purpose: creating an iOS app target by hand once is part of what the spike is
for.

Read [../SPEC.md](../SPEC.md) first. It is banner labeled a spike for a reason,
its budget is five hours, and stopping at five hours with the stretch goals
unfinished is the correct outcome.

## Setup

```bash
sudo xcode-select -s /Applications/Xcode.app/Contents/Developer
xcode-select -p
```

This is the first thing in the course that genuinely needs Xcode. Chapters 01
through 14 all build and test on CommandLineTools, because SwiftUI ships in the
macOS SDK. A simulator does not.

## Creating the project

In Xcode: File, New, Project, iOS, App.

| Field | Value |
|---|---|
| Product Name | `FirstScreen` |
| Interface | SwiftUI |
| Language | Swift |
| Storage | None |
| Testing System | None |
| Save location | this directory, `projects/02-first-screen/App/` |

Nothing from the root package is imported and nothing is added as a package
dependency. Retype what you need. The spike is about seeing a screen, not about
wiring modules together.

Run destination: iPhone 17 Pro simulator.

## What is committed and what is not

`.gitignore` at the repository root already excludes `DerivedData/`,
`xcuserdata/`, and the rest of Xcode's per user cruft. The `.xcodeproj` itself
is not excluded, so decide deliberately: committing it is fine and makes the
spike reproducible, and leaving it out is also fine because the spec describes
it completely enough to rebuild.

What must not be committed is a signing identity, a provisioning profile, or a
team ID belonging to anyone. Automatic signing with your personal team writes a
`DEVELOPMENT_TEAM` value into the project file. Check for it before you commit
anything from this directory.

## First run problems, in the order you will hit them

| Symptom | Cause |
|---|---|
| No simulators in the destination menu | `xcode-select` still points at CommandLineTools. |
| "Signing for FirstScreen requires a development team" | You picked a device instead of a simulator. A simulator needs no team. |
| The app builds and shows a white screen | `ContentView` is still the template. That is the starting point, not a failure. |
| Preview canvas fails and the simulator works | The preview is a separate build. Ignore it for this spike and use the simulator. |

The spike does not run on a physical device and does not need a developer
account. That is requirement 1 of the spec and it is what keeps five hours to
five hours.

## Done

The app launches on the iPhone 17 Pro simulator, the list scrolls, the toolbar
button adds a row that appears immediately, and the push and the back swipe
both work. Then go back to chapter 06.

Record what surprised you in `../../../NOTES/errors.md`, including anything
Xcode did rather than the compiler. Xcode diagnostics count.
