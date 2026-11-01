#if os(macOS)
import AppKit
import SwiftUI
import XCTest
@testable import UIRouting

/// Hosts real views in a window and checks that what a presenter is asked to show appears.
///
/// Both failures these guard against were silent: a presenter was published with nothing bound to
/// it, or published on one layer and read from another, and `present(_:)` did nothing at all.
@MainActor
final class PresentationWiringTests: XCTestCase {

    func testRoutingAttachesTheSheetItPublishes() {
        let seen = Seen()
        let sheets = SheetPresenter<WiringSheet>()

        host(
            Color.clear.routing(
                router: Router<WiringRoute>(),
                sheetPresenter: sheets,
                alertPresenterOnNavigation: AlertPresenter<Never>(),
                alertPresenterOnSheet: AlertPresenter<Never>()
            )
            .environment(seen)
        )
        sheets.present(.filter)

        XCTAssertTrue(waitUntil { seen.names.contains("sheet") })
    }

    func testASheetThatAsksForAFullScreenCoverIsPresentedAsASheetOnMacOS() {
        let seen = Seen()
        let sheets = SheetPresenter<WiringSheet>()

        host(
            Color.clear.routing(
                router: Router<WiringRoute>(),
                sheetPresenter: sheets,
                alertPresenterOnNavigation: AlertPresenter<Never>(),
                alertPresenterOnSheet: AlertPresenter<Never>()
            )
            .environment(seen)
        )
        sheets.present(.paywall)

        XCTAssertTrue(waitUntil { seen.names.contains("paywall") })
        sheets.dismiss()
        XCTAssertTrue(waitUntil { !seen.names.contains("paywall") })
    }

    func testRoutingAttachesTheCoverAndTheCustomHeightSheetItPublishes() {
        let seen = Seen()
        let covers = FullScreenCoverPresenter<WiringCover>()
        let customSheets = CustomHeightSheetPresenter<WiringCustomSheet>()

        host(
            Color.clear.routing(
                router: Router<WiringRoute>(),
                sheetPresenter: SheetPresenter<Never>(),
                customHeightSheetPresenter: customSheets,
                fullScreenCoverPresenter: covers,
                alertPresenterOnNavigation: AlertPresenter<Never>(),
                alertPresenterOnSheet: AlertPresenter<Never>(),
                splitViewPresenter: SplitViewPresenter<Never>()
            )
            .environment(seen)
        )
        covers.present(.camera)

        XCTAssertTrue(waitUntil { seen.names.contains("cover") })
        covers.dismiss()
        XCTAssertTrue(waitUntil { !seen.names.contains("cover") })

        customSheets.present(.quickAdd)

        XCTAssertTrue(waitUntil { seen.names.contains("customSheet") })
    }

    func testACoverPresenterIsReadOnTheLayerItIsPublishedOn() {
        let seen = Seen()

        host(
            CoverButton(context: .sheet)
                .fullScreenCoverPresenter(for: WiringCover.self, context: .sheet)
                .environment(seen)
        )

        XCTAssertTrue(waitUntil { seen.names.contains("cover") })
    }

    func testACustomHeightSheetPresenterIsReadOnTheLayerItIsPublishedOn() {
        let seen = Seen()

        host(
            CustomSheetButton(context: .navigation)
                .customHeightSheetPresenter(for: WiringCustomSheet.self, context: .navigation)
                .environment(seen)
        )

        XCTAssertTrue(waitUntil { seen.names.contains("customSheet") })
    }

    // MARK: - Hosting

    private var windows: [NSWindow] = []

    override func tearDown() async throws {
        windows.forEach { $0.close() }
        windows.removeAll()
        try await super.tearDown()
    }

    private func host(_ view: some View) {
        let window = NSWindow(
            contentRect: NSRect(x: 0, y: 0, width: 320, height: 240),
            styleMask: [.titled],
            backing: .buffered,
            defer: false
        )
        window.isReleasedWhenClosed = false
        window.contentView = NSHostingView(rootView: view)
        window.makeKeyAndOrderFront(nil)
        windows.append(window)
    }

    private func waitUntil(_ condition: () -> Bool) -> Bool {
        let deadline = Date().addingTimeInterval(3)
        while Date() < deadline {
            if condition() { return true }
            RunLoop.main.run(until: Date().addingTimeInterval(0.02))
        }
        return condition()
    }
}

// MARK: - Test views and types

/// Names of the presented views currently on screen.
@MainActor
@Observable
private final class Seen {
    var names: Set<String> = []
}

private struct Marker: View {
    let name: String
    @Environment(Seen.self) private var seen

    var body: some View {
        Color.clear
            .onAppear { seen.names.insert(name) }
            .onDisappear { seen.names.remove(name) }
    }
}

/// Reads a cover presenter on one layer and presents from it as soon as it appears.
private struct CoverButton: View {
    @Environment private var covers: FullScreenCoverPresenter<WiringCover>

    init(context: PresentationContext) {
        _covers = Environment(.fullScreenCover(WiringCover.self, context: context))
    }

    var body: some View {
        Color.clear.onAppear { covers.present(.camera) }
    }
}

/// Reads a custom-height sheet presenter on one layer and presents from it as soon as it appears.
private struct CustomSheetButton: View {
    @Environment private var sheets: CustomHeightSheetPresenter<WiringCustomSheet>

    init(context: PresentationContext) {
        _sheets = Environment(.customHeightSheet(WiringCustomSheet.self, context: context))
    }

    var body: some View {
        Color.clear.onAppear { sheets.present(.quickAdd) }
    }
}

@MainActor
private enum WiringRoute: Routable {
    case detail
    var body: some View { EmptyView() }
}

@MainActor
private enum WiringSheet: Sheetable {
    case filter
    case paywall

    var presentationStyle: SheetPresentationStyle {
        switch self {
        case .filter: .sheet
        case .paywall: .fullScreenCoverWhenRegular
        }
    }

    var body: some View {
        switch self {
        case .filter: Marker(name: "sheet")
        case .paywall: Marker(name: "paywall")
        }
    }
}

@MainActor
private enum WiringCover: FullScreenCoverable {
    case camera
    var body: some View { Marker(name: "cover") }
}

@MainActor
private enum WiringCustomSheet: CustomHeightSheetable {
    case quickAdd
    var detents: Set<PresentationDetent> { [.medium] }
    var body: some View { Marker(name: "customSheet") }
}
#endif
