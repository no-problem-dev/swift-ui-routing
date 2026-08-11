import SwiftUI

/// A sheet that carries its own set of detents.
///
/// Reach for it instead of a plain sheet when different sheets need different heights: each
/// case decides how tall it opens. `Identifiable` and `Hashable` come for free.
/// ```swift
/// enum AppCustomHeightSheet: CustomHeightSheetable {
///     case quickAdd
///     case picker(onSelect: (Item) -> Void)
///
///     var detents: Set<PresentationDetent> {
///         switch self {
///         case .quickAdd:
///             return [.height(200)]
///         case .picker:
///             return [.medium, .large]
///         }
///     }
///
///     @ViewBuilder
///     var body: some View {
///         switch self {
///         case .quickAdd:
///             QuickAddSheet()
///         case .picker(let onSelect):
///             PickerSheet(onSelect: onSelect)
///         }
///     }
/// }
/// ```
///
/// Identity comes from the case name plus its hashable associated values, so do not write
/// `id`, `==`, or `hash(into:)` yourself — all three are provided.
@MainActor
public protocol CustomHeightSheetable: Identifiable, Hashable {
    associatedtype Body: View

    /// The view shown inside the sheet.
    @ViewBuilder var body: Body { get }

    /// The heights this sheet can rest at.
    var detents: Set<PresentationDetent> { get }
}

// MARK: - Default Implementations
public extension CustomHeightSheetable where Self: Hashable, ID == Int {
    nonisolated var id: Int {
        var hasher = Hasher()
        self.hash(into: &hasher)
        return hasher.finalize()
    }
}

public extension CustomHeightSheetable where ID == String {
    nonisolated static func == (lhs: Self, rhs: Self) -> Bool {
        lhs.id == rhs.id
    }

    nonisolated func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
}

// MARK: - Enum Mirror-based Hashable (closures ignored)
public extension CustomHeightSheetable {
    /// Compares two values by case name and by their hashable associated values.
    ///
    /// Closure payloads are skipped, which is what lets a case carry a callback and still be
    /// compared and hashed.
    nonisolated static func == (lhs: Self, rhs: Self) -> Bool {
        ReflectedIdentity.areEqual(lhs, rhs)
    }

    nonisolated func hash(into hasher: inout Hasher) {
        ReflectedIdentity.hash(self, into: &hasher)
    }
}
