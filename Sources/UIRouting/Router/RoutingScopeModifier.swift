import SwiftUI

/// Binds an injected router to a navigation stack and wires alerts into every screen on it.
///
/// The router comes from the environment, so one of the `routing(...)` methods must have run
/// above this view.
///
/// Apply it through `routingScope(for:alert:)`.
/// ```swift
/// ContentView()
///     .routingScope(for: Screen.self, alert: Alert.self)
/// ```
public struct RoutingScopeModifier<Route: Routable, Alert: Alertable>: ViewModifier {
    @Environment private var router: Router<Route>

    public init() {
        self._router = Environment(.router(Route.self))
    }

    public func body(content: Content) -> some View {
        @Bindable var routerBinding = router

        NavigationStack(path: $routerBinding.path) {
            content
                .routingAlert(for: Alert.self)
                .navigationDestination(for: Route.self) { route in
                    route.body
                        .routingAlert(for: Alert.self)
                }
        }
    }
}

public extension View {
    /// Wraps the view in a navigation stack driven by the router already in the environment.
    ///
    /// Every screen it pushes gets the alert modifier applied, so an alert raised deep in the
    /// stack still appears.
    /// ```swift
    /// struct RootView: View {
    ///     var body: some View {
    ///         HomeView()
    ///             .routingScope(for: AppRoute.self, alert: AppAlert.self)
    ///     }
    /// }
    /// ```
    ///
    /// - Parameters:
    ///   - for: The route type this stack navigates.
    ///   - alert: The alert type wired into each screen.
    func routingScope<Route: Routable, Alert: Alertable>(for: Route.Type, alert: Alert.Type) -> some View {
        modifier(RoutingScopeModifier<Route, Alert>())
    }
}
