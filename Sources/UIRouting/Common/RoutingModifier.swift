import SwiftUI

/// Puts a router and every presenter into the environment of the views below it, and attaches
/// the sheet, full-screen cover, and custom-height sheet that those presenters drive.
///
/// Publishing a presenter and attaching the modal it drives are one step here: a presenter in the
/// environment with nothing bound to it takes `present(_:)` calls and shows nothing. A slot typed
/// `Never` attaches nothing.
///
/// Apply it through one of the `routing(...)` methods rather than constructing it directly.
public struct RoutingModifier<
    Route: Routable,
    Sheet,
    CustomHeightSheet,
    FullScreenCover,
    Alert: Alertable,
    Sidebar: SidebarItem
>: ViewModifier
    where
    Sheet: Sheetable,
    CustomHeightSheet: CustomHeightSheetable,
    FullScreenCover: FullScreenCoverable
{
    private let router: Router<Route>
    private let sheetPresenter: SheetPresenter<Sheet>
    private let customHeightSheetPresenter: CustomHeightSheetPresenter<CustomHeightSheet>
    private let fullScreenCoverPresenter: FullScreenCoverPresenter<FullScreenCover>
    private let alertPresenterOnNavigation: AlertPresenter<Alert>
    private let alertPresenterOnSheet: AlertPresenter<Alert>
    private let splitViewPresenter: SplitViewPresenter<Sidebar>

    public init(
        router: Router<Route>,
        sheetPresenter: SheetPresenter<Sheet>,
        customHeightSheetPresenter: CustomHeightSheetPresenter<CustomHeightSheet>,
        fullScreenCoverPresenter: FullScreenCoverPresenter<FullScreenCover>,
        alertPresenterOnNavigation: AlertPresenter<Alert>,
        alertPresenterOnSheet: AlertPresenter<Alert>,
        splitViewPresenter: SplitViewPresenter<Sidebar>
    ) {
        self.router = router
        self.sheetPresenter = sheetPresenter
        self.customHeightSheetPresenter = customHeightSheetPresenter
        self.fullScreenCoverPresenter = fullScreenCoverPresenter
        self.alertPresenterOnNavigation = alertPresenterOnNavigation
        self.alertPresenterOnSheet = alertPresenterOnSheet
        self.splitViewPresenter = splitViewPresenter
    }

    public func body(content: Content) -> some View {
        content
            // Attached below the environment injection, so the presented views see every
            // presenter and the router too.
            .modifier(SheetModifierIfNeeded(presenter: sheetPresenter))
            .modifier(FullScreenCoverModifierIfNeeded(presenter: fullScreenCoverPresenter))
            .modifier(CustomHeightSheetModifierIfNeeded(presenter: customHeightSheetPresenter))
            .transformEnvironment(\.self) { environment in
                environment[router: RouterSpecifier<Route>()] = router
                environment[sheetPresenter: SheetPresenterSpecifier<Sheet>()] = sheetPresenter
                environment[customHeightSheetPresenter: CustomHeightSheetPresenterSpecifier<CustomHeightSheet>()] = customHeightSheetPresenter
                environment[fullScreenCoverPresenter: FullScreenCoverPresenterSpecifier<FullScreenCover>()] = fullScreenCoverPresenter
                environment[alertPresenter: AlertPresenterSpecifier<Alert>(context: .navigation)] = alertPresenterOnNavigation
                environment[alertPresenter: AlertPresenterSpecifier<Alert>(context: .sheet)] = alertPresenterOnSheet
                environment[splitViewPresenter: SplitViewPresenterSpecifier<Sidebar>()] = splitViewPresenter
            }
    }
}

