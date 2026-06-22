import Charts
import SwiftUI

/// Analytics view for consumption and cost visualizations.
struct AnalyticsView: View {
    // MARK: - Properties

    @ObservedObject var viewModel: AnalyticsViewModel

    // MARK: - Body

    var body: some View {
        NavigationStack {
            ScrollView {
                if viewModel.hasData {
                    analyticsContent
                } else {
                    emptyState
                }
            }
            .background(AppTheme.Colors.background)
            .navigationTitle(Text(AppStrings.analyticsTitle))
            .task {
                viewModel.loadAnalytics()
            }
        }
    }

    private var analyticsContent: some View {
        VStack(spacing: AppTheme.Spacing.medium) {
            Picker(String(localized: AppStrings.analyticsPeriodPickerTitle), selection: $viewModel.selectedPeriod) {
                ForEach(AnalyticsPeriod.allCases) { period in
                    Text(period.localizedTitle)
                        .tag(period)
                }
            }
            .pickerStyle(.segmented)

            comparisonCard
            consumptionLineChart

            if !viewModel.costData.isEmpty {
                costLineChart
            }

            barChart(title: AppStrings.analyticsMonthComparisonTitle, data: viewModel.monthComparisonData)
            barChart(title: AppStrings.analyticsYearComparisonTitle, data: viewModel.yearComparisonData)
        }
        .padding(AppTheme.Spacing.medium)
    }

    private var emptyState: some View {
        SectionCard {
            EmptyStateView(
                title: AppStrings.analyticsTitle,
                message: AppStrings.analyticsEmptyMessage,
                icon: "chart.line.uptrend.xyaxis"
            )
        }
        .padding(AppTheme.Spacing.medium)
    }

    private var comparisonCard: some View {
        SectionCard {
            Text(AppStrings.analyticsComparisonTitle)
                .font(AppTheme.Typography.callout)
                .foregroundStyle(AppTheme.Colors.secondaryText)

            Text(viewModel.comparisonText)
                .font(AppTheme.Typography.screenTitle)
                .foregroundStyle(AppTheme.Colors.primaryText)

            Text(AppStrings.analyticsComparisonSubtitle)
                .font(AppTheme.Typography.callout)
                .foregroundStyle(AppTheme.Colors.secondaryText)
        }
    }

    private var consumptionLineChart: some View {
        SectionCard {
            Text(AppStrings.analyticsConsumptionChartTitle)
                .font(AppTheme.Typography.cardTitle)

            Chart(viewModel.consumptionData) { point in
                LineMark(
                    x: .value(String(localized: AppStrings.analyticsChartDateAxis), point.date),
                    y: .value(String(localized: AppStrings.analyticsChartValueAxis), point.chartValue)
                )
                .foregroundStyle(AppTheme.Colors.accent)
            }
            .frame(height: 240)
        }
    }

    private var costLineChart: some View {
        SectionCard {
            Text(AppStrings.analyticsCostChartTitle)
                .font(AppTheme.Typography.cardTitle)

            Chart(viewModel.costData) { point in
                LineMark(
                    x: .value(String(localized: AppStrings.analyticsChartDateAxis), point.date),
                    y: .value(String(localized: AppStrings.analyticsChartCostAxis), point.chartValue)
                )
                .foregroundStyle(AppTheme.Colors.warning)
            }
            .frame(height: 240)
        }
    }

    private func barChart(title: LocalizedStringResource, data: [AnalyticsDataPoint]) -> some View {
        SectionCard {
            Text(title)
                .font(AppTheme.Typography.cardTitle)

            Chart(data) { point in
                BarMark(
                    x: .value(String(localized: AppStrings.analyticsChartDateAxis), point.date),
                    y: .value(String(localized: AppStrings.analyticsChartValueAxis), point.chartValue)
                )
                .foregroundStyle(AppTheme.Colors.accent)
            }
            .frame(height: 220)
        }
    }
}
