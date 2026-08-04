// The crash is the lesson in this file, so it contains the only force unwrap
// in the chapter. Both cases below terminate the process on purpose.
//
// Run one at a time. `make probe` takes the argument through ARGS, and it is
// the only invocation this chapter documents, because a loose .swift file run
// as a script defaults to Swift 5 mode:
//
//     make probe CH=10 P=dangling ARGS=unowned
//     make probe CH=10 P=dangling ARGS=weak
//
// The first line of output is yours. The stack dump under it belongs to the
// interpreter, not to your program, so read the top and ignore the rest.

final class Owner {
    let name: String
    init(name: String) { self.name = name }
    deinit { print("Owner \(name) gone") }
}

final class Child {
    unowned let owner: Owner
    init(owner: Owner) { self.owner = owner }
}

func makeOrphan() -> Child {
    let owner = Owner(name: "temporary")
    return Child(owner: owner)   // the owner dies at this brace
}

func makeWeakBox() -> () -> String {
    let owner = Owner(name: "temporary")
    weak var held: Owner? = owner
    return { held!.name }        // the force unwrap is the lesson
}

let mode = CommandLine.arguments.dropFirst().first ?? ""

switch mode {
case "unowned":
    let orphan = makeOrphan()
    print("about to read an unowned reference to a dead object")
    print(orphan.owner.name)
case "weak":
    let read = makeWeakBox()
    print("about to force unwrap a weak reference to a dead object")
    print(read())
default:
    print("pass 'unowned' or 'weak' as the argument")
}

// Two different failures, and the difference is the whole choice between the
// two keywords. `unowned` has no nil state to check, so the runtime reports
// that you read a destroyed object. `weak` became nil correctly, and the
// force unwrap is what threw the information away.
