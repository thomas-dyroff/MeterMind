import Foundation

/// View model for the settings screen.
@MainActor
final class SettingsViewModel {
    // MARK: - Properties

    let title = AppStrings.settingsTitle

    // MARK: - Initialization

    init(dependencies: AppDependencies) {
        _ = dependencies
    }
}
