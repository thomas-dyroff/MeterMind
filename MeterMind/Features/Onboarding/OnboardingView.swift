import SwiftUI

/// Onboarding wizard shown on first launch and from Settings.
struct OnboardingView: View {
    // MARK: - Properties

    @ObservedObject var state: OnboardingState
    let onFinish: () -> Void

    // MARK: - Body

    var body: some View {
        VStack(spacing: 0) {
            skipBar

            TabView(selection: $state.currentPageIndex) {
                ForEach(Array(state.pages.enumerated()), id: \.element.id) { index, page in
                    OnboardingPageView(page: page)
                        .tag(index)
                }
            }
            .tabViewStyle(.page(indexDisplayMode: .never))
            .animation(.easeOut(duration: 0.2), value: state.currentPageIndex)

            footer
        }
        .background(AppTheme.Colors.background)
    }

    private var skipBar: some View {
        HStack {
            Spacer()

            Button {
                state.skip()
                onFinish()
            } label: {
                Text(AppStrings.onboardingSkip)
                    .font(AppTheme.Typography.callout)
            }
            .accessibilityLabel(Text(AppStrings.onboardingSkip))
        }
        .padding(.horizontal, AppTheme.Spacing.large)
        .padding(.top, AppTheme.Spacing.medium)
    }

    private var footer: some View {
        VStack(spacing: AppTheme.Spacing.medium) {
            progressIndicator

            PrimaryButton(title: primaryButtonTitle) {
                if state.isLastPage {
                    state.complete()
                    onFinish()
                } else {
                    state.advance()
                }
            }
            .accessibilityLabel(Text(primaryButtonTitle))
        }
        .padding(AppTheme.Spacing.large)
    }

    private var progressIndicator: some View {
        HStack(spacing: AppTheme.Spacing.small) {
            ForEach(state.pages.indices, id: \.self) { index in
                Capsule()
                    .fill(index == state.currentPageIndex ? AppTheme.Colors.accent : AppTheme.Colors.secondaryText.opacity(0.25))
                    .frame(width: index == state.currentPageIndex ? 24 : 8, height: 8)
            }
        }
        .accessibilityElement(children: .ignore)
        .accessibilityLabel(Text(progressAccessibilityText))
    }

    private var primaryButtonTitle: LocalizedStringResource {
        state.isLastPage ? AppStrings.onboardingGetStarted : AppStrings.onboardingNext
    }

    private var progressAccessibilityText: String {
        String(
            format: String(localized: AppStrings.onboardingProgressAccessibility),
            state.currentPageIndex + 1,
            state.pages.count
        )
    }
}
