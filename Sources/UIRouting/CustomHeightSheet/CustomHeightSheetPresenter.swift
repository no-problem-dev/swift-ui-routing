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
/// // 2. Create the presenter and inject it into the environment.
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
/// // 3. Attach a sheet modifier that applies the detents.
/// var body: some View {
///     MainView()
///         .sheet(item: Binding(
///             get: { customHeightSheetPresenter?.presentedSheet },
///             set: { customHeightSheetPresenter?.presentedSheet = $0 }
///         )) { sheet in
///             sheet.body
///                 .presentationDetents(sheet.detents)
///         }
/// }
///
/// // 4. Present one.
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

    public init() {}

    /// Puts a sheet up at the detents it declares.
    public func present(_ sheet: Sheet) {
        presentedSheet = sheet
    }

    /// Takes the current sheet down.
    public func dismiss() {
        presentedSheet = nil
    }
}
