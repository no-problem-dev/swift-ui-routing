import SwiftUI

/// A three-column split view — sidebar, list, detail — each column with its own selection and
/// navigation stack.
///
/// The presenter holds both selections, `selectedSidebar` and `selectedContent`, while the
/// middle and detail columns each get a router driven by `ContentRoute` and `DetailRoute`.
/// Changing the sidebar clears the content selection, since a row chosen under the old sidebar
/// item means nothing under the new one.
/// ```swift
/// @State private var splitViewPresenter = SplitViewPresenter<MailSidebar>(initialSelection: .inbox)
///
/// ThreeColumnSplitViewRouting(
///     splitViewPresenter: splitViewPresenter,
///     items: [.inbox, .sent, .archive, .starred]
/// )
/// ```
///
/// With a toolbar in the sidebar:
/// ```swift
/// ThreeColumnSplitViewRouting(
///     splitViewPresenter: splitViewPresenter,
///     sidebarTitle: "Sessions",
///     items: sessions,
///     contentPlaceholder: { Text("Select a session") },
///     detailPlaceholder: { Text("Select an item") }
/// ) {
///     ToolbarItem(placement: .primaryAction) {
///         Button { } label: { Image(systemName: "plus") }
///     }
/// }
/// ```
///
/// The sidebar type that drives it:
/// ```swift
/// enum MailSidebar: SidebarItem {
///     case inbox, sent, archive, starred
///
///     // The types the three columns route with
///     typealias ContentItem = Email           // selected in the middle column
///     typealias ContentRoute = MailContentRoute // pushes inside the middle column
///     typealias DetailRoute = MailRoute       // pushes inside the detail column
///     typealias Sheet = MailSheet
///     typealias Alert = MailAlert
///
///     var label: some View { /* the sidebar row */ }
///     var contentView: some View { MailListView(sidebarItem: self) }  // middle column
///     var detail: some View { MailDetailWrapperView() }               // detail column
/// }
/// ```
///
/// Four movements are possible: switching the sidebar, selecting a row in the middle column,
/// pushing inside the middle column, and pushing inside the detail column.
public struct ThreeColumnSplitViewRouting<
    Sidebar: SidebarItem,
    ContentPlaceholder: View,
    DetailPlaceholder: View,
    SidebarToolbar: ToolbarContent
