import SwiftUI

/// Creates a navigation stack together with the router that drives it.
///
/// It owns the router, so nothing has to be injected first. Reach for it when a screen needs
/// navigation but no alerts.
///
/// Apply it through `routerScope(for:)`.
/// ```swift
/// ContentView()
///     .routerScope(for: AppRoute.self)
/// ```
struct RouterScopeModifier<Route: Routable>: ViewModifier {
    @State private var router = Router<Route>()

    func body(content: Content) -> some View {
        @Bindable var bindableRouter = router

        NavigationStack(path: $bindableRouter.path) {
            content
                .navigationDestination(for: Route.self) { route in
                    route.body
                }
        }
        .transformEnvironment(\.self) { env in
            env[router: RouterSpecifier<Route>()] = router
        }
    }
}

public extension View {
    /// Wraps the view in a navigation stack whose router it creates and owns.
    ///
    /// It builds the router, holds it in `@State`, binds it to the stack, registers the
    /// destinations, and publishes it to the environment. Unlike `routingScope(for:alert:)`
    /// it needs no alert type.
    /// ```swift
    /// struct RootView: View {
    ///     var body: some View {
    ///         HomeView()
    ///             .routerScope(for: AppRoute.self)
    ///             .sheetPresenter(for: AppSheet.self)
    ///     }
    /// }
    /// ```
    ///
    /// - Parameter type: The route type this stack navigates.
    func routerScope<Route: Routable>(for type: Route.Type) -> some View {
        modifier(RouterScopeModifier<Route>())
    }
}
