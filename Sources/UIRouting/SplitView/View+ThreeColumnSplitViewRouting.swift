import SwiftUI

extension View {
    /// Applies the routing the sidebar type declares for its middle column.
    ///
    /// Pushes made here stay inside the middle column, because it routes with `ContentRoute`.
    /// ```swift
    /// enum MailSidebar: SidebarItem {
    ///     case inbox
    ///
    ///     typealias ContentItem = Email
    ///     typealias ContentRoute = Never
    ///     typealias Sheet = MailSheet
    ///     typealias Alert = MailAlert
    ///
    ///     var contentView: some View {
    ///         MailListView()
    ///             .threeColumnContentRouting(for: MailSidebar.self)
    ///     }
    /// }
    /// ```
    ///
    /// - Parameter type: The sidebar type whose routing types should be used.
    public func threeColumnContentRouting<Sidebar>(for type: Sidebar.Type) -> some View where Sidebar: SidebarItem {
        modifier(
            ThreeColumnContentRoutingModifier<
                Sidebar,
                Sidebar.ContentRoute,
                Sidebar.Sheet,
                Sidebar.Alert,
                Sidebar.FullScreen,
                Sidebar.CustomSheet
            >()
        )
    }

    /// Applies the routing the sidebar type declares for its detail column.
    ///
    /// Pushes made here stay inside the detail column, because it routes with `DetailRoute`.
    /// ```swift
    /// enum MailSidebar: SidebarItem {
    ///     case inbox
    ///
    ///     typealias ContentItem = Email
    ///     typealias DetailRoute = MailRoute
    ///     typealias Sheet = MailSheet
    ///     typealias Alert = MailAlert
    ///
    ///     var detail: some View {
    ///         EmailDetailView()
    ///             .threeColumnDetailRouting(for: MailSidebar.self)
    ///     }
    /// }
    /// ```
    ///
    /// - Parameter type: The sidebar type whose routing types should be used.
    public func threeColumnDetailRouting<Sidebar>(for type: Sidebar.Type) -> some View where Sidebar: SidebarItem {
        modifier(
            ThreeColumnDetailRoutingModifier<
                Sidebar,
                Sidebar.DetailRoute,
                Sidebar.Sheet,
                Sidebar.Alert,
                Sidebar.FullScreen,
                Sidebar.CustomSheet
            >()
        )
    }
}
