import SwiftUI

// MARK: - Conditional Presentation Modifier

/// Attaches the sheet modifier only when the sheet type is not `Never`.
///
/// Lets the routing modifiers stay uniform while a screen that declares no sheets pays nothing
/// for the machinery.
struct SheetModifierIfNeeded<Sheet: Sheetable>: ViewModifier {
    @Bindable var presenter: SheetPresenter<Sheet>
    @Environment(\.self) private var environment

    func body(content: Content) -> some View {
        if Sheet.self != Never.self {
            content.sheet(item: $presenter.presentedSheet) { sheet in
                sheet.body
                    .transformEnvironment(\.self) { env in
                        // Carry the same presenter into the sheet so its content can dismiss itself.
                        env[sheetPresenter: SheetPresenterSpecifier<Sheet>(context: .navigation)] = presenter
                    }
            }
        } else {
            content
        }
    }
}

// MARK: - Public Sheet Presenter Modifier

public extension View {
    /// Creates a sheet presenter, publishes it, and attaches the sheet modifier for it.
    ///
    /// Choose the context by where the presentation is triggered from. `.navigation` is for a
    /// screen managing its own sheets, read back as `@Environment(.sheet(AppSheet.self))`;
    /// `.sheet` is for opening a second sheet from inside the first, read back as
    /// `@Environment(.sheet(AppSheet.self, context: .sheet))`.
    ///
    /// ```swift
    /// // At the root of a navigation stack
    /// NavigationStack {
    ///     ContentView()
    /// }
    /// .sheetPresenter(for: AppSheet.self)
    ///
    /// // From inside a sheet
    /// SettingsSheet()
    ///     .sheetPresenter(for: AppSheet.self, context: .sheet)
    /// ```
    ///
    /// - Parameters:
    ///   - type: The sheet type this presenter handles.
    ///   - context: The layer the sheet is presented from.
    func sheetPresenter<Sheet: Sheetable>(
        for type: Sheet.Type,
        context: PresentationContext = .navigation
    ) -> some View {
        modifier(SheetPresenterModifier<Sheet>(context: context))
    }
}

/// Owns a sheet presenter and attaches the sheet modifier for it.
struct SheetPresenterModifier<Sheet: Sheetable>: ViewModifier {
    let context: PresentationContext
    @State private var presenter = SheetPresenter<Sheet>()

    func body(content: Content) -> some View {
        @Bindable var bindablePresenter = presenter

        content
            .environment(\.[sheetPresenter: SheetPresenterSpecifier<Sheet>(context: context)], presenter)
            .sheet(item: $bindablePresenter.presentedSheet) { sheet in
                sheet.body
                    .transformEnvironment(\.self) { env in
                        // Carry the same presenter into the sheet so its content can dismiss itself.
                        env[sheetPresenter: SheetPresenterSpecifier<Sheet>(context: context)] = presenter
                    }
            }
    }
}
