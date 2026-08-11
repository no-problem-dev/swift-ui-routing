import SwiftUI

/// A dialog that can be raised by an alert presenter.
///
/// Conformance is normally an enum: `Identifiable` and `Hashable` come for free, so a case can
/// carry the confirmation closure it needs without any extra boilerplate.
/// ```swift
/// enum Alert: Alertable {
///     case delete(itemName: String, onConfirm: () -> Void)
///     case error(message: String)
///
///     var title: String {
///         switch self {
///         case .delete: return "Confirm deletion"
///         case .error: return "Error"
///         }
///     }
///
///     var message: String? {
///         switch self {
///         case .delete(let itemName, _):
///             return "Delete \(itemName)?"
///         case .error(let msg):
///             return msg
///         }
///     }
///
///     var actions: [AlertAction] {
///         switch self {
///         case .delete(_, let onConfirm):
///             return [
///                 AlertAction(title: "Cancel", role: .cancel) {},
///                 AlertAction(title: "Delete", role: .destructive, action: onConfirm)
///             ]
///         case .error:
///             return [AlertAction(title: "OK") {}]
///         }
///     }
/// }
/// ```
///
/// Identity comes from the case name plus its hashable associated values, so do not write
/// `id`, `==`, or `hash(into:)` yourself — all three are provided.
@MainActor
public protocol Alertable: Identifiable, Hashable {
    /// Text shown in bold at the top of the dialog.
    var title: String { get }

    /// Explanatory text below the title, or `nil` to show none.
    var message: String? { get }

    /// The buttons of the dialog, rendered in the order given.
    var actions: [AlertAction] { get }
}

// MARK: - Default Implementations
public extension Alertable where Self: Hashable, ID == Int {
    nonisolated var id: Int {
        var hasher = Hasher()
        self.hash(into: &hasher)
        return hasher.finalize()
    }
}

public extension Alertable where ID == String {
    nonisolated static func == (lhs: Self, rhs: Self) -> Bool {
        lhs.id == rhs.id
    }

    nonisolated func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
}

// MARK: - Enum Mirror-based Hashable (closures ignored)
public extension Alertable where Self: RawRepresentable, Self.RawValue == String {
    nonisolated static func == (lhs: Self, rhs: Self) -> Bool {
        lhs.rawValue == rhs.rawValue
    }

    nonisolated func hash(into hasher: inout Hasher) {
        hasher.combine(rawValue)
    }
}

// MARK: - Enum without RawValue (Mirror-based)
public extension Alertable {
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

/// A button in an alert dialog.
///
/// Two actions are equal when their titles match: the closure takes no part in identity, so a
/// dialog rebuilt with a fresh callback still compares as the same alert.
///
/// ```swift
/// AlertAction(title: "OK") { print("OK tapped") }
///
/// AlertAction(title: "Cancel", role: .cancel) {}
///
/// AlertAction(title: "Delete", role: .destructive) {
///     deleteItem()
/// }
/// ```
public struct AlertAction: Hashable {
    /// The label on the button, and the only thing used to compare two actions.
    public let title: String

    /// The role that decides styling and placement, or `nil` for a plain button.
    public let role: ButtonRole?

    /// The closure to run on tap. It takes no part in equality or hashing.
    public let action: () -> Void

    /// Creates a button for an alert dialog.
    ///
    /// - Parameters:
    ///   - title: The label shown on the button.
    ///   - role: The role that decides styling and placement.
    ///   - action: The closure to run when the button is tapped.
    public init(
        title: String,
        role: ButtonRole? = nil,
        action: @escaping () -> Void
    ) {
        self.title = title
        self.role = role
        self.action = action
    }

    public static func == (lhs: AlertAction, rhs: AlertAction) -> Bool {
        lhs.title == rhs.title
    }

    public func hash(into hasher: inout Hasher) {
        hasher.combine(title)
    }
}
