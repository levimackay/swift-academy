// The one rule a continuation carries, and what breaks when you break it.
//
//     make probe CH=12 P=continuation
//
// A continuation is the reified rest of a suspended function. Resuming it is
// what wakes the caller back up, so it must happen exactly once: zero times
// leaks a task that never runs again, twice corrupts the runtime. Neither is
// a compiler error, which is why `withCheckedContinuation` exists. It costs
// an allocation and it turns both mistakes into a loud message instead of a
// silent hang or a random crash.

import Dispatch

/// A callback API of the kind you actually meet: it answers on some other
/// thread, once, and it has never heard of `async`.
final class Thermistor: Sendable {
    private let reading: Int

    init(reading: Int) { self.reading = reading }

    func measure(_ completion: @escaping @Sendable (Int) -> Void) {
        let reading = self.reading
        DispatchQueue.global().asyncAfter(deadline: .now() + 0.02) {
            completion(reading)
        }
    }
}

/// The correct bridge. One suspension, one resume, and the callback's thread
/// is not the thread the caller resumes on.
func measured(by thermistor: Thermistor) async -> Int {
    await withCheckedContinuation { continuation in
        thermistor.measure { value in
            continuation.resume(returning: value)
        }
    }
}

let single = await measured(by: Thermistor(reading: 1013))
print("one reading:", single)

// Two bridges awaited concurrently. Each has its own continuation, and
// neither knows about the other.
async let low = measured(by: Thermistor(reading: 950))
async let high = measured(by: Thermistor(reading: 1030))
print("two readings:", await low, await high)

// RESUMING TWICE
//
// func twice() async -> Int {
//     await withCheckedContinuation { continuation in
//         continuation.resume(returning: 1)
//         continuation.resume(returning: 2)
//     }
// }
// print(await twice())
//
// _Concurrency/CheckedContinuation.swift:172: Fatal error: SWIFT TASK
// CONTINUATION MISUSE: twice() tried to resume its continuation more than
// once, returning 2!
//
// It is a fatal error, not a thrown error. There is nothing to catch. The
// unchecked spelling, withUnsafeContinuation, does not diagnose this at all:
// it corrupts the task and you find out somewhere else.

// NEVER RESUMING
//
// func never() async -> Int {
//     await withCheckedContinuation { (continuation: CheckedContinuation<Int, Never>) in
//         _ = continuation
//     }
// }
// let stuck = Task { await never() }
// try? await Task.sleep(for: .milliseconds(200))
// stuck.cancel()
//
// SWIFT TASK CONTINUATION MISUSE: never() leaked its continuation without
// resuming it. This may cause tasks waiting on it to remain suspended
// forever.
//
// Note when that message arrives: at the moment the continuation is
// deallocated, which is not the moment the mistake was made. Note also that
// cancelling the waiting task does not free it. Cancellation is a flag, and
// a task suspended on a continuation nobody will resume never gets to read
// the flag.

print("continuation.swift done")
