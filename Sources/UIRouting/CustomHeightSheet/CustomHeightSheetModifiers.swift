import SwiftUI

// MARK: - Conditional Presentation Modifier

/// Attaches the custom-height sheet modifier only when the sheet type is not `Never`.
///
/// Lets the routing modifiers stay uniform while a screen that declares no such sheets pays
/// nothing for the machinery.
struct CustomHeightSheetModifierIfNeeded<CustomSheet: CustomHeightSheetable>: ViewModifier {
    @Bindable var presenter: CustomHeightSheetPresenter<CustomSheet>
    @Environment(\.self) private var environment

    func body(content: Content) -> some View {
        if CustomSheet.self != Never.self {
            content.sheet(item: $presenter.presentedSheet) { sheet in
                sheet.body
                    .presentationDetents(sheet.detents)
                    .transformEnvironment(\.self) { env in
                        env[customHeightSheetPresenter: CustomHeightSheetPresenterSpecifier<CustomSheet>(context: .navigation)] = presenter
                    }
            }
        } else {
            content
        }
    }
}

// MARK: - Public Custom Height Sheet Presenter Modifier

public extension View {
    /// Creates a custom-height sheet presenter for the sheet layer.
    ///
    /// Apply it inside a sheet that opens a further custom-height sheet; the presenter it
    /// installs is the one `context: .sheet` reads back.
    /// ```swift
    /// struct SettingsSheet: View {
    ///     @Environment(.customHeightSheet(AppCustomSheet.self, context: .sheet)) private var presenter
    ///
    ///     var body: some View {
    ///         Button("Show Filter") {
    ///             presenter.present(.filter)
    ///         }
    ///         .customHeightSheetPresenter(for: AppCustomSheet.self)
    ///     }
    /// }
    /// ```
    ///
    /// - Parameter type: The sheet type this presenter handles.
    func customHeightSheetPresenter<Sheet: CustomHeightSheetable>(for type: Sheet.Type) -> some View {
        modifier(CustomHeightSheetPresenterModifier<Sheet>())
    }
}

/// Owns a custom-height sheet presenter for the sheet layer.
struct CustomHeightSheetPresenterModifier<Sheet: CustomHeightSheetable>: ViewModifier {
    @State private var presenter = CustomHeightSheetPresenter<Sheet>()

    func body(content: Content) -> some View {
        @Bindable var bindablePresenter = presenter

        content
            .environment(\.[customHeightSheetPresenter: CustomHeightSheetPresenterSpecifier<Sheet>(context: .sheet)], presenter)
            .sheet(item: $bindablePresenter.presentedSheet) { sheet in
                sheet.body
                    .presentationDetents(sheet.detents)
                    .transformEnvironment(\.self) { env in
                        env[customHeightSheetPresenter: CustomHeightSheetPresenterSpecifier<Sheet>(context: .sheet)] = presenter
                    }
            }
    }
}
