import SwiftUI

/// The environment lookup for a tab presenter of a given tab type.
///
/// Reading it is how a view deep inside one tab switches to another.
/// ```swift
/// struct ContentView: View {
///     @Environment(.tab(AppTab.self)) private var tabPresenter
///
///     var body: some View {
///         Button("Switch Tab") {
///             tabPresenter.select(.settings)
///         }
///     }
/// }
/// ```
public struct TabEnvironmentKey<Tab: Tabbable> {
    fileprivate let specifier: TabPresenterSpecifier<Tab>
    fileprivate init() {
        self.specifier = TabPresenterSpecifier<Tab>()
    }
}

public extension TabEnvironmentKey {
    /// Builds the environment lookup for tab presenters of the given tab type.
    ///
    /// - Parameter type: The tab type whose presenter should be read.
    static func tab(_ type: Tab.Type) -> TabEnvironmentKey<Tab> {
        TabEnvironmentKey<Tab>()
    }
}

public extension Environment {
    init<Tab: Tabbable>(_ key: TabEnvironmentKey<Tab>) where Value == TabPresenter<Tab> {
        self.init(\.[tabPresenter: key.specifier])
    }
}
