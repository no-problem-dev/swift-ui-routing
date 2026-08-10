import SwiftUI

/// The environment lookup for a router of a given route type.
///
/// A view reads it as `@Environment(.router(Screen.self))`; the route type is what picks the
/// right router out of the environment.
/// ```swift
/// struct ContentView: View {
///     @Environment(.router(Screen.self)) private var router
///
///     var body: some View {
///         Button("Navigate") {
///             router.navigate(to: .detail)
///         }
///     }
/// }
/// ```
public struct RouterEnvironmentKey<Route: Routable> {
    fileprivate let specifier: RouterSpecifier<Route>
    fileprivate init() {
        self.specifier = RouterSpecifier<Route>()
    }
}

public extension RouterEnvironmentKey {
    /// Builds the environment lookup for routers of the given route type.
    ///
    /// - Parameter type: The route type whose router should be read.
    static func router(_ type: Route.Type) -> RouterEnvironmentKey<Route> {
        RouterEnvironmentKey<Route>()
    }
}

public extension Environment {
    init<Route: Routable>(_ key: RouterEnvironmentKey<Route>) where Value == Router<Route> {
        self.init(\.[router: key.specifier])
    }
}
