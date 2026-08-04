#!/usr/bin/env bash
#
# Two mechanical checks that a reviewer catches slowly and a shell script
# catches instantly.
#
#   1. Every relative markdown link resolves to a file or a directory that
#      exists. Absolute URLs, mailto:, and pure anchors are skipped.
#   2. No em dash and no en dash anywhere in tracked text.
#
#   ./scripts/check-links.sh            report and exit nonzero on any problem
#   ./scripts/check-links.sh --quiet    only the failures and the summary
#
# Exit status: 0 when both checks pass, 1 otherwise. This is a hard gate in
# CI, because the repository's premise is that its evidence is trustworthy and
# a dead link on the front page is the cheapest possible way to lose that.
#
# No git and no grep -P, so it runs the same on a fresh clone, in CI, and on a
# machine whose grep is the BSD one. The two dash characters are built from
# their UTF-8 bytes rather than typed, so this file does not fail its own
# check.

set -uo pipefail

REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$REPO_ROOT" || exit 1

QUIET=0
case "${1:-}" in
    --quiet) QUIET=1 ;;
    "") ;;
    *)
        printf 'check-links: unknown argument: %s\n' "$1" >&2
        printf 'usage: %s [--quiet]\n' "$0" >&2
        exit 2
        ;;
esac

say() { [ "$QUIET" -eq 1 ] || printf '%s\n' "$*"; }

BROKEN_LOG="$(mktemp -t swift-academy-links)"
DASH_LOG="$(mktemp -t swift-academy-dashes)"
trap 'rm -f "$BROKEN_LOG" "$DASH_LOG"' EXIT

# Everything tracked as text, minus build output and git internals.
find_sources() {
    find . \
        \( -name .git -o -name .build -o -name DerivedData \) -prune -o \
        -type f \( "$@" \) -print
}

# ------------------------------------------------------------------- links

say ""
say "Relative markdown links"

while IFS= read -r doc; do
    dir="$(dirname "$doc")"
    line_number=0
    while IFS= read -r line; do
        line_number=$((line_number + 1))
        case "$line" in
            *']('*) ;;
            *) continue ;;
        esac
        printf '%s\n' "$line" \
            | grep -o ']([^)]*)' \
            | sed -e 's/^](//' -e 's/)$//' \
            | while IFS= read -r target; do
                case "$target" in
                    http://*|https://*|mailto:*|"#"*|"") continue ;;
                esac
                path="${target%%#*}"
                [ -z "$path" ] && continue
                if [ ! -e "$dir/$path" ]; then
                    printf '  [x]    %s:%s -> %s\n' "$doc" "$line_number" "$target"
                fi
            done
    done < "$doc"
done < <(find_sources -name '*.md') > "$BROKEN_LOG" 2>/dev/null

BROKEN="$(wc -l < "$BROKEN_LOG" | tr -d ' ')"
if [ "$BROKEN" != "0" ]; then
    cat "$BROKEN_LOG"
else
    say "  [ok]   every relative link resolves"
fi

# ------------------------------------------------------------------- dashes

say ""
say "Dashes used as punctuation"

EM_DASH="$(printf '\xe2\x80\x94')"
EN_DASH="$(printf '\xe2\x80\x93')"

find_sources -name '*.md' -o -name '*.swift' -o -name '*.sh' \
             -o -name '*.yml' -o -name '*.json' -o -name 'Makefile' \
    | while IFS= read -r file; do
        grep -n -e "$EM_DASH" -e "$EN_DASH" "$file" /dev/null 2>/dev/null
    done > "$DASH_LOG" 2>/dev/null

DASHES="$(wc -l < "$DASH_LOG" | tr -d ' ')"
if [ "$DASHES" != "0" ]; then
    sed 's/^/  [x]    /' "$DASH_LOG"
else
    say "  [ok]   no em dashes and no en dashes"
fi

# ------------------------------------------------------------------ summary

printf '\n'
printf 'Summary\n'
printf '  broken links: %s\n' "$BROKEN"
printf '  dash hits:    %s\n' "$DASHES"

if [ "$BROKEN" != "0" ] || [ "$DASHES" != "0" ]; then
    printf '\n'
    printf 'Fix the path, or write the file the link promises. For a dash, use a\n'
    printf 'comma, a colon, a period, or parentheses. Both rules are binding, and\n'
    printf 'the reasoning is in docs/how-this-repo-works.md.\n'
    printf '\n'
    exit 1
fi

printf '\n'
exit 0
