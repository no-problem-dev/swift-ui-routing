import SwiftUI

extension View {
    /// Applies the routing this tab's type declares.
    ///
    /// The route, sheet, alert, and cover types are read off the tab type, so nothing has to be
    /// named at the call site. `TabRouting` already does this for the tabs it builds.
    /// ```swift
    /// struct TodoListTab: Tabbable {
    ///     typealias Route = AppRoute
    ///     typealias Sheet = AppSheet
    ///     typealias Alert = AppAlert
    ///
    ///     var contentView: some View {
    ///         TodoListView()
    ///     }
    /// }
    ///
    /// // Routing comes from the tab's own type declarations.
    /// TodoListTab().contentView.tabRouting(tab: TodoListTab())
    /// ```
    ///
    /// - Parameter tab: The tab this view belongs to.
    public func tabRouting<Tab>(
        tab: Tab
    ) -> some View where Tab: Tabbable {
        modifier(
            TabRoutingModifier<Tab, Tab.Route, Tab.Sheet, Tab.Alert, Tab.FullScreen, Tab.CustomSheet>(
                tab: tab
            )
        )
    }
}
