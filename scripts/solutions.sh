#!/usr/bin/env bash
#
# The locked solutions mechanism.
#
# main holds stubs forever. Every solution you write lives on a long lived
# branch called "solutions", and it gets there only after its chapter is
# green. The property that makes this work is simple: for anything you have
# not solved yet, the answer does not exist anywhere in the repository, so
# grep, a fuzzy finder, and GitHub search all come back empty, because there
# is nothing to find.
#
# There is deliberately no "peek" command and no peeked log. `git show` and
# `git diff` already exist, so a one command shortcut with a self audited log
# would be the honor system with extra steps, in a repo whose whole premise
# is trustworthy evidence.
#
# Commands:
#   status          which chapters are recorded on the solutions branch
#   init            create the solutions branch from main, once
#   save NN         record your solved chapter NN, after its tests pass
#   reset NN        restore main's stubs for chapter NN, after it is recorded
#   sync            fast forward the solutions branch onto the latest main
#
# Every command refuses loudly rather than guessing. Nothing here rewrites
# history and nothing here pushes.

set -euo pipefail

SOLUTIONS_BRANCH="solutions"
BASE_BRANCH="main"

REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$REPO_ROOT"

die() {
    printf 'solutions: %s\n' "$1" >&2
    shift || true
    while [ "$#" -gt 0 ]; do
        printf '            %s\n' "$1" >&2
        shift
    done
    exit 1
}

note() { printf '%s\n' "$*"; }

usage() {
    awk 'NR > 2 { if ($0 ~ /^#/) { sub(/^# ?/, ""); print } else { exit } }' "${BASH_SOURCE[0]}"
}

require_git() {
    command -v git >/dev/null 2>&1 || die "git is not on PATH"
    git rev-parse --git-dir >/dev/null 2>&1 || die "this is not a git repository: $REPO_ROOT"
}

current_branch() {
    git rev-parse --abbrev-ref HEAD 2>/dev/null
}

branch_exists() {
    git show-ref --verify --quiet "refs/heads/$1"
}

# Resolves a two digit chapter number to its directory. Exactly one match is
# required, so a duplicate or missing chapter is an error and not a silent
# pick of the first one.
chapter_dir_for() {
    local number="$1"
    case "$number" in
        [0-9][0-9]) ;;
        *) die "chapter must be two digits, for example 03, got: $number" ;;
    esac
    local matches=()
    local candidate
    for candidate in modules/"$number"-*/; do
        [ -d "${candidate}exercises" ] && matches+=("${candidate%/}")
    done
    case "${#matches[@]}" in
        1) printf '%s' "${matches[0]}" ;;
        0) die "no chapter directory matches modules/$number-*/exercises" ;;
        *) die "more than one chapter directory matches modules/$number-*:" "${matches[@]}" ;;
    esac
}

# A scratch worktree lets the solutions branch be committed to without ever
# switching the branch you are standing on, so main's stubs stay in place in
# your editor the whole time. It is registered as a global so the EXIT trap,
# which runs after the function returns, can still see it.
SCRATCH_WORKTREE=""

remove_scratch_worktree() {
    [ -n "$SCRATCH_WORKTREE" ] || return 0
    git worktree remove --force "$SCRATCH_WORKTREE" >/dev/null 2>&1 || true
    rm -rf "$SCRATCH_WORKTREE"
    SCRATCH_WORKTREE=""
}
trap remove_scratch_worktree EXIT

make_scratch_worktree() {
    SCRATCH_WORKTREE="$(mktemp -d -t swift-academy-solutions)"
    rmdir "$SCRATCH_WORKTREE"
    git worktree add --quiet "$SCRATCH_WORKTREE" "$SOLUTIONS_BRANCH" ||
        die "could not check out $SOLUTIONS_BRANCH into a temporary worktree" \
            "Is the branch already checked out somewhere? Run: git worktree list"
}

