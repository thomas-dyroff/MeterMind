import Foundation
import SwiftUI

/// View model for the application tab navigation root.
@MainActor
final class NavigationRootViewModel {
    // MARK: - Properties

    let dashboardViewModel: DashboardViewModel
    let metersViewModel: MeterListViewModel
    let readingsViewModel: ReadingsViewModel
    let analyticsViewModel: AnalyticsViewModel
    let settingsViewModel: SettingsViewModel

    // MARK: - Initialization

    init(dependencies: AppDependencies) {
        self.dashboardViewModel = DashboardViewModel(dependencies: dependencies)
        self.metersViewModel = MeterListViewModel(dependencies: dependencies)
        self.readingsViewModel = ReadingsViewModel(dependencies: dependencies)
        self.analyticsViewModel = AnalyticsViewModel(dependencies: dependencies)
        self.settingsViewModel = SettingsViewModel(dependencies: dependencies)
    }
}
