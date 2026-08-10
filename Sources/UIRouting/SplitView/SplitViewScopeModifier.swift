import SwiftUI

/// Binds an injected split-view presenter to a navigation split view and wires alerts in.
///
/// Everything it uses comes from the environment, so one of the `routing(...)` methods must have
/// run above it.
///
/// Apply it through `splitViewScope(for:items:sheet:alert:)`.
/// ```swift
/// ContentView()
///     .splitViewScope(
///         for: AppSidebar.self,
///         items: [.inbox, .sent, .archive],
///         alert: AppAlert.self
///     )
/// ```
public struct SplitViewScopeModifier<Sidebar: SidebarItem, Sheet: Sheetable, Alert: Alertable>: ViewModifier {
    @Environment private var splitViewPresenter: SplitViewPresenter<Sidebar>
    @Environment private var router: Router<Sidebar.DetailRoute>
    @Environment private var sheetPresenter: SheetPresenter<Sheet>

    private let sidebarItems: [Sidebar]

    public init(sidebarItems: [Sidebar]) {
        self.sidebarItems = sidebarItems
        self._splitViewPresenter = Environment(.splitView(Sidebar.self))
        self._router = Environment(.router(Sidebar.DetailRoute.self))
        self._sheetPresenter = Environment(.sheet(Sheet.self))
    }

    public func body(content: Content) -> some View {
        @Bindable var presenterBinding = splitViewPresenter
        @Bindable var sheetBinding = sheetPresenter

        NavigationSplitView {
            // Sidebar column.
            List(sidebarItems, selection: $presenterBinding.selectedSidebar) { item in
                NavigationLink(value: item) {
                    item.label
                }
            }
            .navigationTitle("サイドバー")
        } detail: {
            // Detail column.
            if let selected = splitViewPresenter.selectedSidebar {
                // Routed detail: wrap it in a navigation stack.
                if Sidebar.DetailRoute.self != Never.self {
                    @Bindable var routerBinding = router

                    NavigationStack(path: $routerBinding.path) {
                        selected.detail
                            .routingAlert(for: Alert.self)
                            .navigationDestination(for: Sidebar.DetailRoute.self) { route in
                                route.body
                                    .routingAlert(for: Alert.self)
                            }
                    }
                } else {
                    selected.detail
                        .routingAlert(for: Alert.self)
                }
            } else {
                // Nothing selected: fall back to the view this was applied to.
                content
                    .routingAlert(for: Alert.self)
            }
        }
        .modifier(SheetModifierIfNeeded(presenter: sheetBinding))
    }
}

public extension View {
    /// Wraps the view in a navigation split view driven by the presenter in the environment.
    ///
    /// The view it is applied to becomes the detail column's empty state. Each detail view gets
    /// the alert modifier, plus a navigation stack when the sidebar declares a detail route.
    /// ```swift
    /// struct RootView: View {
    ///     var body: some View {
    ///         Text("Select an item from the sidebar")
    ///             .splitViewScope(
    ///                 for: AppSidebar.self,
    ///                 items: [.inbox, .sent, .archive],
    ///                 alert: AppAlert.self
    ///             )
    ///     }
    /// }
    /// ```
    ///
    /// - Parameters:
    ///   - type: The sidebar type whose routing types should be used.
    ///   - items: The rows of the sidebar, in order.
    ///   - sheet: The sheet type to wire in, or `Never` for none.
    ///   - alert: The alert type wired into each detail view.
    func splitViewScope<Sidebar: SidebarItem, Sheet: Sheetable, Alert: Alertable>(
        for type: Sidebar.Type,
        items: [Sidebar],
        sheet: Sheet.Type = Never.self,
        alert: Alert.Type
    ) -> some View {
        modifier(SplitViewScopeModifier<Sidebar, Sheet, Alert>(sidebarItems: items))
    }
}
