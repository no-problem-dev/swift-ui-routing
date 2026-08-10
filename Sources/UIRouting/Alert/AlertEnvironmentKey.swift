import SwiftUI

/// The environment lookup for an alert presenter of a given alert type and layer.
///
/// The layer matters: a view inside a sheet must read `context: .sheet`, or its alert goes to a
/// presenter nothing is listening to.
/// ```swift
/// struct ContentView: View {
///     @Environment(.alert(AppAlert.self, context: .navigation)) private var alertPresenter
///
///     var body: some View {
///         Button("Show Alert") {
///             alertPresenter.present(.error(message: "Something went wrong"))
///         }
///     }
/// }
/// ```
public struct AlertEnvironmentKey<Alert: Alertable> {
    fileprivate let specifier: AlertPresenterSpecifier<Alert>
    fileprivate init(context: PresentationContext) {
        self.specifier = AlertPresenterSpecifier<Alert>(context: context)
    }
}

public extension AlertEnvironmentKey {
    /// Builds the environment lookup for alert presenters of the given type.
    ///
    /// - Parameters:
    ///   - type: The alert type whose presenter should be read.
    ///   - context: The layer the alert is raised from.
    static func alert(_ type: Alert.Type, context: PresentationContext) -> AlertEnvironmentKey<Alert> {
        AlertEnvironmentKey<Alert>(context: context)
    }
}

public extension Environment {
    init<Alert: Alertable>(_ key: AlertEnvironmentKey<Alert>) where Value == AlertPresenter<Alert> {
        self.init(\.[alertPresenter: key.specifier])
    }
}
