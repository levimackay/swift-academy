// The load bearing suite for project 05.
//
// This is not an assertion about behavior, it is an assertion about memory: a
// subscriber created inside a scope must have its `deinit` run when that scope
// ends, while the bus is still alive and still holding a registration for it.
// Every implementation that stores its subscribers strongly fails it, and no
// amount of correct delivery makes up for that.
//
// The subscriber classes below are test fixtures with `deinit` bodies, because
// a test cannot observe ARC any other way. They are not part of your answer,
// and they pin the shape of your public API: whatever they call, you provide
// with that spelling. The spec's "Pinned API" section names it.
//
// `withExtendedLifetime` appears wherever a subscriber has to outlive its last
// mention. ARC may release a local immediately after its final use, so without
// it these tests would be measuring when the optimizer felt like releasing
// rather than what the bus does.
//
// This file will not compile until `Bus` exists. That is the intended state
// of an unstarted project: this package is standalone, so failing to build
// here cannot red a single chapter.
//
// The type is `Bus`, not `EventBus`, and that is the Swift API Design
// Guidelines answer rather than an oversight: the module is already called
// EventBus, so `EventBus.EventBus` stutters at every use site. It is also
// practical. A type sharing its module's name makes `EventBus()` ambiguous
// before the type exists, and the compiler reports `cannot call value of
// non-function type 'module<EventBus>'`, which explains nothing to anyone.

import Testing

@testable import EventBus

// MARK: Fixtures

/// A value type, as requirement 1 demands of every event.
private struct Ping: Equatable {
    let id: Int
}

private struct Pong: Equatable {
    let note: String
}

/// A shared, non owning sink. Handlers write here rather than into the
/// subscriber, so that nothing in this file accidentally holds a subscriber
/// alive and turns a real implementation failure into a test bug.
private final class Log {
    private(set) var pings: [Int] = []
    private(set) var pongs: [String] = []
    private(set) var deallocations: [String] = []

    func record(_ ping: Ping) { pings.append(ping.id) }
    func record(_ pong: Pong) { pongs.append(pong.note) }
    func recordDeallocation(of name: String) { deallocations.append(name) }
}

/// The subscriber. It exists only so that its `deinit` is observable.
private final class Listener {
    let name: String
    private let log: Log

    init(name: String, log: Log) {
        self.name = name
        self.log = log
    }

    deinit { log.recordDeallocation(of: name) }
}

// MARK: The suite

@Suite("P05 subscriber deallocation")
struct DeallocationTests {

    // Delivery has to work before the memory question is interesting. Two
    // assertions with distinct expected values, so a `publish` that does
    // nothing and a `publish` that delivers twice both fail.
    @Test("a live subscriber receives every event published after it subscribed")
    func deliveryWorks() {
        let log = Log()
        let bus = Bus()
        let listener = Listener(name: "a", log: log)

        withExtendedLifetime(listener) {
            _ = bus.subscribe(to: Ping.self, owner: listener) { log.record($0) }
            bus.publish(Ping(id: 1))
            bus.publish(Ping(id: 2))

            #expect(log.pings == [1, 2])
            #expect(log.deallocations.isEmpty)
        }
    }

    // The whole project, in one assertion. The bus is alive, the registration
    // was never removed, and the subscriber must still be gone.
    @Test("a subscriber deallocates at end of scope while the bus still holds it")
    func subscriberDeallocatesWhileRegistered() {
        let log = Log()
        let bus = Bus()

        do {
            let listener = Listener(name: "scoped", log: log)
            withExtendedLifetime(listener) {
                _ = bus.subscribe(to: Ping.self, owner: listener) { log.record($0) }
                bus.publish(Ping(id: 7))
                #expect(log.deallocations.isEmpty)
            }
        }

        #expect(log.deallocations == ["scoped"])
        #expect(log.pings == [7])
    }

    // Requirement 6. After the subscriber is gone, publishing must be a no op
    // for that registration rather than a call into a dead handler.
    @Test("a dead subscriber's handler is not called and publishing does not trap")
    func deadSubscribersAreNotCalled() {
        let log = Log()
        let bus = Bus()

        do {
            let listener = Listener(name: "gone", log: log)
            withExtendedLifetime(listener) {
                _ = bus.subscribe(to: Ping.self, owner: listener) { log.record($0) }
            }
        }

        bus.publish(Ping(id: 99))

        #expect(log.pings.isEmpty)
        #expect(log.deallocations == ["gone"])
    }

