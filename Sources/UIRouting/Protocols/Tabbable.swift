import SwiftUI

/// A tab, together with the routing types its own navigation stack uses.
///
/// Each tab keeps a separate stack, so pushing in one leaves the others where they were.
/// Routing types left unspecified default to `Never`, which switches that feature off.
/// ```swift
/// enum AppTab: Tabbable {
///     case home
///     case settings
///
///     typealias Route = AppRoute
///     typealias Sheet = AppSheet
///     typealias Alert = AppAlert
///
///     var contentView: some View {
///         switch self {
///         case .home:
///             HomeView()
///         case .settings:
///             SettingsView()
///         }
///     }
///
///     var tabLabel: some View {
///         switch self {
///         case .home:
///             Label("Home", systemImage: "house")
///         case .settings:
///             Label("Settings", systemImage: "gearshape")
///         }
///     }
/// }
/// ```
///
/// Do not write `id` or `hash(into:)`; both are provided.
@MainActor
public protocol Tabbable<Route>: Hashable, Identifiable {
    // Views
    associatedtype ContentView: View
    associatedtype TabLabel: View

    // Routing types; Route is the primary associated type
    associatedtype Route: Routable = Never
    associatedtype Sheet: Sheetable = Never
    associatedtype Alert: Alertable = Never
    associatedtype FullScreen: FullScreenCoverable = Never
    associatedtype CustomSheet: CustomHeightSheetable = Never

    /// The root view of this tab's navigation stack.
    @ViewBuilder var contentView: ContentView { get }

    /// The item drawn in the tab bar.
    @ViewBuilder var tabLabel: TabLabel { get }

    /// The system role of this tab, or `nil` for an ordinary one.
    ///
    /// Returning `.search` lets the system pin the tab, tune its Liquid Glass treatment, and
    /// classify it correctly when the tab bar adapts into a sidebar.
    var tabRole: TabRole? { get }
}

// MARK: - Default Implementations
public extension Tabbable where Self: Hashable, ID == Int {
    nonisolated var id: Int {
        var hasher = Hasher()
        self.hash(into: &hasher)
        return hasher.finalize()
    }
}

public extension Tabbable where ID == String {
    nonisolated static func == (lhs: Self, rhs: Self) -> Bool {
        lhs.id == rhs.id
    }

    nonisolated func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
}

// MARK: - tabRole default

public extension Tabbable {
    /// Treats every tab as ordinary; override it on a search tab to return `.search`.
    var tabRole: TabRole? { nil }
}
