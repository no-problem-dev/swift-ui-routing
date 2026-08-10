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
/// // 2. Create the presenter and inject it into the environment.
/// ContentView()
///     .routing(
///         router: Router<Screen>(),
///         sheetPresenter: SheetPresenter<Sheet>(),
///         alertPresenterOnNavigation: AlertPresenter<Alert>(),
///         alertPresenterOnSheet: AlertPresenter<Alert>()
///     )
///
/// // 3. Attach the sheet modifier.
/// var body: some View {
///     @Bindable var sheet = sheetPresenter
///
///     MainView()
///         .sheet(item: $sheet.presentedSheet) { sheet in
///             sheet.body
///         }
/// }
///
/// // 4. Present a sheet.
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

    public init() {}

    /// Puts a sheet up.
    public func present(_ sheet: Sheet) {
        presentedSheet = sheet
    }

    /// Takes the current sheet down.
    public func dismiss() {
        presentedSheet = nil
    }
}
