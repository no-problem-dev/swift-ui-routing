import SwiftUI

/// Outside a `TabRouting` there is no tab presenter, and the lookup says so with `nil`.
///
/// A tab presenter cannot be made up as a fallback the way a router can: it needs a tab to start
/// on, and a presenter that no `TabView` is bound to would take `select(_:)` calls and switch
/// nothing. Previews and components shared between tabbed and untabbed screens read `nil` instead
/// of stopping the app.
struct GenericTabPresenterKey<Tab: Tabbable>: EnvironmentKey {
    static var defaultValue: TabPresenter<Tab>? { nil }
}
