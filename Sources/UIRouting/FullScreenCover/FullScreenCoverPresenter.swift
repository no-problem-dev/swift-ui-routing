import SwiftUI

/// Presents full-screen covers of one type.
///
/// On macOS the cover is shown as an ordinary sheet, because AppKit has no equivalent.
///
/// ```swift
/// // 1. Define the covers.
/// enum AppFullScreenCover: FullScreenCoverable {
///     case onboarding
///     case camera
///
///     @ViewBuilder
///     var body: some View {
///         switch self {
///         case .onboarding: OnboardingView()
///         case .camera: CameraView()
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
/// // 3. Attach the cover modifier.
/// var body: some View {
///     MainView()
///         .fullScreenCover(item: Binding(
///             get: { fullScreenCoverPresenter?.presentedCover },
///             set: { fullScreenCoverPresenter?.presentedCover = $0 }
///         )) { cover in
///             cover.body
///         }
/// }
///
/// // 4. Present a cover.
/// struct MainView: View {
///     @Environment(.fullScreenCover(FullScreenCover.self)) private var fullScreenCoverPresenter
///
///     var body: some View {
///         Button("Show onboarding") {
///             fullScreenCoverPresenter.present(.onboarding)
///         }
///     }
/// }
/// ```
@MainActor
@Observable
public final class FullScreenCoverPresenter<Cover> where Cover: Identifiable & Hashable {
    /// The cover currently up, or `nil` when none is.
    public var presentedCover: Cover?

    public init() {}

    /// Puts a cover up.
    public func present(_ cover: Cover) {
        presentedCover = cover
    }

    /// Takes the current cover down.
    public func dismiss() {
        presentedCover = nil
    }
}
