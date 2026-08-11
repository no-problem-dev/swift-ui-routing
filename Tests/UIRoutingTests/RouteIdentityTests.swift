import XCTest
@testable import UIRouting
import SwiftUI

/// Covers the identity the presentation protocols derive for types that write no `id`, `==`, or
/// `hash(into:)` of their own — the arrangement every doc comment in the package recommends.
///
/// The assertions are the ones SwiftUI itself makes: a navigation stack tells two pushes apart by
/// `Hashable`, and `sheet(item:)` decides whether to re-present by `id`. Two destinations that a
/// caller wrote as different cases have to come out different under both.
@MainActor
final class RouteIdentityTests: XCTestCase {

    // MARK: - Cases with no associated value

    func testNavigatingToTwoDifferentCaselessRoutesPushesTwoDistinctDestinations() {
        let router = Router<PlainRoute>()

        router.navigate(to: .home)
        router.navigate(to: .settings)

        XCTAssertEqual(router.path.count, 2)
        XCTAssertNotEqual(router.path[0], router.path[1])
        XCTAssertEqual(Set(router.path).count, 2)
    }

    func testCaselessRoutesDoNotCollideInAHashedCollection() {
        let visited: Set<PlainRoute> = [.home, .settings, .profile]

        XCTAssertEqual(visited.count, 3)
        XCTAssertTrue(visited.contains(.settings))
    }

    func testPresentingADifferentCaselessSheetChangesTheIdentitySwiftUIPresentsOn() {
        let presenter = SheetPresenter<PlainSheet>()

        presenter.present(.filter)
        let first = presenter.presentedSheet?.id

        presenter.present(.about)
        let second = presenter.presentedSheet?.id

        // `sheet(item:)` re-presents only when the identifier changes; equal ids leave the first
        // sheet on screen after the caller asked for the second.
        XCTAssertNotEqual(first, second)
        XCTAssertNotEqual(presenter.presentedSheet, .filter)
    }

    func testCaselessCoversAndAlertsAndCustomHeightSheetsAreAlsoDistinct() {
        XCTAssertNotEqual(PlainCover.camera, PlainCover.scanner)
        XCTAssertNotEqual(PlainCover.camera.id, PlainCover.scanner.id)

        XCTAssertNotEqual(PlainAlert.signOut, PlainAlert.deleteAccount)
        XCTAssertNotEqual(PlainAlert.signOut.id, PlainAlert.deleteAccount.id)

        XCTAssertNotEqual(PlainCustomHeightSheet.quickAdd, PlainCustomHeightSheet.share)
        XCTAssertNotEqual(PlainCustomHeightSheet.quickAdd.id, PlainCustomHeightSheet.share.id)
    }

    // MARK: - A single associated value carried without a label

    func testNavigatingToTheSameCaseWithDifferentUnlabelledPayloadsPushesTwoDestinations() {
        let router = Router<PayloadRoute>()

        router.navigate(to: .profile("alice"))
        router.navigate(to: .profile("bob"))

        XCTAssertEqual(router.path.count, 2)
        XCTAssertNotEqual(router.path[0], router.path[1])
        XCTAssertEqual(Set(router.path).count, 2)
    }

    func testPresentingTheSameSheetCaseWithADifferentUnlabelledPayloadChangesIdentity() {
        let presenter = SheetPresenter<PayloadSheet>()

        presenter.present(.editor("draft-1"))
        let first = presenter.presentedSheet?.id

        presenter.present(.editor("draft-2"))

        XCTAssertNotEqual(first, presenter.presentedSheet?.id)
    }

    // MARK: - Behaviour that must survive the fix

    func testSameCaseWithTheSamePayloadStaysEqual() {
        XCTAssertEqual(PayloadRoute.profile("alice"), PayloadRoute.profile("alice"))
        XCTAssertEqual(PayloadRoute.profile("alice").hashValue, PayloadRoute.profile("alice").hashValue)
        XCTAssertEqual(PlainRoute.home, PlainRoute.home)
        XCTAssertEqual(PlainRoute.home.hashValue, PlainRoute.home.hashValue)
    }

    func testDifferentCasesStayUnequal() {
        XCTAssertNotEqual(PayloadRoute.profile("alice"), PayloadRoute.article(id: "alice"))
        XCTAssertNotEqual(PlainRoute.home, PlainRoute.settings)
    }

    func testClosurePayloadsStillTakeNoPartInIdentity() {
        XCTAssertEqual(
            PayloadSheet.picker(onSelect: { _ in }),
            PayloadSheet.picker(onSelect: { _ in })
        )
        XCTAssertEqual(
            PayloadRoute.editor(id: "1", onSave: {}),
            PayloadRoute.editor(id: "1", onSave: {})
        )
        XCTAssertNotEqual(
            PayloadRoute.editor(id: "1", onSave: {}),
            PayloadRoute.editor(id: "2", onSave: {})
        )
    }
}

// MARK: - Test types
//
// None of these writes `id`, `==`, or `hash(into:)`, which is what the package documents.

@MainActor
enum PlainRoute: Routable {
    case home
    case settings
    case profile

    var body: some View { EmptyView() }
}

@MainActor
enum PlainSheet: Sheetable {
    case filter
    case about

    var body: some View { EmptyView() }
}

@MainActor
enum PlainCover: FullScreenCoverable {
    case camera
    case scanner

    var body: some View { EmptyView() }
}

@MainActor
enum PlainCustomHeightSheet: CustomHeightSheetable {
    case quickAdd
    case share

    var detents: Set<PresentationDetent> { [.medium] }
    var body: some View { EmptyView() }
}

@MainActor
enum PlainAlert: Alertable {
    case signOut
    case deleteAccount

    var title: String { "" }
    var message: String? { nil }
    var actions: [AlertAction] { [] }
}

@MainActor
enum PayloadRoute: Routable {
    case profile(String)
    case article(id: String)
    case editor(id: String, onSave: () -> Void)

    var body: some View { EmptyView() }
}

@MainActor
enum PayloadSheet: Sheetable {
    case editor(String)
    case picker(onSelect: (String) -> Void)

    var body: some View { EmptyView() }
}
