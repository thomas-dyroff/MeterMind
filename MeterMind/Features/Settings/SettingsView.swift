import SwiftUI

/// Settings screen.
struct SettingsView: View {
    // MARK: - Properties

    let viewModel: SettingsViewModel

    @StateObject private var onboardingState = OnboardingState()
    @State private var isPresentingOnboarding = false

    // MARK: - Body

    var body: some View {
        NavigationStack {
            List {
                Section {
                    Button {
                        onboardingState.startManualOnboarding()
                        isPresentingOnboarding = true
                    } label: {
                        Label(AppStrings.settingsHelpShowIntroduction, systemImage: "sparkles.rectangle.stack")
                    }
                    .accessibilityLabel(Text(AppStrings.settingsHelpShowIntroduction))
                } header: {
                    Text(AppStrings.settingsHelpTitle)
                }
            }
            .navigationTitle(Text(viewModel.title))
            .scrollContentBackground(.hidden)
            .background(AppTheme.Colors.background)
        }
        .sheet(isPresented: $isPresentingOnboarding) {
            OnboardingView(
                state: onboardingState,
                onFinish: {
                    onboardingState.finishManualOnboarding()
                    isPresentingOnboarding = false
                }
            )
        }
    }
}
