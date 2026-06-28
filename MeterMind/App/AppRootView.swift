import SwiftUI

/// Root view that gates first launch onboarding before the main app navigation.
struct AppRootView: View {
    // MARK: - Properties

    let viewModel: NavigationRootViewModel

    @StateObject private var onboardingState = OnboardingState()

    @AppStorage(OnboardingStorageKeys.hasCompletedOnboarding)
    private var hasCompletedOnboarding = false

    // MARK: - Body

    var body: some View {
        Group {
            if hasCompletedOnboarding {
                NavigationRootView(viewModel: viewModel)
            } else {
                OnboardingView(
                    state: onboardingState,
                    onFinish: {
                        hasCompletedOnboarding = true
                    }
                )
            }
        }
    }
}
