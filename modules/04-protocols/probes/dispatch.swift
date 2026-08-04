// The one protocol fact worth memorizing, made runnable.
//
//     make probe CH=04 P=dispatch
//
// `tint` is declared in the protocol body, so it is a requirement and it
// dispatches through the witness table. `caption` is declared only in the
// extension, so it is resolved from the static type of the expression at the
// call site. `LoudPin` writes its own version of both. Watch what happens to
// each one when the same value is held as `any Marker`.

protocol Marker {
    var tint: String { get }
}

extension Marker {
    var tint: String { "grey" }
    var caption: String { "caption \(tint)" }
}

struct PlainPin: Marker {}

struct LoudPin: Marker {
    var tint: String { "red" }
    var caption: String { "LOUD \(tint)" }
}

let plain = PlainPin()
let loud = LoudPin()
let boxedPlain: any Marker = plain
let boxedLoud: any Marker = loud

print("PlainPin           tint=\(plain.tint)      caption=\(plain.caption)")
print("LoudPin            tint=\(loud.tint)       caption=\(loud.caption)")
print("any Marker plain   tint=\(boxedPlain.tint) caption=\(boxedPlain.caption)")
print("any Marker loud    tint=\(boxedLoud.tint)  caption=\(boxedLoud.caption)")

// A generic function is the third call site worth checking. `Pin` is known
// statically inside the body, but it is only known to be some `Marker`, so
// `caption` still resolves to the extension.

func report<Pin: Marker>(_ pin: Pin) -> String {
    "generic         tint=\(pin.tint)       caption=\(pin.caption)"
}

print(report(loud))

// The fix, when you wanted the type's version to win: move the member into
// the protocol body so it becomes a requirement. Uncommenting the line below
// changes two of the lines above, and predicting which two before you run it
// is the exercise.
//
// protocol Marker { var tint: String { get }; var caption: String { get } }