>: View {
    @Bindable private var splitViewPresenter: SplitViewPresenter<Sidebar>
    @State private var columnVisibility: NavigationSplitViewVisibility = .all
    @State private var contentRouter = Router<Sidebar.ContentRoute>()
    @State private var detailRouter = Router<Sidebar.DetailRoute>()
    private let sidebarTitle: String
    private let sidebarItems: [Sidebar]
    private let contentPlaceholder: ContentPlaceholder
    private let detailPlaceholder: DetailPlaceholder
    private let sidebarToolbar: SidebarToolbar
    private let onDelete: ((Sidebar) -> Void)?

    /// Creates a three-column split view with a toolbar in the sidebar.
    ///
    /// - Parameters:
    ///   - splitViewPresenter: Holds the sidebar and content selections.
    ///   - sidebarTitle: Navigation title of the sidebar column.
    ///   - items: The rows of the sidebar, in order.
    ///   - contentPlaceholder: Shown in the middle column while no sidebar row is selected.
    ///   - detailPlaceholder: Shown in the detail column while no content row is selected.
    ///   - sidebarToolbar: Toolbar content for the sidebar's navigation bar.
    ///   - onDelete: Called when a row is swiped away. Pass `nil` to disable swipe to delete.
    public init(
        splitViewPresenter: SplitViewPresenter<Sidebar>,
        sidebarTitle: String = "Sidebar",
        items: [Sidebar],
        @ViewBuilder contentPlaceholder: () -> ContentPlaceholder,
        @ViewBuilder detailPlaceholder: () -> DetailPlaceholder,
        @ToolbarContentBuilder sidebarToolbar: () -> SidebarToolbar,
        onDelete: ((Sidebar) -> Void)? = nil
    ) {
        self.splitViewPresenter = splitViewPresenter
        self.sidebarTitle = sidebarTitle
        self.sidebarItems = items
        self.contentPlaceholder = contentPlaceholder()
        self.detailPlaceholder = detailPlaceholder()
        self.sidebarToolbar = sidebarToolbar()
        self.onDelete = onDelete
    }

    public var body: some View {
        NavigationSplitView(columnVisibility: $columnVisibility) {
            // Sidebar column.
            List(sidebarItems, selection: $splitViewPresenter.selectedSidebar) { item in
                NavigationLink(value: item) {
                    item.label
                }
                .swipeActions(edge: .trailing, allowsFullSwipe: true) {
                    if let onDelete {
                        Button(role: .destructive) {
                            if splitViewPresenter.selectedSidebar == item {
                                splitViewPresenter.selectedSidebar = nil
                            }
                            onDelete(item)
                        } label: {
                            Label("Delete", systemImage: "trash")
                        }
                    }
                }
            }
            .navigationTitle(sidebarTitle)
            .toolbar { sidebarToolbar }
            .navigationSplitViewColumnWidth(min: 200, ideal: 240, max: 300)
        } content: {
            // Middle column.
            Group {
                if let selected = splitViewPresenter.selectedSidebar {
                    if Sidebar.ContentRoute.self != Never.self {
                        // Routed middle column: wrap it in a navigation stack.
                        NavigationStack(path: $contentRouter.path) {
                            selected.contentView
                                .threeColumnContentRouting(for: Sidebar.self)
                                .navigationDestination(for: Sidebar.ContentRoute.self) { route in
                                    route.body
                                        .threeColumnContentRouting(for: Sidebar.self)
                                }
                        }
                        .transformEnvironment(\.self) { environment in
                            environment[router: RouterSpecifier<Sidebar.ContentRoute>()] = contentRouter
                            environment[selectedContentBinding: SelectedContentBindingSpecifier<Sidebar.ContentItem>()] = $splitViewPresenter.selectedContent
                        }
                    } else {
                        // No routes: show the view as is.
                        selected.contentView
                            .threeColumnContentRouting(for: Sidebar.self)
                            .transformEnvironment(\.self) { environment in
                                environment[selectedContentBinding: SelectedContentBindingSpecifier<Sidebar.ContentItem>()] = $splitViewPresenter.selectedContent
                            }
                    }
                } else {
                    // Nothing selected in the sidebar.
                    contentPlaceholder
                }
            }
            .navigationSplitViewColumnWidth(min: 400, ideal: 560, max: 720)
        } detail: {
            // Detail column.
            Group {
                if let selected = splitViewPresenter.selectedSidebar {
                    if Sidebar.DetailRoute.self != Never.self {
                        // Routed detail column: wrap it in a navigation stack.
                        NavigationStack(path: $detailRouter.path) {
                            selected.detail
                                .threeColumnDetailRouting(for: Sidebar.self)
                                .navigationDestination(for: Sidebar.DetailRoute.self) { route in
                                    route.body
                                        .threeColumnDetailRouting(for: Sidebar.self)
                                }
                        }
                        .transformEnvironment(\.self) { environment in
                            environment[router: RouterSpecifier<Sidebar.DetailRoute>()] = detailRouter
                        }
                    } else {
                        // No routes: show the view as is.
                        selected.detail
                            .threeColumnDetailRouting(for: Sidebar.self)
                    }
                } else {
                    // Nothing selected in the middle column.
                    detailPlaceholder
                }
            }
            .navigationSplitViewColumnWidth(min: 200, ideal: 260, max: 320)
        }
        .navigationSplitViewStyle(.balanced)
        .transformEnvironment(\.self) { environment in
            environment[splitViewPresenter: SplitViewPresenterSpecifier<Sidebar>()] = splitViewPresenter
        }
    }
}

// MARK: - Empty Sidebar Toolbar

/// The stand-in used when a split view is created without sidebar toolbar content.
public struct EmptySidebarToolbar: ToolbarContent {
    public var body: some ToolbarContent {
        ToolbarItem(placement: .automatic) {
            EmptyView()
        }
    }
}

// MARK: - Convenience Initializers (Without Toolbar)

