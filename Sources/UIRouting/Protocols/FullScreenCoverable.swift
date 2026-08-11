import SwiftUI

/// A screen presented as a full-screen cover.
///
/// On macOS, where full-screen covers do not exist, these are presented as ordinary sheets.
/// `Identifiable` and `Hashable` come for free.
/// ```swift
/// enum AppFullScreenCover: FullScreenCoverable {
///     case camera
///     case editor(itemId: String)
///     case picker(onSelect: (Item) -> Void)
///
///     @ViewBuilder
///     var body: some View {
///         switch self {
///         case .camera:
///             CameraView()
///         case .editor(let itemId):
///             EditorView(itemId: itemId)
///         case .picker(let onSelect):
///             PickerView(onSelect: onSelect)
///         }
///     }
/// }
/// ```
///
/// Identity comes from the case name plus its hashable associated values, so do not write
/// `id`, `==`, or `hash(into:)` yourself — all three are provided.
@MainActor
public protocol FullScreenCoverable: Identifiable, Hashable {
    associatedtype Body: View

    /// The view shown by the cover.
    @ViewBuilder var body: Body { get }
}

// MARK: - Default Implementations
public extension FullScreenCoverable where Self: Hashable, ID == Int {
    nonisolated var id: Int {
        var hasher = Hasher()
        self.hash(into: &hasher)
        return hasher.finalize()
    }
}

public extension FullScreenCoverable where ID == String {
    nonisolated static func == (lhs: Self, rhs: Self) -> Bool {
        lhs.id == rhs.id
    }

    nonisolated func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
}

// MARK: - Enum Mirror-based Hashable (closures ignored)
public extension FullScreenCoverable {
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
