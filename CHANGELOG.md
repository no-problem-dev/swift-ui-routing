# Changelog

## [Unreleased]


All notable changes to this project are recorded in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/).

## [2.1.1] - 2026-07-19

### Changed
- Tests follow Swift 6 isolation (`@MainActor`, `nonisolated` `id`, `Sheetable` conformance).
- README and DocC work: a landing page and a Getting Started article.
- CI workflows synced to the standard SSOT template (tests + release-on-tag; the old
  auto-release is gone). DocC builds on macos-26 / Xcode 26 (Swift 6.2).

## [2.1.0] - 2026-04-26

### Added
- **`TabPresenter.isSelectedTabPushed`**: whether the selected tab's `NavigationStack` is
  deeper than its root, observable from outside. `TabPresenter.routers` is private, so
  there was no way to ask this. Reads the `@Observable` `Router.path`, so a SwiftUI view
  re-evaluates on push and pop — enough to, say, hide the tab bar only while pushed.

## [2.0.0] - 2026-04-14

### Changed
- **Migrated to the iOS 26 `Tab(value:role:)` API**. The internals of `TabScopeModifier` /
  `TabRouting` move off the legacy `.tabItem` + `.tag` to the declarative
  `SwiftUI.Tab(value:role:) { content } label: { label }`, so the Liquid Glass affordances
  (`.tabBarMinimizeBehavior`, `.tabViewBottomAccessory`, `.tabViewStyle(.sidebarAdaptable)`,
  `TabSection`, `.badge`) chain straight off the call site.

### Added
- `Tabbable.tabRole: TabRole?` (default `nil`). Returning `.search` from a search tab is
  enough for the system to place it by role.
- A generic `Content` on `TabRouting`, plus
  `init(tabPresenter:tabs:@ViewBuilder content: (Tab) -> Content)` for customising how each
  tab is drawn (environment injection, overlays). The existing
  `init(tabPresenter:tabs:)` stays as a convenience over `Tab.contentView`, so source
  compatibility holds.

### ⚠️ Breaking Changes
- The platform minimum rises to iOS 18 / macOS 15, which `Tab(value:)` requires. iOS 17 and
  below are no longer supported.
- `Tabbable` gains `tabRole`, but the default implementation (`nil`) means existing
  conformances need no change.

## [1.0.17] - 2026-03-01

### Added
- **`routerScope(for:)` modifier**: a self-contained Router + NavigationStack setup that does
  not require an `Alertable` type. Creates, binds and injects the Router in one go, the same
  pattern as `sheetPresenter(for:)`.

## [1.0.16] - 2026-02-28

### Added
- **`context` parameter on `SheetPresenterModifier`**: `.sheetPresenter(for:context:)` takes a
  `PresentationContext`, so independent sheet management at a NavigationStack root
  (`.navigation`) and a sheet opened from inside a sheet (`.sheet`) can be told apart explicitly.

## [1.0.15] - 2026-02-28

### Added
- Swipe-to-delete and column width control on `ThreeColumnSplitViewRouting`.

## [1.0.14] - 2026-02-24

### Added
- Sidebar toolbar support on `ThreeColumnSplitViewRouting`.

### Fixed
- `ToolbarContentBuilder` type mismatch in the convenience initialiser.

## [1.0.13] - 2026-02-24

### Added
- `sidebarTitle` parameter on `ThreeColumnSplitViewRouting`.

## [1.0.12] - 2025-11-09

### Fixed
- Made the automatic release workflow's messages consistently Japanese (PR description, release notes, log messages)

## [1.0.11] - 2025-11-09

### Fixed
- Fixed the indentation inside the heredoc in the automatic release workflow (resolving a YAML syntax error)

## [1.0.10] - 2025-11-09

### Fixed
- Full implementation of the automatic release workflow (based on swift-design-system)

## [1.0.9] - 2025-11-09

### Fixed
- Fixed backquote escaping inside the heredoc in the workflow file

## [1.0.8] - 2025-11-09

### Other
- Checked that the automatic release workflow works


## [1.0.7] - 2025-11-06

### Fixed
- **Swift Package Manager compatibility**: resolved the fingerprint mismatch on the v1.0.6 tag
  - Recreating the tag fixed SPM's version resolution error
  - Users no longer hit the `does not match previously recorded value` error

