import SwiftUI

/// Displays a single onboarding page.
struct OnboardingPageView: View {
    // MARK: - Properties

    let page: OnboardingPageModel

    // MARK: - Body

    var body: some View {
        VStack(spacing: AppTheme.Spacing.large) {
            illustration

            VStack(spacing: AppTheme.Spacing.medium) {
                Text(page.title)
                    .font(AppTheme.Typography.screenTitle)
                    .foregroundStyle(AppTheme.Colors.primaryText)
                    .multilineTextAlignment(.center)
                    .fixedSize(horizontal: false, vertical: true)

                VStack(spacing: AppTheme.Spacing.small) {
                    ForEach(page.body.indices, id: \.self) { index in
                        Text(page.body[index])
                            .font(AppTheme.Typography.body)
                            .foregroundStyle(AppTheme.Colors.secondaryText)
                            .multilineTextAlignment(.center)
                            .fixedSize(horizontal: false, vertical: true)
                    }
                }
            }
        }
        .padding(.horizontal, AppTheme.Spacing.large)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }

    private var illustration: some View {
        ZStack {
            Circle()
                .fill(AppTheme.Colors.accent.opacity(0.14))
                .frame(width: 148, height: 148)

            Image(systemName: page.iconName)
                .font(.system(size: 58, weight: .semibold))
                .foregroundStyle(AppTheme.Colors.accent)
        }
        .accessibilityElement(children: .ignore)
        .accessibilityLabel(Text(page.illustrationAccessibilityLabel))
    }
}
