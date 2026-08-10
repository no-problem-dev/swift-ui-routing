import SwiftUI

/// Holds what is selected in a split view's sidebar and, for three columns, its middle list.
///
/// The same presenter serves both layouts; the middle selection simply stays `nil` when there
/// are only two columns.
///
/// Two columns:
/// ```swift
/// @State private var splitViewPresenter = SplitViewPresenter<AppSidebar>()
///
/// SplitViewRouting(
///     splitViewPresenter: splitViewPresenter,
///     items: [.inbox, .sent, .archive]
/// )
/// ```
///
/// Three columns:
/// ```swift
/// @State private var splitViewPresenter = SplitViewPresenter<MailSidebar>(initialSelection: .inbox)
///
/// ThreeColumnSplitViewRouting(
///     splitViewPresenter: splitViewPresenter,
///     items: [.inbox, .sent, .archive, .starred]
/// )
/// ```
///
/// Selecting from code:
/// ```swift
/// struct SomeView: View {
///     @Environment(.splitView(AppSidebar.self)) private var splitViewPresenter
///
///     var body: some View {
///         Button("Show inbox") {
///             splitViewPresenter.select(.inbox)
///         }
///     }
/// }
/// ```
@MainActor
@Observable
public final class SplitViewPresenter<Sidebar: SidebarItem> {
    /// The selected sidebar row, or `nil` when nothing is selected.
    public var selectedSidebar: Sidebar?

    /// The row selected in the middle column of a three-column layout.
    ///
    /// Always `nil` in a two-column layout, where the middle column does not exist.
    public var selectedContent: Sidebar.ContentItem?

    /// Creates a presenter, optionally with a sidebar row already selected.
    ///
    /// - Parameter initialSelection: The row to select before the user picks one.
    public init(initialSelection: Sidebar? = nil) {
        self.selectedSidebar = initialSelection
        self.selectedContent = nil
    }

    // MARK: - Sidebar Selection

    /// Selects a sidebar row, clearing the middle column's selection in a three-column layout.
    /// ```swift
    /// @Environment(.splitView(AppSidebar.self)) private var splitViewPresenter
    ///
    /// Button("Show inbox") {
    ///     splitViewPresenter.select(.inbox)
    /// }
    /// ```
    ///
    /// - Parameter item: The row to select.
    public func select(_ item: Sidebar) {
        selectedSidebar = item

        // A row chosen under the old sidebar item means nothing under the new one.
        if Sidebar.ContentItem.self != Never.self {
            selectedContent = nil
        }
    }

    // MARK: - Content Selection (3-column support, future use)

    /// Selects a row in the middle column of a three-column layout.
    ///
    /// - Parameter content: The row to select.
    public func select<Content>(content: Content) where Content == Sidebar.ContentItem {
        selectedContent = content
    }
}
