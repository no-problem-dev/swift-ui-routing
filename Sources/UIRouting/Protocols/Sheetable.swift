import SwiftUI

/// A screen presented as a modal sheet.
///
/// Conformance is normally an enum, one case per sheet. `Identifiable` and `Hashable` come for
/// free, so a case may carry the callback its sheet reports back through.
/// ```swift
/// enum AppSheet: Sheetable {
///     case filter
///     case addTodo
///     case picker(onSelect: (Item) -> Void)
///
///     @ViewBuilder
///     var body: some View {
///         switch self {
///         case .filter:
///             FilterSheet()
///         case .addTodo:
///             AddTodoSheet()
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
public protocol Sheetable: Identifiable, Hashable {
    associatedtype Body: View

    /// The view shown inside the sheet.
    @ViewBuilder var body: Body { get }
}

// MARK: - Default Implementations
public extension Sheetable where Self: Hashable, ID == Int {
    nonisolated var id: Int {
        var hasher = Hasher()
        self.hash(into: &hasher)
        return hasher.finalize()
    }
}

public extension Sheetable where ID == String {
    nonisolated static func == (lhs: Self, rhs: Self) -> Bool {
        lhs.id == rhs.id
    }

    nonisolated func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
}

// MARK: - Enum Mirror-based Hashable (closures ignored)
public extension Sheetable {
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
