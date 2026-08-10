import SwiftUI

// MARK: - Never Conformances

// `Never` conforms to every presentation protocol so that a routing slot can be switched off
// by writing `Never` for it. None of these implementations is ever reached.

extension Never: Routable {
    public var body: Never { fatalError() }
}

extension Never: Sheetable {
    public var id: Never { fatalError() }
}

extension Never: FullScreenCoverable {}

extension Never: CustomHeightSheetable {
    public var detents: Set<PresentationDetent> { fatalError() }
}

extension Never: Alertable {
    public var title: String { fatalError() }
    public var message: String? { fatalError() }
    public var actions: [AlertAction] { fatalError() }
}

extension Never: Selectable {
    public var label: Never { fatalError() }
}

extension Never: SidebarItem {
    public var detail: Never { fatalError() }
}