## [1.0.6] - 2025-11-06

### Added
- **Nested presentation**: opening a sheet from within a sheet
  - `PresentationContext` enum — `.navigation` and `.sheet` distinguish the levels
  - `.sheetPresenter()` modifier for presenting from inside a sheet
  - Added a `CategoryPickerSheet` example to TodoExample
  - Closure-based data passing keeps it type-safe

- **Unified context support**: every presentation type takes a context
  - `Sheet` — nestable with `.sheet(AppSheet.self, context: .sheet)`
  - `FullScreenCover` — nestable with `.fullScreenCover(Cover.self, context: .sheet)`
  - `CustomHeightSheet` — nestable with `.customHeightSheet(Sheet.self, context: .sheet)`
  - `Alert` — the existing `context` parameter folded into the unified `PresentationContext`

### Improved
- **Large-scale file structure refactoring**: much better maintainability and readability
  - Split files over 1000 lines by feature (following the single responsibility principle)
  - Organised files per presenter type (Alert/, Sheet/, Router/, and so on)
  - A clear separation between the public API and the internal implementation

### Changed
- **Directory structure**:
  - Removed the `Internal/` directory (no longer needed)
  - Removed the `Environment/` directory (files moved where they belong)
  - Collected shared components in `Common/`
    - `PresentationContext.swift` — the shared enum
    - `RoutingModifier.swift` — the unified modifier

- **The file splits in detail**:
  - `Specifiers.swift` (146 lines) → 7 dedicated files
  - `GenericEnvironmentKeys.swift` (135 lines) → 7 dedicated files
  - `StaticMemberLookup.swift` (364 lines) → 7 dedicated files
  - `PresentationModifiers.swift` (255 lines) → 4 dedicated files
  - `EnvironmentSubscripts.swift` (100 lines) → 7 dedicated files

### Technical improvements
- **Colocation**: related files live in the same directory
  - e.g. `Sheet/` holds `SheetPresenter.swift`, `SheetSpecifier.swift`, `SheetEnvironmentKey.swift`, `SheetModifiers.swift`
- **Single responsibility**: each file has one clear job
- **Maintainability**: the blast radius of a change is obvious
- **Type-safe nesting**: closures sidestep the Hashable problem with Binding

### Impact
- ✅ **Public API**: backward compatible (the new features are additive)
- ✅ **Build**: everything compiles
- ✅ **Documentation**: reflects the new structure throughout
- ✅ **Behaviour**: everything works

## [1.0.5] - 2025-11-06

### Added
- **Mirror-based Hashable/Equatable**: every protocol now handles enums with associated values
  - `FullScreenCoverable` — handles associated values that include closures
  - `Sheetable` — handles associated values that include closures
  - `Routable` — handles associated values that include closures
  - `CustomHeightSheetable` — added `nonisolated` to the existing implementation
  - `Alertable` — added `nonisolated` to the existing implementation

### Improved
- **Swift 6 concurrency**: `nonisolated` applied to every Hashable/Equatable implementation
  - Fully handles strict concurrency checking (Swift 6)
  - Resolves the conflict with Main Actor isolation
- **Fuller documentation**: added usage examples for the closure case
  - `FullScreenCoverable`: the `picker(onSelect: (Item) -> Void)` example
  - `Routable`: the `editor(onSave: () -> Void)` example
  - Consistent notes added to every protocol

### Technical details
- **How the Mirror-based implementation works**:
  - Identity is decided by the enum's case name
  - Only associated values of Hashable types are compared and hashed
  - Closure types cannot be converted to `AnyHashable`, so they are excluded automatically
  - No hand-written Hashable/Equatable needed

### Benefits
- ✅ No compile error on an enum that contains a closure
- ✅ A flexible design without giving up type safety
- ✅ Far less boilerplate
- ✅ Handles Swift 6's strict concurrency checking

## [1.0.4] - 2025-11-04

### Added
- **ThreeColumnSplitViewRouting**: full support for a three-column NavigationSplitView (sidebar | list | detail)
  - `ContentItem: Selectable` — the item type selectable in the middle column
  - `ContentRoute: Routable` — navigation within the middle column
  - `contentView` — the view shown in the middle column
