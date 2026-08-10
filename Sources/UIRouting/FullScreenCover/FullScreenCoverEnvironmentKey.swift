import SwiftUI

/// The environment lookup for a full-screen cover presenter of a given type and layer.
///
/// The cover type and the layer together pick the presenter, so reading without a context from
/// inside a sheet reaches the navigation layer's presenter instead of the sheet's own.
///
/// ```swift
/// // From the main content
/// struct ContentView: View {
///     @Environment(.fullScreenCover(AppCover.self)) private var presenter
///
///     var body: some View {
///         Button("Show Cover") {
///             presenter.present(.onboarding)
///         }
///     }
/// }
///
/// // From inside a sheet
/// struct SettingsSheet: View {
///     @Environment(.fullScreenCover(AppCover.self, context: .sheet)) private var presenter
///
///     var body: some View {
///         Button("Show Another Cover") {
///             presenter.present(.onboarding)
///         }
///         .fullScreenCoverPresenter(for: AppCover.self)
///     }
/// }
/// ```
public struct FullScreenCoverEnvironmentKey<Cover> where Cover: Identifiable & Hashable {
    fileprivate let specifier: FullScreenCoverPresenterSpecifier<Cover>
    fileprivate init(context: PresentationContext = .navigation) {
        self.specifier = FullScreenCoverPresenterSpecifier<Cover>(context: context)
    }
}

public extension FullScreenCoverEnvironmentKey {
    /// Builds the environment lookup for cover presenters of the given type.
    ///
    /// - Parameters:
    ///   - type: The cover type whose presenter should be read.
    ///   - context: The layer the presenter belongs to.
    static func fullScreenCover(_ type: Cover.Type, context: PresentationContext = .navigation) -> FullScreenCoverEnvironmentKey<Cover> {
        FullScreenCoverEnvironmentKey<Cover>(context: context)
    }
}

public extension Environment {
    init<Cover>(_ key: FullScreenCoverEnvironmentKey<Cover>) where Value == FullScreenCoverPresenter<Cover>, Cover: Identifiable & Hashable {
        self.init(\.[fullScreenCoverPresenter: key.specifier])
    }
}
