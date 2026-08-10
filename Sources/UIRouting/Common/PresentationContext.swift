import SwiftUI

// MARK: - Presentation Context

/// The layer a sheet, cover, or alert is attached to.
///
/// SwiftUI cannot present from a view that is already covered, so anything opened from inside
/// a sheet needs its own layer or it silently never appears.
public enum PresentationContext: Hashable {
    /// The main navigation layer, and the default for every presenter.
    case navigation
    /// The layer of an open sheet, for presentations triggered from inside it.
    case sheet
}
