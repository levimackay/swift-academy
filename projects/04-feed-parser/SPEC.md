---
project: 04
slug: 04-feed-parser
title: Feed Parser
after_chapter: 09-codable
difficulty: 3 of 5
estimated_hours: 10
package: standalone (projects/04-feed-parser/Package.swift)
---

# Project 04. Feed Parser

## What you are building

A library that turns a hostile JSON feed into strict domain values, with no
network anywhere. The JSON lives in `Fixtures/` at the package root, as
ordinary files on disk, and is loaded by deriving a path from `#filePath`
rather than as a bundled SwiftPM resource. That is settled in the header
comment of this project's `Package.swift` and it is the one place it is
settled. The feed is a list of posts, each with an
author, a body, a publication date, a category, and some optional attachments,
and the payload does everything a real backend does: it names fields in snake
case, sends `null` where you expected a value, omits keys entirely, encodes dates
in two different formats in the same file, and sends a category string your app
has never heard of. When it is done, valid fixtures decode into domain types
where every property is exactly the type it should be (no `String` standing in
for a date, no `String` standing in for a category), invalid fixtures produce a
typed error that names the field and the reason, and no fixture anywhere causes a
crash or a silently wrong value.

The domain types are the deliverable. The decoding is how they get filled.

## What this project forces you to use

| Concept | Chapter |
|---|---|
| `Codable`, `CodingKeys`, and custom `init(from:)` where the synthesized one loses | `09-codable` |
| Nested and keyed containers, `decodeIfPresent` versus `decode` of an optional | `09-codable` |
| Unknown enum case fallback that keeps the raw value instead of discarding it | `09-codable`, `05-enums` |
| `throws(E)` with a domain error type, and why not `Error` | `08-errors` |
| The nil versus `throws` versus `Result` decision, made per API and defended | `08-errors` |
| Enums with associated values for a partially known category | `05-enums` |
| Optional versus a defaulted value, decided deliberately per field | `01-optionals` |
| Value types throughout, and `compactMap` where a lenient mode drops entries | `03-value-semantics`, `06-collections` |

## The wire shape

Field names are snake case on the wire and must not be snake case in your
domain types. Which fields are required decides what half the fixtures mean,
so it is fixed here rather than left for you to infer:

| Path | Required | Note |
|---|---|---|
| `feed_title` | yes | |
| `feed_version` | yes | an integer |
| `posts` | yes | may be empty |
| `posts[].post_id` | yes | a string, and fixture 09 sends a number |
| `posts[].author.display_name` | yes | |
| `posts[].author.handle` | yes | |
| `posts[].author.avatar_url` | no | a URL, or absent, or `null` |
| `posts[].body` | yes | |
| `posts[].published_at` | yes | ISO 8601 string or epoch seconds number |
| `posts[].category` | yes | a known case, or an unknown string |
| `posts[].attachments` | no | absent means none, and so does `[]` |
| `posts[].attachments[].kind` | yes | `image` or `link` |
| `posts[].attachments[].url` | yes | |
| `posts[].attachments[].caption` | no | |

The known categories are `engineering` and `operations`. Everything else is
the unknown case, and it keeps its string.

## Fixture inventory

The eleven files in `Fixtures/` are given to you, not written by you. They are
adversarial data rather than answers, which is why they live on `main`. Every
row has one file and your tests must cover all of them:

| File | Fixture trait | What it must produce |
|---|---|---|
| `01-valid-feed.json` | Fully valid feed | Every post decoded, no error |
| `02-null-optional-field.json` | Explicit `null` for an optional field | Absent value, not an error |
| `03-null-required-field.json` | Explicit `null` for a required field | A typed error naming that field |
| `04-missing-optional-key.json` | Missing key for an optional field | Absent value, not an error |
| `05-missing-required-key.json` | Missing key for a required field | A typed error naming that field |
| `06-iso8601-dates.json` | ISO 8601, three time zone spellings | Three `Date` values, one instant |
| `07-epoch-dates.json` | Unix epoch seconds as a number | A `Date`, the same instant as its ISO twin |
| `08-unknown-category.json` | Two unknown categories and one known | Decoded, each raw value preserved, no error |
| `09-wrong-json-type.json` | Number where a string was expected | A typed error naming that field |
| `10-empty-posts.json` | Empty array of posts | An empty feed, not an error |
| `11-truncated.json` | Malformed JSON, truncated mid string | A typed error distinguishable from a field error |

