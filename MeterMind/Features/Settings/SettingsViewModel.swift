import Foundation

/// View model for the settings placeholder screen.
@MainActor
final class SettingsViewModel {
    // MARK: - Properties

    let title = AppStrings.settingsTitle
    let message = AppStrings.settingsPlaceholderMessage
    let icon = "gearshape"

    // MARK: - Initialization

    init(dependencies: AppDependencies) {
        _ = dependencies
    }
}
