[English](./README.md) | 日本語

# UIRouting

SwiftUI の型安全なルーティング。画面遷移・シート・カバー・アラート・タブ・スプリットビューを 1 つのパターンで扱う。

![Swift](https://img.shields.io/badge/Swift-6.0-orange.svg)
![Platforms](https://img.shields.io/badge/Platforms-iOS%2018.0+%20%7C%20macOS%2015.0+-blue.svg)
![License](https://img.shields.io/badge/License-MIT-yellow.svg)

## 特徴

- **型安全** — 遷移先はすべて enum の case。コンパイル時に検証される
- **どこからでも届く** — Router と Presenter は `@Environment` にあるので、深い階層のボタンからでも上位のビューを介さず遷移できる
- **クロージャを持てる** — case がコールバックを持ったまま `Hashable` でいられる。`id` / `==` / `hash(into:)` は書かない
- **全部同じ書き方** — NavigationStack, Sheet, FullScreenCover, CustomHeightSheet, Alert, TabView, NavigationSplitView

## 基本的な使い方

### 1. 遷移先を定義する

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

    var title: String { "削除しますか？" }
    var message: String? { nil }

    var actions: [AlertAction] {
        switch self {
        case .delete(let onConfirm):
            return [
                AlertAction(title: "キャンセル", role: .cancel) {},
                AlertAction(title: "削除", role: .destructive, action: onConfirm)
            ]
        }
    }
}
```

### 2. セットアップ

```swift
// Router と Presenter は一度だけ作って注入する。
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

// NavigationStack はルーティングスコープが用意する。
struct ContentView: View {
    var body: some View {
        HomeView()
            .routingScope(for: AppRoute.self, alert: AppAlert.self)
    }
}
```

`routing(...)` は Presenter を環境に入れ、その Presenter が出すシート（カバー・高さ指定のシートも）を取り付けるところまで行う。`.sheet(item:)` は書かない。

AlertPresenter を 2 つ渡すのは、シートに覆われたビューから SwiftUI がアラートを出せないため。シート階層には専用のものが要る。

### 3. ビューで使う

```swift
struct HomeView: View {
    @Environment(.router(AppRoute.self)) private var router
    @Environment(.sheet(AppSheet.self)) private var sheetPresenter
    @Environment(.alert(AppAlert.self, context: .navigation)) private var alertPresenter

    var body: some View {
        Button("詳細へ") { router.navigate(to: .detail(id: "123")) }
        Button("設定") { sheetPresenter.present(.settings) }
        Button("削除") { alertPresenter.present(.delete { print("削除") }) }
    }
}
```

## TabView

タブごとに Router を持つので、1 つのタブを深い画面に残したまま別のタブへ行き、戻ってきても元の場所のまま。

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
        case .home: Label("ホーム", systemImage: "house")
        case .settings: Label("設定", systemImage: "gearshape")
        }
    }
}

@State private var tabPresenter = TabPresenter(initialTab: AppTab.home)

TabRouting(tabPresenter: tabPresenter, tabs: [.home, .settings])
```

タブ切り替えと画面遷移を一度に行う。コールバックはそのタブの Router ができてから走るので、タブが初めて表示される前に頼んだ push も捨てられず待つ。`TabRouting` の外（プレビューなど）では `nil` になる:

```swift
@Environment(.tab(AppTab.self)) private var tabPresenter

tabPresenter?.select(.home) { context in
    context.router.navigate(to: .detail(id: "123"))
}
```

### アプリの外から来た遷移

URL・通知・ウィジェット・App Intent は、どれも `TabDestination`（タブと、そのルートに積む画面）に変える。URL が何を指すかはアプリの契約なので変換はアプリが書き、Presenter はその結果を開く。タブの Router がまだ無ければ、できるまで待つ。最初の描画より前に届く入口から触れるよう、Presenter はビューでなくアプリの側で持つ。

```swift
enum AppLink {
    static func destination(for url: URL) -> TabDestination<AppTab>? {
        guard url.host() == "detail" else { return nil }
        return TabDestination(tab: .home, path: [.detail(id: url.lastPathComponent)])
    }
}

TabRouting(tabPresenter: tabPresenter, tabs: [.home, .settings])
    .onOpenURL { url in
        tabPresenter.open(url, resolve: AppLink.destination(for:))
    }
```

## モーダル表示

### iPad でだけ全画面にする

`Sheetable` のケースは、シートでなく画面全体を覆うよう指定できる。presenter・`present(_:)`・
`dismiss()` はそのまま使える。

```swift
enum AppSheet: Sheetable {
    case settings
    case paywall

    var presentationStyle: SheetPresentationStyle {
        switch self {
        case .settings: .sheet                    // 既定
        case .paywall: .fullScreenCoverWhenRegular
        }
    }

    @ViewBuilder
    var body: some View { ... }
}
```

`.fullScreenCoverWhenRegular` は、表示元のビューが regular 幅（iPad）なら全画面カバー、
compact 幅（iPhone や、狭いウインドウの iPad）ならシートになる。`.fullScreenCover` はどの幅でも
全画面。macOS ではどれもシートになる。

### FullScreenCover

macOS にはフルスクリーンカバーが無いため、通常のシートとして表示される。

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

// 全部入りの routing で注入する。カバーの取り付けもこれが行う。
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

高さは case 自身が持つので、呼び出し側は detent を書かない。

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

// routing を使わない場合: このモディファイアが Presenter の生成、指定した階層への公開、
// シートの取り付けまで行う。読む側のビューの親に付ける。
ContentView()
    .customHeightSheetPresenter(for: AppCustomSheet.self, context: .navigation)

// ContentView の中。上と同じ階層を読む。
@Environment(.customHeightSheet(AppCustomSheet.self)) private var presenter
presenter.present(.picker)
```

## NavigationSplitView

### 2 カラム（サイドバー + 詳細）

```swift
enum Sidebar: String, SidebarItem {
    case inbox, sent

    typealias DetailRoute = MailRoute

    var id: String { rawValue }
    var label: some View { Label("受信箱", systemImage: "tray") }
    var detail: some View { InboxView() }
}

@State private var presenter = SplitViewPresenter<Sidebar>(initialSelection: .inbox)

SplitViewRouting(splitViewPresenter: presenter, items: [.inbox, .sent])
```

### 3 カラム（サイドバー + リスト + 詳細）

中央カラムと詳細カラムはそれぞれ別の Router を持つので、片方で push してももう片方は動かない。

```swift
enum Sidebar: String, SidebarItem {
    case inbox

    typealias ContentItem = Email         // 中央カラムで選択するアイテム
    typealias ContentRoute = FilterRoute  // 中央カラム内の push
    typealias DetailRoute = MailRoute     // 詳細カラム内の push

    var id: String { rawValue }
    var label: some View { Label("受信箱", systemImage: "tray") }
    var contentView: some View { MailListView() }
    var detail: some View { MailDetailView() }
}

@State private var presenter = SplitViewPresenter<Sidebar>(initialSelection: .inbox)

ThreeColumnSplitViewRouting(splitViewPresenter: presenter, items: [.inbox])
```

中央カラムの選択 Binding は自動で環境に入るので、そのまま `List` に渡す:

```swift
@Environment(.selectedContentBinding(Email.self)) private var selectedContentBinding

List(selection: selectedContentBinding) {
    ForEach(emails) { email in
        NavigationLink(value: email) { email.label }
    }
}
```

## ドキュメント

API リファレンスとガイド:
**[no-problem-dev.github.io/swift-ui-routing](https://no-problem-dev.github.io/swift-ui-routing/documentation/uirouting/)**

動かせるサンプル: [TodoExample](Examples/TodoExample)（画面遷移・シート・アラート・タブ・カバー）と
[MailExample](Examples/MailExample)（3 カラムスプリットビュー）。

## インストール

```swift
// Package.swift
dependencies: [
    .package(url: "https://github.com/no-problem-dev/swift-ui-routing.git", from: "3.0.0")
]
```

Xcode の場合は File > Add Package Dependencies から URL を入力する。

## 要件

- iOS 18.0+ / macOS 15.0+
- Swift 6.0+

## ライセンス

MIT License — 詳細は [LICENSE](LICENSE) を参照。
