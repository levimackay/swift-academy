#!/usr/bin/env bash
#
# Checks that this machine can build and test the repo, and reports which
# chapters are runnable right now. Every failed check prints the exact
# command that fixes it.
#
#   ./scripts/verify-environment.sh          full report
#   ./scripts/verify-environment.sh --quiet  only problems and the summary
#
# Exit status: 0 if every required check passed, 1 if any required check
# failed. Warnings do not change the exit status.

set -uo pipefail

REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$REPO_ROOT" || exit 1

QUIET=0
case "${1:-}" in
    --quiet) QUIET=1 ;;
    "") ;;
    *)
        printf 'verify-environment: unknown argument: %s\n' "$1" >&2
        printf 'usage: %s [--quiet]\n' "$0" >&2
        exit 2
        ;;
esac

REQUIRED_SWIFT_MAJOR=6
REQUIRED_SWIFT_MINOR=2

FAILURES=0
WARNINGS=0
NEXT_STEPS=()

say()  { [ "$QUIET" -eq 1 ] || printf '%s\n' "$*"; }
ok()   { [ "$QUIET" -eq 1 ] || printf '  [ok]   %s\n' "$*"; }
warn() { printf '  [warn] %s\n' "$*"; WARNINGS=$((WARNINGS + 1)); }
bad()  { printf '  [x]    %s\n' "$*"; FAILURES=$((FAILURES + 1)); }
step() { NEXT_STEPS+=("$1"); }

# ---------------------------------------------------------------- toolchain

say ""
say "Toolchain"

if ! command -v swift >/dev/null 2>&1; then
    bad "swift is not on PATH"
    step "Install the Xcode command line tools: xcode-select --install"
    SWIFT_OK=0
else
    SWIFT_OK=1
    SWIFT_VERSION_LINE="$(swift --version 2>&1 | head -n 1)"
    SWIFT_TARGET_LINE="$(swift --version 2>&1 | grep -i '^Target:' | head -n 1)"
    # Anchor on the "Swift version" phrase rather than taking the first
    # number on the line. Current toolchains print the driver version ahead
    # of the Swift version on the same line ("swift-driver version: 1.148.6
    # Apple Swift version 6.3.3 (...)"), so the first number read as 1.148
    # and this reported a brand new Xcode as too old. The phrase is in both
    # the Apple and the open source banners.
    SWIFT_SEMVER="$(swift --version 2>&1 | sed -n 's/.*Swift version \([0-9][0-9.]*\).*/\1/p' | head -n 1)"
    SWIFT_SEMVER="${SWIFT_SEMVER%.}"
    SWIFT_MAJOR="${SWIFT_SEMVER%%.*}"
    SWIFT_REST="${SWIFT_SEMVER#*.}"
    SWIFT_MINOR="${SWIFT_REST%%.*}"

    if [ -z "$SWIFT_SEMVER" ]; then
        warn "could not parse a version out of: $SWIFT_VERSION_LINE"
    elif [ "$SWIFT_MAJOR" -gt "$REQUIRED_SWIFT_MAJOR" ] ||
         { [ "$SWIFT_MAJOR" -eq "$REQUIRED_SWIFT_MAJOR" ] && [ "$SWIFT_MINOR" -ge "$REQUIRED_SWIFT_MINOR" ]; }; then
        ok "Swift $SWIFT_SEMVER ($SWIFT_VERSION_LINE)"
    else
        bad "Swift $SWIFT_SEMVER is older than the required ${REQUIRED_SWIFT_MAJOR}.${REQUIRED_SWIFT_MINOR}"
        step "Update Xcode, then run: sudo xcode-select -s /Applications/Xcode.app/Contents/Developer"
    fi
    [ -n "${SWIFT_TARGET_LINE:-}" ] && ok "$SWIFT_TARGET_LINE"
fi

if command -v make >/dev/null 2>&1; then
    ok "make is available"
else
    bad "make is not on PATH, so the shortcuts in the Makefile will not run"
    step "Install the Xcode command line tools: xcode-select --install"
fi

if command -v git >/dev/null 2>&1; then
    ok "git is available"
