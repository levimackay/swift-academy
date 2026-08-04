# Setup

Ten minutes, most of it verification. Read
[PREREQUISITES.md](PREREQUISITES.md) first if you have not.

## 1. Clone and check the machine

```bash
git clone https://github.com/levibmackay/swift-academy.git
cd swift-academy
make verify
```

`make verify` reports your Swift version, where `xcode-select` points, which
chapters are runnable right now, and the exact command to fix anything that is
wrong. It exits non zero only on a real failure, so a warning is safe to read
and keep going.

## 2. Confirm the toolchain

```bash
swift --version
```

You want `swift-6.2-RELEASE` or newer. Anything older and the manifests will
not parse, because they are `swift-tools-version: 6.2`.

Swift 6 language mode is the **default** at this tools version. Strict
concurrency checking is on. Nothing in this repo opts into it and nothing
should: if you see `swiftLanguageMode(.v6)` or `-strict-concurrency=complete`
in a manifest here, that is a bug, because both statements imply Swift 6
concurrency is something you turn on. It is not.

## 3. Run the tests

```bash
swift test
```

**Expect red.** Every exercise ships as a stub that returns a compiling wrong
value, and every test suite is written so that no constant return can pass. A
fresh clone of `main` is supposed to fail, and the failure list is your
scoreboard. What you should not see is a crash: no stub calls `fatalError`,
because that aborts the whole parallel run with
`error: Exited with unexpected signal code 5` and prints no summary line.

If the run ends with a summary line counting tests and suites, the repo is
working.

One chapter at a time:

```bash
swift test --filter Chapter01Tests
make test CH=01
```

Use the target name (`Chapter01Tests`), not the bare number. Swift Testing
matches the filter regex against a test ID that includes the source line, so
`--filter 01` also selects tests in other chapters that happen to be declared
on a line containing 01. `make test CH=01` builds the target name for you.

## 4. Xcode, and what actually needs it

```bash
xcode-select -p
```

If that prints `/Library/Developer/CommandLineTools`, you can build and test
**every chapter, 01 through 14**. SwiftUI and Observation ship in the macOS
SDK, so chapter 13's and chapter 14's exercise and test targets compile and
run headless with no Xcode selected. Verified on this toolchain.

What genuinely needs Xcode and a simulator or a device:

| Thing | Why |
|---|---|
| `modules/13-swiftui-state/preview-app/` | Runs a screen so you can watch state reset when identity changes. |
| `modules/14-swiftui-app/preview-app/` | Same, for navigation and persistence. |
| `projects/02-first-screen/App/` | The whole point of the spike is a running app. |
| `projects/06-capstone/App/` | The capstone ships to a device. |

To switch:

```bash
sudo xcode-select -s /Applications/Xcode.app/Contents/Developer
xcode-select -p
```

To keep the terminal work on the command line tools and reach for Xcode only
when you need it, scope it per command instead of switching globally:

```bash
DEVELOPER_DIR=/Applications/Xcode.app/Contents/Developer xcodebuild -version
```

Both are correct. Switching globally is simpler; `DEVELOPER_DIR` is what you
want if you have other projects pinned to the command line tools.

## 5. The commands you will actually use

```bash
make test                    # every chapter
make test CH=03              # chapter 03 only
make next                    # the single next concrete action
make done CH=03              # the chapter 03 gate, then its checklist
make probe CH=03 P=predict   # run one probe file
make verify                  # check this machine again
make clean                   # delete every .build directory
```

`make probe` passes `-swift-version 6` explicitly, because a loose `.swift`
file run as a script defaults to Swift 5 mode, which is not the mode any
chapter is written against. Run probes through `make probe`, not through
`swift file.swift`.

Probes that need an argument take one:

```bash
make probe CH=10 P=dangling ARGS=unowned
```

## 6. Editor

Any editor. VS Code with the Swift extension, or Xcode, or something else.

One thing to know whichever you pick: some Swift 6 concurrency diagnostics
come from a SIL pass that runs during full compilation and not during type
checking. An editor that only type checks will show you a clean file that
`swift build` rejects. Verified: a particular `Task` capture reports nothing
under `swiftc -typecheck` and reports
`error: sending value of non-Sendable type '() async -> ()' risks causing data
races [#SendingRisksDataRace]` under `swiftc -c`.

`swift build` is the source of truth. The squiggles are a hint.

## 7. Before chapter 01

Two files to open once:

- `NOTES/errors.md` already has one seeded entry showing the three column
  format. You append to it every time a diagnostic costs you more than ten
  minutes.
- `PROGRESS.md` ends with a `**Next action:**` line. `make next` prints it.
  When you stop for the day, rewrite that line before you close the laptop.
  It is the mechanism that makes reopening the repo after a two week gap cost
  nothing.

Then: [modules/01-optionals/README.md](modules/01-optionals/README.md).
