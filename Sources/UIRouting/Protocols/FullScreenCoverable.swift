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
    static func == (lhs: Self, rhs: Self) -> Bool {
        lhs.id == rhs.id
    }

    func hash(into hasher: inout Hasher) {
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
        let lhsMirror = Mirror(reflecting: lhs)
        let rhsMirror = Mirror(reflecting: rhs)

        // Different case names mean the values are not equal.
        guard lhsMirror.children.first?.label == rhsMirror.children.first?.label else {
            return false
        }

        // Compare associated values, hashable ones only.
        let lhsHashableValues = extractHashableValues(from: lhs)
        let rhsHashableValues = extractHashableValues(from: rhs)

        return lhsHashableValues == rhsHashableValues
    }

    nonisolated func hash(into hasher: inout Hasher) {
        let mirror = Mirror(reflecting: self)

        // Hash the case name.
        hasher.combine(mirror.children.first?.label ?? "")

        // Hash only the hashable associated values.
        let hashableValues = extractHashableValues(from: self)
        hasher.combine(hashableValues)
    }

    private nonisolated static func extractHashableValues(from value: Self) -> [AnyHashable] {
        let mirror = Mirror(reflecting: value)
        guard let values = mirror.children.first?.value else {
            return []
        }

        let valuesMirror = Mirror(reflecting: values)
        return valuesMirror.children.compactMap { child -> AnyHashable? in
            // Closures cannot be cast to AnyHashable, so they drop out here.
            child.value as? AnyHashable
        }
    }

    private nonisolated func extractHashableValues(from value: Self) -> [AnyHashable] {
        Self.extractHashableValues(from: value)
    }
}
