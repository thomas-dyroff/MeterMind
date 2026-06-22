import SwiftUI

/// A reusable empty state for placeholder and empty-list screens.
struct EmptyStateView: View {
    // MARK: - Properties

    private let title: LocalizedStringResource
    private let message: LocalizedStringResource
    private let icon: String

    // MARK: - Initialization

    init(
        title: LocalizedStringResource,
        message: LocalizedStringResource,
        icon: String
    ) {
        self.title = title
        self.message = message
        self.icon = icon
    }

    // MARK: - Body

    var body: some View {
        VStack(spacing: AppTheme.Spacing.medium) {
            Image(systemName: icon)
                .font(.system(size: AppTheme.Spacing.iconSize))
                .foregroundStyle(AppTheme.Colors.accent)

            Text(title)
                .font(AppTheme.Typography.cardTitle)
                .foregroundStyle(AppTheme.Colors.primaryText)

            Text(message)
                .font(AppTheme.Typography.body)
                .foregroundStyle(AppTheme.Colors.secondaryText)
                .multilineTextAlignment(.center)
        }
        .padding(AppTheme.Spacing.large)
    }
}
