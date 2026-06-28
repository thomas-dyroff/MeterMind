import XCTest
@testable import MeterMind

@MainActor
final class OnboardingStateTests: XCTestCase {
    private var userDefaults: UserDefaults!
    private var suiteName: String!

    override func setUpWithError() throws {
        try super.setUpWithError()
        suiteName = "MeterMindOnboardingTests-\(UUID().uuidString)"
        userDefaults = UserDefaults(suiteName: suiteName)
        userDefaults.removePersistentDomain(forName: suiteName)
    }

    override func tearDownWithError() throws {
        userDefaults.removePersistentDomain(forName: suiteName)
        userDefaults = nil
        suiteName = nil
        try super.tearDownWithError()
    }

    func testFirstAppStartShowsWizard() {
        let state = makeState()

        XCTAssertTrue(state.shouldShowAutomaticOnboarding)
        XCTAssertFalse(state.hasCompletedOnboarding)
    }

    func testCompletionSetsHasCompletedOnboarding() {
        let state = makeState()

        state.complete()

        XCTAssertTrue(state.hasCompletedOnboarding)
        XCTAssertFalse(state.shouldShowAutomaticOnboarding)
    }

    func testSkippingSetsHasCompletedOnboarding() {
        let state = makeState()

        state.skip()

        XCTAssertTrue(state.hasCompletedOnboarding)
        XCTAssertFalse(state.shouldShowAutomaticOnboarding)
    }

    func testManualStartFromSettingsIsPossible() {
        let state = makeState()

        state.startManualOnboarding()

        XCTAssertTrue(state.isManuallyPresented)
        XCTAssertEqual(state.currentPageIndex, 0)
    }

    func testManualOnboardingCanReturnToSettings() {
        let state = makeState()
        state.startManualOnboarding()

        state.finishManualOnboarding()

        XCTAssertFalse(state.isManuallyPresented)
    }

    func testLastSeenOnboardingVersionIsSetOnCompletion() {
        let state = makeState()

        state.complete()

        XCTAssertEqual(
            state.lastSeenOnboardingVersion,
            OnboardingStorageKeys.currentOnboardingVersion
        )
    }

    func testAfterCompletionNormalAppCanBeShown() {
        let state = makeState()

        state.complete()

        XCTAssertFalse(state.shouldShowAutomaticOnboarding)
    }

    private func makeState() -> OnboardingState {
        OnboardingState(userDefaults: userDefaults)
    }
}
