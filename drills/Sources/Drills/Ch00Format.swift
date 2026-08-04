// The worked format example shipped with the repo. It is deliberately about
// nothing any chapter teaches, so reading it gives away no answer. Read it
// for the shape, then delete it whenever you like.
//
// A drill is a retrieval prompt you contribute after finishing a chapter,
// four per chapter, and it ships complete because you already solved it. Its
// value from then on is that you can re-solve it cold: delete the body, keep
// the signature and the doc comment, and run the suite.

/// Sum the even numbers in `1...limit`.
///
/// Returns zero when `limit` is below one, because the range is empty. A
/// `limit` that is itself even is included.
public func formatDemoEvenSum(upTo limit: Int) -> Int {
    guard limit >= 1 else { return 0 }
    return stride(from: 2, through: limit, by: 2).reduce(0, +)
}
