import XCTest
@testable import UIRouting
import SwiftUI

/// Covers navigation that arrives before the tab it targets has a router.
///
/// A tab registers its router when it first appears. A notification, widget, or Siri launch asks
/// to navigate before that, and the request used to be dropped after a fixed 100 ms wait. These
/// tests pin the replacement: the request waits for the router, and only the latest one waits.
@MainActor
final class TabPresenterTests: XCTestCase {

    func testNavigationBeforeTheRouterExistsRunsWhenItRegisters() {
        let presenter = TabPresenter(initialTab: PendingTab.home)
        let tripsRouter = Router<PendingRoute>()

        presenter.select(.trips) { $0.router.navigate(to: .trip("a")) }

        XCTAssertEqual(presenter.selectedTab, .trips)
        XCTAssertTrue(presenter.isNavigationPending)
        XCTAssertTrue(tripsRouter.path.isEmpty)

        presenter.registerRouter(tripsRouter, for: .trips)

        XCTAssertEqual(tripsRouter.path, [.trip("a")])
        XCTAssertFalse(presenter.isNavigationPending)
    }

    func testNavigationRunsAtOnceWhenTheRouterIsAlreadyRegistered() {
        let presenter = TabPresenter(initialTab: PendingTab.home)
        let tripsRouter = Router<PendingRoute>()
        presenter.registerRouter(tripsRouter, for: .trips)

        presenter.select(.trips) { $0.router.navigate(to: .trip("a")) }

        XCTAssertEqual(tripsRouter.path, [.trip("a")])
        XCTAssertFalse(presenter.isNavigationPending)
    }

    func testAnotherTabRegisteringDoesNotRunTheWaitingNavigation() {
        let presenter = TabPresenter(initialTab: PendingTab.home)
        let homeRouter = Router<PendingRoute>()

        presenter.select(.trips) { $0.router.navigate(to: .trip("a")) }
        presenter.registerRouter(homeRouter, for: .home)

        XCTAssertTrue(homeRouter.path.isEmpty)
        XCTAssertTrue(presenter.isNavigationPending)
    }

    func testOnlyTheLatestWaitingNavigationRuns() {
        let presenter = TabPresenter(initialTab: PendingTab.home)
        let homeRouter = Router<PendingRoute>()
        let tripsRouter = Router<PendingRoute>()

        presenter.select(.home) { $0.router.navigate(to: .trip("stale")) }
        presenter.select(.trips) { $0.router.navigate(to: .trip("latest")) }
        presenter.registerRouter(homeRouter, for: .home)
        presenter.registerRouter(tripsRouter, for: .trips)

        XCTAssertTrue(homeRouter.path.isEmpty)
        XCTAssertEqual(tripsRouter.path, [.trip("latest")])
    }

    func testAPlainSelectionDropsTheWaitingNavigation() {
        let presenter = TabPresenter(initialTab: PendingTab.home)
        let tripsRouter = Router<PendingRoute>()

        presenter.select(.trips) { $0.router.navigate(to: .trip("a")) }
        presenter.select(.home)
        presenter.registerRouter(tripsRouter, for: .trips)

        XCTAssertTrue(tripsRouter.path.isEmpty)
        XCTAssertFalse(presenter.isNavigationPending)
    }

    func testOpeningADestinationReplacesThatTabsStack() {
        let presenter = TabPresenter(initialTab: PendingTab.home)
        let tripsRouter = Router<PendingRoute>()
        tripsRouter.navigate(to: .trip("left-open"))
        presenter.registerRouter(tripsRouter, for: .trips)

        presenter.open(TabDestination(tab: .trips, path: [.trip("a"), .booking("b")]))

        XCTAssertEqual(presenter.selectedTab, .trips)
        XCTAssertEqual(tripsRouter.path, [.trip("a"), .booking("b")])
    }

    func testOpeningAURLGoesThroughTheAppsResolver() throws {
        let presenter = TabPresenter(initialTab: PendingTab.home)
        let tripsRouter = Router<PendingRoute>()

        let opened = presenter.open(try XCTUnwrap(URL(string: "app://trips/a")), resolve: PendingLink.destination(for:))
        presenter.registerRouter(tripsRouter, for: .trips)

        XCTAssertTrue(opened)
        XCTAssertEqual(presenter.selectedTab, .trips)
        XCTAssertEqual(tripsRouter.path, [.trip("a")])
    }

    func testAURLTheAppDoesNotRouteChangesNothing() throws {
        let presenter = TabPresenter(initialTab: PendingTab.home)

        let opened = presenter.open(try XCTUnwrap(URL(string: "app://unknown")), resolve: PendingLink.destination(for:))

        XCTAssertFalse(opened)
        XCTAssertEqual(presenter.selectedTab, .home)
        XCTAssertFalse(presenter.isNavigationPending)
    }

    func testTheTabLookupIsNilOutsideTabRouting() {
        let environment = EnvironmentValues()

        XCTAssertNil(environment[tabPresenter: TabPresenterSpecifier<PendingTab>()])
    }
}

// MARK: - Test types

@MainActor
enum PendingTab: Tabbable {
    case home
    case trips

    typealias Route = PendingRoute

    var contentView: some View { EmptyView() }
    var tabLabel: some View { EmptyView() }
}

@MainActor
enum PendingRoute: Routable {
    case trip(String)
    case booking(String)

    var body: some View { EmptyView() }
}

enum PendingLink {
    static func destination(for url: URL) -> TabDestination<PendingTab>? {
        guard url.host() == "trips" else { return nil }
        return TabDestination(tab: .trips, path: [.trip(url.lastPathComponent)])
    }
}
