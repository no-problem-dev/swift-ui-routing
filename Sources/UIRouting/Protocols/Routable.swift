import SwiftUI

/// A destination that can be pushed onto a navigation stack.
///
/// Conformance is normally an enum whose cases carry the data each screen needs. `Identifiable`
/// and `Hashable` come for free, including for cases that carry closures.
/// ```swift
/// enum Screen: Routable {
///     case profile(userId: String)
///     case settings
///     case editor(onSave: () -> Void)
///
///     @ViewBuilder
///     var body: some View {
///         switch self {
///         case .profile(let userId):
///             ProfileView(userId: userId)
///         case .settings:
///             SettingsView()
///         case .editor(let onSave):
///             EditorView(onSave: onSave)
///         }
///     }
/// }
/// ```
///
/// Identity comes from the case name plus its hashable associated values, so do not write
/// `id`, `==`, or `hash(into:)` yourself — all three are provided.
@MainActor
public protocol Routable: Hashable, Identifiable {
    associatedtype Body: View

    /// The view this destination shows once pushed.
    @ViewBuilder var body: Body { get }
}

// MARK: - Default Implementations
public extension Routable where Self: Hashable, ID == Int {
    nonisolated var id: Int {
        var hasher = Hasher()
        self.hash(into: &hasher)
        return hasher.finalize()
    }
}

public extension Routable where ID == String {
    nonisolated static func == (lhs: Self, rhs: Self) -> Bool {
        lhs.id == rhs.id
    }

    nonisolated func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
}

// MARK: - Enum Mirror-based Hashable (closures ignored)
public extension Routable {
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
