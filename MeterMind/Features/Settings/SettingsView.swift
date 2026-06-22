import SwiftUI

/// Placeholder view for the settings tab.
struct SettingsView: View {
    // MARK: - Properties

    let viewModel: SettingsViewModel

    // MARK: - Body

    var body: some View {
        PlaceholderScreen(
            title: viewModel.title,
            message: viewModel.message,
            icon: viewModel.icon
        )
    }
}
