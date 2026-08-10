import XCTest
@testable import UIRouting
import SwiftUI

/// Covers the Hashable and Equatable defaults the presentation protocols provide.
///
/// The point of interest is how associated values are treated, in particular that closures are
/// left out of both comparison and hashing.
final class HashableEquatableTests: XCTestCase {

    // MARK: - FullScreenCoverable Tests

    func testFullScreenCoverableWithSimpleAssociatedValues() {
        let cover1 = TestFullScreenCover.editor(itemId: "123")
        let cover2 = TestFullScreenCover.editor(itemId: "123")
        let cover3 = TestFullScreenCover.editor(itemId: "456")

        // Same associated values compare equal.
        XCTAssertEqual(cover1, cover2)
        XCTAssertEqual(cover1.hashValue, cover2.hashValue)

        // Different associated values do not.
        XCTAssertNotEqual(cover1, cover3)
        XCTAssertNotEqual(cover1.hashValue, cover3.hashValue)
    }

    func testFullScreenCoverableWithClosureAssociatedValues() {
        var called1 = false
        var called2 = false

        let cover1 = TestFullScreenCover.picker { _ in called1 = true }
        let cover2 = TestFullScreenCover.picker { _ in called2 = true }

        // Closures are ignored, so the same case compares equal.
        XCTAssertEqual(cover1, cover2)
        XCTAssertEqual(cover1.hashValue, cover2.hashValue)
    }

    func testFullScreenCoverableWithMixedAssociatedValues() {
        let cover1 = TestFullScreenCover.editorWithCallback(itemId: "123") { print("done") }
        let cover2 = TestFullScreenCover.editorWithCallback(itemId: "123") { print("complete") }
        let cover3 = TestFullScreenCover.editorWithCallback(itemId: "456") { print("done") }

        // The hashable payload is compared; the closure is ignored.
        XCTAssertEqual(cover1, cover2)
        XCTAssertEqual(cover1.hashValue, cover2.hashValue)

        // A different hashable payload breaks equality, whatever the closures do.
        XCTAssertNotEqual(cover1, cover3)
    }

    func testFullScreenCoverableWithoutAssociatedValues() {
        let cover1 = TestFullScreenCover.camera
        let cover2 = TestFullScreenCover.camera
        let cover3 = TestFullScreenCover.editor(itemId: "123")

        // A case with no payload compares equal to itself.
        XCTAssertEqual(cover1, cover2)
        XCTAssertEqual(cover1.hashValue, cover2.hashValue)

        // Different cases do not.
        XCTAssertNotEqual(cover1, cover3)
    }

    // MARK: - Sheetable Tests

    func testSheetableWithSimpleAssociatedValues() {
        let sheet1 = TestSheet.filter(category: "Books")
        let sheet2 = TestSheet.filter(category: "Books")
        let sheet3 = TestSheet.filter(category: "Movies")

        XCTAssertEqual(sheet1, sheet2)
        XCTAssertEqual(sheet1.hashValue, sheet2.hashValue)

        XCTAssertNotEqual(sheet1, sheet3)
        XCTAssertNotEqual(sheet1.hashValue, sheet3.hashValue)
    }

    func testSheetableWithClosureAssociatedValues() {
        let sheet1 = TestSheet.picker { _ in print("selected1") }
        let sheet2 = TestSheet.picker { _ in print("selected2") }

        // Closures are ignored, so these compare equal.
        XCTAssertEqual(sheet1, sheet2)
        XCTAssertEqual(sheet1.hashValue, sheet2.hashValue)
    }

    func testSheetableWithMixedAssociatedValues() {
        let sheet1 = TestSheet.editorWithSave(itemId: "abc") { print("saved") }
        let sheet2 = TestSheet.editorWithSave(itemId: "abc") { print("done") }
        let sheet3 = TestSheet.editorWithSave(itemId: "xyz") { print("saved") }

        XCTAssertEqual(sheet1, sheet2)
        XCTAssertEqual(sheet1.hashValue, sheet2.hashValue)

        XCTAssertNotEqual(sheet1, sheet3)
    }

    func testSheetableWithoutAssociatedValues() {
        let sheet1 = TestSheet.addTodo
        let sheet2 = TestSheet.addTodo
        let sheet3 = TestSheet.filter(category: "Books")

        XCTAssertEqual(sheet1, sheet2)
        XCTAssertEqual(sheet1.hashValue, sheet2.hashValue)

        XCTAssertNotEqual(sheet1, sheet3)
    }