extension ThreeColumnSplitViewRouting where SidebarToolbar == EmptySidebarToolbar {
    /// Creates a three-column split view with no sidebar toolbar.
    ///
    /// - Parameters:
    ///   - splitViewPresenter: Holds the sidebar and content selections.
    ///   - sidebarTitle: Navigation title of the sidebar column.
    ///   - items: The rows of the sidebar, in order.
    ///   - contentPlaceholder: Shown in the middle column while no sidebar row is selected.
    ///   - detailPlaceholder: Shown in the detail column while no content row is selected.
    ///   - onDelete: Called when a row is swiped away. Pass `nil` to disable swipe to delete.
    public init(
        splitViewPresenter: SplitViewPresenter<Sidebar>,
        sidebarTitle: String = "Sidebar",
        items: [Sidebar],
        @ViewBuilder contentPlaceholder: () -> ContentPlaceholder,
        @ViewBuilder detailPlaceholder: () -> DetailPlaceholder,
        onDelete: ((Sidebar) -> Void)? = nil
    ) {
        self.splitViewPresenter = splitViewPresenter
        self.sidebarTitle = sidebarTitle
        self.sidebarItems = items
        self.contentPlaceholder = contentPlaceholder()
        self.detailPlaceholder = detailPlaceholder()
        self.sidebarToolbar = EmptySidebarToolbar()
        self.onDelete = onDelete
    }
}

extension ThreeColumnSplitViewRouting where ContentPlaceholder == Text, DetailPlaceholder == Text, SidebarToolbar == EmptySidebarToolbar {
    /// Creates a three-column split view with stock placeholders in both columns.
    ///
    /// - Parameters:
    ///   - splitViewPresenter: Holds the sidebar and content selections.
    ///   - sidebarTitle: Navigation title of the sidebar column.
    ///   - items: The rows of the sidebar, in order.
    ///   - onDelete: Called when a row is swiped away. Pass `nil` to disable swipe to delete.
    public init(
        splitViewPresenter: SplitViewPresenter<Sidebar>,
        sidebarTitle: String = "Sidebar",
        items: [Sidebar],
        onDelete: ((Sidebar) -> Void)? = nil
    ) {
        self.splitViewPresenter = splitViewPresenter
        self.sidebarTitle = sidebarTitle
        self.sidebarItems = items
        self.contentPlaceholder = Text("Select an item from the sidebar")
        self.detailPlaceholder = Text("Select an item")
        self.sidebarToolbar = EmptySidebarToolbar()
        self.onDelete = onDelete
    }
}

extension ThreeColumnSplitViewRouting where ContentPlaceholder == Text, SidebarToolbar == EmptySidebarToolbar {
    /// Creates a three-column split view with a stock placeholder in the middle column.
    ///
    /// - Parameters:
    ///   - splitViewPresenter: Holds the sidebar and content selections.
    ///   - sidebarTitle: Navigation title of the sidebar column.
    ///   - items: The rows of the sidebar, in order.
    ///   - detailPlaceholder: Shown in the detail column while no content row is selected.
    ///   - onDelete: Called when a row is swiped away. Pass `nil` to disable swipe to delete.
    public init(
        splitViewPresenter: SplitViewPresenter<Sidebar>,
        sidebarTitle: String = "Sidebar",
        items: [Sidebar],
        @ViewBuilder detailPlaceholder: () -> DetailPlaceholder,
        onDelete: ((Sidebar) -> Void)? = nil
    ) {
        self.splitViewPresenter = splitViewPresenter
        self.sidebarTitle = sidebarTitle
        self.sidebarItems = items
        self.contentPlaceholder = Text("Select an item from the sidebar")
        self.detailPlaceholder = detailPlaceholder()
        self.sidebarToolbar = EmptySidebarToolbar()
        self.onDelete = onDelete
    }
}

extension ThreeColumnSplitViewRouting where DetailPlaceholder == Text, SidebarToolbar == EmptySidebarToolbar {
    /// Creates a three-column split view with a stock placeholder in the detail column.
    ///
    /// - Parameters:
    ///   - splitViewPresenter: Holds the sidebar and content selections.
    ///   - sidebarTitle: Navigation title of the sidebar column.
    ///   - items: The rows of the sidebar, in order.
    ///   - contentPlaceholder: Shown in the middle column while no sidebar row is selected.
    ///   - onDelete: Called when a row is swiped away. Pass `nil` to disable swipe to delete.
    public init(
        splitViewPresenter: SplitViewPresenter<Sidebar>,
        sidebarTitle: String = "Sidebar",
        items: [Sidebar],
        @ViewBuilder contentPlaceholder: () -> ContentPlaceholder,
        onDelete: ((Sidebar) -> Void)? = nil
    ) {
        self.splitViewPresenter = splitViewPresenter
        self.sidebarTitle = sidebarTitle
        self.sidebarItems = items
        self.contentPlaceholder = contentPlaceholder()
        self.detailPlaceholder = Text("Select an item")
        self.sidebarToolbar = EmptySidebarToolbar()
        self.onDelete = onDelete
    }
}
