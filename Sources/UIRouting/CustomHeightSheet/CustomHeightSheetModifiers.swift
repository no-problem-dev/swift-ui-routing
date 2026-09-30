import SwiftUI

// MARK: - Conditional Presentation Modifier

/// Attaches the custom-height sheet modifier only when the sheet type is not `Never`.
///
/// Lets the routing modifiers stay uniform while a screen that declares no such sheets pays
/// nothing for the machinery.
struct CustomHeightSheetModifierIfNeeded<CustomSheet: CustomHeightSheetable>: ViewModifier {
    @Bindable var presenter: CustomHeightSheetPresenter<CustomSheet>

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
    /// Creates a custom-height sheet presenter, publishes it on one layer, and attaches the sheet.
    ///
    /// The layer is spelled out at both ends: the `context` given here must be the one the reader
    /// asks for, or the reader gets a presenter nothing is bound to and `present(_:)` shows
    /// nothing. It has no default for that reason.
    ///
    /// The presenter reaches only the views below this modifier, so apply it to the parent of the
    /// view that reads it, not to the reader's own body.
    /// ```swift
    /// // The parent installs the presenter...
    /// SettingsSheet()
    ///     .customHeightSheetPresenter(for: AppCustomSheet.self, context: .sheet)
    ///
    /// // ...and the view below reads it back on the same layer.
    /// struct SettingsSheet: View {
    ///     @Environment(.customHeightSheet(AppCustomSheet.self, context: .sheet)) private var presenter
    ///
    ///     var body: some View {
    ///         Button("Show Filter") {
    ///             presenter.present(.filter)
    ///         }
    ///     }
    /// }
    /// ```
    ///
    /// - Parameters:
    ///   - type: The sheet type this presenter handles.
    ///   - context: The layer the presenter is published on; readers must ask for the same one.
    func customHeightSheetPresenter<Sheet: CustomHeightSheetable>(
        for type: Sheet.Type,
        context: PresentationContext
    ) -> some View {
        modifier(CustomHeightSheetPresenterModifier<Sheet>(context: context))
    }
}

/// Owns a custom-height sheet presenter and attaches the sheet for it.
struct CustomHeightSheetPresenterModifier<Sheet: CustomHeightSheetable>: ViewModifier {
    let context: PresentationContext
    @State private var presenter = CustomHeightSheetPresenter<Sheet>()

    func body(content: Content) -> some View {
        @Bindable var bindablePresenter = presenter

        content
            .environment(\.[customHeightSheetPresenter: CustomHeightSheetPresenterSpecifier<Sheet>(context: context)], presenter)
            .sheet(item: $bindablePresenter.presentedSheet) { sheet in
                sheet.body
                    .presentationDetents(sheet.detents)
                    .transformEnvironment(\.self) { env in
                        env[customHeightSheetPresenter: CustomHeightSheetPresenterSpecifier<Sheet>(context: context)] = presenter
                    }
            }
    }
}
