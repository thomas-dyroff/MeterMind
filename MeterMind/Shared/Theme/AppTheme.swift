import SwiftUI

/// Central design tokens for MeterMind.
enum AppTheme {
    /// Shared color definitions.
    enum Colors {
        static let background = Color(.systemGroupedBackground)
        static let surface = Color(.secondarySystemGroupedBackground)
        static let primaryText = Color(.label)
        static let secondaryText = Color(.secondaryLabel)
        static let accent = Color.green
        static let buttonText = Color.white
        static let error = Color.red
        static let warning = Color.orange
    }

    /// Shared typography definitions.
    enum Typography {
        static let screenTitle = Font.title.bold()
        static let cardTitle = Font.headline
        static let body = Font.body
        static let callout = Font.callout
        static let button = Font.headline
    }

    /// Shared spacing and sizing constants.
    enum Spacing {
        static let extraSmall: CGFloat = 4
        static let small: CGFloat = 8
        static let medium: CGFloat = 16
        static let large: CGFloat = 24
        static let extraLarge: CGFloat = 32
        static let cornerRadius: CGFloat = 8
        static let iconSize: CGFloat = 44
    }
}
