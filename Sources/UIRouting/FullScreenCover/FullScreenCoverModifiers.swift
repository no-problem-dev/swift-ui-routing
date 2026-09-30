import SwiftUI

// MARK: - Conditional Presentation Modifier

/// Attaches the cover modifier only when the cover type is not `Never`.
///
/// On macOS it falls back to a sheet, since full-screen covers do not exist there.
struct FullScreenCoverModifierIfNeeded<FullScreen: FullScreenCoverable>: ViewModifier {
    @Bindable var presenter: FullScreenCoverPresenter<FullScreen>

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
    /// Creates a full-screen cover presenter, publishes it on one layer, and attaches the cover.
    ///
    /// The layer is spelled out at both ends: the `context` given here must be the one the reader
    /// asks for, or the reader gets a presenter nothing is bound to and `present(_:)` shows
    /// nothing. It has no default for that reason.
    ///
    /// The presenter reaches only the views below this modifier, so apply it to the parent of the
    /// view that reads it, not to the reader's own body.
    /// ```swift
    /// // The parent installs the presenter...
    /// SettingsSheet()
    ///     .fullScreenCoverPresenter(for: AppCover.self, context: .sheet)
    ///
    /// // ...and the view below reads it back on the same layer.
    /// struct SettingsSheet: View {
    ///     @Environment(.fullScreenCover(AppCover.self, context: .sheet)) private var presenter
    ///
    ///     var body: some View {
    ///         Button("Show Onboarding") {
    ///             presenter.present(.onboarding)
    ///         }
    ///     }
    /// }
    /// ```
    ///
    /// - Parameters:
    ///   - type: The cover type this presenter handles.
    ///   - context: The layer the presenter is published on; readers must ask for the same one.
    func fullScreenCoverPresenter<Cover: FullScreenCoverable>(
        for type: Cover.Type,
        context: PresentationContext
    ) -> some View {
        modifier(FullScreenCoverPresenterModifier<Cover>(context: context))
    }
}

/// Owns a full-screen cover presenter and attaches the cover for it.
struct FullScreenCoverPresenterModifier<Cover: FullScreenCoverable>: ViewModifier {
    let context: PresentationContext
    @State private var presenter = FullScreenCoverPresenter<Cover>()

    func body(content: Content) -> some View {
        @Bindable var bindablePresenter = presenter

        content
            .environment(\.[fullScreenCoverPresenter: FullScreenCoverPresenterSpecifier<Cover>(context: context)], presenter)
            #if os(iOS) || os(tvOS) || os(watchOS) || os(visionOS)
            .fullScreenCover(item: $bindablePresenter.presentedCover) { cover in
                cover.body
                    .transformEnvironment(\.self) { env in
                        env[fullScreenCoverPresenter: FullScreenCoverPresenterSpecifier<Cover>(context: context)] = presenter
                    }
            }
            #else
            .sheet(item: $bindablePresenter.presentedCover) { cover in
                cover.body
                    .transformEnvironment(\.self) { env in
                        env[fullScreenCoverPresenter: FullScreenCoverPresenterSpecifier<Cover>(context: context)] = presenter
                    }
            }
            #endif
    }
}
