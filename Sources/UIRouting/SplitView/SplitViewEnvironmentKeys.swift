import SwiftUI

extension SplitViewPresenter {
    @MainActor
    static func createDefault() -> SplitViewPresenter<Sidebar> {
        SplitViewPresenter<Sidebar>()
    }
}

struct GenericSplitViewPresenterKey<Sidebar: SidebarItem>: EnvironmentKey {
    static var defaultValue: SplitViewPresenter<Sidebar> {
        MainActor.assumeIsolated {
            DefaultPresenterStore.instance(for: Self.self) { SplitViewPresenter<Sidebar>.createDefault() }
        }
    }
}

struct GenericSelectedContentBindingKey<ContentItem: Selectable>: EnvironmentKey {
    static var defaultValue: Binding<ContentItem?>? {
        nil
    }
}