else
    warn "git is not on PATH, so the solutions branch workflow will not run"
fi

# ------------------------------------------------------------------- Xcode

say ""
say "Developer directory"

XCODE_SELECTED=0
if ! command -v xcode-select >/dev/null 2>&1; then
    bad "xcode-select is not on PATH"
    step "Install the Xcode command line tools: xcode-select --install"
else
    DEVELOPER_DIR_PATH="$(xcode-select -p 2>/dev/null)"
    if [ -z "$DEVELOPER_DIR_PATH" ]; then
        bad "xcode-select -p printed nothing"
        step "Point at Xcode: sudo xcode-select -s /Applications/Xcode.app/Contents/Developer"
    elif printf '%s' "$DEVELOPER_DIR_PATH" | grep -q "Xcode.app"; then
        XCODE_SELECTED=1
        ok "xcode-select points at Xcode: $DEVELOPER_DIR_PATH"
    else
        ok "xcode-select points at $DEVELOPER_DIR_PATH"
        say "         Every chapter builds and tests here, including 13 and 14:"
        say "         SwiftUI and Observation ship in the macOS SDK. Only the"
        say "         simulator work needs Xcode (the preview apps in 13 and 14,"
        say "         and the app targets in projects 02 and 06)."
        if [ -d /Applications/Xcode.app ]; then
            say "         Xcode.app is installed. Switch when you reach a preview app:"
            say "           sudo xcode-select -s /Applications/Xcode.app/Contents/Developer"
            say "         Or scope it per command with DEVELOPER_DIR."
        else
            step "Install Xcode from the App Store before project 02, then run: sudo xcode-select -s /Applications/Xcode.app/Contents/Developer"
        fi
    fi
fi

if [ "$XCODE_SELECTED" -eq 1 ]; then
    if xcrun --sdk iphonesimulator --show-sdk-path >/dev/null 2>&1; then
        ok "iOS simulator SDK found: $(xcrun --sdk iphonesimulator --show-sdk-version 2>/dev/null)"
    else
        warn "no iOS simulator SDK is installed"
        step "Open Xcode, then Settings, Components, and download an iOS simulator runtime"
    fi
    if command -v xcrun >/dev/null 2>&1 && xcrun simctl list devices available 2>/dev/null | grep -q "iPhone"; then
        DEVICE="$(xcrun simctl list devices available 2>/dev/null | grep -oE 'iPhone [0-9A-Za-z ]+' | tail -n 1)"
        ok "at least one iPhone simulator is available (${DEVICE:-iPhone})"
    else
        warn "no available iPhone simulator was found"
        step "Open Xcode, then Settings, Components, and download an iOS simulator runtime"
    fi
fi

# ------------------------------------------------------------- repo layout

say ""
say "Repository"

if [ -f Package.swift ]; then
    ok "root Package.swift is present"
else
    bad "no Package.swift at the repository root"
    step "Run this script from inside a clone of swift-academy"
fi

for extra in drills projects/01-life-grid projects/03-collections-kit \
             projects/04-feed-parser projects/05-event-bus projects/06-capstone/Core; do
    if [ ! -f "$extra/Package.swift" ]; then
        warn "missing manifest: $extra/Package.swift"
    fi
done

# ----------------------------------------------------------------- chapters

say ""
say "Chapters"

# A chapter counts as runnable when its exercises directory and its tests
# directory each hold at least one Swift file that is not the scaffold
# placeholder. There is no Xcode special case: verified on this toolchain,
# chapter 13's 20 tests run with xcode-select pointing at CommandLineTools,
# because SwiftUI and Observation ship in the macOS SDK. A chapter that
# imports SwiftUI and does not build is a real failure, not a setup step.
runnable_count=0
authored_count=0
total_count=0

real_swift_count() {
    local dir="$1"
    [ -d "$dir" ] || { printf '0'; return; }
    find "$dir" -maxdepth 1 -name '*.swift' ! -name 'Scaffold.swift' 2>/dev/null | wc -l | tr -d ' '
}

