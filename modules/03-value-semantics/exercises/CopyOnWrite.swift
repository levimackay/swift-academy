// Chapter 03 exercises, part two: exercise 4, on its own because it is the
// only one that needs a reference type to exist at all.
//
// `LedgerStorage` below is written for you and you are not asked to change
// it. The storage box, the copy, and the generation counter are plumbing.
// The exercise is the one decision `post(_:)` has to make before it writes.

// MARK: - 4. Ledger

/// The shared heap buffer behind a `Ledger`. Provided in full.
///
/// `copies` records how many copies deep this particular buffer is. A buffer
/// made by `init` is generation 0; the buffer `copied()` returns is one
/// generation further along. That number is how the test suite watches
/// whether you copied, without caring about addresses.
final class LedgerStorage {
    var amounts: [Int]
    let copies: Int

    init(amounts: [Int], copies: Int = 0) {
        self.amounts = amounts
        self.copies = copies
    }

    /// A fresh buffer holding the same amounts, one generation on.
    func copied() -> LedgerStorage {
        LedgerStorage(amounts: amounts, copies: copies + 1)
    }
}

/// A list of amounts that behaves exactly like a value and stores exactly
/// like a reference, which is the trick every standard library collection
/// plays on you.
///
/// The contract, and both halves of it are graded:
///
/// 1. Two ledgers that were copied from one another never observe each
///    other's writes. This is what makes `Ledger` a value.
/// 2. Writing to a ledger whose buffer nobody else is holding does not
///    allocate a new buffer. This is what makes the value affordable.
///
/// Satisfying 1 alone is easy and slow: copy on every write. Satisfying
/// both means asking, at the moment of the write, whether anyone else is
/// looking.
struct Ledger {
    private var storage: LedgerStorage

    init(amounts: [Int]) {
        storage = LedgerStorage(amounts: amounts)
    }

    /// The amounts in this ledger, in order.
    var amounts: [Int] {
        storage.amounts
    }

    /// How many copies deep this ledger's buffer is. Test only instrument.
    /// A ledger that has never had to split from a sibling reports 0.
    var copiesMade: Int {
        storage.copies
    }

    /// Appends `amount` to the end of this ledger.
    mutating func post(_ amount: Int) {
        // TODO: replace this.
    }
}
