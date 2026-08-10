import SwiftUI

/// An entry in a split view's sidebar, together with the routing types its columns use.
///
/// One conformance describes the whole layout: the sidebar row, the detail view, and the route,
/// sheet, and alert types those columns route with. Anything left unspecified defaults to
/// `Never`, which switches that feature off.
///
/// Two columns:
/// ```swift
/// enum AppSidebar: SidebarItem {
///     case inbox
///     case sent
///     case archive
///
///     typealias DetailRoute = MailRoute
///
///     var label: some View {
///         switch self {
///         case .inbox:
///             Label("Inbox", systemImage: "tray")
///         case .sent:
///             Label("Sent", systemImage: "paperplane")
///         case .archive:
///             Label("Archive", systemImage: "archivebox")
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
///         }
///     }
/// }
/// ```
///
/// For a three-column layout, add `ContentItem` (what the middle column selects), `ContentRoute`
/// (pushes inside that column), and `contentView` (the column itself). Do not write `id` or
/// `hash(into:)` — both are provided.
@MainActor
public protocol SidebarItem: Hashable, Identifiable {
    // Views
    associatedtype LabelView: View
    associatedtype Detail: View

    // Routing types for the detail column
    associatedtype DetailRoute: Routable = Never
    associatedtype Sheet: Sheetable = Never
    associatedtype Alert: Alertable = Never
    associatedtype FullScreen: FullScreenCoverable = Never
    associatedtype CustomSheet: CustomHeightSheetable = Never

    // Extra types used only by three-column layouts
    associatedtype ContentItem: Selectable = Never
    associatedtype ContentRoute: Routable = Never
    associatedtype ContentView: View = EmptyView

    /// The row shown for this item in the sidebar.
    @ViewBuilder var label: LabelView { get }

    /// The view shown in the last column while this item is selected.
    @ViewBuilder var detail: Detail { get }

    /// The middle column, which is empty unless `ContentItem` is given.
    @ViewBuilder var contentView: ContentView { get }
}

// MARK: - Default Implementations

/// Supplies an empty middle column for two-column layouts.
public extension SidebarItem where ContentItem == Never {
    var contentView: some View { EmptyView() }
}

/// Derives the identifier from the value's hash.
public extension SidebarItem where Self: Hashable, ID == Int {
    var id: Int {
        var hasher = Hasher()
        self.hash(into: &hasher)
        return hasher.finalize()
    }
}

/// Compares and hashes by identifier.
public extension SidebarItem where ID == String {
    static func == (lhs: Self, rhs: Self) -> Bool {
        lhs.id == rhs.id
    }

    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
}

// MARK: - Selectable Protocol

/// A row the middle column of a three-column split view can select.
///
/// Conform the model type itself — a message, a contact, a file — and give it the row SwiftUI
/// should draw for it in the list.
/// ```swift
/// struct Email: Identifiable, Hashable {
///     let id: String
///     let subject: String
///     let from: String
/// }
///
/// extension Email: Selectable {
///     var label: some View {
///         VStack(alignment: .leading) {
///             Text(subject)
///             Text(from).font(.caption)
///         }
///     }
/// }
/// ```
@MainActor
public protocol Selectable: Hashable, Identifiable {
    associatedtype LabelView: View

    @ViewBuilder var label: LabelView { get }
}

/// Derives the identifier from the value's hash.
public extension Selectable where Self: Hashable, ID == Int {
    var id: Int {
        var hasher = Hasher()
        self.hash(into: &hasher)
        return hasher.finalize()
    }
}

/// Compares and hashes by identifier.
public extension Selectable where ID == String {
    static func == (lhs: Self, rhs: Self) -> Bool {
        lhs.id == rhs.id
    }

    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
}
