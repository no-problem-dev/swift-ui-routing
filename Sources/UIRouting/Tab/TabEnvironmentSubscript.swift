import SwiftUI

extension EnvironmentValues {
    subscript<Tab: Tabbable>(tabPresenter specifier: TabPresenterSpecifier<Tab>) -> TabPresenter<Tab>? {
        get { self[GenericTabPresenterKey<Tab>.self] }
        set { self[GenericTabPresenterKey<Tab>.self] = newValue }
    }
}
