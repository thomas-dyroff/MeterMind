import Foundation

/// Content model for a single onboarding page.
struct OnboardingPageModel: Identifiable, Equatable {
    /// Stable page identifier.
    let id: String

    /// SF Symbol used for the page illustration.
    let iconName: String

    /// Localized title.
    let title: LocalizedStringResource

    /// Localized body paragraphs.
    let body: [LocalizedStringResource]

    /// VoiceOver description for the illustration.
    let illustrationAccessibilityLabel: LocalizedStringResource
}

extension OnboardingPageModel {
    /// Current onboarding pages.
    static let pages: [OnboardingPageModel] = [
        OnboardingPageModel(
            id: "welcome",
            iconName: "square.grid.2x2",
            title: AppStrings.onboardingWelcomeTitle,
            body: [
                AppStrings.onboardingWelcomeBody1,
                AppStrings.onboardingWelcomeBody2
            ],
            illustrationAccessibilityLabel: AppStrings.onboardingWelcomeIllustration
        ),
        OnboardingPageModel(
            id: "meters",
            iconName: "gauge.with.dots.needle.bottom.50percent",
            title: AppStrings.onboardingMetersTitle,
            body: [
                AppStrings.onboardingMetersBody1,
                AppStrings.onboardingMetersBody2
            ],
            illustrationAccessibilityLabel: AppStrings.onboardingMetersIllustration
        ),
        OnboardingPageModel(
            id: "readings",
            iconName: "calendar.badge.plus",
            title: AppStrings.onboardingReadingsTitle,
            body: [
                AppStrings.onboardingReadingsBody1,
                AppStrings.onboardingReadingsBody2
            ],
            illustrationAccessibilityLabel: AppStrings.onboardingReadingsIllustration
        ),
        OnboardingPageModel(
            id: "analytics",
            iconName: "chart.line.uptrend.xyaxis",
            title: AppStrings.onboardingAnalyticsTitle,
            body: [
                AppStrings.onboardingAnalyticsBody1,
                AppStrings.onboardingAnalyticsBody2,
                AppStrings.onboardingAnalyticsBody3
            ],
            illustrationAccessibilityLabel: AppStrings.onboardingAnalyticsIllustration
        )
    ]
}
