import SwiftUI

extension View {
    /// Applies the routing the sidebar type declares for its detail column.
    ///
    /// The route, sheet, alert, and cover types are read off the sidebar type, so nothing has to
    /// be named at the call site.
    /// ```swift
    /// enum MailSidebar: SidebarItem {
    ///     case inbox
    ///
    ///     typealias DetailRoute = MailRoute
    ///     typealias Sheet = MailSheet
    ///     typealias Alert = MailAlert
    ///
    ///     var detail: some View {
    ///         InboxView()
    ///             .splitViewRouting(for: MailSidebar.self)
    ///     }
    /// }
    /// ```
    ///
    /// - Parameter type: The sidebar type whose routing types should be used.
    public func splitViewRouting<Sidebar>(for type: Sidebar.Type) -> some View where Sidebar: SidebarItem {
        modifier(
            SplitViewRoutingModifier<
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
