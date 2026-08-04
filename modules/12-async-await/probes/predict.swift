// Write your prediction on the PREDICTION line above each snippet, then run
// the file. The toolchain is the answer key, and there is no other one in
// this repository.
//
//     make probe CH=12 P=predict
//
// Items 1 and 3 are about inheritance: what a new task picks up from the task
// that created it, and what it deliberately does not. Item 2 is not; it is
// about what an AsyncStream buffers and what it drops.

// 1. An unstructured task started inside another task.
//    PREDICTION:
print("1:")
let outer = Task { () -> (Bool, Bool) in
    let inner = Task { () -> Bool in
        try? await Task.sleep(for: .milliseconds(50))
        return Task.isCancelled
    }
    try? await Task.sleep(for: .milliseconds(50))
    return (Task.isCancelled, await inner.value)
}
outer.cancel()
let (outerSawCancel, innerSawCancel) = await outer.value
print("  outer.isCancelled \(outerSawCancel), inner.isCancelled \(innerSawCancel)")

// 2. A stream that is filled before anybody iterates it, and pushed to once
//    more after it is closed.
//    PREDICTION:
print("2:")
let prefilled = AsyncStream<Int> { continuation in
    continuation.yield(1)
    continuation.yield(2)
    continuation.finish()
    continuation.yield(3)
}
var seen: [Int] = []
for await value in prefilled {
    seen.append(value)
}
print("  \(seen)")

// 3. Priority, down a structured child and down a detached one. Note that
//    nothing here awaits the detached task, which matters: awaiting a task
//    from a higher priority one raises the awaited task to match.
//    PREDICTION:
print("3:")
actor Recorder {
    var seen: [String: TaskPriority] = [:]
    func record(_ name: String, _ priority: TaskPriority) { seen[name] = priority }
    func priority(of name: String) -> TaskPriority? { seen[name] }
}
let recorder = Recorder()
let elevated = Task(priority: .high) {
    async let child: Void = recorder.record("child", Task.currentPriority)
    Task.detached { await recorder.record("detached", Task.currentPriority) }
    await child
}
await elevated.value
try? await Task.sleep(for: .milliseconds(50))
print("  child \(await recorder.priority(of: "child") as Any)")
print("  detached \(await recorder.priority(of: "detached") as Any)")
