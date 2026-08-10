import SwiftUI

/// Builds a tab view from a presenter already in the environment and a list of tabs.
///
/// Prefer the `TabRouting` view, which owns the presenter and publishes it for you.
/// ```swift
/// @State private var tabPresenter = TabPresenter(initialTab: AppTab.home)
///
/// var body: some View {
///     TabRouting(tabPresenter: tabPresenter, tabs: [.home, .search, .profile])
/// }
/// ```
public struct TabScopeModifier<Tab: Tabbable>: ViewModifier {
    @Environment private var tabPresenter: TabPresenter<Tab>
    private let tabs: [Tab]

    public init(tabs: [Tab]) {
        self.tabs = tabs
        self._tabPresenter = Environment(.tab(Tab.self))
    }

    public func body(content: Content) -> some View {
        @Bindable var binding = tabPresenter

        TabView(selection: $binding.selectedTab) {
            ForEach(tabs) { tab in
                SwiftUI.Tab(value: tab, role: tab.tabRole) {
                    tab.contentView
                        .tabRouting(tab: tab)
                } label: {
                    tab.tabLabel
                }
            }
        }
    }
}

/// A tab view whose tabs each arrive with their own routing already wired up.
///
/// It is built on the declarative `Tab(value:role:)` API, so Liquid Glass modifiers such as
/// `tabViewBottomAccessory(_:)`, `tabBarMinimizeBehavior(_:)`, `tabViewStyle(_:)`, and
/// `badge(_:)` can be chained straight onto it.
///
/// A flat set of tabs:
/// ```swift
/// struct ContentView: View {
///     @State private var tabPresenter = TabPresenter(initialTab: AppTab.home)
///
///     var body: some View {
///         TabRouting(tabPresenter: tabPresenter, tabs: [.home, .library, .insights, .me])
///             .tabBarMinimizeBehavior(.onScrollDown)
///             .tabViewBottomAccessory {
///                 InterventionAccessoryBar()
///             }
///     }
/// }
/// ```
///
/// Customising how each tab is drawn:
/// ```swift
/// TabRouting(tabPresenter: tabPresenter, tabs: AppTab.allCases) { tab in
///     switch tab {
///     case .home: HomeView().environment(\.navigationTheme, .light)
///     default:    tab.contentView
///     }
/// }
/// ```
///
/// The router, presenters, and navigation stack are added around whatever the builder returns,
/// so the closure only has to describe the tab's own view.
public struct TabRouting<Tab: Tabbable, Content: View>: View {
    @Bindable private var tabPresenter: TabPresenter<Tab>
    private let tabs: [Tab]
    private let content: (Tab) -> Content

    /// Creates a tab view with a custom builder for each tab's content.
    ///
    /// - Parameters:
    ///   - tabPresenter: Holds which tab is selected and each tab's router.
    ///   - tabs: The tabs to show, in bar order.
    ///   - content: Builds one tab's view. Routing is added around whatever it returns.
    public init(
        tabPresenter: TabPresenter<Tab>,
        tabs: [Tab],
        @ViewBuilder content: @escaping (Tab) -> Content
    ) {
        self.tabPresenter = tabPresenter
        self.tabs = tabs
        self.content = content
    }

    public var body: some View {
        TabView(selection: $tabPresenter.selectedTab) {
            ForEach(tabs) { tab in
                SwiftUI.Tab(value: tab, role: tab.tabRole) {
                    content(tab)
                        .tabRouting(tab: tab)
                } label: {
                    tab.tabLabel
                }
            }
        }
        .transformEnvironment(\.self) { environment in
            environment[tabPresenter: TabPresenterSpecifier<Tab>()] = tabPresenter
        }
    }
}

// MARK: - Convenience init (default content: tab.contentView)

public extension TabRouting {
    /// Creates a tab view that draws each tab with the view the tab itself declares.
    init(
        tabPresenter: TabPresenter<Tab>,
        tabs: [Tab]
    ) where Content == Tab.ContentView {
        self.tabPresenter = tabPresenter
        self.tabs = tabs
        self.content = { $0.contentView }
    }
}
