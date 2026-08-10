English | [日本語](./README.ja.md)

# UIRouting

Type-safe routing for SwiftUI: navigation, sheets, covers, alerts, tabs, and split views behind one pattern.

![Swift](https://img.shields.io/badge/Swift-6.0-orange.svg)
![Platforms](https://img.shields.io/badge/Platforms-iOS%2018.0+%20%7C%20macOS%2015.0+-blue.svg)
![License](https://img.shields.io/badge/License-MIT-yellow.svg)

## Features

- **Type-safe** — every destination is an enum case, checked at compile time
- **Reachable from anywhere** — routers and presenters live in `@Environment`, so a button several levels down can navigate without the views above it knowing
- **Closures in payloads** — a case can carry a callback and still be `Hashable`; you never write `id`, `==`, or `hash(into:)`
- **One pattern for all of it** — NavigationStack, Sheet, FullScreenCover, CustomHeightSheet, Alert, TabView, NavigationSplitView

## Basic Usage

### 1. Describe the destinations

```swift
enum AppRoute: Routable {
    case detail(id: String)

    @ViewBuilder
    var body: some View { DetailView(id: id) }
}

enum AppSheet: Sheetable {
    case settings

    @ViewBuilder
    var body: some View { SettingsView() }
}

enum AppAlert: Alertable {
    case delete(onConfirm: () -> Void)

    var title: String { "Delete?" }
    var message: String? { nil }

    var actions: [AlertAction] {
        switch self {
        case .delete(let onConfirm):
            return [
                AlertAction(title: "Cancel", role: .cancel) {},
                AlertAction(title: "Delete", role: .destructive, action: onConfirm)
            ]
        }
    }
}
```

### 2. Set up

```swift
// Create the router and presenters once and inject them.
@main
struct MyApp: App {
    @State private var router = Router<AppRoute>()
    @State private var sheetPresenter = SheetPresenter<AppSheet>()
    @State private var alertPresenter = AlertPresenter<AppAlert>()

    var body: some Scene {
        WindowGroup {
            ContentView()
                .routing(
                    router: router,
                    sheetPresenter: sheetPresenter,
                    alertPresenterOnNavigation: alertPresenter,
                    alertPresenterOnSheet: AlertPresenter<AppAlert>()
                )
        }
    }
}

// The routing scope gives you the NavigationStack.
struct ContentView: View {
    var body: some View {
        HomeView()
            .routingScope(for: AppRoute.self, alert: AppAlert.self)
    }
}
```

Two alert presenters, not one: SwiftUI cannot raise an alert from a view a sheet already covers,
so the sheet layer gets its own.

### 3. Use in views

```swift
struct HomeView: View {
    @Environment(.router(AppRoute.self)) private var router
    @Environment(.sheet(AppSheet.self)) private var sheetPresenter
    @Environment(.alert(AppAlert.self, context: .navigation)) private var alertPresenter

    var body: some View {
        Button("Detail") { router.navigate(to: .detail(id: "123")) }
        Button("Settings") { sheetPresenter.present(.settings) }
        Button("Delete") { alertPresenter.present(.delete { print("deleted") }) }
    }
}
```

## TabView

Each tab keeps its own router, so a user can leave one tab deep in a stack, visit another, and
come back to where they were.

```swift
enum AppTab: Tabbable {
    case home, settings

    typealias Route = AppRoute
    typealias Sheet = AppSheet

    @ViewBuilder
    var contentView: some View {
        switch self {
        case .home: HomeView()
        case .settings: SettingsView()
        }
    }

    @ViewBuilder
    var tabLabel: some View {
        switch self {
        case .home: Label("Home", systemImage: "house")
        case .settings: Label("Settings", systemImage: "gearshape")
        }
    }
}

@State private var tabPresenter = TabPresenter(initialTab: AppTab.home)

TabRouting(tabPresenter: tabPresenter, tabs: [.home, .settings])
```

Switching tab and pushing in one gesture — the callback runs after the transition, so the push
is not swallowed by the animation:

```swift
@Environment(.tab(AppTab.self)) private var tabPresenter

tabPresenter.select(.home) { context in
    context.router.navigate(to: .detail(id: "123"))
}
```

## Modal Presentations

### FullScreenCover

Presented as an ordinary sheet on macOS, which has no full-screen cover.

```swift
enum AppFullScreenCover: FullScreenCoverable {
    case camera
    case editor(id: String)

    @ViewBuilder
    var body: some View {
        switch self {
        case .camera: CameraView()
        case .editor(let id): EditorView(id: id)
        }
    }
}

// Inject it with the full routing overload.
ContentView()
    .routing(
        router: router,
        sheetPresenter: sheetPresenter,
        customHeightSheetPresenter: CustomHeightSheetPresenter<Never>(),
        fullScreenCoverPresenter: fullScreenCoverPresenter,
        alertPresenterOnNavigation: AlertPresenter<AppAlert>(),
        alertPresenterOnSheet: AlertPresenter<AppAlert>(),
        splitViewPresenter: SplitViewPresenter<Never>()
    )

@Environment(.fullScreenCover(AppFullScreenCover.self)) private var presenter
presenter.present(.camera)
```

### CustomHeightSheet

Each case declares the heights it rests at, so the call site never mentions detents.

```swift
enum AppCustomSheet: CustomHeightSheetable {
    case picker
    case quickAdd

    @ViewBuilder
    var body: some View {
        switch self {
        case .picker: PickerView()
        case .quickAdd: QuickAddView()
        }
    }

    var detents: Set<PresentationDetent> {
        switch self {
        case .picker: return [.medium, .large]
        case .quickAdd: return [.height(200)]
        }
    }
}

// This modifier creates the presenter and attaches the sheet.
ContentView()
    .customHeightSheetPresenter(for: AppCustomSheet.self)

@Environment(.customHeightSheet(AppCustomSheet.self, context: .sheet)) private var presenter
presenter.present(.picker)
```

## NavigationSplitView

### 2-column (sidebar + detail)

```swift
enum Sidebar: String, SidebarItem {
    case inbox, sent

    typealias DetailRoute = MailRoute

    var id: String { rawValue }
    var label: some View { Label("Inbox", systemImage: "tray") }
    var detail: some View { InboxView() }
}

@State private var presenter = SplitViewPresenter<Sidebar>(initialSelection: .inbox)

SplitViewRouting(splitViewPresenter: presenter, items: [.inbox, .sent])
```

### 3-column (sidebar + list + detail)

The middle and detail columns each get their own router, so a push in one leaves the other alone.

```swift
enum Sidebar: String, SidebarItem {
    case inbox

    typealias ContentItem = Email         // selected in the middle column
    typealias ContentRoute = FilterRoute  // pushes inside the middle column
    typealias DetailRoute = MailRoute     // pushes inside the detail column

    var id: String { rawValue }
    var label: some View { Label("Inbox", systemImage: "tray") }
    var contentView: some View { MailListView() }
    var detail: some View { MailDetailView() }
}

@State private var presenter = SplitViewPresenter<Sidebar>(initialSelection: .inbox)

ThreeColumnSplitViewRouting(splitViewPresenter: presenter, items: [.inbox])
```

The middle column's selection binding is installed for you — hand it straight to `List`:

```swift
@Environment(.selectedContentBinding(Email.self)) private var selectedContentBinding

List(selection: selectedContentBinding) {
    ForEach(emails) { email in
        NavigationLink(value: email) { email.label }
    }
}
```

## Documentation

Full API reference and guides:
**[no-problem-dev.github.io/swift-ui-routing](https://no-problem-dev.github.io/swift-ui-routing/documentation/uirouting/)**

Runnable apps: [TodoExample](Examples/TodoExample) (navigation, sheets, alerts, tabs, covers) and
[MailExample](Examples/MailExample) (3-column split view).

## Installation

```swift
// Package.swift
dependencies: [
    .package(url: "https://github.com/no-problem-dev/swift-ui-routing.git", from: "2.0.0")
]
```

Or in Xcode: File > Add Package Dependencies, then enter the URL.

## Requirements

- iOS 18.0+ / macOS 15.0+
- Swift 6.0+

## License

MIT License — see [LICENSE](LICENSE) for details.
