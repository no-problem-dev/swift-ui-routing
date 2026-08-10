import SwiftUI

/// Gives one tab its own router, presenters, and navigation stack.
///
/// Every tab gets a fresh set, which is what keeps one tab's stack and sheets out of another's.
///
/// Apply it through `tabRouting(tab:)`.
public struct TabRoutingModifier<
    Tab: Tabbable,
    Route: Routable,
    Sheet: Sheetable,
    Alert: Alertable,
    FullScreen: FullScreenCoverable,
    CustomSheet: CustomHeightSheetable
>: ViewModifier where Tab.Route == Route {

    @Environment private var tabPresenter: TabPresenter<Tab>

    private let currentTab: Tab

    // Presenters owned by this scope.
    @State private var router = Router<Route>()
    @State private var sheetPresenter = SheetPresenter<Sheet>()
    @State private var alertPresenterOnNavigation = AlertPresenter<Alert>()
    @State private var alertPresenterOnSheet = AlertPresenter<Alert>()
    @State private var fullScreenCoverPresenter = FullScreenCoverPresenter<FullScreen>()
    @State private var customHeightSheetPresenter = CustomHeightSheetPresenter<CustomSheet>()

    public init(tab: Tab) {
        self.currentTab = tab
        self._tabPresenter = Environment(.tab(Tab.self))
    }

    public func body(content: Content) -> some View {
        content
            // A navigation stack, but only if this tab declares routes.
            .modifier(NavigationScopeModifierIfNeeded<Tab, Route, Alert>(tab: currentTab))
            // Publish everything to the environment.
            .routing(
                router: router,
                sheetPresenter: sheetPresenter,
                customHeightSheetPresenter: customHeightSheetPresenter,
                fullScreenCoverPresenter: fullScreenCoverPresenter,
                alertPresenterOnNavigation: alertPresenterOnNavigation,
                alertPresenterOnSheet: alertPresenterOnSheet,
                splitViewPresenter: SplitViewPresenter<Never>()
            )
            // Sheets.
            .modifier(SheetModifierIfNeeded(presenter: sheetPresenter))
            // Full-screen covers.
            .modifier(FullScreenCoverModifierIfNeeded(presenter: fullScreenCoverPresenter))
            // Custom-height sheets.
            .modifier(CustomHeightSheetModifierIfNeeded(presenter: customHeightSheetPresenter))
            // Let the presenter reach this tab's router from anywhere else.
            .onAppear {
                tabPresenter.registerRouter(router, for: currentTab)
            }
    }
}

// MARK: - Conditional Modifiers

/// Wraps a tab in a navigation stack only when it declares a route type.
///
/// A tab with no routes stays a plain view, so it gets no navigation bar it never asked for.
private struct NavigationScopeModifierIfNeeded<
    Tab: Tabbable,
    Route: Routable,
    Alert: Alertable
>: ViewModifier where Tab.Route == Route {
    let tab: Tab

    func body(content: Content) -> some View {
        if Tab.Route.self != Never.self {
            content.routingScope(for: Route.self, alert: Alert.self)
        } else {
            content
        }
    }
}
