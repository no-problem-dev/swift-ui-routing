import Foundation

/// The identity ``Routable``, ``Sheetable``, ``FullScreenCoverable``, ``CustomHeightSheetable``
/// and ``Alertable`` derive by reflection for conformances that write no `==` or `hash(into:)`.
///
/// A value is reduced to two things: a discriminator that separates one enum case from another,
/// and the hashable part of its associated values. Closures are not hashable, so they fall out —
/// which is what lets a case carry a callback and still be pushed onto a navigation stack.
///
/// The two shapes worth naming, because both used to collapse into "no payload at all":
///
/// - A case with no associated value reflects to no children, so the case name has to come from
///   the value's own description. Without that, every such case in a type is the same value.
/// - A single *unlabelled* associated value reflects as the value itself, not as a one-element
///   tuple. Mirroring it a second time yields nothing, so the payload has to be taken directly.
enum ReflectedIdentity {

    /// Whether two values reduce to the same discriminator and the same hashable payload.
    static func areEqual(_ lhs: Any, _ rhs: Any) -> Bool {
        components(of: lhs) == components(of: rhs)
    }

    /// Feeds a value's discriminator and hashable payload to a hasher.
    static func hash(_ value: Any, into hasher: inout Hasher) {
        let identity = components(of: value)
        hasher.combine(identity.discriminator)
        hasher.combine(identity.payload)
    }

    private static func components(of value: Any) -> (discriminator: String, payload: [AnyHashable]) {
        let mirror = Mirror(reflecting: value)

        guard let child = mirror.children.first else {
            // Nothing to reflect. For an enum case with no associated value the description is
            // exactly the case name, which is the only thing separating it from its siblings.
            return (String(describing: value), [])
        }

        guard mirror.displayStyle == .enum else {
            // Not an enum: there are no cases, so every stored property takes part instead.
            return ("", hashableValues(in: mirror))
        }

        return (child.label ?? "", payloadValues(of: child.value))
    }

    /// The hashable values inside one enum case's associated value.
    private static func payloadValues(of payload: Any) -> [AnyHashable] {
        // A lone unlabelled value arrives as itself; everything else arrives as a tuple, which is
        // never hashable and so is taken apart child by child.
        if let single = payload as? AnyHashable {
            return [single]
        }
        return hashableValues(in: Mirror(reflecting: payload))
    }

    private static func hashableValues(in mirror: Mirror) -> [AnyHashable] {
        mirror.children.compactMap { $0.value as? AnyHashable }
    }
}
