import Foundation
import Testing

@testable import Chapter14

@Suite("14 Route path restoration")
struct RoutePathTests {
    private let ada = UUID()
    private let grace = UUID()

    @Test("a saved path comes back with the same screens in the same order")
    func aSavedPathComesBackInOrder() throws {
        let path: [AppRoute] = [.inbox, .tag(name: "field"), .entry(id: ada)]
        let restored = RoutePath.decode(try RoutePath.encode(path))
        #expect(restored == path)
        #expect(restored.count == 3)
    }

    @Test("a repeated screen survives as two entries, not one")
    func aRepeatedScreenSurvivesTwice() throws {
        let path: [AppRoute] = [.inbox, .tag(name: "field"), .inbox]
        let restored = RoutePath.decode(try RoutePath.encode(path))
        #expect(restored == path)
        #expect(restored.count == 3)
    }

    @Test("two different payloads under the same case stay different")
    func payloadsStayDistinct() throws {
        let path: [AppRoute] = [.entry(id: ada), .entry(id: grace)]
        let restored = RoutePath.decode(try RoutePath.encode(path))
        #expect(restored == path)
        #expect(restored.first != restored.last)
    }

    @Test("an empty stack round trips as an empty stack")
    func anEmptyStackRoundTrips() throws {
        #expect(RoutePath.decode(try RoutePath.encode([])).isEmpty)
    }

    @Test("equal paths encode to equal bytes")
    func equalPathsEncodeToEqualBytes() throws {
        let once = try RoutePath.encode([.tag(name: "field"), .entry(id: grace)])
        let twice = try RoutePath.encode([.tag(name: "field"), .entry(id: grace)])
        let other = try RoutePath.encode([.tag(name: "field")])
        #expect(once == twice)
        #expect(once != other)
    }

    @Test("bytes from somewhere else land the user at the root instead of failing")
    func foreignBytesLandAtTheRoot() {
        let notJSON = Data([0xFF, 0x00, 0x11, 0xEE])
        let wrongShape = Data(#"{"screen":"inbox"}"#.utf8)
        let truncated = Data(#"[{"inbox":{}"#.utf8)
        #expect(RoutePath.decode(notJSON).isEmpty)
        #expect(RoutePath.decode(wrongShape).isEmpty)
        #expect(RoutePath.decode(truncated).isEmpty)
        #expect(RoutePath.decode(Data()).isEmpty)
    }
}
