// Write your prediction in the comment above each print, then run the file.
// The toolchain is the answer key, and there is no answer key in this
// repository.
//
//     make probe CH=11 P=predict

struct Ration: Sendable {
    var units: Int
}

/// `code` is outside the actor's isolation domain because it can never
/// change. `served` is inside it because it can.
actor Canteen {
    nonisolated let code: String
    private var served = 0

    init(code: String) { self.code = code }

    func serve(_ ration: Ration) -> Int {
        served += ration.units
        return served
    }

    /// Prints on both sides of a suspension, so you can see what the actor
    /// let in while this method was waiting.
    func slowServe(_ ration: Ration, tick: @Sendable () async -> Void) async -> Int {
        let before = served
        await tick()
        served = before + ration.units
        return served
    }
}

// 1. Two lines. Which of them needs an `await`, and what does it print?
let canteen = Canteen(code: "north")
print(canteen.code, await canteen.serve(Ration(units: 3)))

// 2. `sent` crossed into another isolation domain, and `mine` did not.
//    What are the two numbers?
var mine = Ration(units: 1)
let sent = mine
mine.units = 99
let echo = Task { sent.units }
print(mine.units, await echo.value)

// 3. `slowServe` reads before its await and writes after it. The tick
//    closure calls `serve` on the same actor. What is the final total, and
//    what would it be if `served` were read after the await instead?
let total = await canteen.slowServe(Ration(units: 10)) {
    _ = await canteen.serve(Ration(units: 100))
}
print(total, await canteen.serve(Ration(units: 0)))
