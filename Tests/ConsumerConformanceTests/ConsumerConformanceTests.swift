import SwiftUI
import UIRouting
import XCTest

/// Guards the isolation contract of every routing protocol.
///
/// Each protocol is `@MainActor`, but `Identifiable`, `Equatable` and `Hashable` are not. A
/// default implementation of `id`, `==` or `hash(into:)` that is left main-actor isolated cannot
/// satisfy those nonisolated requirements, and a conforming type in a downstream module fails to
/// compile with "conformance crosses into main actor-isolated code".
///
/// The conformances below are the regression check: they are ordinary types with no `@MainActor`
/// annotation, declared outside the `UIRouting` module, in a target pinned to the Swift 6 language
/// mode. If a default implementation loses its `nonisolated` marker, this target stops compiling.
///
/// The test methods are the second half of the check. `XCTestCase` methods are nonisolated, so
/// reading `id` and calling `==` and `hash(into:)` from them can only type-check while those
/// members really are callable off the main actor.
final class ConsumerConformanceTests: XCTestCase {

    // MARK: Identifiers derived from the value's hash

    func testHashDerivedIdentifiersAreReachableOffTheMainActor() {
        XCTAssertEqual(ConsumerTab.home.id, ConsumerTab.home.id)
        XCTAssertNotEqual(ConsumerTab.home.id, ConsumerTab.settings.id)

        XCTAssertEqual(ConsumerSidebar.inbox.id, ConsumerSidebar.inbox.id)
        XCTAssertNotEqual(ConsumerSidebar.inbox.id, ConsumerSidebar.archive.id)

        XCTAssertEqual(ConsumerRoute.settings.id, ConsumerRoute.settings.id)
        XCTAssertNotEqual(ConsumerRoute.settings.id, ConsumerRoute.profile(userID: "a").id)

        XCTAssertNotEqual(ConsumerSelectable(name: "a").id, ConsumerSelectable(name: "b").id)
    }

    // MARK: Equality and hashing driven by a string identifier

    func testStringIdentifiedValuesCompareAndHashOffTheMainActor() {
        let first = StringIdentifiedTab(id: "home")
        let sameIdentifier = StringIdentifiedTab(id: "home")
        let other = StringIdentifiedTab(id: "settings")

        XCTAssertEqual(first, sameIdentifier)
        XCTAssertNotEqual(first, other)
        XCTAssertEqual(first.hashValue, sameIdentifier.hashValue)

        XCTAssertEqual(StringIdentifiedSheet(id: "x"), StringIdentifiedSheet(id: "x"))
        XCTAssertNotEqual(StringIdentifiedSidebar(id: "x"), StringIdentifiedSidebar(id: "y"))
        XCTAssertEqual(StringIdentifiedSelectable(id: "x"), StringIdentifiedSelectable(id: "x"))
        XCTAssertEqual(StringIdentifiedAlert(id: "x"), StringIdentifiedAlert(id: "x"))
        XCTAssertNotEqual(StringIdentifiedFullScreen(id: "x"), StringIdentifiedFullScreen(id: "y"))
        XCTAssertEqual(StringIdentifiedCustomSheet(id: "x"), StringIdentifiedCustomSheet(id: "x"))
    }

    // MARK: Equality and hashing driven by a string raw value

    func testRawRepresentableAlertsCompareOffTheMainActor() {
        XCTAssertEqual(RawValueAlert.networkFailure, RawValueAlert.networkFailure)
        XCTAssertNotEqual(RawValueAlert.networkFailure, RawValueAlert.signedOut)
        XCTAssertEqual(
            RawValueAlert.networkFailure.hashValue,
            RawValueAlert.networkFailure.hashValue
        )
    }

    // MARK: Conformances usable as generic constraints without isolation

    func testConformancesSatisfyNonisolatedGenericConstraints() {
        XCTAssertEqual(Set([ConsumerTab.home, ConsumerTab.home, ConsumerTab.settings]).count, 2)
        XCTAssertEqual(Set([ConsumerSidebar.inbox, ConsumerSidebar.archive]).count, 2)
        XCTAssertEqual(
            Set([StringIdentifiedSelectable(id: "x"), StringIdentifiedSelectable(id: "x")]).count,
            1
        )
    }
}

// MARK: - Conformers whose identifier is derived from the value's hash

enum ConsumerRoute: Routable {
    case profile(userID: String)
    case settings

    var body: some View { EmptyView() }
}

enum ConsumerSheet: Sheetable {
    case compose
    case filter(category: String)

    var body: some View { EmptyView() }
}

enum ConsumerFullScreenCover: FullScreenCoverable {
    case camera
    case editor(itemID: String)

    var body: some View { EmptyView() }
}

enum ConsumerCustomHeightSheet: CustomHeightSheetable {
    case quickAdd
    case picker(title: String)

    var detents: Set<PresentationDetent> { [.medium] }
    var body: some View { EmptyView() }
}

enum ConsumerAlert: Alertable {
    case delete(itemName: String)
    case error(message: String)

    var title: String { "Title" }
    var message: String? { nil }
    var actions: [AlertAction] { [] }
}

enum ConsumerTab: Tabbable {
    case home
    case settings

    typealias Route = ConsumerRoute
    typealias Sheet = ConsumerSheet
    typealias Alert = ConsumerAlert
    typealias FullScreen = ConsumerFullScreenCover
    typealias CustomSheet = ConsumerCustomHeightSheet

    var contentView: some View { EmptyView() }
    var tabLabel: some View { Label("Home", systemImage: "house") }
}

enum ConsumerSidebar: SidebarItem {
    case inbox
    case archive

    typealias DetailRoute = ConsumerRoute
    typealias ContentItem = ConsumerSelectable
    typealias ContentRoute = ConsumerRoute

    var label: some View { Label("Inbox", systemImage: "tray") }
    var detail: some View { EmptyView() }
    var contentView: some View { EmptyView() }
}

struct ConsumerSelectable: Selectable {
    var name: String

    var label: some View { Text(name) }
}

// MARK: - Conformers identified by a string

struct StringIdentifiedRoute: Routable {
    let id: String

    var body: some View { EmptyView() }
}

struct StringIdentifiedSheet: Sheetable {
    let id: String

    var body: some View { EmptyView() }
}

struct StringIdentifiedFullScreen: FullScreenCoverable {
    let id: String

    var body: some View { EmptyView() }
}

struct StringIdentifiedCustomSheet: CustomHeightSheetable {
    let id: String

    var detents: Set<PresentationDetent> { [.large] }
    var body: some View { EmptyView() }
}

struct StringIdentifiedAlert: Alertable {
    let id: String

    var title: String { id }
    var message: String? { nil }
    var actions: [AlertAction] { [] }
}

struct StringIdentifiedTab: Tabbable {
    let id: String

    var contentView: some View { EmptyView() }
    var tabLabel: some View { Text(id) }
}

struct StringIdentifiedSidebar: SidebarItem {
    let id: String

    var label: some View { Text(id) }
    var detail: some View { EmptyView() }
}

struct StringIdentifiedSelectable: Selectable {
    let id: String

    var label: some View { Text(id) }
}

// MARK: - Conformer identified by a string raw value

enum RawValueAlert: String, Alertable {
    case networkFailure
    case signedOut

    var title: String { rawValue }
    var message: String? { nil }
    var actions: [AlertAction] { [] }
}
