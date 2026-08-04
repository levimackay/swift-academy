# Shortcuts for the four things you do every session, plus the two tooling
# entry points. Everything here is a thin wrapper over a command you could
# type yourself, on purpose: the tooling is not the course.
#
#   make test              run every chapter
#   make test CH=03        run chapter 03 only
#   make next              print the next concrete action from PROGRESS.md
#   make done CH=03        the chapter 03 gate, then the Done when checklist
#   make probe CH=03 P=predict     run modules/03-*/probes/predict.swift
#
# The chapter gate filters on the test target name, ChapterNNTests, and never
# on the bare number. Swift Testing matches the filter regex against a test ID
# that includes the source line, so `--filter 10` also selects tests in other
# chapters declared on a line containing 10. Measured on this toolchain:
# `--filter 10` runs 17 tests, `--filter Chapter10Tests` runs 15.
#
# The probe recipe passes -swift-version 6 explicitly because a loose .swift
# file run as a script defaults to Swift 5 mode, which is not the mode any
# chapter is written against.
#   make probe CH=10 P=dangling ARGS=unowned   pass arguments to a probe
#   make verify            check this machine and report runnable chapters
#   make solutions ARGS=status     drive the solutions branch workflow

SHELL := /bin/bash
.DEFAULT_GOAL := help

# CH is a two digit chapter number. The slug is looked up rather than typed,
# so renaming a chapter directory does not break these recipes.
CHAPTER_DIR = $(firstword $(wildcard modules/$(CH)-*))
CHAPTER_SUITE = Chapter$(strip $(CH))Tests

.PHONY: help test next done probe verify solutions clean

# Fails with a readable message instead of an empty path. Inlined rather than
# recursed into, so a missing CH does not print a make[1] stack.
define check_chapter
if [ -z "$(strip $(CH))" ]; then \
	echo "This target needs a chapter number. Example: make $(1) CH=03"; \
	exit 1; \
fi; \
if [ -z "$(strip $(CHAPTER_DIR))" ]; then \
	echo "No chapter directory matches modules/$(CH)-*"; \
	echo "Chapters present:"; \
	ls -d modules/[0-9][0-9]-* 2>/dev/null | sed 's|^|  |'; \
	exit 1; \
fi
endef

define list_probes
echo "Available probes:"; \
if [ -n "$$(ls -A $(CHAPTER_DIR)/probes 2>/dev/null)" ]; then \
	ls $(CHAPTER_DIR)/probes | sed 's|^|  |'; \
else \
	echo "  (none yet)"; \
fi
endef

help:
	@echo "swift-academy"
	@echo ""
	@echo "  make test                    run every chapter test suite"
	@echo "  make test CH=03              run chapter 03 only"
	@echo "  make next                    print the next concrete action"
	@echo "  make done CH=03              chapter 03 gate plus its checklist"
	@echo "  make probe CH=03 P=predict   run one probe file"
	@echo "  make probe CH=10 P=dangling ARGS=unowned"
	@echo "  make verify                  check this machine"
	@echo "  make solutions ARGS=status   solutions branch workflow"
	@echo "  make clean                   delete every .build directory"

test:
ifeq ($(strip $(CH)),)
	swift test
else
	@$(call check_chapter,test)
	swift test --filter $(CHAPTER_SUITE)
endif

# Prints from the **Next action:** marker to the end of the file, because the
# next action is prose and is allowed to wrap. Printing the last line only
# would emit a sentence fragment, which defeats the one mechanism that makes
# reopening the repo after a two week gap cost nothing.
next:
	@if [ ! -f PROGRESS.md ]; then \
		echo "No PROGRESS.md. Create it, and end it with a Log whose last entry is the next action."; \
		exit 1; \
	fi
	@if ! grep -q '\*\*Next action:\*\*' PROGRESS.md; then \
		echo "PROGRESS.md has no **Next action:** marker. Add one as its last entry."; \
		exit 1; \
	fi
	@echo "Next action, from PROGRESS.md:"
	@echo ""
	@sed -n '/\*\*Next action:\*\*/,$$p' PROGRESS.md

# A filter that matches nothing exits 0 with "Test run with 0 tests in 0
# suites passed", so a naive gate congratulates every unwritten chapter and
# any chapter whose test file was deleted. Parse the run instead of trusting
# the exit status.
done:
	@$(call check_chapter,done)
	@echo "Gate for chapter $(CH): swift test --filter $(CHAPTER_SUITE)"
	@set -o pipefail; \
	log="$$(mktemp -t swift-academy-done)"; \
	swift test --filter $(CHAPTER_SUITE) 2>&1 | tee "$$log"; \
	status=$$?; \
	summary="$$(grep -E 'Test run with [0-9]+ test' "$$log" | tail -n 1)"; \
	rm -f "$$log"; \
	if [ -z "$$summary" ]; then \
		echo ""; \
		echo "No test run summary. Chapter $(CH) did not get as far as running tests."; \
		exit 1; \
	fi; \
	count="$$(printf '%s' "$$summary" | grep -oE 'with [0-9]+ test' | grep -oE '[0-9]+')"; \
	if [ "$$count" = "0" ]; then \
		echo ""; \
		echo "Chapter $(CH) has no tests, so there is nothing to be green."; \
		echo "A filter matching nothing exits 0. That is not a passing chapter."; \
		echo "Write $(CHAPTER_DIR)/tests before running this gate."; \
		exit 1; \
	fi; \
	if [ "$$status" -ne 0 ]; then exit "$$status"; fi; \
	echo ""; \
	echo "Chapter $(CH) is green, $$count tests. The rest of the checklist is yours to answer:"; \
	echo "  [ ] Every diagnostic that cost more than ten minutes is in NOTES/errors.md"; \
	echo "  [ ] I contributed this chapter's four drills to drills/"; \
	echo "  [ ] I can explain the three concepts in the front matter out loud, no notes"; \
	echo ""; \
	echo "Then record the solution: ./scripts/solutions.sh save $(CH)"

probe:
	@$(call check_chapter,probe)
	@if [ -z "$(strip $(P))" ]; then \
		echo "probe needs a file name. Example: make probe CH=03 P=predict"; \
		$(list_probes); \
		exit 1; \
	fi
	@if [ ! -f "$(CHAPTER_DIR)/probes/$(P).swift" ]; then \
		echo "No such probe: $(CHAPTER_DIR)/probes/$(P).swift"; \
		$(list_probes); \
		exit 1; \
	fi
	swift -swift-version 6 "$(CHAPTER_DIR)/probes/$(P).swift" $(ARGS)

verify:
	@./scripts/verify-environment.sh

solutions:
	@./scripts/solutions.sh $(ARGS)

clean:
	@find . -type d -name .build -prune -print -exec rm -rf {} +
	@echo "Build directories removed."