Verified when they were written: files 01 through 10 parse as JSON and
`11-truncated.json` does not. In `06` and `07` the instant is 1784021400,
which is `2026-07-14T09:30:00Z`, written four ways across the two files
(`Z`, `+02:00`, `-04:00`, and the number). Requirement 6's "same instant" test
is that number.

Fixture `08` carries two different unknown categories on purpose. An
`Equatable` conformance that treats all unknowns as equal passes every other
fixture and fails this one, which is the point the architecture questions
below make about a hand written `==`.

## Functional requirements

1. Domain types (`Feed`, `Post`, `Author`, `Attachment`, `Category`, or whatever
   you name them) contain no JSON vocabulary. No `snake_case` property names, no
   `String` where the domain means a date, an enum, or a URL.
2. The public entry point takes `Data` and returns a decoded feed, or fails with
   your error type. It does not take a file path and it does not read the disk.
3. A second, thin layer loads a named fixture from `Fixtures/` and hands the
   bytes to that entry point. Only that layer knows about files, and it finds
   the directory from `#filePath`, not from a bundle and not from the current
   working directory (which differs between `swift test` and Xcode).
4. Every failure mode in the fixture inventory produces a specific case of your
   error type, not a rethrown `DecodingError`, and carries enough information to
   name the offending field or index.
5. The parse function's failure is declared in the signature with a concrete
   error type, not as untyped `throws`.
6. Both date formats decode correctly to the same instant when they represent the
   same instant, and there is a test asserting exactly that.
7. Date decoding is per property or per container. A single global
   `dateDecodingStrategy` that handles both formats by trying one then the other
   is acceptable only if you can state why it is not fragile here.
8. An unknown category decodes to a case that preserves the original string, so
   the app can display it and telemetry can report it. Discarding it or mapping it
   to a shared "other" with no payload fails this requirement.
9. Adding a new known category must produce compiler errors at every site that
   must change, and no compiler error at sites that must not. Say in a comment
   which behavior you chose and how the enum shape produces it.
10. There is a strict mode and a lenient mode. Strict fails the whole feed on the
    first bad post. Lenient skips bad posts, decodes the rest, and reports which
    indices were skipped and why. Both are reachable through the public API.
11. Lenient mode never silently loses a post: every skipped index appears in the
    result along with its reason.
12. Round trip: any successfully decoded feed re encodes to JSON that decodes
    again to an equal feed. Byte for byte identity with the original file is not
    required and is not a goal.
13. `Equatable` on the domain types is real, so tests can compare whole decoded
    values rather than asserting field by field.
14. No fixture, including malformed JSON and wrong types, can cause a trap. The
    test suite runs to completion on every fixture.

## Non-goals

- No network. No `URLSession`, no `URLRequest`, no async. The bytes come from a
  file, always.
- No caching, no persistence, no database.
- No custom JSON parser. `JSONDecoder` is the tool.
- No XML, no RSS, no Atom, despite the project name.
- No pagination, no incremental parsing, no streaming.
- No concurrency. Chapters 11 and 12 have not happened yet.
- No UI.

## Architecture: constraints and questions

**Your domain layer must not import Foundation for JSON reasons.** It will
probably import Foundation for `Date` and `URL`, and that is fine, but no domain
type should mention `CodingKeys`, `Decoder`, or `JSONDecoder` if you can avoid
it. Why does that separation matter here specifically, when the only source of
data today is JSON?

- There are two shapes available: conform your domain types to `Decodable`
  directly, or decode into separate wire types and map them into domain types.
  Both are defensible and real teams do both. Pick one, write three sentences on
  the tradeoff, and notice which one made requirement 1 easier to hold.
