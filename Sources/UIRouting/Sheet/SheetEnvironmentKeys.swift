import SwiftUI

extension SheetPresenter {
    @MainActor
    static func createDefault() -> SheetPresenter<Sheet> {
        SheetPresenter<Sheet>()
    }
}

struct GenericSheetPresenterKey<Sheet>: EnvironmentKey where Sheet: Sheetable {
    static var defaultValue: SheetPresenter<Sheet> {
        MainActor.assumeIsolated {
            DefaultPresenterStore.instance(for: Self.self) { SheetPresenter<Sheet>.createDefault() }
        }
    }
}

struct GenericSheetPresenterOnSheetKey<Sheet>: EnvironmentKey where Sheet: Sheetable {
    static var defaultValue: SheetPresenter<Sheet> {
        MainActor.assumeIsolated {
            DefaultPresenterStore.instance(for: Self.self) { SheetPresenter<Sheet>.createDefault() }
        }
    }
}
