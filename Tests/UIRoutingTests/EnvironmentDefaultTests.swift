import XCTest
@testable import UIRouting
import SwiftUI

/// Covers what a view gets from `@Environment(.router(_:))` and friends when nothing above it
/// injected one.
///
/// The lookups fall back to an `EnvironmentKey` default, and a view reads that default afresh on
/// every update. If the default hands back a new object each time, the router a button mutates is
/// not the router the navigation stack is bound to: the caller sees no navigation, no crash, and
/// nothing in the log. These tests pin the fallback to one object per lookup so that a missing
/// injection degrades to a working — if shared — presenter instead of a silent no-op.
@MainActor
final class EnvironmentDefaultTests: XCTestCase {

    func testRouterFallbackKeepsWhatWasPushedOntoIt() {
        var environment = EnvironmentValues()

        let pushedFrom = environment[router: RouterSpecifier<FallbackRoute>()]
        pushedFrom.navigate(to: .detail)

        let readBackByTheStack = environment[router: RouterSpecifier<FallbackRoute>()]

        XCTAssertEqual(readBackByTheStack.path, [.detail])
        XCTAssertTrue(readBackByTheStack === pushedFrom)
    }

    func testSheetPresenterFallbackKeepsWhatWasPresentedOnIt() {
        var environment = EnvironmentValues()

        let presentedFrom = environment[sheetPresenter: SheetPresenterSpecifier<FallbackSheet>()]
        presentedFrom.present(.filter)

        let readBackByTheModifier = environment[sheetPresenter: SheetPresenterSpecifier<FallbackSheet>()]

        XCTAssertEqual(readBackByTheModifier.presentedSheet, .filter)
    }

    func testAlertPresenterFallbackKeepsWhatWasRaisedOnIt() {
        var environment = EnvironmentValues()

        let raisedFrom = environment[alertPresenter: AlertPresenterSpecifier<FallbackAlert>(context: .navigation)]
        raisedFrom.present(.signOut)

        let readBackByTheModifier = environment[alertPresenter: AlertPresenterSpecifier<FallbackAlert>(context: .navigation)]

        XCTAssertTrue(readBackByTheModifier.isPresented)
        XCTAssertEqual(readBackByTheModifier.presentedAlert, .signOut)
    }

    func testFullScreenCoverAndCustomHeightSheetAndSplitViewFallbacksAreAlsoStable() {
        var environment = EnvironmentValues()

        let cover = environment[fullScreenCoverPresenter: FullScreenCoverPresenterSpecifier<FallbackCover>()]
        XCTAssertTrue(environment[fullScreenCoverPresenter: FullScreenCoverPresenterSpecifier<FallbackCover>()] === cover)

        let custom = environment[customHeightSheetPresenter: CustomHeightSheetPresenterSpecifier<FallbackCustomSheet>()]
        XCTAssertTrue(environment[customHeightSheetPresenter: CustomHeightSheetPresenterSpecifier<FallbackCustomSheet>()] === custom)

        let split = environment[splitViewPresenter: SplitViewPresenterSpecifier<FallbackSidebar>()]
        XCTAssertTrue(environment[splitViewPresenter: SplitViewPresenterSpecifier<FallbackSidebar>()] === split)
    }

    func testTheNavigationAndSheetLayersDoNotShareOneFallback() {
        var environment = EnvironmentValues()

        let onNavigation = environment[alertPresenter: AlertPresenterSpecifier<FallbackAlert>(context: .navigation)]
        let onSheet = environment[alertPresenter: AlertPresenterSpecifier<FallbackAlert>(context: .sheet)]

        XCTAssertFalse(onNavigation === onSheet)
    }

    func testTwoRouteTypesDoNotShareOneFallback() {
        var environment = EnvironmentValues()

        let forRoutes = environment[router: RouterSpecifier<FallbackRoute>()]
        let forOtherRoutes = environment[router: RouterSpecifier<OtherFallbackRoute>()]

        forRoutes.navigate(to: .detail)

        XCTAssertTrue(environment[router: RouterSpecifier<OtherFallbackRoute>()].path.isEmpty)
        XCTAssertTrue(environment[router: RouterSpecifier<OtherFallbackRoute>()] === forOtherRoutes)
    }

    func testAnInjectedPresenterStillWinsOverTheFallback() {
        var environment = EnvironmentValues()

        _ = environment[router: RouterSpecifier<FallbackRoute>()]
        let injected = Router<FallbackRoute>()
        environment[router: RouterSpecifier<FallbackRoute>()] = injected

        XCTAssertTrue(environment[router: RouterSpecifier<FallbackRoute>()] === injected)
    }
}

// MARK: - Test types

@MainActor
enum FallbackRoute: Routable {
    case detail
    var body: some View { EmptyView() }
}

@MainActor
enum OtherFallbackRoute: Routable {
    case elsewhere
    var body: some View { EmptyView() }
}

@MainActor
enum FallbackSheet: Sheetable {
    case filter
    var body: some View { EmptyView() }
}

@MainActor
enum FallbackCover: FullScreenCoverable {
    case camera
    var body: some View { EmptyView() }
}

@MainActor
enum FallbackCustomSheet: CustomHeightSheetable {
    case quickAdd
    var detents: Set<PresentationDetent> { [.medium] }
    var body: some View { EmptyView() }
}

@MainActor
enum FallbackAlert: Alertable {
    case signOut
    var title: String { "" }
    var message: String? { nil }
    var actions: [AlertAction] { [] }
}

@MainActor
enum FallbackSidebar: SidebarItem {
    case inbox
    var label: some View { EmptyView() }
    var detail: some View { EmptyView() }
}
