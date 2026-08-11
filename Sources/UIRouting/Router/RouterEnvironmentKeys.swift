import SwiftUI

extension Router {
    @MainActor
    static func createDefault() -> Router<Route> {
        Router<Route>()
    }
}

struct GenericRouterKey<Route: Routable>: EnvironmentKey {
    static var defaultValue: Router<Route> {
        MainActor.assumeIsolated {
            DefaultPresenterStore.instance(for: Self.self) { Router<Route>.createDefault() }
        }
    }
}
