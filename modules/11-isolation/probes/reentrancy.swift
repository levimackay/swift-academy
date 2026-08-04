// An actor is not a lock. It is released at every `await` inside its own
// methods, and another message is free to run before yours resumes. This
// file makes that happen on purpose, with no threads and no timing, so the
// interleaving is the same on every run.
//
//     make probe CH=11 P=reentrancy
//
// Read `price(for:)` first and convince yourself it caches. Then read what
// it prints.

/// Fires true exactly once, so the demonstration re-enters a single time
/// instead of recursing forever.
actor Once {
    private var used = false

    func firstCall() -> Bool {
        if used { return false }
        used = true
        return true
    }
}

/// A cache with the shape everyone writes first: look, miss, fetch, store.
/// The fetch is an `await`, and the whole bug lives in that one word.
actor PriceCache {
    private var cached: [String: Int] = [:]
    private(set) var loads = 0
    private var fetch: (@Sendable (String) async -> Int)?

    func use(_ fetch: @escaping @Sendable (String) async -> Int) {
        self.fetch = fetch
    }

    func price(for symbol: String) async -> Int {
        if let hit = cached[symbol] { return hit }
        loads += 1
        let fresh = await fetch?(symbol) ?? 0
        // Anything could have run here. This line believes nothing did.
        cached[symbol] = fresh
        return fresh
    }
}

let cache = PriceCache()
let once = Once()

// The fetch calls back into the same cache for the same symbol. That is a
// stand in for the ordinary case: two callers asking at once. The actor is
// suspended at its own `await`, so this second message is admitted.
await cache.use { symbol in
    if await once.firstCall() {
        _ = await cache.price(for: symbol)
    }
    return symbol.count * 100
}

let first = await cache.price(for: "AAPL")
let second = await cache.price(for: "AAPL")

print("price:", first, second)
print("loads:", await cache.loads)
print("one symbol, and the fetch ran that many times")

// The rule this file is teaching, stated once: every `await` inside an
// isolated method is a point where your invariants must already hold,
// because the actor is open for business while you are suspended. Reading
// state before an `await` and writing it after is the shape to distrust.
