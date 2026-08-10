import SwiftUI

/// The routing handles of one tab, handed to a callback after switching to it.
/// ```swift
/// tabPresenter.select(TodoListTab()) { context in
///     // context.router is that tab's own router.
///     context.router.navigate(to: .todoDetail(todo: someTodo))
/// }
/// ```
@MainActor
public struct TabContext<Route: Routable> {
    /// The router driving this tab's navigation stack.
    public let router: Router<Route>

    internal init(router: Router<Route>) {
        self.router = router
    }
}
