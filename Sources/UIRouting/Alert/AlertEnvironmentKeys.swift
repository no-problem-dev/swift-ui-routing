import SwiftUI

extension AlertPresenter {
    @MainActor
    static func createDefault() -> AlertPresenter<Alert> {
        AlertPresenter<Alert>()
    }
}

struct GenericAlertPresenterOnNavigationKey<Alert: Alertable>: EnvironmentKey {
    static var defaultValue: AlertPresenter<Alert> {
        MainActor.assumeIsolated {
            DefaultPresenterStore.instance(for: Self.self) { AlertPresenter<Alert>.createDefault() }
        }
    }
}

struct GenericAlertPresenterOnSheetKey<Alert: Alertable>: EnvironmentKey {
    static var defaultValue: AlertPresenter<Alert> {
        MainActor.assumeIsolated {
            DefaultPresenterStore.instance(for: Self.self) { AlertPresenter<Alert>.createDefault() }
        }
    }
}
