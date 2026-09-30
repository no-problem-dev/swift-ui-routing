import SwiftUI

/// Holds which tab is selected, and the router belonging to each tab.
///
/// Because every tab keeps its own router, switching tabs leaves each stack where the user left
/// it, and code can navigate inside a tab that is not currently on screen.
///
/// Navigation asked for before a tab's router exists waits for it instead of being dropped. A tab
/// registers its router when it first appears, which for a notification, widget, or Siri launch
/// can be well after the request arrived. Keep the presenter where the app starts (the `App`, or
/// the object that owns the app's state) so those entry points can reach it before any view is up.
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

    /// Navigation waiting for its tab's router. Only the latest request is kept.
    @ObservationIgnored private var pendingNavigation: PendingNavigation<Tab>?

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

    /// Records the router that drives one tab's navigation stack, and runs any navigation that
    /// was waiting for it.
    ///
    /// - Parameters:
    ///   - router: The router to record.
    ///   - tab: The tab it belongs to.
    internal func registerRouter(_ router: Router<Tab.Route>, for tab: Tab) {
        routers[tab.id] = router
        guard let pending = pendingNavigation, pending.tabID == tab.id else { return }
        pendingNavigation = nil
        pending.perform(TabContext(router: router))
    }

    /// Whether navigation is waiting for a tab's router to register.
    internal var isNavigationPending: Bool {
        pendingNavigation != nil
    }

    // MARK: - Tab Selection

    /// Switches to a tab, leaving its navigation stack as the user left it.
    ///
    /// Any navigation still waiting for another tab's router is dropped: the latest request wins.
    /// ```swift
    /// @Environment(.tab(AppTab.self)) private var tabPresenter
    ///
    /// Button("Go to settings") {
    ///     tabPresenter?.select(.settings)
    /// }
    /// ```
    ///
    /// - Parameter tab: The tab to switch to.
    public func select(_ tab: Tab) {
        pendingNavigation = nil
        selectedTab = tab
    }

    /// Switches to a tab and then navigates inside it.
    ///
    /// The callback runs at once when the tab's router is registered. Otherwise it waits until the
    /// tab appears and registers one — on a cold launch that is after the first frame — so a push
    /// is never dropped for arriving early. Only the latest waiting request is kept; a later
    /// `select` or `open` replaces it.
    /// ```swift
    /// @Environment(.tab(AppTab.self)) private var tabPresenter
    ///
    /// Button("Open a detail screen in Home") {
    ///     tabPresenter?.select(.home) { context in
    ///         context.router.navigate(to: .detail(id: "123"))
    ///     }
    /// }
    /// ```
    ///
    /// - Parameters:
    ///   - tab: The tab to switch to.
    ///   - callback: Work to run once that tab's router exists, given its routing context.
    public func select(_ tab: Tab, then callback: @escaping (TabContext<Tab.Route>) -> Void) {
        selectedTab = tab
        if let router = routers[tab.id] {
            pendingNavigation = nil
            callback(TabContext(router: router))
        } else {
            pendingNavigation = PendingNavigation<Tab>(tabID: tab.id, perform: callback)
        }
    }

    // MARK: - Opening Destinations

    /// Switches to the destination's tab and replaces that tab's stack with its path.
    ///
    /// This is the landing point for everything that arrives from outside the view tree — a
    /// URL, a notification, a widget, an App Intent. Like `select(_:then:)`, it waits for the
    /// tab's router when there is none yet.
    /// ```swift
    /// tabPresenter.open(TabDestination(tab: .trips, path: [.trip(id: tripID)]))
    /// ```
    ///
    /// - Parameter destination: The tab to show and the screens to stack on its root.
    public func open(_ destination: TabDestination<Tab>) {
        let path = destination.path
        select(destination.tab) { context in
            context.router.path = path
        }
    }

    /// Converts a URL into a destination and opens it.
    ///
    /// The conversion is the app's: what a URL means is the app's own contract, and it usually
    /// lives next to the code that builds the same URLs (widgets, notifications, the server).
    /// ```swift
    /// TabRouting(tabPresenter: tabPresenter, tabs: AppTab.allCases)
    ///     .onOpenURL { url in
    ///         tabPresenter.open(url, resolve: AppLink.destination(for:))
    ///     }
    /// ```
    ///
    /// - Parameters:
    ///   - url: The incoming URL.
    ///   - resolve: Turns the URL into a destination, or returns `nil` for a URL this app does
    ///     not route.
    /// - Returns: Whether the URL resolved to a destination and was opened.
    @discardableResult
    public func open(_ url: URL, resolve: (URL) -> TabDestination<Tab>?) -> Bool {
        guard let destination = resolve(url) else { return false }
        open(destination)
        return true
    }
}

/// Navigation that is waiting for its tab's router to register.
private struct PendingNavigation<Tab: Tabbable> {
    let tabID: Tab.ID
    let perform: (TabContext<Tab.Route>) -> Void
}
