---
title: Core Data literacy
kind: reference
verified: Apple Swift 6.2 (swift-6.2-RELEASE), arm64-apple-macosx26.0, 2026-08-03
---

# Core Data literacy

Two pages. No exercises, no test target, no chapter.

This course teaches SwiftData and only SwiftData. That decision was made on
merit and the reasoning is in
[CURRICULUM-DESIGN.md](CURRICULUM-DESIGN.md) section 5: a full Core Data
chapter with exercises on merge policies and lightweight migration is many
hours bought for interview trivia, and completion is the product.

But there are two things you cannot get from skipping it entirely. You will be
asked about Core Data in an interview, and you will join a team that uses it.
This page is sized for exactly those two situations.

Read it **after** chapter 14, not before. Core Data is the system SwiftData's
design responds to, and reading it in that order turns an API tour into a
comparison, which is both more memorable and a better answer out loud. Reading
it first teaches discipline-based concurrency safety at exactly the moment the
rest of the course is teaching type-based safety.

---

## 1. What it is

An object graph manager with a persistence backend, shipped in 2005, and
SQLite-backed in nearly every real deployment. It is not an ORM, and saying so
is the first thing that signals you have used it: it does not map your objects
onto a schema you own, it owns the schema and vends you objects.

Four pieces.

| Piece | What it does |
|---|---|
| **Managed object model** | The schema. A `.xcdatamodeld` file: entities, attributes, relationships, and the delete rules between them. Compiled into a `.momd`. |
| **Persistent store coordinator** | Owns the store file and mediates between the model and the contexts. Mostly invisible now, behind `NSPersistentContainer`. |
| **Managed object context** | A scratchpad. You fetch into it, mutate in it, and `save()` it. Until you save, nothing has happened to the file. |
| **Managed object** | `NSManagedObject`, or a generated subclass. A reference type whose properties are backed by the context, not by stored fields. |

`NSPersistentContainer` is the modern front door: it builds the model, the
coordinator, and the view context, and hands you `container.viewContext`.

---

## 2. Faulting, which is the question they actually ask

**A fault is a placeholder object whose data has not been loaded yet.**

When you fetch, Core Data does not necessarily load the attribute values. It
can hand you an object that knows its identity and nothing else. Touch any
attribute and the object *fires the fault*: Core Data goes to the store,
loads the row, and fills it in. This is transparent, so the code that fires a
fault looks exactly like the code that does not.

Relationships fault too, and that is where the cost is. A to-many relationship
is a fault holding no objects; iterating it fires it. Iterating a hundred
parents and touching one attribute on each child is a hundred round trips to
SQLite. This is Core Data's N+1 problem, and it is the reason
`NSFetchRequest.relationshipKeyPathsForPrefetching` exists.

**The interview answer, in one paragraph:** a fault is a lazy placeholder, so
Core Data can hold a large graph in memory cheaply and load only what you
touch. The cost is that a property access is a possible disk read, so
performance problems present as a loop that is slow for no visible reason. You
diagnose it with the SQL debug flag
(`-com.apple.CoreData.SQLDebug 1`) and you fix it by prefetching the
relationships the loop will touch, or by using a batch fetch, or by fetching
dictionaries instead of objects when you only need values.

A related word: **turning a fault back into a fault** is `refresh(_:mergeChanges:)`,
which is how you reclaim memory from a context that has walked a large graph.

---

## 3. Contexts, threads, and why confinement exists

**A managed object context is not thread safe, and neither are the objects it
vends.** That rule is enforced by convention and a debug flag, not by the type
system, which is the single most important thing to understand about it.

The shape:

- **The view context** is main-queue confined. It exists to feed the UI.
- **Background contexts** are private-queue confined. You get work onto them
  with `container.performBackgroundTask { context in ... }` or
  `context.perform { }`.
- `perform` is async, `performAndWait` is synchronous and blocks the caller.
  Both put the block on the context's own queue, which is the only place its
  objects may be touched.
- **Never pass an `NSManagedObject` between contexts.** Pass its
  `NSManagedObjectID`, which is thread safe, and refetch on the other side
  with `context.object(with:)`.

When you save a background context, the view context does not know about the
change until it merges it. `automaticallyMergesChangesFromParent = true` on
the view context handles the common case; otherwise you observe
`NSManagedObjectContextDidSave` and merge by hand.

**Merge policies** decide what happens when two contexts changed the same row.
`NSMergeByPropertyObjectTrumpMergePolicy` (in-memory wins per property),
`NSMergeByPropertyStoreTrumpMergePolicy` (the store wins per property),
`NSOverwriteMergePolicy`, `NSRollbackMergePolicy`, and the default,
`NSErrorMergePolicy`, which refuses and throws. The default is the honest one
and it is the one people change first without reading.

**The debug flag that turns convention into a crash:** launch with
`-com.apple.CoreData.ConcurrencyDebug 1` and any cross-queue access traps
immediately instead of corrupting the graph three screens later. Turn it on
in every debug scheme of every Core Data project you ever touch.

