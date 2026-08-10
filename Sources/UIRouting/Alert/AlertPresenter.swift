import SwiftUI

/// Raises alerts of one type.
///
/// The navigation layer and the sheet layer each get their own instance, which is why an alert
/// asked for from inside a sheet still shows.
///
/// ```swift
/// // 1. Create the presenters and inject them into the environment.
/// ContentView()
///     .routing(
///         router: Router<Screen>(),
///         sheetPresenter: SheetPresenter<Sheet>(),
///         alertPresenterOnNavigation: AlertPresenter<Alert>(),
///         alertPresenterOnSheet: AlertPresenter<Alert>()
///     )
///
/// // 2. Apply routingAlert(for:) or sheetAlert(for:).
/// var body: some View {
///     MainView()
///         .routingAlert(for: Alert.self)
/// }
///
/// // 3. Present an alert.
/// struct MainView: View {
///     @Environment(.alert(Alert.self, context: .navigation)) private var alertPresenter
///
///     var body: some View {
///         Button("Delete") {
///             alertPresenter.present(.delete(
///                 itemName: "Item",
///                 onConfirm: { /* delete it */ }
///             ))
///         }
///     }
/// }
/// ```
@MainActor
@Observable
public final class AlertPresenter<Alert: Alertable> {
    /// The alert currently on screen, or `nil` when none is.
    public var presentedAlert: Alert?

    /// Whether an alert is on screen. SwiftUI writes back to it when the user dismisses one.
    public var isPresented: Bool = false

    public init() {}

    /// Puts an alert on screen, replacing any that is already there.
    public func present(_ alert: Alert) {
        presentedAlert = alert
        isPresented = true
    }

    /// Takes the current alert off screen.
    public func dismiss() {
        isPresented = false
        presentedAlert = nil
    }
}
