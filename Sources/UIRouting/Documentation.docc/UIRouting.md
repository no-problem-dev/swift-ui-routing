# ``UIRouting``

Type-safe routing for SwiftUI: navigation, sheets, covers, alerts, tabs, and split views behind one pattern.

## Overview

Every destination in UIRouting is a case of an enum you write. The enum says what each screen is
and what data it needs, the compiler checks that nothing is missing, and a router or presenter
kept in the environment does the presenting.

A case may also carry a callback and stay `Hashable`, which is what makes a screen able to report
a result back to whoever opened it:

```swift
enum Screen: Routable {
    case profile(userId: String)
    case editor(onSave: (Draft) -> Void)

    @ViewBuilder
    var body: some View {
        switch self {
        case .profile(let userId):
            ProfileView(userId: userId)
        case .editor(let onSave):
            EditorView(onSave: onSave)
        }
    }
}
```

Closures are left out of comparison and hashing, so identity comes from the case name plus its
hashable payload. You never write `id`, `==`, or `hash(into:)` for a `Routable`, `Sheetable`,
`FullScreenCoverable`, `CustomHeightSheetable`, or `Alertable` type.

Because the router is read out of the environment rather than passed down, the view that pushes a
screen does not need any of the views above it to know about it:

```swift
struct EditButton: View {
    @Environment(.router(Screen.self)) private var router

    var body: some View {
        Button("Edit") {
            router.navigate(to: .editor(onSave: save))
        }
    }
}
```

### One router per stack

A router owns exactly one navigation stack. Tabs and split-view columns each get their own, which
is what lets a user leave one tab deep in a stack, visit another, and come back to where they
were. Presenters follow the same rule: the navigation layer and the sheet layer hold separate
alert presenters, so an alert raised from inside a sheet still appears.

## Topics

### Essentials

- <doc:GettingStarted>

### Navigation

- ``Router``
- ``Routable``
- ``RoutingScopeModifier``
- ``RouterEnvironmentKey``

### Sheets

- ``SheetPresenter``
- ``Sheetable``
- ``SheetEnvironmentKey``

### Alerts

- ``AlertPresenter``
- ``Alertable``
- ``AlertAction``
- ``AlertEnvironmentKey``
- ``AlertOnNavigationModifier``
- ``AlertOnSheetModifier``

### Full-screen covers

- ``FullScreenCoverPresenter``
- ``FullScreenCoverable``
- ``FullScreenCoverEnvironmentKey``

### Sheets with custom heights

- ``CustomHeightSheetPresenter``
- ``CustomHeightSheetable``
- ``CustomHeightSheetEnvironmentKey``

### Tabs

- ``TabRouting``
- ``TabPresenter``
- ``Tabbable``
- ``TabContext``
- ``TabEnvironmentKey``
- ``TabScopeModifier``
- ``TabRoutingModifier``

### Split views

- ``SplitViewRouting``
- ``ThreeColumnSplitViewRouting``
- ``SplitViewPresenter``
- ``SidebarItem``
- ``Selectable``
- ``SplitViewEnvironmentKey``
- ``SelectedContentBindingEnvironmentKey``
- ``SplitViewScopeModifier``
- ``SplitViewRoutingModifier``
- ``ThreeColumnContentRoutingModifier``
- ``ThreeColumnDetailRoutingModifier``
- ``EmptySidebarToolbar``

### Presentation layers

- ``PresentationContext``
- ``RoutingModifier``
