import SwiftUI

/// Holds which tab is selected, and the router belonging to each tab.
///
/// Because every tab keeps its own router, switching tabs leaves each stack where the user left
/// it, and code can navigate inside a tab that is not currently on screen.
/// ```swift
/// struct ContentView: View {
///     @State private var tabPresenter = TabPresenter(initialTab: AppTab.home)
///
///     var body: some View {
///         TabRouting(tabPresenter: tabPresenter, tabs: [.home, .search, .settings])
///     }
/// }
/// ```
@MainActor
@Observable
public final class TabPresenter<Tab: Tabbable> {
    /// The tab on screen. Assigning to it switches tabs, and so does the tab bar.
    public var selectedTab: Tab

    /// Routers registered by each tab's routing modifier, keyed by tab identifier.
    private var routers: [Tab.ID: Router<Tab.Route>] = [:]

    /// Creates a presenter with the tab that should be selected first.
    ///
    /// - Parameter initialTab: The tab shown before the user picks another.
    public init(initialTab: Tab) {
        self.selectedTab = initialTab
    }

    // MARK: - Stack Observation

    /// Whether the selected tab has pushed anything past its root.
    ///
    /// Reading it from a view tracks pushes and pops, which makes it the hook for hiding the tab
    /// bar on deeper screens. It stays `false` while that tab's router is still unregistered.
    /// ```swift
    /// @Environment(.tab(AppTab.self)) private var tabPresenter
    ///
    /// var body: some View {
    ///     ContentView()
    ///         .toolbar(tabPresenter.isSelectedTabPushed ? .hidden : .visible, for: .tabBar)
    /// }
    /// ```
    public var isSelectedTabPushed: Bool {
        guard let router = routers[selectedTab.id] else { return false }
        return !router.path.isEmpty
    }

    // MARK: - Router Registration

    /// Records the router that drives one tab's navigation stack.
    ///
    /// - Parameters:
    ///   - router: The router to record.
    ///   - tab: The tab it belongs to.
    internal func registerRouter(_ router: Router<Tab.Route>, for tab: Tab) {
        routers[tab.id] = router
    }

    // MARK: - Tab Selection

    /// Switches to a tab, leaving its navigation stack as the user left it.
    /// ```swift
    /// @Environment(.tab(AppTab.self)) private var tabPresenter
    ///
    /// Button("Go to settings") {
    ///     tabPresenter.select(.settings)
    /// }
    /// ```
    ///
    /// - Parameter tab: The tab to switch to.
    public func select(_ tab: Tab) {
        selectedTab = tab
    }

    /// Switches to a tab and then navigates inside it.
    ///
    /// The callback runs after the tab transition, which is what keeps the push from being
    /// swallowed by the animation. It is skipped when that tab has no router registered yet.
    /// ```swift
    /// @Environment(.tab(AppTab.self)) private var tabPresenter
    ///
    /// Button("Open a detail screen in Home") {
    ///     tabPresenter.select(.home) { context in
    ///         context.router.navigate(to: .detail(id: "123"))
    ///     }
    /// }
    /// ```
    ///
    /// - Parameters:
    ///   - tab: The tab to switch to.
    ///   - callback: Work to run once that tab is on screen, given its routing context.
    public func select(_ tab: Tab, then callback: @escaping (TabContext<Tab.Route>) -> Void) {
        selectedTab = tab

        // Run the callback only once the tab has actually changed.
        Task { @MainActor in
            // Wait for the tab transition to finish.
            try? await Task.sleep(for: .milliseconds(100))

            guard let router = routers[tab.id] else {
                assertionFailure("Router not registered for tab: \(tab.id)")
                return
            }

            let context = TabContext(router: router)
            callback(context)
        }
    }
}
