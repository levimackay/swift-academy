---
title: Strings, in detail
kind: reference
verified: Apple Swift 6.2 (swift-6.2-RELEASE), arm64-apple-macosx26.0, 2026-08-03
---

# Strings, in detail

A lookup page, not a chapter. Chapter
[06-collections](../modules/06-collections/README.md) teaches the model: a
`Character` is a grapheme cluster, `String.Index` is opaque and O(n) to
advance, and the four views are four real collections over one storage. This
page holds the parts that are recipe rather than model, so that the chapter
does not have to carry them and you do not have to rediscover them.

Nothing here is sequenced and nothing here has exercises. Look up what you
were about to type, take the recipe, go back to the chapter.

Foundation is imported where a row needs it, and every row says so.

---

## 1. Index arithmetic recipes

Every index comes from the string, and every one of these is a walk rather
than an addition. `index(_:offsetBy:)` is O(k) in the offset, so a loop that
calls it once per iteration is accidentally quadratic. When you find yourself
writing that loop, you wanted `enumerated()`, `indices`, or a plain
`for character in text` instead.

```swift
let text = "collections"

let third = text.index(text.startIndex, offsetBy: 2)
text[third]                                     // "l"

// Bounds safe. Returns nil instead of trapping when the offset runs off
// the end, which is the form to reach for on untrusted input.
text.index(text.startIndex, offsetBy: 99, limitedBy: text.endIndex)   // nil

// Distance between two indices, in Characters, also O(n).
text.distance(from: text.startIndex, to: third)  // 2

// Neighbours.
text.index(after: text.startIndex)
text.index(before: text.endIndex)

// Every valid position, as a collection you can zip or enumerate.
for position in text.indices where text[position] == "c" {
    _ = text.distance(from: text.startIndex, to: position)
}

// Search returns an index, so a range built from it is already valid.
if let found = text.firstIndex(of: "t") {
    _ = text[found...]
    _ = text[..<found]
}
```

`endIndex` is one past the last character, so subscripting it traps. Half open
ranges written with `..<endIndex` are correct; `...endIndex` is not.

`String.Index` is comparable and it carries the encoding offset it was built
from, which is why an index produced by one string must not be used to
subscript another. Two strings that compare equal can have different index
values, and the compiler cannot stop you crossing them. An index taken from a
view is usable in the other views when it lands on a boundary they share, and
`samePosition(in:)` is the conversion that returns `nil` when it does not.

---

## 2. Substring: storage, lifetime, and the boundary

Slicing a `String` gives a `Substring`. It is a view over the parent's
storage, it shares the parent's indices, and it exists so that splitting a
large document into a thousand fields does not allocate a thousand buffers.

```swift
let header = "name,email,role"
let fields = header.split(separator: ",")        // [Substring]
fields[0].startIndex == header.startIndex        // true
```

The cost is retention. A `Substring` keeps the entire parent buffer alive, so
holding a three character slice of a ten megabyte file retains ten megabytes.
The rule that makes this a non issue: **convert at the boundary.** A
`Substring` is fine as a local, as a loop variable, and as an argument. The
moment it is stored in a property, returned from a public function, or put in
a long lived array, write `String(field)` and pay the copy once.

```swift
let names: [String] = header.split(separator: ",").map(String.init)
```

`String(substring)` is the only conversion; there is no coercion, and `as
String` does not compile.

---

## 3. Normalization and locale aware comparison

`==` on `String` is canonical equivalence, which is normalization insensitive
by construction: `"e\u{301}"` and `"\u{e9}"` are equal and both have `count`
1. That is the default and it is almost always what you want.

The forms exist anyway, and Foundation exposes them.

| You want | Write |
|---|---|
| The precomposed form, NFC | `text.precomposedStringWithCanonicalMapping` |
| The decomposed form, NFD | `text.decomposedStringWithCanonicalMapping` |
| The compatibility forms, NFKC and NFKD | `precomposedStringWithCompatibilityMapping`, `decomposedStringWithCompatibilityMapping` |
| Case insensitive comparison | `a.caseInsensitiveCompare(b) == .orderedSame` |
| Sorting the way the user's Finder sorts | `a.localizedStandardCompare(b)` |
| Sorting in a fixed locale, for a file format | `a.compare(b, options: [], range: nil, locale: Locale(identifier: "en_US_POSIX"))` |

All six need `import Foundation`.

The distinction worth keeping: `<` on `String` orders by Unicode scalar value,
which is stable, reproducible, and wrong for humans. `localizedStandardCompare`
orders the way the user expects, which means it changes with the user's locale
and must never be used to sort something you then persist or hash. Sort for
storage with `<`. Sort for display with `localizedStandardCompare`.

`lowercased()` and `uppercased()` are locale independent. `lowercased(with:)`
is the locale aware form, and the reason it exists is Turkish dotted and
dotless i.

---

## 4. Encoding conversion

Going out is total: every `String` has a valid UTF-8 encoding.

```swift
let bytes = Array("café".utf8)              // [UInt8], 5 bytes
let data = Data("café".utf8)                // needs Foundation
```

Coming in can fail, so the initialiser you pick is a decision about what to do
with invalid bytes.

| Initialiser | Invalid input becomes |
|---|---|
| `String(decoding: bytes, as: UTF8.self)` | U+FFFD replacement characters, never fails |
| `String(bytes: bytes, encoding: .utf8)` | `nil`, and needs Foundation |
| `String(validating: bytes, as: UTF8.self)` | `nil`, no Foundation |

`String(decoding:as:)` is the right default for display. The failable forms
are right when invalid bytes mean the input is corrupt and you want to say so
rather than render a row of question marks. Nothing in this repository decodes
bytes by hand except chapter 09, which lets `JSONDecoder` do it.

---

## 5. StringProtocol, and why you should not write generics over it

`String` and `Substring` both conform to `StringProtocol`, so it looks like
the right way to write a function that accepts either.

It is not. The standard library's own documentation says not to, and the
reason is that `StringProtocol` carries `Self` requirements and associated
types that make every generic over it harder to read, harder to specialise,
and prone to overload ambiguity at the call site.

Write `String` and let the caller convert:

```swift
func slug(of text: String) -> String {
    text.lowercased().split(separator: " ").joined(separator: "-")
}

let title = "Collections and Transformations"
_ = slug(of: title)
_ = slug(of: String(title.prefix(11)))
```

The one time to generalise is when profiling shows the conversion is the cost,
and then the shape to reach for is `some Sequence<Character>`, which says what
you actually need.

---

## 6. Regex, in one pointer

Swift has regex literals, `Regex`, and a `RegexBuilder` DSL, all introduced in
Swift 5.7 and all part of the standard library rather than Foundation.

```swift
let version = /(\d+)\.(\d+)/
if let match = "swift 6.2".firstMatch(of: version) {
    _ = (match.1, match.2)                  // ("6", "2"), both Substring
}
```

Nothing in this curriculum teaches it, and nothing in it requires it. The
capture groups are typed, `RegexBuilder` gives the same thing in a readable
form for anything longer than one line, and both are documented at
<https://developer.apple.com/documentation/swift/regex>. Treat this section as
permission to use regex and notice that the matches come back as `Substring`,
which puts you back in section 2.

---

Related: [06-collections](../modules/06-collections/README.md) for the model,
[bridge-python.md](bridge-python.md) for the `s[0]` and `len(s)` rows, and
[reference.md](reference.md) for everything else that is lookup rather than
instruction.
