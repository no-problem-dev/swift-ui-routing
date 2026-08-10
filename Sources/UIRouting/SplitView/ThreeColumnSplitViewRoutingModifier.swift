import SwiftUI

/// Gives the middle column of a three-column split view its presenters and alert handling.
///
/// It routes with `ContentRoute`, so pushes stay inside the middle column instead of taking
/// over the detail column.
///
/// Apply it through `threeColumnContentRouting(for:)`.
public struct ThreeColumnContentRoutingModifier<
    Sidebar: SidebarItem,
    Route: Routable,
    Sheet: Sheetable,
    Alert: Alertable,
    FullScreen: FullScreenCoverable,
    CustomSheet: CustomHeightSheetable
>: ViewModifier where Sidebar.ContentRoute == Route {

    @Environment private var splitViewPresenter: SplitViewPresenter<Sidebar>
    @Environment private var router: Router<Route>

    // Presenters owned by this scope.
    @State private var sheetPresenter = SheetPresenter<Sheet>()
    @State private var alertPresenterOnNavigation = AlertPresenter<Alert>()
    @State private var alertPresenterOnSheet = AlertPresenter<Alert>()
    @State private var fullScreenCoverPresenter = FullScreenCoverPresenter<FullScreen>()
    @State private var customHeightSheetPresenter = CustomHeightSheetPresenter<CustomSheet>()

    public init() {
        self._splitViewPresenter = Environment(.splitView(Sidebar.self))
        self._router = Environment(.router(Route.self))
    }

    public func body(content: Content) -> some View {
        content
            // Publish them to the environment.
            .routing(
                router: router,
                sheetPresenter: sheetPresenter,
                customHeightSheetPresenter: customHeightSheetPresenter,
                fullScreenCoverPresenter: fullScreenCoverPresenter,
                alertPresenterOnNavigation: alertPresenterOnNavigation,
                alertPresenterOnSheet: alertPresenterOnSheet,
                splitViewPresenter: splitViewPresenter
            )
            // Sheets.
            .modifier(SheetModifierIfNeeded(presenter: sheetPresenter))
            // Full-screen covers.
            .modifier(FullScreenCoverModifierIfNeeded(presenter: fullScreenCoverPresenter))
            // Custom-height sheets.
            .modifier(CustomHeightSheetModifierIfNeeded(presenter: customHeightSheetPresenter))
            // Alerts.
            .modifier(AlertModifierIfNeeded(presenter: alertPresenterOnNavigation))
    }
}

/// Gives the detail column of a three-column split view its presenters and alert handling.
///
/// It routes with `DetailRoute`, keeping its stack separate from the middle column's.
///
/// Apply it through `threeColumnDetailRouting(for:)`.
public struct ThreeColumnDetailRoutingModifier<
    Sidebar: SidebarItem,
    Route: Routable,
    Sheet: Sheetable,
    Alert: Alertable,
    FullScreen: FullScreenCoverable,
    CustomSheet: CustomHeightSheetable
>: ViewModifier where Sidebar.DetailRoute == Route {

    @Environment private var splitViewPresenter: SplitViewPresenter<Sidebar>
    @Environment private var router: Router<Route>

    // Presenters owned by this scope.
    @State private var sheetPresenter = SheetPresenter<Sheet>()
    @State private var alertPresenterOnNavigation = AlertPresenter<Alert>()
    @State private var alertPresenterOnSheet = AlertPresenter<Alert>()
    @State private var fullScreenCoverPresenter = FullScreenCoverPresenter<FullScreen>()
    @State private var customHeightSheetPresenter = CustomHeightSheetPresenter<CustomSheet>()

    public init() {
        self._splitViewPresenter = Environment(.splitView(Sidebar.self))
        self._router = Environment(.router(Route.self))
    }

    public func body(content: Content) -> some View {
        content
            // Publish them to the environment.
            .routing(
                router: router,
                sheetPresenter: sheetPresenter,
                customHeightSheetPresenter: customHeightSheetPresenter,
                fullScreenCoverPresenter: fullScreenCoverPresenter,
                alertPresenterOnNavigation: alertPresenterOnNavigation,
                alertPresenterOnSheet: alertPresenterOnSheet,
                splitViewPresenter: splitViewPresenter
            )
            // Sheets.
            .modifier(SheetModifierIfNeeded(presenter: sheetPresenter))
            // Full-screen covers.
            .modifier(FullScreenCoverModifierIfNeeded(presenter: fullScreenCoverPresenter))
            // Custom-height sheets.
            .modifier(CustomHeightSheetModifierIfNeeded(presenter: customHeightSheetPresenter))
            // Alerts.
            .modifier(AlertModifierIfNeeded(presenter: alertPresenterOnNavigation))
    }
}
