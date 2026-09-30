import SwiftUI

/// Presents modal sheets of one type.
///
/// It holds at most one sheet, so presenting a second one replaces the first rather than
/// stacking on top of it.
///
/// ```swift
/// // 1. Define the sheets.
/// enum Sheet: Identifiable, Hashable {
///     case settings
///     case profile(userId: String)
///
///     var id: String {
///         switch self {
///         case .settings: return "settings"
///         case .profile(let userId): return "profile_\(userId)"
///         }
///     }
///
///     @ViewBuilder
///     var body: some View {
///         switch self {
///         case .settings: SettingsView()
///         case .profile(let userId): ProfileView(userId: userId)
///         }
///     }
/// }
///
/// // 2. Create the presenter and inject it. `routing(...)` also attaches the sheet, so
/// //    there is no `.sheet(item:)` to write.
/// ContentView()
///     .routing(
///         router: Router<Screen>(),
///         sheetPresenter: SheetPresenter<Sheet>(),
///         alertPresenterOnNavigation: AlertPresenter<Alert>(),
///         alertPresenterOnSheet: AlertPresenter<Alert>()
///     )
///
/// // 3. Present a sheet.
/// struct MainView: View {
///     @Environment(.sheet(Sheet.self)) private var sheetPresenter
///
///     var body: some View {
///         Button("Settings") {
///             sheetPresenter.present(.settings)
///         }
///     }
/// }
/// ```
@MainActor
@Observable
public final class SheetPresenter<Sheet> where Sheet: Sheetable {
    /// The sheet currently up, or `nil` when none is.
    public var presentedSheet: Sheet?

    /// Creates an empty one.
    ///
    /// It is `nonisolated` so that `@State private var x = ...()` in a generic view can create
    /// it: the `@State` macro evaluates that initial value outside the main actor.
    nonisolated public init() {}

    /// Puts a sheet up.
    public func present(_ sheet: Sheet) {
        presentedSheet = sheet
    }

    /// Takes the current sheet down.
    public func dismiss() {
        presentedSheet = nil
    }
}