- **Four levels of routing**:
  1. Sidebar switching (Inbox → Sent)
  2. Content selection (pick a mail → show it in the detail column)
  3. ContentRoute (a push within the middle column)
  4. DetailRoute (a push within the detail column)
- **selectedContentBinding**: type-safe management of the middle column's selection
  - Reached with `@Environment(.selectedContentBinding(Email.self))`
  - A generic implementation, fully type-safe
- **MailExample**: a complete three-column SplitView example
  - Different data per sidebar entry
  - Examples of ContentRoute/DetailRoute
  - A comparison with the two-column case

### Improved
- **README rewritten**: 404 lines → 238 lines (41% shorter)
  - A code example up front (the whole feature set in three lines)
  - A full explanation of the three-column SplitView
  - An API list
  - Structured around worked examples
- **Better documentation comments**: written from the caller's point of view
  - Removed inaccurate phrasing such as "for future use"
  - Made the concrete examples more general
  - Made each type's role and when to use it explicit
- **Examples README**: fuller descriptions of TodoExample/MailExample

### Internal
- `SelectedContentBindingSpecifier` — type-safe Binding management
- `GenericSelectedContentBindingKey` — Environment integration
- `ThreeColumnSplitViewRoutingModifier` — automatic routing setup
- Follows the same Specifier pattern as the existing Router/SheetPresenter
- A runtime check (`!= Never.self`) decides whether a feature is present

## [1.0.3] - 2025-11-04

### Added
- **Automatic DocC deployment**: documentation published to GitHub Pages by GitHub Actions
  - A push to main generates and deploys the documentation automatically
  - Online documentation: https://no-problem-dev.github.io/swift-ui-routing/documentation/uirouting/
- **Documentation URL in the README**: a link to the online documentation

### Improved
- Added the swift-docc-plugin dependency
- The GitHub Actions workflow uses a macOS runner and Xcode 16.1
- Proper handling of SwiftPM sandbox permissions

## [1.0.2] - 2025-11-04

### Added
- **Cross-tab navigation**: switch tab and navigate in one step
  - The `tabPresenter.select(.home) { context in context.router.navigate(to: .detail) }` API
  - Each tab keeps its own Router
- **Automatic routing setup**: `TabRouting` applies routing to each tab automatically
- **Comprehensive public API documentation**: documentation comments written from the caller's point of view on every public API

### Changed
- **Enum-based tabs**: simpler tab definitions, less boilerplate
  - Removed the `RoutingConfiguration` protocol
  - `associatedtype` declared directly on the `Tabbable` protocol
- **README largely updated**: the quick start is now a tab-based app, a more realistic example

### Improved
- Optimised the ordering of `.routingScope()` (placed before `.routing()`)
- Navigation waits for the tab-switch animation to finish (visually natural)
- Enabled full screen cover and custom height sheet in the sample app

### Fixed
- Cross-tab navigation ran more than once
- Navigation ran against the Router from before the tab switch

### Removed
- `RoutingConfiguration.swift`: an unused protocol
- `TodoListRoutingConfig.swift`: a configuration file made redundant by the move to enum-based tabs
- The duplicated TabView section in the README (131 lines shorter)

## [1.0.1] - 2025-11-04

### Added
- **TabView support**: type-safe tab management
  - `Tabbable` protocol — defines a tab (body + tabLabel)
  - `TabPresenter` — manages the selected tab (selectedTab + select())
  - `TabRouting` View — a concise API that builds the TabView directly
  - Environment integration — reached with `@Environment(.tab(AppTab.self))`
  - Each tab keeps its own NavigationStack, Router and AlertPresenter

- **Full screen cover support**: `FullScreenCoverPresenter`
  - `AppFullScreenCover` enum — full screen modal definitions
  - Examples added to TodoExample (PhotoCaptureView, NoteEditorView)
  - Environment integration — `@Environment(.fullScreenCover(Cover.self))`

- **Custom height sheet support**: `CustomHeightSheetPresenter`
  - `CustomHeightSheetable` protocol — customise the height with detents
  - Examples added to TodoExample (CategoryPickerSheet, QuickAddSheet)
  - Environment integration — `@Environment(.customHeightSheet(Sheet.self))`