    // MARK: - CustomHeightSheetable Tests

    func testCustomHeightSheetableWithClosures() {
        let sheet1 = TestCustomHeightSheet.quickAdd { print("added1") }
        let sheet2 = TestCustomHeightSheet.quickAdd { print("added2") }

        // Closures are ignored.
        XCTAssertEqual(sheet1, sheet2)
        XCTAssertEqual(sheet1.hashValue, sheet2.hashValue)
    }

    func testCustomHeightSheetableWithMixedValues() {
        let sheet1 = TestCustomHeightSheet.picker(title: "Select") { _ in }
        let sheet2 = TestCustomHeightSheet.picker(title: "Select") { _ in }
        let sheet3 = TestCustomHeightSheet.picker(title: "Choose") { _ in }

        XCTAssertEqual(sheet1, sheet2)
        XCTAssertNotEqual(sheet1, sheet3)
    }

    // MARK: - Alertable Tests

    func testAlertableWithClosures() {
        let alert1 = TestAlertWithClosure.delete(itemName: "File") { print("deleted1") }
        let alert2 = TestAlertWithClosure.delete(itemName: "File") { print("deleted2") }
        let alert3 = TestAlertWithClosure.delete(itemName: "Folder") { print("deleted1") }

        // Closures are ignored, so only itemName decides equality.
        XCTAssertEqual(alert1, alert2)
        XCTAssertEqual(alert1.hashValue, alert2.hashValue)

        XCTAssertNotEqual(alert1, alert3)
    }

    // MARK: - Collection Tests

    func testInSetWithClosures() {
        var calledA = false
        var calledB = false

        let cover1 = TestFullScreenCover.picker { _ in calledA = true }
        let cover2 = TestFullScreenCover.picker { _ in calledB = true }
        let cover3 = TestFullScreenCover.camera

        var set: Set<TestFullScreenCover> = []

        set.insert(cover1)
        XCTAssertEqual(set.count, 1)

        // Same case, so the set treats it as a duplicate.
        set.insert(cover2)
        XCTAssertEqual(set.count, 1)

        // Different case, so it is added.
        set.insert(cover3)
        XCTAssertEqual(set.count, 2)
    }

    func testInDictionaryWithClosures() {
        let sheet1 = TestSheet.picker { _ in print("A") }
        let sheet2 = TestSheet.picker { _ in print("B") }

        var dict: [TestSheet: String] = [:]

        dict[sheet1] = "First"
        XCTAssertEqual(dict[sheet2], "First") // Treated as the same key.
    }
}

// MARK: - Test Types

@MainActor
enum TestFullScreenCover: FullScreenCoverable {
    case camera
    case editor(itemId: String)
    case picker(onSelect: (String) -> Void)
    case editorWithCallback(itemId: String, onSave: () -> Void)

    var body: some View {
        EmptyView()
    }
}

@MainActor
enum TestSheet: Sheetable {
    case addTodo
    case filter(category: String)
    case picker(onSelect: (String) -> Void)
    case editorWithSave(itemId: String, onSave: () -> Void)

    var body: some View {
        EmptyView()
    }
}

@MainActor
enum TestCustomHeightSheet: CustomHeightSheetable {
    case quickAdd(onAdd: () -> Void)
    case picker(title: String, onSelect: (String) -> Void)

    var detents: Set<PresentationDetent> {
        switch self {
        case .quickAdd:
            return [.height(200)]
        case .picker:
            return [.medium, .large]
        }
    }

    var body: some View {
        EmptyView()
    }
}

@MainActor
enum TestAlertWithClosure: Alertable {
    case delete(itemName: String, onConfirm: () -> Void)
    case error(message: String)

    var title: String {
        switch self {
        case .delete: return "削除の確認"
        case .error: return "エラー"
        }
    }

    var message: String? {
        switch self {
        case .delete(let itemName, _):
            return "\(itemName)を削除してもよろしいですか？"
        case .error(let msg):
            return msg
        }
    }

    var actions: [AlertAction] {
        switch self {
        case .delete(_, let onConfirm):
            return [
                AlertAction(title: "キャンセル", role: .cancel, action: {}),
                AlertAction(title: "削除", role: .destructive, action: onConfirm)
            ]
        case .error:
            return [AlertAction(title: "OK", action: {})]
        }
    }
}
