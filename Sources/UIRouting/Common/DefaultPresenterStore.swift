import Foundation

/// Holds the one object an environment lookup falls back to when nothing injected a presenter.
///
/// `EnvironmentKey.defaultValue` is a computed requirement, read afresh on every lookup, and Swift
/// does not allow a static stored property inside a generic type. So the obvious spelling —
/// constructing the presenter in the getter — hands out a *new* object on every read. A button
/// then pushes onto one router while the navigation stack is bound to another, and the caller sees
/// no navigation, no crash, and nothing in the log.
///
/// Keeping one object per environment key type makes a forgotten injection behave like a shared
/// presenter rather than like a presenter that forgets. It is still worth injecting: two stacks
/// that both fall back share the same one.
@MainActor
enum DefaultPresenterStore {
    private static var instances: [ObjectIdentifier: AnyObject] = [:]

    /// Returns the object stored for an environment key, creating it on first use.
    ///
    /// - Parameters:
    ///   - key: The environment key type. Each generic instantiation gets its own object, and the
    ///     navigation-layer and sheet-layer keys are distinct types, so the two layers stay apart.
    ///   - create: Builds the object the first time this key is asked for.
    static func instance<Key, Presenter: AnyObject>(
        for key: Key.Type,
        create: () -> Presenter
    ) -> Presenter {
        let identifier = ObjectIdentifier(key)
        if let existing = instances[identifier] as? Presenter {
            return existing
        }
        let created = create()
        instances[identifier] = created
        return created
    }
}
