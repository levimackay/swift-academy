# Capstone app target

The Xcode project lives here and is not committed by this repository. You
create it. Read [../SPEC.md](../SPEC.md) for the fixed shape and your own
`../CAPSTONE-SPEC.md` for the content, which you wrote before chapter 11
started.

## The split, and why it is the whole architecture

```text
projects/06-capstone/
├── Core/     a standalone SwiftPM package
│             domain types, state model, persistence contract
│             tested with `swift test`, never imports SwiftUI
└── App/      an Xcode iOS app target
              views, navigation, wiring, and nothing else
```

`Core` is where the thinking is and it is testable with no simulator, no
device, and no signing. Verified on this toolchain: an `@Observable`
`@MainActor` model with an injected `@Sendable () async throws -> [Row]`
closure passes both its success and its failure tests under plain
`swift test` with `xcode-select` pointing at CommandLineTools.

That is the point of the split. If a piece of logic can only be exercised by
launching the app, it is in the wrong target. The test for that is
mechanical: run `swift test --package-path projects/06-capstone/Core` and ask
whether the thing you just wrote is covered. If it cannot be, move it.

`App` imports `Core` as a local package dependency. `Core` imports nothing
from `App`, and `Core` does not import SwiftUI. If you find yourself wanting
`import SwiftUI` inside `Core`, the type you are writing is a view or it is
carrying a view's concern.

## Setup

```bash
sudo xcode-select -s /Applications/Xcode.app/Contents/Developer
xcode-select -p
```

In Xcode: File, New, Project, iOS, App. SwiftUI interface, Swift, and pick
SwiftData for storage only if your `CAPSTONE-SPEC.md` says the app persists a
queried domain, which it probably does.

Then add `Core` as a local package: File, Add Package Dependencies, Add Local,
and select `projects/06-capstone/Core/`. Add the `CapstoneCore` library to the
app target's frameworks.

## What is committed and what is not

Not committed, ever:

- A signing certificate or its private key.
- A provisioning profile.
- An API key, token, or secret, in the project file, in an `.xcconfig`, or in
  `Info.plist`. Secrets belong in the Keychain at run time, and a secret in a
  git history is a secret you have published.
- `DerivedData/` and `xcuserdata/`, both already excluded by the root
  `.gitignore`.

Decide deliberately about the `.xcodeproj` and about `DEVELOPMENT_TEAM`, which
automatic signing writes into the project file. A team ID is not a secret, but
it is yours, and this repository is a portfolio that other people read.

## Signing and getting it onto the phone

Everything about certificates, profiles, entitlements, the privacy manifest,
version and build numbers, archiving, and validation is
[../../../docs/shipping.md](../../../docs/shipping.md). Read it before you
first plug the phone in, not after the first signing error.

The two things worth repeating here:

**The definition of done is a signed build installed on your own iPhone that
you have used for real.** Not a simulator recording, not a TestFlight link.
App Store submission is a stated post course goal and is not a completion
gate, because review latency is measured in days and is not yours to schedule.

**A free Apple ID provisioning profile expires in seven days.** The spec has a
milestone asking for seven consecutive days of use without rebuilding, and on
the free tier those two facts collide exactly. Either hold a paid membership
by the time you reach it, or read that milestone as "reinstall on day seven
and keep going". Write down which in `CAPSTONE-SPEC.md`, before day one, not
on day seven.

## Done

- [ ] `swift test --package-path projects/06-capstone/Core` is green.
- [ ] Nothing in `Core` imports SwiftUI.
- [ ] Every dependency the app uses has a test double in `Core`'s suite, and
      every dependency's failure branch is tested.
- [ ] A signed build is on my phone and I have used it for a week.
- [ ] No secret, certificate, or profile is in this repository's history.

Related: [../SPEC.md](../SPEC.md),
[../Core/](../Core/),
[../../../docs/shipping.md](../../../docs/shipping.md),
[../../../docs/testing-policy.md](../../../docs/testing-policy.md).
