import SwiftUI
import XCTest
@testable import UIRouting

/// Checks how a sheet's declared style picks between the sheet and the full-screen cover, and that
/// the one presenter behind both still presents and dismisses as before.
@MainActor
final class SheetPresentationStyleTests: XCTestCase {

    // MARK: - Declaring

    func testASheetIsASheetUnlessItSaysOtherwise() {
        XCTAssertEqual(StyledSheet.plain.presentationStyle, .sheet)
        XCTAssertEqual(StyledSheet.paywall.presentationStyle, .fullScreenCoverWhenRegular)
        XCTAssertEqual(StyledSheet.camera.presentationStyle, .fullScreenCover)
    }

    // MARK: - Resolving against the width

    func testEachStyleResolvesToItsFormAtEveryWidth() {
        let widths: [UserInterfaceSizeClass?] = [.regular, .compact, nil]

        for width in widths {
            XCTAssertEqual(SheetPresentationStyle.sheet.form(horizontalSizeClass: width), .sheet)
            XCTAssertEqual(SheetPresentationStyle.fullScreenCover.form(horizontalSizeClass: width), .fullScreenCover)
        }
        XCTAssertEqual(SheetPresentationStyle.fullScreenCoverWhenRegular.form(horizontalSizeClass: .regular), .fullScreenCover)
        XCTAssertEqual(SheetPresentationStyle.fullScreenCoverWhenRegular.form(horizontalSizeClass: .compact), .sheet)
        XCTAssertEqual(SheetPresentationStyle.fullScreenCoverWhenRegular.form(horizontalSizeClass: nil), .sheet)
    }

    // MARK: - Splitting one presenter between two modifiers

    func testOnlyTheModifierForTheResolvedFormSeesThePresentedSheet() {
        let presenter = SheetPresenter<StyledSheet>()
        presenter.present(.paywall)

        XCTAssertEqual(presenter.presentedSheet(in: .fullScreenCover, horizontalSizeClass: .regular).wrappedValue, .paywall)
        XCTAssertNil(presenter.presentedSheet(in: .sheet, horizontalSizeClass: .regular).wrappedValue)

        XCTAssertEqual(presenter.presentedSheet(in: .sheet, horizontalSizeClass: .compact).wrappedValue, .paywall)
        XCTAssertNil(presenter.presentedSheet(in: .fullScreenCover, horizontalSizeClass: .compact).wrappedValue)
    }

    func testDismissingFromTheFormOnScreenClearsThePresenter() {
        let presenter = SheetPresenter<StyledSheet>()
        presenter.present(.paywall)

        presenter.presentedSheet(in: .fullScreenCover, horizontalSizeClass: .regular).wrappedValue = nil

        XCTAssertNil(presenter.presentedSheet)
    }

    func testTheOtherFormsDismissalLeavesTheSheetThatReplacedIt() {
        let presenter = SheetPresenter<StyledSheet>()
        presenter.present(.plain)
        presenter.present(.camera)

        presenter.presentedSheet(in: .sheet, horizontalSizeClass: .regular).wrappedValue = nil

        XCTAssertEqual(presenter.presentedSheet, .camera)
    }

    func testPresentingThroughEitherFormReachesThePresenter() {
        let presenter = SheetPresenter<StyledSheet>()

        presenter.presentedSheet(in: .sheet, horizontalSizeClass: .compact).wrappedValue = .camera

        XCTAssertEqual(presenter.presentedSheet, .camera)
    }

    func testDismissStillTakesDownACoveringSheet() {
        let presenter = SheetPresenter<StyledSheet>()
        presenter.present(.camera)

        presenter.dismiss()

        XCTAssertNil(presenter.presentedSheet(in: .fullScreenCover, horizontalSizeClass: .regular).wrappedValue)
    }
}

@MainActor
private enum StyledSheet: Sheetable {
    case plain
    case paywall
    case camera

    var presentationStyle: SheetPresentationStyle {
        switch self {
        case .plain: .sheet
        case .paywall: .fullScreenCoverWhenRegular
        case .camera: .fullScreenCover
        }
    }

    var body: some View { EmptyView() }
}
