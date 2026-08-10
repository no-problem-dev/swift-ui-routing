import SwiftUI

/// Owns the path of one navigation stack.
///
/// One router drives one stack, so a tab-based or split-view app has several; each is reached
/// from the environment by the route type it carries.
///
/// ```swift
/// // 1. Define the destinations.
/// enum Screen: Routable {
///     case profile(userId: String)
///     case settings
///
///     var id: String {
///         switch self {
///         case .profile(let userId): return "profile_\(userId)"
///         case .settings: return "settings"
///         }
///     }
///
///     @ViewBuilder
///     var body: some View {
///         switch self {
///         case .profile(let userId): ProfileView(userId: userId)
///         case .settings: SettingsView()
///         }
///     }
/// }
///
/// // 2. Create the router and inject it into the environment.
/// ContentView()
///     .routing(
///         router: Router<Screen>(),
///         sheetPresenter: SheetPresenter<Sheet>(),
///         alertPresenterOnNavigation: AlertPresenter<Alert>(),
///         alertPresenterOnSheet: AlertPresenter<Alert>()
///     )
///
/// // 3. Set up the navigation stack.
/// var body: some View {
///     HomeView()
///         .routingScope(for: Screen.self, alert: Alert.self)
/// }
///
/// // 4. Navigate.
/// struct HomeView: View {
///     @Environment(.router(Screen.self)) private var router
///
///     var body: some View {
///         Button("Show profile") {
///             router.navigate(to: .profile(userId: "123"))
///         }
///     }
/// }
/// ```
@MainActor
@Observable
public final class Router<Route: Routable> {
    /// The destinations pushed onto the stack, in order.
    public var path: [Route] = []

    public init() {}

    /// Pushes a destination onto the stack.
    public func navigate(to route: Route) {
        path.append(route)
    }

    /// Pops the top destination, doing nothing at the root.
    public func back() {
        guard !path.isEmpty else { return }
        path.removeLast()
    }

    /// Pops everything at once, returning to the root.
    public func popToRoot() {
        path.removeAll()
    }

    /// Replaces the top destination, or pushes it when the stack is empty.
    public func replace(with route: Route) {
        if path.isEmpty {
            path.append(route)
        } else {
            path[path.count - 1] = route
        }
    }
}
