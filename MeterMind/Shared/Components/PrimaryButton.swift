import SwiftUI

/// A reusable primary action button.
struct PrimaryButton: View {
    // MARK: - Properties

    private let title: LocalizedStringResource
    private let action: () -> Void

    // MARK: - Initialization

    init(title: LocalizedStringResource, action: @escaping () -> Void) {
        self.title = title
        self.action = action
    }

    // MARK: - Body

    var body: some View {
        Button(action: action) {
            Text(title)
                .font(AppTheme.Typography.button)
                .foregroundStyle(AppTheme.Colors.buttonText)
                .frame(maxWidth: .infinity)
                .padding(.vertical, AppTheme.Spacing.medium)
        }
        .background(AppTheme.Colors.accent)
        .clipShape(RoundedRectangle(cornerRadius: AppTheme.Spacing.cornerRadius))
    }
}
