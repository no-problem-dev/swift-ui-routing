import SwiftUI

/// The environment lookup for a split-view presenter of a given sidebar type.
///
/// Reading it is how a view inside any column changes the sidebar selection.
/// ```swift
/// struct ContentView: View {
///     @Environment(.splitView(AppSidebar.self)) private var splitViewPresenter
///
///     var body: some View {
///         Button("Select Inbox") {
///             splitViewPresenter.select(.inbox)
///         }
///     }
/// }
/// ```
public struct SplitViewEnvironmentKey<Sidebar: SidebarItem> {
    fileprivate let specifier: SplitViewPresenterSpecifier<Sidebar>
    fileprivate init() {
        self.specifier = SplitViewPresenterSpecifier<Sidebar>()
    }
}

public extension SplitViewEnvironmentKey {
    /// Builds the environment lookup for split-view presenters of the given sidebar type.
    ///
    /// - Parameter type: The sidebar type whose presenter should be read.
    static func splitView(_ type: Sidebar.Type) -> SplitViewEnvironmentKey<Sidebar> {
        SplitViewEnvironmentKey<Sidebar>()
    }
}

public extension Environment {
    init<Sidebar: SidebarItem>(_ key: SplitViewEnvironmentKey<Sidebar>) where Value == SplitViewPresenter<Sidebar> {
        self.init(\.[splitViewPresenter: key.specifier])
    }
}

/// The environment lookup for the middle column's selection binding.
///
/// Pass it straight to `List(selection:)` in the middle column. The three-column split view
/// installs it, so the list and the presenter stay in step with no glue code.
///
/// ```swift
/// // The type the middle column selects
/// struct Email: Selectable { /* ... */ }
///
/// // Used by the middle column's view
/// struct MailListView: View {
///     @Environment(.selectedContentBinding(Email.self)) private var selectedContentBinding
///
///     var body: some View {
///         List(selection: selectedContentBinding) {
///             ForEach(emails) { email in
///                 NavigationLink(value: email) {
///                     email.label
///                 }
///             }
///         }
///     }
/// }
/// ```
public struct SelectedContentBindingEnvironmentKey<ContentItem: Selectable> {
    fileprivate let specifier: SelectedContentBindingSpecifier<ContentItem>
    fileprivate init() {
        self.specifier = SelectedContentBindingSpecifier<ContentItem>()
    }
}

public extension SelectedContentBindingEnvironmentKey {
    /// Builds the environment lookup for the selection binding of the given item type.
    ///
    /// - Parameter type: The type the middle column selects.
    static func selectedContentBinding(_ type: ContentItem.Type) -> SelectedContentBindingEnvironmentKey<ContentItem> {
        SelectedContentBindingEnvironmentKey<ContentItem>()
    }
}

public extension Environment {
    init<ContentItem: Selectable>(_ key: SelectedContentBindingEnvironmentKey<ContentItem>) where Value == Binding<ContentItem?>? {
        self.init(\.[selectedContentBinding: key.specifier])
    }
}
