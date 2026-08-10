import XCTest
@testable import UIRouting

/// Basic coverage for the router and the presenters.
@MainActor
final class UIRoutingTests: XCTestCase {

    // MARK: - Router Tests

    func testRouterNavigate() {
        let router = Router<TestRoute>()

        XCTAssertTrue(router.path.isEmpty)

        router.navigate(to: .home)
        XCTAssertEqual(router.path.count, 1)
        XCTAssertEqual(router.path.first, .home)

        router.navigate(to: .detail(id: "123"))
        XCTAssertEqual(router.path.count, 2)
    }

    func testRouterBack() {
        let router = Router<TestRoute>()
        router.navigate(to: .home)
        router.navigate(to: .detail(id: "123"))

        XCTAssertEqual(router.path.count, 2)

        router.back()
        XCTAssertEqual(router.path.count, 1)
        XCTAssertEqual(router.path.first, .home)

        router.back()
        XCTAssertTrue(router.path.isEmpty)

        // Calling back() on an empty stack must not crash.
        router.back()
        XCTAssertTrue(router.path.isEmpty)
    }

    func testRouterPopToRoot() {
        let router = Router<TestRoute>()
        router.navigate(to: .home)
        router.navigate(to: .detail(id: "123"))
        router.navigate(to: .settings)

        XCTAssertEqual(router.path.count, 3)

        router.popToRoot()
        XCTAssertTrue(router.path.isEmpty)
    }

    func testRouterReplace() {
        let router = Router<TestRoute>()
        router.navigate(to: .home)

        router.replace(with: .settings)
        XCTAssertEqual(router.path.count, 1)
        XCTAssertEqual(router.path.first, .settings)

        // On an empty stack, replace behaves like navigate.
        let emptyRouter = Router<TestRoute>()
        emptyRouter.replace(with: .home)
        XCTAssertEqual(emptyRouter.path.count, 1)
        XCTAssertEqual(emptyRouter.path.first, .home)
    }

    // MARK: - SheetPresenter Tests

    func testSheetPresenterPresent() {
        let presenter = SheetPresenter<TestRoute>()

        XCTAssertNil(presenter.presentedSheet)

        presenter.present(.settings)
        XCTAssertNotNil(presenter.presentedSheet)
        XCTAssertEqual(presenter.presentedSheet, .settings)
    }

    func testSheetPresenterDismiss() {
        let presenter = SheetPresenter<TestRoute>()
        presenter.present(.settings)

        XCTAssertNotNil(presenter.presentedSheet)

        presenter.dismiss()
        XCTAssertNil(presenter.presentedSheet)
    }

    // MARK: - AlertPresenter Tests

    func testAlertPresenterPresent() {
        let presenter = AlertPresenter<TestAlert>()

        XCTAssertFalse(presenter.isPresented)
        XCTAssertNil(presenter.presentedAlert)

        presenter.present(.confirmation)
        XCTAssertTrue(presenter.isPresented)
        XCTAssertNotNil(presenter.presentedAlert)
        XCTAssertEqual(presenter.presentedAlert, .confirmation)
    }

    func testAlertPresenterDismiss() {
        let presenter = AlertPresenter<TestAlert>()
        presenter.present(.error(message: "Test"))

        XCTAssertTrue(presenter.isPresented)
        XCTAssertNotNil(presenter.presentedAlert)

        presenter.dismiss()
        XCTAssertFalse(presenter.isPresented)
        XCTAssertNil(presenter.presentedAlert)
    }
}

// MARK: - Test Types

enum TestRoute: Routable, Sheetable {
    case home
    case detail(id: String)
    case settings

    nonisolated var id: String {
        switch self {
        case .home: return "home"
        case .detail(let id): return "detail_\(id)"
        case .settings: return "settings"
        }
    }

    var body: some View {
        EmptyView()
    }
}

enum TestAlert: Alertable {
    case confirmation
    case error(message: String)

    var title: String {
        switch self {
        case .confirmation: return "確認"
        case .error: return "エラー"
        }
    }

    var message: String? {
        switch self {
        case .confirmation: return "実行しますか？"
        case .error(let msg): return msg
        }
    }

    var actions: [AlertAction] {
        switch self {
        case .confirmation:
            return [
                AlertAction(title: "キャンセル", role: .cancel, action: {}),
                AlertAction(title: "OK", action: {})
            ]
        case .error:
            return [AlertAction(title: "OK", action: {})]
        }
    }
}

import SwiftUI
