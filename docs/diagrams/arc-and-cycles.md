---
title: ARC and cycles
kind: diagram
verified: Apple Swift 6.2 (swift-6.2-RELEASE), arm64-apple-macosx26.0, 2026-08-03
---

# ARC and cycles

Cross cutting. Chapter
[10-classes-and-arc](../../modules/10-classes-and-arc/README.md) owns the
teaching and carries its own diagram. This file is the long version: the
retain counts drawn as numbers inside the boxes, frame by frame, for the one
graph shape that a tracing collector reclaims and ARC does not.

Run the code these frames describe:

```bash
make probe CH=10 P=cycle
```

## The three node loop

Two objects and one closure. Every edge is strong, which is the default for
a stored property and the default for a capture.

```text
Frame 1: inside the function, the scope local still holds the screen
   +- scope --------------+
   |   screen ---------+  |
   +-------------------|--+
                       v
              +-------------------+
              |  Screen   count 2 |<---------------------+
              +-------------------+                      |
                       | stored property (strong)        |
                       v                                 |
              +-------------------+                      |
              | Uploader  count 1 |                      | captured
              +-------------------+                      | self
                       | stored closure (strong)         | (strong)
                       v                                 |
              +-------------------+                      |
              | closure   count 1 |----------------------+
              +-------------------+

Frame 2: the scope ends and releases its one reference
   +- scope (gone) -------+
   +----------------------+
              +-------------------+
              |  Screen   count 1 |<---------------------+
              +-------------------+                      |
                       v                                 |
              | Uploader  count 1 |                      |
                       v                                 |
              | closure   count 1 |----------------------+

   Screen went 2 -> 1 and stopped. Nothing in the loop reaches zero, so
   no deinit runs, and every byte the three objects hold stays held.
   Unreachable and alive is a state a tracing collector has no name for.

Frame 3: the same graph with [weak self] on the capture
              +-------------------+
              |  Screen   count 0 | -> deinit fires
              +-------------------+
                       v
              | Uploader  count 0 | -> released by Screen
                       v
              | closure   count 0 | -> released by Uploader
                       . . . . . . . weak edge, never counted

   The weak edge was never part of the count, so the scope local was the
   only holder, and its release cascades all the way down.
```

Three things to read off it. The count is a number inside the box, so
reaching zero is something you watch rather than a rule you recall. The
scope is a container that disappears between frames, which is what makes
frame 2 the point. And the weak edge is dashed and one directional, so the
asymmetry that fixes the loop is visible rather than asserted.

## weak against unowned, at the moment of death

```text
weak     var x: Thing?     count unchanged, slot zeroed on dealloc
                           +---------+                +-----+
                           | Thing   |  dealloc  -->   | nil |
                           +---------+                +-----+
                           reading it afterwards is an ordinary Optional

unowned  let x: Thing      count unchanged, slot left dangling
                           +---------+                +-----------+
                           | Thing   |  dealloc  -->   | tombstone |
                           +---------+                +-----------+
                           reading it afterwards terminates:
   Fatal error: Attempted to read an unowned reference but object
   0x... was already destroyed
```

The address in that message is per run, not part of the wording: two
consecutive runs on this machine printed `0xc32d208e0` and `0xb9ccc0ec0`. If
you are comparing character by character, compare everything except the
number.

Both spellings avoid the retain. Only one of them has a defined behavior
after the referent dies, which is the whole basis for choosing. Reproduce the
trap with:

```bash
make probe CH=10 P=dangling ARGS=unowned
```

## What ARC is not

It is not a collector with the pauses removed. A collector answers "can I
reach this object" by walking from roots. ARC answers "does anyone still
hold this object" by counting. The two questions give the same answer for
every graph except a loop, and a loop is exactly what a stored callback
creates. That is the entire delta from C# and from CPython, and it is worth
one sentence rather than one chapter of vocabulary.
