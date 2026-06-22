import SwiftUI

/// Shared placeholder screen used by feature shells.
struct PlaceholderScreen: View {
    // MARK: - Properties

    private let title: LocalizedStringResource
    private let message: LocalizedStringResource
    private let icon: String

    // MARK: - Initialization

    init(
        title: LocalizedStringResource,
        message: LocalizedStringResource,
        icon: String
    ) {
        self.title = title
        self.message = message
        self.icon = icon
    }

    // MARK: - Body

    var body: some View {
        NavigationStack {
            ZStack {
                AppTheme.Colors.background
                    .ignoresSafeArea()

                SectionCard {
                    EmptyStateView(title: title, message: message, icon: icon)
                }
                .padding(AppTheme.Spacing.medium)
            }
            .navigationTitle(Text(title))
        }
    }
}