- `decodeIfPresent(String.self, forKey:)` and `decode(String?.self, forKey:)` are
  not the same function and do not behave the same on a missing key versus a
  `null`. Find the difference by running it, then decide which one each optional
  field wants. This is the single highest yield hour in the project.
- Requirement 4 says do not rethrow `DecodingError`. So you are catching it and
  translating. Where does that translation live so that it happens exactly once
  rather than at every call site?
- `DecodingError` carries a `codingPath`. Requirement 4 wants a field name. What
  does a coding path look like for a bad attachment inside the third post, and
  what is the readable string you turn it into?
- Requirement 10 asks for two modes. Is that a parameter, two functions, or a
  configuration value passed to the initializer? Which of those makes it
  impossible to call the parser without having decided?
- Lenient mode's return value is not the same type as strict mode's. Is it a
  `Result`, a tuple, a struct with two fields, or a throwing function that also
  returns diagnostics? Chapter 08 gave you the decision procedure. Apply it and
  write down the answer.
- The unknown category case has a payload. Does it conform to `Equatable`
  correctly when two unknown categories carry different strings? Test that
  specifically, because a hand written `==` is where this quietly breaks.
- Your error type is public and other code will switch over it. Does it have a
  case that means "something else happened"? If yes, you have reintroduced
  untyped errors with extra steps. If no, what happens when `JSONDecoder` throws
  something you did not anticipate?

## Milestones

1. **Domain types first, no decoding.** Write `Feed`, `Post`, and friends with
   `Equatable`, and construct one by hand in a test. If the types are wrong,
   decoding will paper over it.
2. **Happy path decode.** The fully valid fixture, synthesized conformances only,
   `CodingKeys` for the snake case mapping.
3. **Optionality.** The `null` and missing key fixtures, all four combinations of
   required versus optional and null versus missing.
4. **Dates.** Both formats, plus the same instant test.
5. **The category enum.** Known cases, then the unknown case with its payload,
   then requirement 9.
6. **The error type.** Introduce it, convert the throwing surface to `throws(E)`,
   translate `DecodingError` in one place, and make the wrong type and malformed
   JSON fixtures produce distinguishable cases.
7. **Lenient mode and the skipped index report.**
8. **Round trip encoding.**

## Definition of done

- [ ] `swift build` is clean with no warnings.
- [ ] `swift test` is green, with at least one test per row of the fixture
      inventory table.
- [ ] Every domain type is a value type and none of them stores a raw JSON
      dictionary "just in case".
- [ ] The public parse signature names its error type.
- [ ] No test asserts on the text of a `DecodingError` message. You may assert on
      your own error's case and payload.
- [ ] No force unwrap in `Sources/`.
- [ ] `NOTES/errors.md` has the verbatim text of at least one `DecodingError`
      you actually hit, with what you first thought it meant.
- [ ] You can explain out loud, no notes, the difference between a missing key
      and an explicit `null` and how each of your fields treats both.

## Stretch goals

Not required to advance.

- Add a fixture with a deeply nested attachment array where one element is bad,
  and make the error path name the exact index chain.
- Support a second, incompatible feed version behind the same domain types, and
  decide where the version switch lives.
- Add a property based test that generates random valid feeds, encodes them, and
  decodes them back.
- Write the same parser once more against `Decodable` synthesis only, with no
  custom `init(from:)`, and compare how much of the fixture inventory it can
  actually satisfy.

## Self-review before you call it finished

1. Can a caller of my public API construct an invalid `Post`? If yes, is that on
   purpose?
2. Is there any place where a decoding failure turns into a default value without
   the caller being able to find out?
3. Does the phrase "snake case" appear anywhere outside my `CodingKeys`?
4. If the backend adds a field tomorrow, does my parser break? Should it?
5. If the backend renames a field tomorrow, does my parser fail loudly or produce
   an empty string?
6. Did I test the empty array fixture, or did I assume it?
7. Does my lenient mode's report let me reconstruct which posts were lost, or
   only how many?
8. Would I be able to answer, in an interview, why my parse function uses
   `throws(E)` rather than returning `Result`?