    // Requirement 7. Whether reclamation is eager or happens on the next
    // publish is your decision, so this asserts the count after a publish,
    // which is true either way.
    @Test("registrations for a dead subscriber are reclaimed")
    func deadRegistrationsAreReclaimed() {
        let log = Log()
        let bus = Bus()
        let survivor = Listener(name: "survivor", log: log)

        withExtendedLifetime(survivor) {
            _ = bus.subscribe(to: Ping.self, owner: survivor) { log.record($0) }

            do {
                let temporary = Listener(name: "temporary", log: log)
                withExtendedLifetime(temporary) {
                    _ = bus.subscribe(to: Ping.self, owner: temporary) { log.record($0) }
                    #expect(bus.subscriberCount(for: Ping.self) == 2)
                }
            }

            bus.publish(Ping(id: 5))

            #expect(bus.subscriberCount(for: Ping.self) == 1)
            #expect(log.pings == [5])
        }
    }

    // Requirement 1. A registry keyed by nothing passes every other test in
    // this file and fails this one.
    @Test("an event is delivered only to subscribers of its own type")
    func eventTypesDoNotCross() {
        let log = Log()
        let bus = Bus()
        let listener = Listener(name: "typed", log: log)

        withExtendedLifetime(listener) {
            _ = bus.subscribe(to: Ping.self, owner: listener) { log.record($0) }
            _ = bus.subscribe(to: Pong.self, owner: listener) { log.record($0) }

            bus.publish(Ping(id: 3))
            bus.publish(Pong(note: "hello"))

            #expect(log.pings == [3])
            #expect(log.pongs == ["hello"])
        }
    }

    // Requirement 8. One owner, two registrations, one token cancelled. An
    // implementation keying registrations by owner identity alone removes
    // both and fails here.
    @Test("unsubscribing one token leaves the same owner's other registration")
    func unsubscribeRemovesExactlyOne() {
        let log = Log()
        let bus = Bus()
        let listener = Listener(name: "double", log: log)

        withExtendedLifetime(listener) {
            let first = bus.subscribe(to: Ping.self, owner: listener) { log.record($0) }
            _ = bus.subscribe(to: Ping.self, owner: listener) { log.record($0) }

            #expect(bus.subscriberCount(for: Ping.self) == 2)

            bus.unsubscribe(first)
            bus.publish(Ping(id: 4))

            #expect(bus.subscriberCount(for: Ping.self) == 1)
            #expect(log.pings == [4])
        }
    }

    // Requirement 9. Cancelling twice is the caller's ordinary mistake and it
    // is not an error they have to handle.
    @Test("unsubscribing the same token twice is safe")
    func doubleUnsubscribeIsSafe() {
        let log = Log()
        let bus = Bus()
        let listener = Listener(name: "twice", log: log)

        withExtendedLifetime(listener) {
            let token = bus.subscribe(to: Ping.self, owner: listener) { log.record($0) }

            bus.unsubscribe(token)
            bus.unsubscribe(token)
            bus.publish(Ping(id: 1))

            #expect(bus.subscriberCount(for: Ping.self) == 0)
            #expect(log.pings.isEmpty)
        }
    }

    // Requirement 10. Delivery order for one event type is registration
    // order, which is a choice, and pinning it is what makes it a choice
    // rather than an accident.
    @Test("handlers run in registration order")
    func deliveryOrderIsRegistrationOrder() {
        let log = Log()
        let bus = Bus()
        let first = Listener(name: "first", log: log)
        let second = Listener(name: "second", log: log)

        withExtendedLifetime((first, second)) {
            _ = bus.subscribe(to: Ping.self, owner: first) {
                log.record(Ping(id: $0.id * 10))
            }
            _ = bus.subscribe(to: Ping.self, owner: second) {
                log.record(Ping(id: $0.id * 100))
            }

            bus.publish(Ping(id: 1))

            #expect(log.pings == [10, 100])
        }
    }

    // Requirement 13. A token may outlive the bus. If the token holds the bus
    // strongly, the bus outlives this scope too, and a bus that holds its
    // owners strongly then keeps the subscriber alive, which is what this
    // asserts against. Nothing here pins what `unsubscribe` on an orphaned
    // token means, because the spec leaves that to you.
    @Test("a token outliving the bus keeps neither the bus nor the subscriber alive")
    func staleTokenHoldsNothing() {
        let log = Log()
        var token: SubscriptionToken?

        do {
            let bus = Bus()
            let listener = Listener(name: "orphan", log: log)
            withExtendedLifetime(listener) {
                token = bus.subscribe(to: Ping.self, owner: listener) { log.record($0) }
                bus.publish(Ping(id: 2))
            }
        }

        #expect(log.pings == [2])
        #expect(log.deallocations == ["orphan"])
        #expect(token != nil)
    }
}
