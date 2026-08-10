import SwiftUI

/// The environment lookup for a sheet presenter of a given sheet type and layer.
///
/// The sheet type and the layer together pick the presenter, so reading without a context from
/// inside a sheet reaches the navigation layer's presenter instead of the sheet's own.
///
/// ```swift
/// // From the main content
/// struct ContentView: View {
///     @Environment(.sheet(AppSheet.self)) private var sheetPresenter
///
///     var body: some View {
///         Button("Show Sheet") {
///             sheetPresenter.present(.settings)
///         }
///     }
/// }
///
/// // From inside a sheet
/// struct SettingsSheet: View {
///     @Environment(.sheet(AppSheet.self, context: .sheet)) private var sheetPresenter
///
///     var body: some View {
///         Button("Show Another Sheet") {
///             sheetPresenter.present(.about)
///         }
///         .sheetPresenter(for: AppSheet.self, context: .sheet)
///     }
/// }
/// ```
public struct SheetEnvironmentKey<Sheet> where Sheet: Identifiable & Hashable {
    fileprivate let specifier: SheetPresenterSpecifier<Sheet>
    fileprivate init(context: PresentationContext = .navigation) {
        self.specifier = SheetPresenterSpecifier<Sheet>(context: context)
    }
}

public extension SheetEnvironmentKey {
    /// Builds the environment lookup for sheet presenters of the given type.
    ///
    /// - Parameters:
    ///   - type: The sheet type whose presenter should be read.
    ///   - context: The layer the presenter belongs to.
    static func sheet(_ type: Sheet.Type, context: PresentationContext = .navigation) -> SheetEnvironmentKey<Sheet> {
        SheetEnvironmentKey<Sheet>(context: context)
    }
}

public extension Environment {
    init<Sheet>(_ key: SheetEnvironmentKey<Sheet>) where Value == SheetPresenter<Sheet>, Sheet: Identifiable & Hashable {
        self.init(\.[sheetPresenter: key.specifier])
    }
}
