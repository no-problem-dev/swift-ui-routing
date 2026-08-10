import SwiftUI

// MARK: - Conditional Presentation Modifier

/// Attaches the cover modifier only when the cover type is not `Never`.
///
/// On macOS it falls back to a sheet, since full-screen covers do not exist there.
struct FullScreenCoverModifierIfNeeded<FullScreen: FullScreenCoverable>: ViewModifier {
    @Bindable var presenter: FullScreenCoverPresenter<FullScreen>
    @Environment(\.self) private var environment

    func body(content: Content) -> some View {
        if FullScreen.self != Never.self {
            #if os(iOS) || os(tvOS) || os(watchOS) || os(visionOS)
            content.fullScreenCover(item: $presenter.presentedCover) { cover in
                cover.body
                    .transformEnvironment(\.self) { env in
                        env[fullScreenCoverPresenter: FullScreenCoverPresenterSpecifier<FullScreen>(context: .navigation)] = presenter
                    }
            }
            #else
            content.sheet(item: $presenter.presentedCover) { cover in
                cover.body
                    .transformEnvironment(\.self) { env in
                        env[fullScreenCoverPresenter: FullScreenCoverPresenterSpecifier<FullScreen>(context: .navigation)] = presenter
                    }
            }
            #endif
        } else {
            content
        }
    }
}

// MARK: - Public Full Screen Cover Presenter Modifier

public extension View {
    /// Creates a full-screen cover presenter for the sheet layer.
    ///
    /// Apply it inside a sheet that opens a cover; the presenter it installs is the one
    /// `context: .sheet` reads back.
    /// ```swift
    /// struct SettingsSheet: View {
    ///     @Environment(.fullScreenCover(AppCover.self, context: .sheet)) private var presenter
    ///
    ///     var body: some View {
    ///         Button("Show Onboarding") {
    ///             presenter.present(.onboarding)
    ///         }
    ///         .fullScreenCoverPresenter(for: AppCover.self)
    ///     }
    /// }
    /// ```
    ///
    /// - Parameter type: The cover type this presenter handles.
    func fullScreenCoverPresenter<Cover: FullScreenCoverable>(for type: Cover.Type) -> some View {
        modifier(FullScreenCoverPresenterModifier<Cover>())
    }
}

/// Owns a full-screen cover presenter for the sheet layer.
struct FullScreenCoverPresenterModifier<Cover: FullScreenCoverable>: ViewModifier {
    @State private var presenter = FullScreenCoverPresenter<Cover>()

    func body(content: Content) -> some View {
        @Bindable var bindablePresenter = presenter

        content
            .environment(\.[fullScreenCoverPresenter: FullScreenCoverPresenterSpecifier<Cover>(context: .sheet)], presenter)
            #if os(iOS) || os(tvOS) || os(watchOS) || os(visionOS)
            .fullScreenCover(item: $bindablePresenter.presentedCover) { cover in
                cover.body
                    .transformEnvironment(\.self) { env in
                        env[fullScreenCoverPresenter: FullScreenCoverPresenterSpecifier<Cover>(context: .sheet)] = presenter
                    }
            }
            #else
            .sheet(item: $bindablePresenter.presentedCover) { cover in
                cover.body
                    .transformEnvironment(\.self) { env in
                        env[fullScreenCoverPresenter: FullScreenCoverPresenterSpecifier<Cover>(context: .sheet)] = presenter
                    }
            }
            #endif
    }
}
