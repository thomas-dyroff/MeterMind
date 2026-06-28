import Foundation

/// Coordinates onboarding progress and persistence.
@MainActor
final class OnboardingState: ObservableObject {
    // MARK: - Properties

    @Published var currentPageIndex = 0
    @Published private(set) var isManuallyPresented = false

    let pages: [OnboardingPageModel]

    private let userDefaults: UserDefaults

    var hasCompletedOnboarding: Bool {
        userDefaults.bool(forKey: OnboardingStorageKeys.hasCompletedOnboarding)
    }

    var lastSeenOnboardingVersion: Int {
        userDefaults.integer(forKey: OnboardingStorageKeys.lastSeenOnboardingVersion)
    }

    var isLastPage: Bool {
        currentPageIndex >= pages.count - 1
    }

    var shouldShowAutomaticOnboarding: Bool {
        !hasCompletedOnboarding
    }

    // MARK: - Initialization

    init(
        pages: [OnboardingPageModel] = OnboardingPageModel.pages,
        userDefaults: UserDefaults = .standard
    ) {
        self.pages = pages
        self.userDefaults = userDefaults
    }

    // MARK: - Actions

    /// Starts onboarding from settings without changing the app root.
    func startManualOnboarding() {
        currentPageIndex = 0
        isManuallyPresented = true
    }

    /// Ends manual onboarding presentation.
    func finishManualOnboarding() {
        isManuallyPresented = false
    }

    /// Advances to the next page or completes onboarding.
    func advance() {
        guard !isLastPage else {
            complete()
            return
        }

        currentPageIndex += 1
    }

    /// Marks onboarding as completed.
    func complete() {
        persistCompletion()
    }

    /// Marks onboarding as skipped.
    func skip() {
        persistCompletion()
    }

    private func persistCompletion() {
        userDefaults.set(true, forKey: OnboardingStorageKeys.hasCompletedOnboarding)
        userDefaults.set(
            OnboardingStorageKeys.currentOnboardingVersion,
            forKey: OnboardingStorageKeys.lastSeenOnboardingVersion
        )
    }
}
