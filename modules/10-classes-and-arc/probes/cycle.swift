// Run: make probe CH=10 P=cycle
//
// The most common leak in a real app: an object stores a closure, and the
// closure refers back to the object. Both halves are ordinary code. The bug
// is only visible as a `deinit` that never prints.

final class Downloader {
    var onFinish: ((String) -> Void)?
    func finish(_ payload: String) { onFinish?(payload) }
    deinit { print("  Downloader gone") }
}

final class Screen {
    let downloader = Downloader()
    private(set) var lastPayload = ""
    deinit { print("  Screen gone") }

    // The leak. `self` is captured strongly by the closure, the closure is
    // owned by `downloader`, and `downloader` is owned by `self`.
    func wireLeaking() {
        downloader.onFinish = { payload in
            self.lastPayload = payload
        }
    }

    // The fix. The capture list makes exactly one edge in the loop not own
    // its target, so the loop is no longer a loop.
    func wireClean() {
        downloader.onFinish = { [weak self] payload in
            guard let self else { return }
            self.lastPayload = payload
        }
    }
}

func runLeaking() {
    print("-- leaking --")
    let screen = Screen()
    screen.wireLeaking()
    screen.finishOnce()
}

func runClean() {
    print("-- clean --")
    let screen = Screen()
    screen.wireClean()
    screen.finishOnce()
}

extension Screen {
    func finishOnce() {
        downloader.finish("ok")
        print("  lastPayload = \(lastPayload)")
    }
}

runLeaking()
print("  (scope exited)")
runClean()
print("  (scope exited)")

// Both runs print the same payload. Only one of them prints a deinit.
// The leaked pair is unreachable and still alive, which is a state a
// tracing collector has no name for.