### Improved
- **Better alert API**: more intuitive names
  - `.alertOnNavigation()` → `.routingAlert()`
  - `.alertOnSheet()` → `.sheetAlert()`
  - Makes it explicit that these work outside a NavigationStack too

### Fixed
- RoutingScopeModifier applies alerts to ListView (the root content) as well
  - Previously alerts only applied to pushed screens
  - Alerts now work on the first screen of a NavigationStack

### Changed
- TodoExample considerably extended
  - Moved to a tab-based app structure
  - Removed the settings case from AppRoute (it became a tab)
  - TodoTabRoot — an independent routing context for the Todo tab
  - AdvancedSettingsSheet — an example of a NavigationStack of its own inside a sheet
- README updated — usage examples for TabView, FullScreenCover and CustomHeightSheet

## [1.0.0] - 2025-11-03

### Added
- **First release**: a type-safe routing library for SwiftUI

- **Basic routing**:
  - `Router<Route>` — routing tied to NavigationStack
  - `Routable` protocol — the type definition for a screen transition
  - `navigate(to:)` — type-safe navigation
  - `back()` / `popToRoot()` — navigation stack operations

- **Sheet management**:
  - `SheetPresenter<Sheet>` — modal sheet management
  - `Sheetable` protocol — sheet definitions (Identifiable + Hashable + body)
  - `present()` / `dismiss()` — showing and hiding a sheet

- **Alert management**:
  - `AlertPresenter<Alert>` — alert management
  - `Alertable` protocol — alert definitions (title + actions)
  - `AlertAction` — alert button definitions (default/cancel/destructive)

- **Environment integration**:
  - A static member lookup pattern
  - `@Environment(.router(Route.self))` — get the Router
  - `@Environment(.sheet(Sheet.self))` — get the SheetPresenter
  - `@Environment(.alert(Alert.self, context:))` — get the AlertPresenter

- **Context separation**:
  - The Navigation level and the Sheet level hold independent AlertPresenters
  - The `.navigation` / `.sheet` contexts tell alerts apart

- **The TodoExample sample app**:
  - Examples of Router, SheetPresenter and AlertPresenter
  - A todo list app (add, edit, delete, filter)
  - Category management, a settings screen

### Technical specifications
- **Platforms**: iOS 17.0+, macOS 14.0+
- **Language**: Swift 6.0+
- **Dependencies**: none
- **Architecture**:
  - The Specifier pattern — identifying environment values
  - GenericEnvironmentKey — type-safe access to environment values
  - EnvironmentSubscript — dynamic environment value resolution

[Unreleased]: https://github.com/no-problem-dev/swift-ui-routing/compare/2.1.1...HEAD
[2.1.1]: https://github.com/no-problem-dev/swift-ui-routing/compare/v2.1.0...2.1.1
[2.1.0]: https://github.com/no-problem-dev/swift-ui-routing/compare/v2.0.0...v2.1.0
[2.0.0]: https://github.com/no-problem-dev/swift-ui-routing/compare/v1.0.17...v2.0.0
[1.0.17]: https://github.com/no-problem-dev/swift-ui-routing/compare/v1.0.16...v1.0.17
[1.0.16]: https://github.com/no-problem-dev/swift-ui-routing/compare/v1.0.15...v1.0.16
[1.0.15]: https://github.com/no-problem-dev/swift-ui-routing/compare/v1.0.14...v1.0.15
[1.0.14]: https://github.com/no-problem-dev/swift-ui-routing/compare/v1.0.13...v1.0.14
[1.0.13]: https://github.com/no-problem-dev/swift-ui-routing/compare/v1.0.12...v1.0.13
[1.0.12]: https://github.com/no-problem-dev/swift-ui-routing/compare/v1.0.11...v1.0.12
[1.0.11]: https://github.com/no-problem-dev/swift-ui-routing/compare/v1.0.10...v1.0.11
[1.0.10]: https://github.com/no-problem-dev/swift-ui-routing/compare/v1.0.9...v1.0.10
[1.0.9]: https://github.com/no-problem-dev/swift-ui-routing/compare/v1.0.8...v1.0.9
[1.0.8]: https://github.com/no-problem-dev/swift-ui-routing/compare/v1.0.7...v1.0.8
