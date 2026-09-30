import SwiftUI

/// Presents sheets that open at heights the sheet itself declares.
///
/// The detents travel with the presented value, so each case can rest at a different height
/// without the call site knowing anything about it.
///
/// ```swift
/// // 1. Define the sheets and their detents.
/// enum AppCustomHeightSheet: CustomHeightSheetable {
///     case filter
///     case quickSettings
///
///     var detents: Set<PresentationDetent> {
///         switch self {
///         case .filter: return [.medium, .large]
///         case .quickSettings: return [.height(200), .medium]
///         }
///     }
///
///     @ViewBuilder
///     var body: some View {
///         switch self {
///         case .filter: FilterView()
///         case .quickSettings: QuickSettingsView()
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
///         customHeightSheetPresenter: CustomHeightSheetPresenter<CustomHeightSheet>(),
///         fullScreenCoverPresenter: FullScreenCoverPresenter<FullScreenCover>(),
///         alertPresenterOnNavigation: AlertPresenter<Alert>(),
///         alertPresenterOnSheet: AlertPresenter<Alert>(),
///         splitViewPresenter: SplitViewPresenter<Never>()
///     )
///
/// // 3. Present one.
/// struct MainView: View {
///     @Environment(.customHeightSheet(CustomHeightSheet.self)) private var customHeightSheetPresenter
///
///     var body: some View {
///         Button("Show filter") {
///             customHeightSheetPresenter.present(.filter)
///         }
///     }
/// }
/// ```
@MainActor
@Observable
public final class CustomHeightSheetPresenter<Sheet> where Sheet: CustomHeightSheetable {
    /// The sheet currently up, or `nil` when none is.
    public var presentedSheet: Sheet?

    /// Creates an empty one.
    ///
    /// It is `nonisolated` so that `@State private var x = ...()` in a generic view can create
    /// it: the `@State` macro evaluates that initial value outside the main actor.
    nonisolated public init() {}

    /// Puts a sheet up at the detents it declares.
    public func present(_ sheet: Sheet) {
        presentedSheet = sheet
    }

    /// Takes the current sheet down.
    public func dismiss() {
        presentedSheet = nil
    }
}
