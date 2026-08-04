import Foundation
import Testing

@testable import Chapter14

@MainActor
@Suite("14 Router as owned state")
struct AppRouterTests {
    private let ada = UUID()

    @Test("pushing two screens leaves both of them on the stack")
    func pushingTwoScreensLeavesBoth() {
        let router = AppRouter()
        router.go(to: .tag(name: "field"))
        router.go(to: .entry(id: ada))
        #expect(router.path == [.tag(name: "field"), .entry(id: ada)])
        #expect(router.depth == 2)
    }

    @Test("the same screen visited twice is two screens deep")
    func theSameScreenTwiceIsTwoDeep() {
        let router = AppRouter()
        router.go(to: .inbox)
        router.go(to: .tag(name: "field"))
        router.go(to: .inbox)
        #expect(router.depth == 3)
        #expect(router.path.last == .inbox)
    }

    @Test("going back at the root is a no op rather than a crash")
    func goingBackAtTheRootDoesNothing() {
        let router = AppRouter()
        router.back()
        router.back()
        #expect(router.depth == 0)
        #expect(router.path.isEmpty)

        router.go(to: .inbox)
        router.back()
        router.back()
        #expect(router.depth == 0)
    }

    @Test("unwinding to the root also takes down the sheet that was over it")
    func unwindingTakesDownThePresentedModal() {
        let router = AppRouter()
        router.go(to: .inbox)
        router.go(to: .entry(id: ada))
        router.present(.composer)
        #expect(router.depth == 2)
        #expect(router.presented == .composer)
        router.backToRoot()
        #expect(router.path.isEmpty)
        #expect(router.presented == nil)
    }

    @Test("presenting a second modal replaces the first")
    func presentingASecondModalReplacesTheFirst() {
        let router = AppRouter()
        router.present(.onboarding)
        #expect(router.presented == .onboarding)
        router.present(.composer)
        #expect(router.presented == .composer)
        router.dismiss()
        #expect(router.presented == nil)
        router.dismiss()
        #expect(router.presented == nil)
    }

    @Test("a deep link replaces the stack instead of stacking on top of it")
    func aDeepLinkReplacesTheStack() {
        let router = AppRouter()
        router.go(to: .inbox)
        router.go(to: .inbox)
        router.present(.onboarding)
        router.follow([.tag(name: "field"), .entry(id: ada)])
        #expect(router.path == [.tag(name: "field"), .entry(id: ada)])
        #expect(router.presented == nil)
    }

    @Test("a deep link to nowhere is a way home")
    func aDeepLinkToNowhereGoesHome() {
        let router = AppRouter()
        router.go(to: .tag(name: "field"))
        router.follow([])
        #expect(router.depth == 0)
        #expect(router.path.isEmpty)
    }
}