cmd_status() {
    require_git
    if ! branch_exists "$SOLUTIONS_BRANCH"; then
        note "The $SOLUTIONS_BRANCH branch does not exist yet."
        note "Create it once with: ./scripts/solutions.sh init"
        return 0
    fi

    note "Recorded on $SOLUTIONS_BRANCH:"
    local found=0
    local chapter_dir slug number solution_blob stub_blob
    for chapter_dir in modules/[0-9][0-9]-*/; do
        chapter_dir="${chapter_dir%/}"
        [ -d "$chapter_dir/exercises" ] || continue
        slug="$(basename "$chapter_dir")"
        number="${slug%%-*}"

        solution_blob="$(git ls-tree -r "$SOLUTIONS_BRANCH" -- "$chapter_dir/exercises" 2>/dev/null || true)"
        stub_blob="$(git ls-tree -r "$BASE_BRANCH" -- "$chapter_dir/exercises" 2>/dev/null || true)"

        if [ -z "$solution_blob" ]; then
            printf '  [ ] %s (nothing on the branch)\n' "$slug"
        elif [ "$solution_blob" = "$stub_blob" ]; then
            printf '  [ ] %s (still identical to the stubs on %s)\n' "$slug" "$BASE_BRANCH"
        else
            printf '  [x] %s\n' "$slug"
            found=$((found + 1))
        fi
    done
    note ""
    note "$found chapter(s) solved and recorded."
}

cmd_init() {
    require_git
    if branch_exists "$SOLUTIONS_BRANCH"; then
        die "the $SOLUTIONS_BRANCH branch already exists" \
            "Nothing to do. Run: ./scripts/solutions.sh status"
    fi
    branch_exists "$BASE_BRANCH" || die "there is no $BASE_BRANCH branch to branch from"

    git branch "$SOLUTIONS_BRANCH" "$BASE_BRANCH"
    note "Created $SOLUTIONS_BRANCH from $BASE_BRANCH."
    note "It is a normal long lived branch. Push it when you want it backed up:"
    note "  git push -u origin $SOLUTIONS_BRANCH"
}

