import SwiftUI

/// How a ``Sheetable`` screen is put up.
///
/// A screen picks its style by overriding ``Sheetable/presentationStyle``; the default is
/// ``sheet``. The presenter stays the same whichever style a screen picks, so `present(_:)` and
/// `dismiss()` work unchanged.
///
/// ```swift
/// enum AppSheet: Sheetable {
///     case settings
///     case paywall
///
///     var presentationStyle: SheetPresentationStyle {
///         switch self {
///         case .settings: .sheet
///         case .paywall: .fullScreenCoverWhenRegular
///         }
///     }
///
///     @ViewBuilder
///     var body: some View { ... }
/// }
/// ```
///
/// On macOS, which has no full-screen cover, every style is presented as a sheet.
public enum SheetPresentationStyle: Hashable, Sendable {
    /// A modal sheet. On a regular-width iPad this is the centered form sheet.
    case sheet
    /// A full-screen cover at every width.
    case fullScreenCover
    /// A full-screen cover when the presenting view is regular width, and a sheet otherwise.
    ///
    /// For a screen that needs the whole display on iPad but reads best as a sheet on iPhone.
    /// The width is the presenting view's `horizontalSizeClass`, so an iPad app in a compact
    /// Split View or Slide Over window gets the sheet.
    case fullScreenCoverWhenRegular
}

/// The SwiftUI modifier a style resolves to at a given width.
enum SheetPresentationForm: Hashable, Sendable {
    case sheet
    case fullScreenCover
}

extension SheetPresentationStyle {
    func form(horizontalSizeClass: UserInterfaceSizeClass?) -> SheetPresentationForm {
        switch self {
        case .sheet:
            .sheet
        case .fullScreenCover:
            .fullScreenCover
        case .fullScreenCoverWhenRegular:
            horizontalSizeClass == .regular ? .fullScreenCover : .sheet
        }
    }
}

extension SheetPresenter {
    /// The presented sheet as seen by the modifier for one form: the sheet when it resolves to that
    /// form, and `nil` otherwise.
    ///
    /// Writing `nil` clears the presenter only while the sheet it holds still belongs to this form,
    /// so the other modifier's dismissal never takes down a sheet that has just replaced it.
    func presentedSheet(
        in form: SheetPresentationForm,
        horizontalSizeClass: UserInterfaceSizeClass?
    ) -> Binding<Sheet?> {
        Binding(
            get: {
                self.presentedSheet.flatMap { sheet in
                    sheet.presentationStyle.form(horizontalSizeClass: horizontalSizeClass) == form ? sheet : nil
                }
            },
            set: { newValue in
                if let newValue {
                    self.presentedSheet = newValue
                } else if self.presentedSheet?.presentationStyle.form(horizontalSizeClass: horizontalSizeClass) == form {
                    self.presentedSheet = nil
                }
            }
        )
    }
}
