import SwiftUI

/// Root view that owns the application tab navigation.
struct NavigationRootView: View {
    // MARK: - Properties

    let viewModel: NavigationRootViewModel
    @State private var selectedTab = AppTab.dashboard

    // MARK: - Body

    var body: some View {
        TabView(selection: $selectedTab) {
            DashboardView(viewModel: viewModel.dashboardViewModel)
                .tabItem {
                    Label(AppStrings.dashboardTitle, systemImage: AppTab.dashboard.systemImage)
                }
                .tag(AppTab.dashboard)

            MetersView(viewModel: viewModel.metersViewModel)
                .tabItem {
                    Label(AppStrings.metersTitle, systemImage: AppTab.meters.systemImage)
                }
                .tag(AppTab.meters)

            ReadingsView(viewModel: viewModel.readingsViewModel)
                .tabItem {
                    Label(AppStrings.readingsTitle, systemImage: AppTab.readings.systemImage)
                }
                .tag(AppTab.readings)

            AnalyticsView(viewModel: viewModel.analyticsViewModel)
                .tabItem {
                    Label(AppStrings.analyticsTitle, systemImage: AppTab.analytics.systemImage)
                }
                .tag(AppTab.analytics)

            SettingsView(viewModel: viewModel.settingsViewModel)
                .tabItem {
                    Label(AppStrings.settingsTitle, systemImage: AppTab.settings.systemImage)
                }
                .tag(AppTab.settings)
        }
        .tint(AppTheme.Colors.accent)
    }
}

// MARK: - AppTab

private enum AppTab: Hashable {
    case dashboard
    case meters
    case readings
    case analytics
    case settings

    var systemImage: String {
        switch self {
        case .dashboard:
            "square.grid.2x2"
        case .meters:
            "gauge.with.dots.needle.bottom.50percent"
        case .readings:
            "plus.circle"
        case .analytics:
            "chart.line.uptrend.xyaxis"
        case .settings:
            "gearshape"
        }
    }
}
