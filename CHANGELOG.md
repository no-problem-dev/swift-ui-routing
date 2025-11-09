# Changelog

このプロジェクトに対する注目すべき変更はすべてこのファイルに記録されます。

このフォーマットは [Keep a Changelog](https://keepachangelog.com/ja/1.0.0/) に基づいており、
このプロジェクトは [Semantic Versioning](https://semver.org/lang/ja/) に準拠しています。

## [未リリース]

なし

## [1.0.11] - 2025-11-09

### 修正
- 自動リリースワークフローのheredoc内インデンテーション修正（YAMLシンタックスエラー解消）

## [1.0.10] - 2025-11-09

### 修正
- 自動リリースワークフローの完全版実装（swift-design-systemベース）

## [1.0.9] - 2025-11-09

### 修正
- ワークフローファイルのheredoc内バッククォートエスケープ修正

## [1.0.8] - 2025-11-09

### その他
- 自動リリースワークフローの動作確認


## [1.0.7] - 2025-11-06

### 修正
- **Swift Package Manager 互換性**: v1.0.6 タグの fingerprint 不一致問題を解決
  - タグの再作成により、SPM のバージョン解決エラーを修正
  - ユーザーが `does not match previously recorded value` エラーに遭遇する問題を解消

## [1.0.6] - 2025-11-06

### 追加
- **ネストプレゼンテーション機能**: シート内からシートを開く機能を追加
  - `PresentationContext` enum - `.navigation` と `.sheet` で階層を区別
  - シート内プレゼンテーション用の `.sheetPresenter()` modifier
  - TodoExampleに `CategoryPickerSheet` 実装例を追加
  - クロージャベースのデータ受け渡しで型安全性を確保

- **統合コンテキストサポート**: すべてのプレゼンテーションタイプにコンテキスト対応
  - `Sheet` - `.sheet(AppSheet.self, context: .sheet)` でネスト可能
  - `FullScreenCover` - `.fullScreenCover(Cover.self, context: .sheet)` でネスト可能
  - `CustomHeightSheet` - `.customHeightSheet(Sheet.self, context: .sheet)` でネスト可能
  - `Alert` - 既存の `context` パラメータを統合 `PresentationContext` に統一

### 改善
- **大規模なファイル構造リファクタリング**: コードベースの保守性と可読性を大幅に向上
  - 1000行超の大規模ファイルを機能別に分割（単一責任の原則に準拠）
  - 各プレゼンタータイプごとにファイルを整理（Alert/, Sheet/, Router/, など）
  - 公開APIと内部実装の明確な分離

### 変更
- **ディレクトリ構造の最適化**:
  - `Internal/` ディレクトリを削除（不要になった）
  - `Environment/` ディレクトリを削除（ファイルを適切な場所に再配置）
  - `Common/` ディレクトリに共通コンポーネントを集約
    - `PresentationContext.swift` - 共通enum
    - `RoutingModifier.swift` - 統合Modifier

- **ファイル分割の詳細**:
  - `Specifiers.swift` (146行) → 7つの専用ファイルに分割
  - `GenericEnvironmentKeys.swift` (135行) → 7つの専用ファイルに分割
  - `StaticMemberLookup.swift` (364行) → 7つの専用ファイルに分割
  - `PresentationModifiers.swift` (255行) → 4つの専用ファイルに分割
  - `EnvironmentSubscripts.swift` (100行) → 7つの専用ファイルに分割

### 技術的改善
- **コロケーション**: 関連するファイルを同じディレクトリに配置
  - 例: `Sheet/` に `SheetPresenter.swift`, `SheetSpecifier.swift`, `SheetEnvironmentKey.swift`, `SheetModifiers.swift` など
- **単一責任**: 各ファイルが1つの明確な責務のみを持つ
- **保守性向上**: 変更時の影響範囲が明確化
- **型安全なネスト**: クロージャを使用してBindingのHashable問題を回避

### 影響
- ✅ **公開API**: 後方互換性あり（新機能は additive）
- ✅ **ビルド**: すべて正常にコンパイル
- ✅ **ドキュメント**: すべて最新の構造を反映
- ✅ **機能**: すべての機能が正常に動作

## [1.0.5] - 2025-11-06

### 追加
- **Mirror-based Hashable/Equatable実装**: すべてのプロトコルにenumのassociated values対応を追加
  - `FullScreenCoverable` - クロージャを含むassociated valuesに対応
  - `Sheetable` - クロージャを含むassociated valuesに対応
  - `Routable` - クロージャを含むassociated valuesに対応
  - `CustomHeightSheetable` - 既存実装に`nonisolated`を追加
  - `Alertable` - 既存実装に`nonisolated`を追加

### 改善
- **Swift 6並行性対応**: すべてのHashable/Equatable実装に`nonisolated`を適用
  - 厳格な並行性チェック（Swift 6）に完全対応
  - Main Actor isolationとの競合を解消
- **ドキュメント充実**: クロージャ対応の使用例を追加
  - `FullScreenCoverable`: `picker(onSelect: (Item) -> Void)` の例
  - `Routable`: `editor(onSave: () -> Void)` の例
  - すべてのプロトコルに一貫した注意書きを追加

### 技術詳細
- **Mirror-based実装の仕組み**:
  - enumのcase名で同一性を判定
  - Hashable型のassociated valueのみを比較・ハッシュ化
  - クロージャ型は`AnyHashable`に変換できないため自動的に除外
  - 手動でのHashable/Equatable実装が不要に

### 利点
- ✅ クロージャを含むenumでコンパイルエラーが発生しない
- ✅ 型安全性を維持しながら柔軟な設計が可能
- ✅ ボイラープレートコードの大幅削減
- ✅ Swift 6の厳格な並行性チェックに対応

## [1.0.4] - 2025-11-04

### 追加
- **ThreeColumnSplitViewRouting**: 3カラムNavigationSplitView（サイドバー | リスト | 詳細）の完全対応
  - `ContentItem: Selectable` - 中央カラムで選択可能なアイテム型
  - `ContentRoute: Routable` - 中央カラム内でのナビゲーション
  - `contentView` - 中央カラムに表示するビュー
- **4階層ルーティング**:
  1. サイドバー切り替え（受信箱 → 送信済み）
  2. コンテンツ選択（メール選択 → 詳細に表示）
  3. ContentRoute（中央カラム内のpush遷移）
  4. DetailRoute（詳細カラム内のpush遷移）
- **selectedContentBinding**: 中央カラムの選択状態を型安全に管理
  - `@Environment(.selectedContentBinding(Email.self))` でアクセス
  - ジェネリックな実装で完全な型安全性
- **MailExample**: 3カラムSplitViewの完全実装例
  - サイドバーごとに異なるデータ表示
  - ContentRoute/DetailRouteの実装例
  - 2カラムとの比較

### 改善
- **README完全リニューアル**: 404行 → 238行（41%削減）
  - 冒頭にコード例を追加（3行で全機能を理解）
  - 3カラムSplitViewの完全説明
  - API一覧の追加
  - 実装例重視の構成
- **ドキュメントコメント改善**: 利用者目線での説明に統一
  - 「将来使用」などの不正確な表現を削除
  - 具体例を汎用的に改善
  - 各型の役割と使い分けを明確化
- **Examples README追加**: TodoExample/MailExampleの説明を充実

### 内部実装
- `SelectedContentBindingSpecifier` - 型安全なBinding管理
- `GenericSelectedContentBindingKey` - Environment統合
- `ThreeColumnSplitViewRoutingModifier` - 自動ルーティング設定
- 既存のRouter/SheetPresenterと同じSpecifierパターンを踏襲
- ランタイムチェック（`!= Never.self`）で機能の有無を判定

## [1.0.3] - 2025-11-04

### 追加
- **DocC ドキュメント自動デプロイ**: GitHub Actions による GitHub Pages へのドキュメント自動公開
  - main ブランチへのプッシュで自動的にドキュメントを生成・デプロイ
  - オンラインドキュメント: https://no-problem-dev.github.io/swift-ui-routing/documentation/uirouting/
- **README にドキュメント URL を追加**: オンラインドキュメントへのリンクを追加

### 改善
- swift-docc-plugin の依存関係を追加
- GitHub Actions ワークフローで macOS ランナーと Xcode 16.1 を使用
- SwiftPM サンドボックス権限の適切な処理

## [1.0.2] - 2025-11-04

### 追加
- **クロスタブナビゲーション**: タブ切り替えと画面遷移を同時に実行する機能を実装
  - `tabPresenter.select(.home) { context in context.router.navigate(to: .detail) }` API
  - 各タブごとに独立したRouterを保持
- **自動ルーティング設定**: `TabRouting`が各タブに自動的にルーティング機能を適用
- **包括的な公開APIドキュメント**: 全公開APIに利用者目線のドキュメントコメントを追加

### 変更
- **enum-basedタブアプローチ**: タブ定義を簡素化し、ボイラープレートコードを削減
  - `RoutingConfiguration`プロトコルを削除
  - `Tabbable`プロトコルに直接`associatedtype`を定義
- **README大幅更新**: クイックスタートをタブベースアプリに変更し、より実践的な例を提供

### 改善
- `.routingScope()`の順序を最適化（`.routing()`の前に配置）
- タブ切り替えのアニメーション完了を待機してから画面遷移を実行（視覚的に自然な動作）
- サンプルアプリでフルスクリーンカバーとカスタム高さシートを有効化

### 修正
- クロスタブナビゲーションが複数回実行される問題を修正
- タブ切り替え前のRouterに対してナビゲーションが実行される問題を解決

### 削除
- `RoutingConfiguration.swift`: 使用されていないプロトコル
- `TodoListRoutingConfig.swift`: enum-based移行により不要になった設定ファイル
- 重複したTabView説明セクションをREADMEから削除（131行削減）

## [1.0.1] - 2025-11-04

### 追加
- **TabView対応**: 型安全なタブ管理機能を実装
  - `Tabbable`プロトコル - タブの定義（body + tabLabel）
  - `TabPresenter` - タブの選択状態を管理（selectedTab + select()）
  - `TabRouting` View - TabViewを直接構築する簡潔なAPI
  - Environment統合 - `@Environment(.tab(AppTab.self))` でアクセス可能
  - タブごとに独立したNavigationStack、Router、AlertPresenterを保持

- **フルスクリーンカバー対応**: `FullScreenCoverPresenter` を実装
  - `AppFullScreenCover` enum - フルスクリーンモーダル定義
  - TodoExampleに実装例を追加（PhotoCaptureView、NoteEditorView）
  - Environment統合 - `@Environment(.fullScreenCover(Cover.self))`

- **カスタム高さシート対応**: `CustomHeightSheetPresenter` を実装
  - `CustomHeightSheetable`プロトコル - detentsで高さをカスタマイズ
  - TodoExampleに実装例を追加（CategoryPickerSheet、QuickAddSheet）
  - Environment統合 - `@Environment(.customHeightSheet(Sheet.self))`

### 改善
- **アラートAPI改善**: より直感的な命名に変更
  - `.alertOnNavigation()` → `.routingAlert()` に変更
  - `.alertOnSheet()` → `.sheetAlert()` に変更
  - NavigationStack以外でも使えることを明示

### 修正
- RoutingScopeModifierでListView（root content）にもアラートを適用
  - 以前は遷移先画面にしかアラートが適用されていなかった
  - NavigationStackの最初の画面でもアラートが動作するように修正

### 変更
- TodoExample大幅拡張
  - タブベースのアプリ構造に移行
  - AppRouteからsettingsケースを削除（タブに移行）
  - TodoTabRoot - Todoタブの独立したルーティングコンテキスト
  - AdvancedSettingsSheet - Sheet内独自NavigationStack実装例
- README更新 - TabView、FullScreenCover、CustomHeightSheetの使用例を追加

## [1.0.0] - 2025-11-03

### 追加
- **初回リリース**: SwiftUI向け型安全なルーティングライブラリ

- **基本ルーティング機能**:
  - `Router<Route>` - NavigationStack統合のルーティング管理
  - `Routable`プロトコル - 画面遷移の型定義
  - `navigate(to:)` - 型安全な画面遷移
  - `back()` / `popToRoot()` - ナビゲーションスタック操作

- **シート管理**:
  - `SheetPresenter<Sheet>` - モーダルシート管理
  - `Sheetable`プロトコル - シート定義（Identifiable + Hashable + body）
  - `present()` / `dismiss()` - シート表示・非表示

- **アラート管理**:
  - `AlertPresenter<Alert>` - アラート管理
  - `Alertable`プロトコル - アラート定義（title + actions）
  - `AlertAction` - アラートボタン定義（default/cancel/destructive）

- **Environment統合**:
  - 静的メンバールックアップパターン
  - `@Environment(.router(Route.self))` - Router取得
  - `@Environment(.sheet(Sheet.self))` - SheetPresenter取得
  - `@Environment(.alert(Alert.self, context:))` - AlertPresenter取得

- **コンテキスト分離**:
  - Navigation階層とSheet階層で独立したAlertPresenterを持つ
  - `.navigation` / `.sheet` コンテキストでアラートを区別

- **TodoExampleサンプルアプリ**:
  - Router、SheetPresenter、AlertPresenterの実装例
  - Todoリストアプリ（追加、編集、削除、フィルタ）
  - カテゴリ管理、設定画面

### 技術仕様
- **プラットフォーム**: iOS 17.0+、macOS 14.0+
- **言語**: Swift 6.0+
- **依存関係**: ゼロ依存
- **アーキテクチャ**:
  - Specifierパターン - 環境値の識別
  - GenericEnvironmentKey - 型安全な環境値アクセス
  - EnvironmentSubscript - 動的な環境値解決

[未リリース]: https://github.com/no-problem-dev/swift-ui-routing/compare/v1.0.11...HEAD
[1.0.11]: https://github.com/no-problem-dev/swift-ui-routing/compare/v1.0.10...v1.0.11
[1.0.10]: https://github.com/no-problem-dev/swift-ui-routing/compare/v1.0.9...v1.0.10
[1.0.9]: https://github.com/no-problem-dev/swift-ui-routing/compare/v1.0.8...v1.0.9
[1.0.8]: https://github.com/no-problem-dev/swift-ui-routing/compare/v1.0.7...v1.0.8

<!-- Auto-generated on 2025-11-09T01:33:52Z by release workflow -->