public extension View {
    /// Injects a router and every presenter into the environment, and attaches the sheet,
    /// full-screen cover, and custom-height sheet they drive.
    ///
    /// Do not attach `.sheet(item:)` or `.fullScreenCover(item:)` for these presenters yourself;
    /// this already does, and a second one would present the same value twice. Alerts are wired
    /// by `routingScope(for:alert:)` instead, because they must sit on every pushed screen.
    ///
    /// Use this overload when a screen needs the full set; the shorter one covers navigation,
    /// sheets, and alerts only.
    /// ```swift
    /// @State private var router = Router<AppRoute>()
    /// @State private var sheetPresenter = SheetPresenter<AppSheet>()
    /// @State private var alertPresenter = AlertPresenter<AppAlert>()
    ///
    /// ContentView()
    ///     .routing(
    ///         router: router,
    ///         sheetPresenter: sheetPresenter,
    ///         customHeightSheetPresenter: CustomHeightSheetPresenter<AppCustomSheet>(),
    ///         fullScreenCoverPresenter: FullScreenCoverPresenter<AppCover>(),
    ///         alertPresenterOnNavigation: alertPresenter,
    ///         alertPresenterOnSheet: AlertPresenter<AppAlert>(),
    ///         splitViewPresenter: SplitViewPresenter<Never>()
    ///     )
    /// ```
    ///
    /// - Parameters:
    ///   - router: The navigation stack's router.
    ///   - sheetPresenter: The presenter for sheets.
    ///   - customHeightSheetPresenter: The presenter for sheets with explicit detents.
    ///   - fullScreenCoverPresenter: The presenter for full-screen covers.
    ///   - alertPresenterOnNavigation: The presenter for alerts raised from the navigation layer.
    ///   - alertPresenterOnSheet: The presenter for alerts raised from inside a sheet.
    ///   - splitViewPresenter: The presenter for split-view selection.
    func routing<Route: Routable, Sheet, CustomHeightSheet, FullScreenCover, Alert: Alertable, Sidebar: SidebarItem>(
        router: Router<Route>,
        sheetPresenter: SheetPresenter<Sheet>,
        customHeightSheetPresenter: CustomHeightSheetPresenter<CustomHeightSheet>,
        fullScreenCoverPresenter: FullScreenCoverPresenter<FullScreenCover>,
        alertPresenterOnNavigation: AlertPresenter<Alert>,
        alertPresenterOnSheet: AlertPresenter<Alert>,
        splitViewPresenter: SplitViewPresenter<Sidebar>
    ) -> some View
        where
        Sheet: Sheetable,
        CustomHeightSheet: CustomHeightSheetable,
        FullScreenCover: FullScreenCoverable
    {
        modifier(RoutingModifier(
            router: router,
            sheetPresenter: sheetPresenter,
            customHeightSheetPresenter: customHeightSheetPresenter,
            fullScreenCoverPresenter: fullScreenCoverPresenter,
            alertPresenterOnNavigation: alertPresenterOnNavigation,
            alertPresenterOnSheet: alertPresenterOnSheet,
            splitViewPresenter: splitViewPresenter
        ))
    }

    /// Injects a router, a sheet presenter, and both alert presenters into the environment, and
    /// attaches the sheet the sheet presenter drives.
    ///
    /// Full-screen covers, custom-height sheets, and split views are filled in with `Never`,
    /// so reaching for any of them later means switching to the full overload.
    /// ```swift
    /// @State private var router = Router<AppRoute>()
    /// @State private var sheetPresenter = SheetPresenter<AppSheet>()
    /// @State private var alertPresenter = AlertPresenter<AppAlert>()
    ///
    /// ContentView()
    ///     .routing(
    ///         router: router,
    ///         sheetPresenter: sheetPresenter,
    ///         alertPresenterOnNavigation: alertPresenter,
    ///         alertPresenterOnSheet: AlertPresenter<AppAlert>()
    ///     )
    /// ```
    ///
    /// - Parameters:
    ///   - router: The navigation stack's router.
    ///   - sheetPresenter: The presenter for sheets.
    ///   - alertPresenterOnNavigation: The presenter for alerts raised from the navigation layer.
    ///   - alertPresenterOnSheet: The presenter for alerts raised from inside a sheet.
    func routing<Route: Routable, Sheet, Alert: Alertable>(
        router: Router<Route>,
        sheetPresenter: SheetPresenter<Sheet>,
        alertPresenterOnNavigation: AlertPresenter<Alert>,
        alertPresenterOnSheet: AlertPresenter<Alert>
    ) -> some View where Sheet: Sheetable {
        routing(
            router: router,
            sheetPresenter: sheetPresenter,
            customHeightSheetPresenter: CustomHeightSheetPresenter<Never>(),
            fullScreenCoverPresenter: FullScreenCoverPresenter<Never>(),
            alertPresenterOnNavigation: alertPresenterOnNavigation,
            alertPresenterOnSheet: alertPresenterOnSheet,
            splitViewPresenter: SplitViewPresenter<Never>()
        )
    }
}
