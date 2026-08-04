// The force unwraps in this file are the lesson. Nothing else in this
// repository uses one, and neither should your exercises.
//
//   make probe CH=01 P=forceunwrap
//
// It prints two lines and then terminates the process on SIGTRAP. Check
// with `echo $?` afterwards: nonzero either way, 5 through the interpreter
// and 133 from a compiled binary. This is not an exception. There is
// nothing to catch, and no `finally` runs.
//
// The interpreter also prints a long stack dump of its own frames. The only
// line that concerns you is the first one. Pipe the run anywhere, into
// `head` for instance, and the two prints vanish: stdout is block buffered
// when it is not a terminal, and the trap discards the buffer.

let port: Int? = Int("8080")
print("a force unwrap that holds:", port!)

// Implicitly unwrapped optional. `handle` has type Optional<String>, and
// the ! moves from the declaration to every single use of it.
var handle: String! = "open"
print("an implicit one that holds:", handle.count)

handle = nil

// One of these two lines ends the program. Comment out the first to watch
// the second do exactly the same thing with different wording.
print(handle.count)

let missing: Int? = Int("eighty eighty")
print(missing!)
