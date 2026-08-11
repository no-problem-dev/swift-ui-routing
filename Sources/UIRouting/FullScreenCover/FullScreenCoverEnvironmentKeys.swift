import SwiftUI

extension FullScreenCoverPresenter {
    @MainActor
    static func createDefault() -> FullScreenCoverPresenter<Cover> {
        FullScreenCoverPresenter<Cover>()
    }
}

struct GenericFullScreenCoverPresenterKey<Cover>: EnvironmentKey where Cover: Identifiable & Hashable {
    static var defaultValue: FullScreenCoverPresenter<Cover> {
        MainActor.assumeIsolated {
            DefaultPresenterStore.instance(for: Self.self) { FullScreenCoverPresenter<Cover>.createDefault() }
        }
    }
}

struct GenericFullScreenCoverPresenterOnSheetKey<Cover>: EnvironmentKey where Cover: Identifiable & Hashable {
    static var defaultValue: FullScreenCoverPresenter<Cover> {
        MainActor.assumeIsolated {
            DefaultPresenterStore.instance(for: Self.self) { FullScreenCoverPresenter<Cover>.createDefault() }
        }
    }
}
