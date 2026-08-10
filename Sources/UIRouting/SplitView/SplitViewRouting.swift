import SwiftUI

/// A two-column split view whose detail column arrives with routing already wired up.
///
/// The detail column is wrapped in a navigation stack when the sidebar type declares a
/// `DetailRoute`, and left plain when it does not.
/// ```swift
/// struct ContentView: View {
///     @State private var splitViewPresenter = SplitViewPresenter<MailSidebar>(initialSelection: .inbox)
///
///     var body: some View {
///         SplitViewRouting(
///             splitViewPresenter: splitViewPresenter,
///             items: [.inbox, .sent, .archive, .starred]
///         )
///     }
/// }
///
/// enum MailSidebar: String, SidebarItem {
///     case inbox, sent, archive, starred
///
///     typealias DetailRoute = MailRoute
///     typealias Sheet = MailSheet
///     typealias Alert = MailAlert
///
///     var label: some View {
///         switch self {
///         case .inbox:
///             Label("Inbox", systemImage: "tray")
///         case .sent:
///             Label("Sent", systemImage: "paperplane")
///         case .archive:
///             Label("Archive", systemImage: "archivebox")
///         case .starred:
///             Label("Starred", systemImage: "star")
///         }
///     }
///
///     var detail: some View {
///         switch self {
///         case .inbox:
///             InboxView()
///         case .sent:
///             SentView()
///         case .archive:
///             ArchiveView()
///         case .starred:
///             StarredView()
///         }
///     }
/// }
/// ```
public struct SplitViewRouting<Sidebar: SidebarItem, PlaceholderContent: View>: View {
    @Bindable private var splitViewPresenter: SplitViewPresenter<Sidebar>
    @State private var router = Router<Sidebar.DetailRoute>()
    private let sidebarItems: [Sidebar]
    private let placeholderContent: PlaceholderContent

    /// Creates a two-column split view with a placeholder of your own.
    ///
    /// - Parameters:
    ///   - splitViewPresenter: Holds which sidebar row is selected.
    ///   - items: The rows of the sidebar, in order.
    ///   - placeholder: Shown in the detail column while nothing is selected.
    public init(
        splitViewPresenter: SplitViewPresenter<Sidebar>,
        items: [Sidebar],
        @ViewBuilder placeholder: () -> PlaceholderContent
    ) {
        self.splitViewPresenter = splitViewPresenter
        self.sidebarItems = items
        self.placeholderContent = placeholder()
    }

    public var body: some View {
        NavigationSplitView {
            // Sidebar column.
            List(sidebarItems, selection: $splitViewPresenter.selectedSidebar) { item in
                NavigationLink(value: item) {
                    item.label
                }
            }
            .navigationTitle("Sidebar")
        } detail: {
            // Detail column.
            if let selected = splitViewPresenter.selectedSidebar {
                if Sidebar.DetailRoute.self != Never.self {
                    // Routed detail: wrap it in a navigation stack.
                    NavigationStack(path: $router.path) {
                        selected.detail
                            .splitViewRouting(for: Sidebar.self)
                            .navigationDestination(for: Sidebar.DetailRoute.self) { route in
                                route.body
                                    .splitViewRouting(for: Sidebar.self)
                            }
                    }
                    .transformEnvironment(\.self) { environment in
                        environment[router: RouterSpecifier<Sidebar.DetailRoute>()] = router
                    }
                } else {
                    // No routes: show the view as is.
                    selected.detail
                        .splitViewRouting(for: Sidebar.self)
                }
            } else {
                // Nothing selected yet.
                placeholderContent
            }
        }
        .transformEnvironment(\.self) { environment in
            environment[splitViewPresenter: SplitViewPresenterSpecifier<Sidebar>()] = splitViewPresenter
        }
    }
}

// MARK: - Convenience Initializer

extension SplitViewRouting where PlaceholderContent == Text {
    /// Creates a two-column split view with a stock placeholder.
    ///
    /// - Parameters:
    ///   - splitViewPresenter: Holds which sidebar row is selected.
    ///   - items: The rows of the sidebar, in order.
    public init(
        splitViewPresenter: SplitViewPresenter<Sidebar>,
        items: [Sidebar]
    ) {
        self.init(
            splitViewPresenter: splitViewPresenter,
            items: items,
            placeholder: { Text("Select an item from the sidebar") }
        )
    }
}
