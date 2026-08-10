import SwiftUI

/// The environment lookup for a custom-height sheet presenter of a given type and layer.
///
/// The sheet type and the layer together pick the presenter, so reading without a context from
/// inside a sheet reaches the navigation layer's presenter instead of the sheet's own.
///
/// ```swift
/// // From the main content
/// struct ContentView: View {
///     @Environment(.customHeightSheet(AppCustomSheet.self)) private var presenter
///
///     var body: some View {
///         Button("Show Custom Sheet") {
///             presenter.present(.filter)
///         }
///     }
/// }
///
/// // From inside a sheet
/// struct SettingsSheet: View {
///     @Environment(.customHeightSheet(AppCustomSheet.self, context: .sheet)) private var presenter
///
///     var body: some View {
///         Button("Show Another Custom Sheet") {
///             presenter.present(.filter)
///         }
///         .customHeightSheetPresenter(for: AppCustomSheet.self)
///     }
/// }
/// ```
public struct CustomHeightSheetEnvironmentKey<Sheet> where Sheet: Identifiable & Hashable {
    fileprivate let specifier: CustomHeightSheetPresenterSpecifier<Sheet>
    fileprivate init(context: PresentationContext = .navigation) {
        self.specifier = CustomHeightSheetPresenterSpecifier<Sheet>(context: context)
    }
}

public extension CustomHeightSheetEnvironmentKey {
    /// Builds the environment lookup for custom-height sheet presenters of the given type.
    ///
    /// - Parameters:
    ///   - type: The sheet type whose presenter should be read.
    ///   - context: The layer the presenter belongs to.
    static func customHeightSheet(_ type: Sheet.Type, context: PresentationContext = .navigation) -> CustomHeightSheetEnvironmentKey<Sheet> {
        CustomHeightSheetEnvironmentKey<Sheet>(context: context)
    }
}

public extension Environment {
    init<Sheet>(_ key: CustomHeightSheetEnvironmentKey<Sheet>) where Value == CustomHeightSheetPresenter<Sheet>, Sheet: Identifiable & Hashable {
        self.init(\.[customHeightSheetPresenter: key.specifier])
    }
}
