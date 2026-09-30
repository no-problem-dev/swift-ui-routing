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
/// // 2. Create the presenter and inject it. `routing(...)` also attaches the cover, so
/// //    there is no `.fullScreenCover(item:)` to write.
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
/// // 3. Present a cover.
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

    /// Creates an empty one.
    ///
    /// It is `nonisolated` so that `@State private var x = ...()` in a generic view can create
    /// it: the `@State` macro evaluates that initial value outside the main actor.
    nonisolated public init() {}

    /// Puts a cover up.
    public func present(_ cover: Cover) {
        presentedCover = cover
    }

    /// Takes the current cover down.
    public func dismiss() {
        presentedCover = nil
    }
}
