import SwiftUI

// MARK: - Conditional Presentation Modifier

/// Attaches the alert modifier only when the alert type is not `Never`.
///
/// Lets the routing modifiers stay uniform while a screen that declares no alerts pays nothing
/// for the machinery.
struct AlertModifierIfNeeded<Alert: Alertable>: ViewModifier {
    @Bindable var presenter: AlertPresenter<Alert>

    func body(content: Content) -> some View {
        if Alert.self != Never.self {
            content.alert(
                presenter.presentedAlert?.title ?? "",
                isPresented: Binding(
                    get: { presenter.isPresented },
                    set: { presenter.isPresented = $0 }
                ),
                presenting: presenter.presentedAlert,
                actions: { alert in
                    ForEach(Array(alert.actions.enumerated()), id: \.offset) { _, action in
                        Button(role: action.role) {
                            action.action()
                        } label: {
                            Text(action.title)
                        }
                    }
                },
                message: { alert in
                    if let message = alert.message {
                        Text(message)
                    }
                }
            )
        } else {
            content
        }
    }
}

// MARK: - Context-Specific Modifiers

/// Shows alerts raised on the navigation layer.
///
/// Applied for you by `routingScope(for:alert:)`; reach for it directly only when you build the
/// navigation stack yourself.
public struct AlertOnNavigationModifier<Alert: Alertable>: ViewModifier {
    @Environment private var alertPresenter: AlertPresenter<Alert>

    public init() {
        self._alertPresenter = Environment(.alert(Alert.self, context: .navigation))
    }

    public func body(content: Content) -> some View {
        content.alert(
            alertPresenter.presentedAlert?.title ?? "",
            isPresented: Binding(
                get: { alertPresenter.isPresented },
                set: { alertPresenter.isPresented = $0 }
            ),
            presenting: alertPresenter.presentedAlert,
            actions: { alert in
                ForEach(Array(alert.actions.enumerated()), id: \.offset) { _, action in
                    Button(role: action.role) {
                        action.action()
                    } label: {
                        Text(action.title)
                    }
                }
            },
            message: { alert in
                if let message = alert.message {
                    Text(message)
                }
            }
        )
    }
}

/// Shows alerts raised from inside a sheet.
///
/// Nothing applies it for you: apply `sheetAlert(for:)` to the sheet's own content.
public struct AlertOnSheetModifier<Alert: Alertable>: ViewModifier {
    @Environment private var alertPresenter: AlertPresenter<Alert>

    public init() {
        self._alertPresenter = Environment(.alert(Alert.self, context: .sheet))
    }

    public func body(content: Content) -> some View {
        content.alert(
            alertPresenter.presentedAlert?.title ?? "",
            isPresented: Binding(
                get: { alertPresenter.isPresented },
                set: { alertPresenter.isPresented = $0 }
            ),
            presenting: alertPresenter.presentedAlert,
            actions: { alert in
                ForEach(Array(alert.actions.enumerated()), id: \.offset) { _, action in
                    Button(role: action.role) {
                        action.action()
                    } label: {
                        Text(action.title)
                    }
                }
            },
            message: { alert in
                if let message = alert.message {
                    Text(message)
                }
            }
        )
    }
}

public extension View {
    /// Enables alerts raised on the navigation layer for this view.
    ///
    /// `routingScope(for:alert:)` already does this. Call it directly only when you build the
    /// navigation stack yourself.
    ///
    /// ```swift
    /// // The usual way
    /// ContentView()
    ///     .routingScope(for: AppRoute.self, alert: AppAlert.self)
    ///
    /// // Building the stack yourself
    /// NavigationStack(path: $customPath) {
    ///     ContentView()
    ///         .routingAlert(for: AppAlert.self)
    /// }
    /// ```
    ///
    /// - Parameter for: The alert type to show.
    func routingAlert<Alert: Alertable>(for: Alert.Type) -> some View {
        modifier(AlertOnNavigationModifier<Alert>())
    }

    /// Enables alerts raised from inside a sheet for this view.
    ///
    /// Apply it to the sheet's content: alerts asked for there are invisible to the navigation
    /// layer's modifier.
    /// ```swift
    /// struct SettingsSheet: View {
    ///     @Environment(.alert(AppAlert.self, context: .sheet)) private var alertPresenter
    ///
    ///     var body: some View {
    ///         Form {
    ///             Button("Delete") {
    ///                 alertPresenter.present(.confirmDelete)
    ///             }
    ///         }
    ///         .sheetAlert(for: AppAlert.self)
    ///     }
    /// }
    /// ```
    ///
    /// - Parameter for: The alert type to show.
    func sheetAlert<Alert: Alertable>(for: Alert.Type) -> some View {
        modifier(AlertOnSheetModifier<Alert>())
    }
}
