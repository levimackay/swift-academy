// The arithmetic behind the chapter's claim that a bag of optional fields
// buys you states you never wanted.
//
//   make probe CH=05 P=states
//
// Two models of the same audio player. The first is what the same feature
// looks like in a language with no sum type: four independent fields, and an
// unwritten rule about which combinations are meaningful. The second is the
// enum. Nothing here validates anything. The point is how many shapes each
// model can hold at all.

struct PlayerFields {
    var isPlaying: Bool
    var track: String?
    var bufferedFraction: Double?
    var failureMessage: String?
}

enum Player {
    case stopped
    case buffering(track: String, fraction: Double)
    case playing(track: String)
    case failed(message: String)
}

// Collapse each field to "present or not", which is the only distinction the
// legality rule cares about, and walk every combination of the four.
let flags = [false, true]
var representable = 0
var legal = 0
var nonsense: [String] = []

for playing in flags {
    for hasTrack in flags {
        for hasFraction in flags {
            for hasFailure in flags {
                representable += 1

                // The rules a reviewer would write in a comment, not in a
                // type: playing implies a track, buffering implies both a
                // track and a fraction, a failure stands alone.
                let isStopped = !playing && !hasTrack && !hasFraction && !hasFailure
                let isBuffering = !playing && hasTrack && hasFraction && !hasFailure
                let isPlaying = playing && hasTrack && !hasFraction && !hasFailure
                let isFailed = !playing && !hasTrack && !hasFraction && hasFailure

                if isStopped || isBuffering || isPlaying || isFailed {
                    legal += 1
                } else {
                    nonsense.append(
                        "isPlaying=\(playing) track=\(hasTrack) "
                        + "fraction=\(hasFraction) failure=\(hasFailure)"
                    )
                }
            }
        }
    }
}

print("PlayerFields can hold \(representable) shapes.")
print("\(legal) of them mean something. \(nonsense.count) do not.")
print("")
print("A few of the ones that do not:")
for line in nonsense.prefix(4) {
    print("  " + line)
}

// The enum side of the same count. Every value of type Player is one of
// exactly four cases, and there is no fifth to guard against.
let everyShape: [Player] = [
    .stopped,
    .buffering(track: "Kind of Blue", fraction: 0.25),
    .playing(track: "Kind of Blue"),
    .failed(message: "network unreachable"),
]

print("")
print("Player can hold \(everyShape.count) shapes, and all \(everyShape.count) mean something.")

// Which is why this function needs no defensive branch. It cannot be handed
// a playing track that is also a failure, because that value does not exist.
func headline(_ player: Player) -> String {
    switch player {
    case .stopped:
        return "nothing playing"
    case .buffering(let track, let fraction):
        return "buffering \(track) at \(Int(fraction * 100))%"
    case .playing(let track):
        return "playing \(track)"
    case .failed(let message):
        return "stopped: \(message)"
    }
}

print("")
for shape in everyShape {
    print("  " + headline(shape))
}
