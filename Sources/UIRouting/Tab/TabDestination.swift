import SwiftUI

/// A place inside a tab app: the tab to show and the screens stacked on its root.
///
/// It is what a URL, a notification, or a widget tap turns into, and what
/// ``TabPresenter``'s `open(_:)` takes.
/// ```swift
/// enum AppLink {
///     static func destination(for url: URL) -> TabDestination<AppTab>? {
///         switch url.pathComponents.dropFirst().first {
///         case "trips":
///             return TabDestination(tab: .trips, path: [.trip(id: url.lastPathComponent)])
///         case "settings":
///             return TabDestination(tab: .settings)
///         default:
///             return nil
///         }
///     }
/// }
/// ```
public struct TabDestination<Tab: Tabbable> {
    /// The tab to switch to.
    public let tab: Tab
    /// The screens to stack on the tab's root, bottom first. Empty shows the root itself.
    public let path: [Tab.Route]

    /// Creates a destination.
    ///
    /// - Parameters:
    ///   - tab: The tab to switch to.
    ///   - path: The screens to stack on the tab's root, bottom first.
    public init(tab: Tab, path: [Tab.Route] = []) {
        self.tab = tab
        self.path = path
    }
}
