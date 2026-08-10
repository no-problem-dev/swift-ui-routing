import SwiftUI

/// Gives a split view's detail column its presenters and alert handling.
///
/// The router comes from the environment, since the split view owns it, while the presenters
/// are created here so each detail column has its own sheets and alerts.
///
/// Apply it through `splitViewRouting(for:)`.
public struct SplitViewRoutingModifier<
    Sidebar: SidebarItem,
    Route: Routable,
    Sheet: Sheetable,
    Alert: Alertable,
    FullScreen: FullScreenCoverable,
    CustomSheet: CustomHeightSheetable
>: ViewModifier where Sidebar.DetailRoute == Route {

    @Environment private var splitViewPresenter: SplitViewPresenter<Sidebar>
    @Environment private var router: Router<Route>

    // Presenters owned here; the router comes from the environment.
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
            // Publish them, passing the environment's router straight through.
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
            // Alerts.
            .modifier(AlertModifierIfNeeded(presenter: alertPresenterOnNavigation))
    }
}
