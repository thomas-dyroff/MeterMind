import Charts
import SwiftUI

/// Dashboard view for core KPIs.
struct DashboardView: View {
    // MARK: - Properties

    @ObservedObject var viewModel: DashboardViewModel

    // MARK: - Body

    var body: some View {
        NavigationStack {
            ScrollView {
                if viewModel.hasData {
                    dashboardContent
                } else {
                    emptyState
                }
            }
            .background(AppTheme.Colors.background)
            .navigationTitle(Text(AppStrings.dashboardTitle))
            .task {
                viewModel.loadDashboard()
            }
        }
    }

    private var dashboardContent: some View {
        VStack(spacing: AppTheme.Spacing.medium) {
            LazyVGrid(
                columns: [GridItem(.flexible()), GridItem(.flexible())],
                spacing: AppTheme.Spacing.medium
            ) {
                kpiCard(title: AppStrings.dashboardKpiMeterCount, value: viewModel.meterCountText)
                kpiCard(title: AppStrings.dashboardKpiLatestReading, value: viewModel.latestReadingText)
                kpiCard(title: AppStrings.dashboardKpiMonthConsumption, value: viewModel.currentMonthConsumptionText)
                kpiCard(title: AppStrings.dashboardKpiYearConsumption, value: viewModel.currentYearConsumptionText)

                if let currentMonthCostText = viewModel.currentMonthCostText {
                    kpiCard(title: AppStrings.dashboardKpiMonthCost, value: currentMonthCostText)
                }
            }

            lineChart(
                title: AppStrings.analyticsConsumptionChartTitle,
                data: viewModel.consumptionChartData
            )

            if !viewModel.costChartData.isEmpty {
                costLineChart(data: viewModel.costChartData)
            }
        }
        .padding(AppTheme.Spacing.medium)
    }

    private var emptyState: some View {
        SectionCard {
            EmptyStateView(
                title: AppStrings.dashboardTitle,
                message: AppStrings.dashboardEmptyMessage,
                icon: "square.grid.2x2"
            )
        }
        .padding(AppTheme.Spacing.medium)
    }

    private func kpiCard(title: LocalizedStringResource, value: String) -> some View {
        SectionCard {
            Text(title)
                .font(AppTheme.Typography.callout)
                .foregroundStyle(AppTheme.Colors.secondaryText)

            Text(value)
                .font(AppTheme.Typography.screenTitle)
                .foregroundStyle(AppTheme.Colors.primaryText)
        }
    }

    private func lineChart(title: LocalizedStringResource, data: [AnalyticsDataPoint]) -> some View {
        SectionCard {
            Text(title)
                .font(AppTheme.Typography.cardTitle)

            Chart(data) { point in
                LineMark(
                    x: .value(String(localized: AppStrings.analyticsChartDateAxis), point.date),
                    y: .value(String(localized: AppStrings.analyticsChartValueAxis), point.chartValue)
                )
                .foregroundStyle(AppTheme.Colors.accent)
            }
            .frame(height: 220)
        }
    }

    private func costLineChart(data: [CostDataPoint]) -> some View {
        SectionCard {
            Text(AppStrings.analyticsCostChartTitle)
                .font(AppTheme.Typography.cardTitle)

            Chart(data) { point in
                LineMark(
                    x: .value(String(localized: AppStrings.analyticsChartDateAxis), point.date),
                    y: .value(String(localized: AppStrings.analyticsChartCostAxis), point.chartValue)
                )
                .foregroundStyle(AppTheme.Colors.warning)
            }
            .frame(height: 220)
        }
    }
}
