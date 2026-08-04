// The shape of the task tree, printed rather than described.
//
//     make probe CH=12 P=tree
//
// Three claims are made in the chapter's model section. This file is the
// evidence for all three:
//
//   1. a child task starts when it is created, not when it is awaited
//   2. a scope cannot exit before its children are finished
//   3. cancelling a parent cancels its children, and cancels nothing else

import Dispatch

/// A timestamped log, so the order of events survives being printed from
/// several tasks at once.
actor Timeline {
    private var entries: [String] = []
    private let start = DispatchTime.now().uptimeNanoseconds

    func note(_ text: String) {
        let elapsed = (DispatchTime.now().uptimeNanoseconds - start) / 1_000_000
        let stamp = String(repeating: " ", count: max(0, 4 - "\(elapsed)".count)) + "\(elapsed)"
        entries.append("  \(stamp)ms  \(text)")
    }

    func report(_ heading: String) {
        print(heading)
        entries.forEach { print($0) }
        entries.removeAll()
    }
}

let timeline = Timeline()

/// Sleeps, and says so on the way in and on the way out. If cancelled it
/// says that instead, which is the only way it differs from a real network
/// call.
func step(_ name: String, milliseconds: Int, on timeline: Timeline) async -> String {
    await timeline.note("\(name) begins")
    do {
        try await Task.sleep(for: .milliseconds(milliseconds))
    } catch {
        await timeline.note("\(name) cancelled")
        return "\(name):cancelled"
    }
    await timeline.note("\(name) ends")
    return "\(name):done"
}

// 1. Both children begin before either result is read. The `await` is where
//    this function waits, not where the work starts.
async let alpha = step("alpha", milliseconds: 60, on: timeline)
async let beta = step("beta", milliseconds: 30, on: timeline)
await timeline.note("both declared, nothing awaited yet")
let pair = await (alpha, beta)
await timeline.note("collected \(pair.0) and \(pair.1)")
await timeline.report("async let, two children:")

// 2. The group's closing brace is a join. The line after it cannot run
//    while any child is still going, so there is no leaked work and no
//    fire and forget.
let names = await withTaskGroup(of: String.self) { group in
    for (index, delay) in [50, 10, 30].enumerated() {
        group.addTask { await step("child\(index)", milliseconds: delay, on: timeline) }
    }
    var collected: [String] = []
    for await result in group {
        collected.append(result)
    }
    return collected
}
await timeline.note("group returned \(names.count) results in completion order")
await timeline.report("withTaskGroup, results arrive as they finish:")

// 3. Cancelling the parent cancels the children it owns. The detached task
//    is not one of them, which is the entire argument against reaching for
//    Task.detached.
let parent = Task {
    let stray = Task.detached {
        await step("detached", milliseconds: 120, on: timeline)
    }
    async let owned = step("owned", milliseconds: 120, on: timeline)
    _ = await owned
    _ = await stray.value
}

try? await Task.sleep(for: .milliseconds(40))
parent.cancel()
await timeline.note("parent.cancel() called")
_ = await parent.result
try? await Task.sleep(for: .milliseconds(160))
await timeline.report("cancellation reaches children, not strangers:")

print("tree.swift done")
