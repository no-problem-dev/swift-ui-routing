# Getting Started with UIRouting

Set up routing for an app, from the first enum to navigating from a leaf view.

## Overview

Adopting UIRouting is four steps: describe the destinations as enums, create the router and
presenters where the app starts, install a routing scope so a navigation stack exists, and then
navigate from anywhere by reading the router out of the environment.

For how to add the package to a project, see the
[README](https://github.com/no-problem-dev/swift-ui-routing).

## Describe the destinations

A destination is a case. Give the enum a `body` that returns the screen and let the associated
values carry whatever that screen needs.

```swift
import UIRouting

enum AppRoute: Routable {
    case detail(id: String)
    case settings

    @ViewBuilder
    var body: some View {
        switch self {
        case .detail(let id):
            DetailView(id: id)
        case .settings:
            SettingsView()
        }
    }
}
```

There is no `id`, `==`, or `hash(into:)` to write. A case may also carry a closure, which is
useful when a screen has to report a result back to whoever opened it:

```swift
enum AppSheet: Sheetable {
    case profile(userId: String)
    case picker(onSelect: (Item) -> Void)

    @ViewBuilder
    var body: some View {
        switch self {
        case .profile(let userId):
            ProfileSheet(userId: userId)
        case .picker(let onSelect):
            PickerSheet(onSelect: onSelect)
        }
    }
}
```

Closures are ignored when the value is compared or hashed, so two `.picker` cases with different
callbacks count as the same sheet. Alerts work the same way, which is what makes a confirmation
dialog with an inline handler practical:

```swift
enum AppAlert: Alertable {
    case deleteConfirmation(onConfirm: () -> Void)

    var title: String { "Delete this item?" }
    var message: String? { "This cannot be undone." }

    var actions: [AlertAction] {
        switch self {
        case .deleteConfirmation(let onConfirm):
            return [
                AlertAction(title: "Cancel", role: .cancel) {},
                AlertAction(title: "Delete", role: .destructive, action: onConfirm)
            ]
        }
    }
}
```

## Create the router and presenters

Make them once, where the app starts, and inject them with `routing(...)`.

```swift
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
```

Two alert presenters go in, not one. SwiftUI cannot raise an alert from a view that a sheet
already covers, so the sheet layer needs its own; ``PresentationContext`` is how a view says
which one it means.

## Install a routing scope

`routing(...)` only publishes the objects. The navigation stack itself comes from
`routingScope(for:alert:)`, which binds the router's path and applies the alert modifier to
every screen it pushes.

```swift
struct ContentView: View {
    var body: some View {
        HomeView()
            .routingScope(for: AppRoute.self, alert: AppAlert.self)
    }
}
```

If a screen needs navigation but no alerts, `routerScope(for:)` creates the router and the
stack together, so nothing has to be injected above it.

## Navigate from anywhere

Read what you need out of the environment. Nothing has to be threaded through initializers, so a
button several levels down can push a screen the views around it know nothing about.

```swift
struct HomeView: View {
    @Environment(.router(AppRoute.self)) private var router
    @Environment(.sheet(AppSheet.self)) private var sheetPresenter
    @Environment(.alert(AppAlert.self, context: .navigation)) private var alertPresenter

    var body: some View {
        VStack {
            Button("Detail") {
                router.navigate(to: .detail(id: "123"))
            }
            Button("Profile") {
                sheetPresenter.present(.profile(userId: "abc"))
            }
            Button("Delete") {
                alertPresenter.present(.deleteConfirmation {
                    // delete it
                })
            }
        }
    }
}
```

``Router`` also offers ``Router/back()``, ``Router/popToRoot()``, and
``Router/replace(with:)`` for the rest of the stack operations.

## Give each tab its own stack

A tab type declares the routing types its own stack uses, and ``TabRouting`` builds the tab view
around them. Each tab gets a separate router, so a user can leave one tab deep in a stack, visit
another, and come back to exactly where they were.

```swift
enum AppTab: Tabbable {
    case home
    case settings

    typealias Route = AppRoute
    typealias Sheet = AppSheet
    typealias Alert = AppAlert

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

struct RootView: View {
    @State private var tabPresenter = TabPresenter(initialTab: AppTab.home)

    var body: some View {
        TabRouting(tabPresenter: tabPresenter, tabs: [.home, .settings])
    }
}
```

Anything a tab leaves unspecified defaults to `Never`, which switches that feature off for it.

To switch tabs and push in one gesture, hand ``TabPresenter/select(_:then:)`` a callback. It runs
after the tab transition, which is what keeps the push from being swallowed by the animation.

```swift
@Environment(.tab(AppTab.self)) private var tabPresenter

tabPresenter.select(.home) { context in
    context.router.navigate(to: .detail(id: "123"))
}
```