cmd_save() {
    local number="${1:-}"
    [ -n "$number" ] || die "save needs a chapter number" "usage: ./scripts/solutions.sh save 03"
    require_git

    local chapter_dir slug
    chapter_dir="$(chapter_dir_for "$number")"
    slug="$(basename "$chapter_dir")"

    local branch
    branch="$(current_branch)"
    [ "$branch" = "$BASE_BRANCH" ] || die \
        "save must run from $BASE_BRANCH, but HEAD is on $branch" \
        "Switch back with: git switch $BASE_BRANCH"

    branch_exists "$SOLUTIONS_BRANCH" || die \
        "the $SOLUTIONS_BRANCH branch does not exist" \
        "Create it once with: ./scripts/solutions.sh init"

    if git diff --quiet HEAD -- "$chapter_dir/exercises"; then
        die "$chapter_dir/exercises is identical to what is committed on $BASE_BRANCH" \
            "There is no solution here to record."
    fi

    # Filter on the test target name, never on the bare number. Swift Testing
    # matches the regex against a test ID containing the source line, so
    # `--filter 10` also runs tests from other chapters. Recording a solution
    # off the back of another chapter's green run would be the worst possible
    # place for that bug to land.
    suite="Chapter${number}Tests"
    note "Running $suite before recording anything."
    test_log="$(mktemp -t swift-academy-solutions)"
    if ! swift test --filter "$suite" 2>&1 | tee "$test_log"; then
        rm -f "$test_log"
        die "chapter $number is not green, so nothing was recorded" \
            "Only a passing chapter goes on the $SOLUTIONS_BRANCH branch."
    fi
    if grep -qE 'Test run with 0 tests' "$test_log"; then
        rm -f "$test_log"
        die "chapter $number ran zero tests, so there is nothing to record" \
            "A filter matching nothing exits 0. Write $chapter_dir/tests first."
    fi
    rm -f "$test_log"

    # The worktree is always removed, including on a failed commit, so a
    # crashed run never leaves a stale registration behind.
    make_scratch_worktree

    mkdir -p "$SCRATCH_WORKTREE/$chapter_dir/exercises"
    # Mirror the directory so a deleted stub on main is a deletion on the
    # solutions branch too, rather than a file that silently survives.
    rm -f "$SCRATCH_WORKTREE/$chapter_dir/exercises"/*.swift
    cp "$chapter_dir/exercises"/*.swift "$SCRATCH_WORKTREE/$chapter_dir/exercises/" ||
        die "no Swift files to copy out of $chapter_dir/exercises"

    git -C "$SCRATCH_WORKTREE" add -- "$chapter_dir/exercises"
    if git -C "$SCRATCH_WORKTREE" diff --cached --quiet; then
        die "the $SOLUTIONS_BRANCH branch already holds exactly these files" \
            "Nothing was recorded."
    fi

    git -C "$SCRATCH_WORKTREE" commit --quiet -m "Solve $slug" ||
        die "the commit on $SOLUTIONS_BRANCH failed" "Nothing was recorded."

    note ""
    note "Recorded $slug on $SOLUTIONS_BRANCH."
    note "Your working tree on $BASE_BRANCH is untouched."
    note "When you want main back to stubs: ./scripts/solutions.sh reset $number"
}

cmd_reset() {
    local number="${1:-}"
    [ -n "$number" ] || die "reset needs a chapter number" "usage: ./scripts/solutions.sh reset 03"
    require_git

    local chapter_dir slug
    chapter_dir="$(chapter_dir_for "$number")"
    slug="$(basename "$chapter_dir")"

    branch_exists "$SOLUTIONS_BRANCH" || die \
        "the $SOLUTIONS_BRANCH branch does not exist, so your work is not recorded anywhere" \
        "Run ./scripts/solutions.sh init and then save $number first."

    local solution_blob stub_blob
    solution_blob="$(git ls-tree -r "$SOLUTIONS_BRANCH" -- "$chapter_dir/exercises" 2>/dev/null || true)"
    stub_blob="$(git ls-tree -r "$BASE_BRANCH" -- "$chapter_dir/exercises" 2>/dev/null || true)"

    if [ -z "$solution_blob" ] || [ "$solution_blob" = "$stub_blob" ]; then
        die "chapter $number is not recorded on $SOLUTIONS_BRANCH" \
            "Refusing to throw your work away. Run: ./scripts/solutions.sh save $number"
    fi

    git restore --source=HEAD --worktree -- "$chapter_dir/exercises"
    note "Restored the committed stubs for $slug."
    note "Your solution is safe on $SOLUTIONS_BRANCH."
}

cmd_sync() {
    require_git
    branch_exists "$SOLUTIONS_BRANCH" || die \
        "the $SOLUTIONS_BRANCH branch does not exist" \
        "Create it once with: ./scripts/solutions.sh init"

    make_scratch_worktree

    if git -C "$SCRATCH_WORKTREE" merge --no-edit "$BASE_BRANCH"; then
        note "Merged $BASE_BRANCH into $SOLUTIONS_BRANCH."
    else
        die "the merge hit a conflict and was left in the temporary worktree" \
            "Resolve it by hand: git switch $SOLUTIONS_BRANCH && git merge $BASE_BRANCH"
    fi
}

case "${1:-status}" in
    status) shift || true; cmd_status "$@" ;;
    init)   shift; cmd_init "$@" ;;
    save)   shift; cmd_save "$@" ;;
    reset)  shift; cmd_reset "$@" ;;
    sync)   shift; cmd_sync "$@" ;;
    -h|--help|help) usage ;;
    *)
        printf 'solutions: unknown command: %s\n\n' "$1" >&2
        usage >&2
        exit 2
        ;;
esac