for chapter_dir in modules/[0-9][0-9]-*/; do
    [ -d "$chapter_dir" ] || continue
    chapter_dir="${chapter_dir%/}"
    slug="$(basename "$chapter_dir")"
    number="${slug%%-*}"

    if [ ! -d "$chapter_dir/exercises" ]; then
        warn "$slug does not have an exercises/ directory, so it is not part of the root package"
        step "Move or delete modules/$slug, which does not match the modules/NN-slug/exercises layout"
        continue
    fi
    total_count=$((total_count + 1))

    exercises="$(real_swift_count "$chapter_dir/exercises")"
    tests="$(real_swift_count "$chapter_dir/tests")"

    if [ "$exercises" -eq 0 ] && [ "$tests" -eq 0 ]; then
        [ "$QUIET" -eq 1 ] || printf '  [ ]    %s (not written yet)\n' "$slug"
        continue
    fi

    authored_count=$((authored_count + 1))

    if [ "$exercises" -eq 0 ]; then
        warn "$slug has tests but no exercise stubs"
        continue
    fi
    if [ "$tests" -eq 0 ]; then
        warn "$slug has exercise stubs but no tests, so nothing grades it"
        continue
    fi

    runnable_count=$((runnable_count + 1))
    ok "$slug is runnable (swift test --filter Chapter${number}Tests)"
done

# ------------------------------------------------------- links and dashes

if [ -x ./scripts/check-links.sh ]; then
    LINK_LOG="$(mktemp -t swift-academy-linkcheck)"
    if ./scripts/check-links.sh --quiet >"$LINK_LOG" 2>&1; then
        say ""
        say "Documentation"
        ok "every relative link resolves, and no dash is used as punctuation"
    else
        say ""
        say "Documentation"
        bad "scripts/check-links.sh failed"
        grep -E '^\s*\[x\]' "$LINK_LOG" | head -n 20
        step "Read the list above, then run: ./scripts/check-links.sh"
    fi
    rm -f "$LINK_LOG"
fi

# ------------------------------------------------------------------ compile

say ""
say "Build check"

if [ "$SWIFT_OK" -eq 1 ] && [ -f Package.swift ]; then
    BUILD_LOG="$(mktemp -t swift-academy-verify)"
    if swift build --build-tests >"$BUILD_LOG" 2>&1; then
        ok "swift build --build-tests succeeded"
    else
        bad "swift build --build-tests failed"
        printf '\n---- last 20 lines of the build log ----\n'
        tail -n 20 "$BUILD_LOG"
        printf -- '----------------------------------------\n\n'
        step "Read the build failure above, then run: swift build --build-tests"
    fi
    rm -f "$BUILD_LOG"
else
    warn "skipped the build check because Swift or the manifest is missing"
fi

# ------------------------------------------------------------------ summary

printf '\n'
printf 'Summary\n'
printf '  chapters present:  %s\n' "$total_count"
printf '  chapters authored: %s\n' "$authored_count"
printf '  chapters runnable: %s\n' "$runnable_count"
printf '  failures: %s, warnings: %s\n' "$FAILURES" "$WARNINGS"

printf '\nNext steps\n'
if [ "$runnable_count" -eq 0 ] && [ "$FAILURES" -eq 0 ]; then
    step "No chapter has shipped stubs yet. Start with modules/01-optionals/README.md"
fi
if [ "${#NEXT_STEPS[@]}" -eq 0 ]; then
    # Print from the **Next action:** marker to end of file. The next action is
    # prose and is allowed to wrap, so printing the last line only would emit a
    # sentence fragment.
    if [ -f PROGRESS.md ] && grep -q '\*\*Next action:\*\*' PROGRESS.md; then
        printf '  1. From PROGRESS.md:\n\n'
        sed -n '/\*\*Next action:\*\*/,$p' PROGRESS.md | sed 's/^/     /'
    else
        printf '  1. Open PROGRESS.md and add a **Next action:** entry at the end.\n'
    fi
else
    i=1
    for s in "${NEXT_STEPS[@]}"; do
        printf '  %s. %s\n' "$i" "$s"
        i=$((i + 1))
    done
fi
printf '\n'

[ "$FAILURES" -eq 0 ]
