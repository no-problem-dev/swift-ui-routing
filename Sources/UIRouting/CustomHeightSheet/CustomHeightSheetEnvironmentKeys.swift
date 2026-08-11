import SwiftUI

extension CustomHeightSheetPresenter {
    @MainActor
    static func createDefault() -> CustomHeightSheetPresenter<Sheet> {
        CustomHeightSheetPresenter<Sheet>()
    }
}

struct GenericCustomHeightSheetPresenterKey<Sheet>: EnvironmentKey where Sheet: CustomHeightSheetable {
    static var defaultValue: CustomHeightSheetPresenter<Sheet> {
        MainActor.assumeIsolated {
            DefaultPresenterStore.instance(for: Self.self) { CustomHeightSheetPresenter<Sheet>.createDefault() }
        }
    }
}

struct GenericCustomHeightSheetPresenterOnSheetKey<Sheet>: EnvironmentKey where Sheet: CustomHeightSheetable {
    static var defaultValue: CustomHeightSheetPresenter<Sheet> {
        MainActor.assumeIsolated {
            DefaultPresenterStore.instance(for: Self.self) { CustomHeightSheetPresenter<Sheet>.createDefault() }
        }
    }
}