**Why this is the comparison that matters.** Core Data's answer to concurrency
is a rule you follow. Swift's answer is a type the compiler checks. A Core
Data context under Swift 6 is not `Sendable` and cannot be made `Sendable`
truthfully, so a modern codebase wraps it and confines the wrapper. SwiftData's
`ModelActor` is exactly that wrapper, promoted into the language's own model:
the actor owns the context, and the compiler enforces what
`ConcurrencyDebug` used to catch at runtime.

---

## 4. `NSFetchedResultsController`

The controller that watches a fetch request and tells a table view exactly
which rows changed: inserted, deleted, moved, updated, with index paths and
section boundaries, batched into begin and end updates.

It is worth knowing because it is the direct ancestor of `@Query`. In UIKit it
was the difference between a table that reloads entirely on every change and a
table that animates the one row that moved. It also handled sectioning by a
key path, and it kept a fetch live without you re-running it.

`@Query` in SwiftUI is that idea with the diffing moved into SwiftUI's own
identity system: you declare the fetch as a property, and the view updates.
You never write the delegate.

---

## 5. Migration

Core Data models are versioned. Adding a version and letting Core Data infer
the mapping is **lightweight migration**, and it handles adding and removing
attributes and entities, renaming with a renaming identifier, and changing
optionality where a default exists.

Anything it cannot infer needs a **mapping model** and possibly an
`NSEntityMigrationPolicy` subclass, which is real code you write and test.
Splitting an entity in two, merging two into one, or transforming values
during the move are all in that bucket.

**The rule that survives into SwiftData: design for migration before you ship,
not after.** The first version's schema is the one you are stuck with for
every user who ever installed it. Once real data exists on real devices, the
cost of a schema decision is the cost of writing and testing a migration for
every version pair, forever.

SwiftData has `VersionedSchema` and `SchemaMigrationPlan` for the same job,
with lightweight and custom stages, and the same rule applies unchanged.

---

## 6. The three reasons a real team still picks Core Data in 2026

Answer this one specifically, because "it is older" is not an answer.

1. **Migration control.** Custom migration policies are mature, testable, and
   documented, with a decade of production experience behind them. If your
   schema will change in ways that are not inferrable, that maturity is worth
   real money.
2. **CloudKit configuration granularity.** `NSPersistentCloudKitContainer`
   lets you configure which store configurations sync, split public and
   private databases, and handle sharing. SwiftData's CloudKit story is
   simpler and correspondingly less configurable.
3. **An existing codebase.** By far the most common reason. A five year old
   app with a hundred entities and a suite of migration tests does not rewrite
   its persistence layer to save syntax.

A fourth, honest one: **the interoperation escape hatch.** SwiftData and Core
Data can address the same store, so a team can adopt SwiftData for new code
without a migration. That is a Core Data answer wearing a SwiftData hat, and
it is the most common real migration path.

---

## 7. Vocabulary you should recognise instantly

| Term | One line |
|---|---|
| `NSManagedObjectContext` | The scratchpad. Queue confined. |
| `NSManagedObjectID` | A thread safe identity you may pass between contexts. |
| `NSPersistentContainer` | The modern front door: model, coordinator, view context. |
| Fault | A lazy placeholder that loads on first touch. |
| Firing a fault | The load that first touch triggers. |
| `NSFetchRequest` | The query, with a predicate, sort descriptors, and a batch size. |
| `NSPredicate` | The query language, string based, unchecked at compile time. |
| `NSBatchInsertRequest`, `NSBatchDeleteRequest` | Store level operations that bypass the context, so the context does not know about them. |
| Delete rule | Cascade, nullify, deny, or no action, declared per relationship in the model. |
| Merge policy | Who wins when two contexts changed the same row. |
| `performBackgroundTask` | The correct way to get work off the main queue. |
| Lightweight migration | Inferred schema mapping. Everything else needs a mapping model. |

---

## 8. What this maps to in what you learned

| Core Data | SwiftData | Note |
|---|---|---|
| `.xcdatamodeld` file | `@Model` on a Swift type | The schema is code, checked by the compiler. |
| `NSManagedObject` subclass | your `@Model` class | Still a reference type, still with identity. |
| `NSPredicate` (strings) | `#Predicate` (a macro) | Type checked at compile time. This is the LINQ expression tree comparison. |
| `NSFetchRequest` | `FetchDescriptor`, or `@Query` | |
| `NSFetchedResultsController` | `@Query` | The diffing moved into SwiftUI's identity system. |
| `viewContext` | `modelContext` from `@Environment` | |
| `performBackgroundTask` | `ModelActor` | Confinement by convention becomes isolation by type. |
| Merge policies | still there, less exposed | |
| Mapping models | `SchemaMigrationPlan` | Same rule: design for it before shipping. |

---

Related: [legacy-swift.md](legacy-swift.md),
[interview-questions.md](interview-questions.md), and chapter 14,
[../modules/14-swiftui-app/README.md](../modules/14-swiftui-app/README.md).
