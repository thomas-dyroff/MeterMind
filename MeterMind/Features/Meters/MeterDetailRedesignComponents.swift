import Charts
import SwiftUI

/// Monthly consumption line chart optimized for household readings.
struct MeterMonthlyTrendChart: View {
    let points: [MeterConsumptionChartDataPoint]
    let unit: String
    let color: Color

    @State private var selectedPoint: MeterConsumptionChartDataPoint?

    var body: some View {
        SectionCard {
            VStack(alignment: .leading, spacing: AppTheme.Spacing.medium) {
                Text(AppStrings.meterDetailMonthlyTrendTitle)
                    .font(AppTheme.Typography.cardTitle)
                    .foregroundStyle(AppTheme.Colors.primaryText)

                if points.isEmpty {
                    EmptyStateView(
                        title: AppStrings.meterDetailMonthlyTrendTitle,
                        message: AppStrings.meterDetailMonthlyTrendEmpty,
                        icon: "chart.line.uptrend.xyaxis"
                    )
                } else if points.count == 1 {
                    EmptyStateView(
                        title: AppStrings.meterDetailMonthlyTrendTitle,
                        message: AppStrings.meterDetailMonthlyTrendOneValue,
                        icon: "chart.line.uptrend.xyaxis"
                    )
                } else {
                    Chart {
                        ForEach(points) { point in
                            AreaMark(
                                x: .value(String(localized: AppStrings.analyticsChartDateAxis), point.date),
                                y: .value(String(localized: AppStrings.analyticsChartValueAxis), point.chartValue)
                            )
                            .interpolationMethod(.catmullRom)
                            .foregroundStyle(
                                LinearGradient(
                                    colors: [color.opacity(0.22), color.opacity(0.02)],
                                    startPoint: .top,
                                    endPoint: .bottom
                                )
                            )

                            LineMark(
                                x: .value(String(localized: AppStrings.analyticsChartDateAxis), point.date),
                                y: .value(String(localized: AppStrings.analyticsChartValueAxis), point.chartValue)
                            )
                            .interpolationMethod(.catmullRom)
                            .foregroundStyle(color)
                            .lineStyle(StrokeStyle(lineWidth: 3, lineCap: .round, lineJoin: .round))
                        }

                        if let selectedPoint {
                            PointMark(
                                x: .value(String(localized: AppStrings.analyticsChartDateAxis), selectedPoint.date),
                                y: .value(String(localized: AppStrings.analyticsChartValueAxis), selectedPoint.chartValue)
                            )
                            .foregroundStyle(color)
                            .symbolSize(44)
                            .annotation(position: .top) {
                                Text("\(AnalyticsFormatters.decimalString(for: selectedPoint.value)) \(unit) · \(selectedPoint.label)")
                                    .font(AppTheme.Typography.caption)
                                    .padding(AppTheme.Spacing.small)
                                    .background(.regularMaterial)
                                    .clipShape(RoundedRectangle(cornerRadius: AppTheme.Spacing.cornerRadius))
                            }
                        }
                    }
                    .frame(height: 220)
                    .chartXAxis {
                        AxisMarks(values: .automatic(desiredCount: 4))
                    }
                    .chartYAxis(.hidden)
                    .chartLegend(.hidden)
                    .chartOverlay { proxy in
                        GeometryReader { geometry in
                            if let plotFrame = proxy.plotFrame {
                                let frame = geometry[plotFrame]
                                Rectangle()
                                    .fill(Color.clear)
                                    .contentShape(Rectangle())
                                    .gesture(selectionGesture(proxy: proxy, frame: frame))
                            }
                        }
                    }
                    .accessibilityLabel(Text(AppStrings.meterDetailMonthlyTrendTitle))
                }
            }
        }
    }

    private func selectionGesture(proxy: ChartProxy, frame: CGRect) -> some Gesture {
        DragGesture(minimumDistance: 0)
            .onChanged { value in
                let xPosition = value.location.x - frame.origin.x
                guard let date = proxy.value(atX: xPosition, as: Date.self) else {
                    return
                }

                selectedPoint = points.min {
                    abs($0.date.timeIntervalSince(date)) < abs($1.date.timeIntervalSince(date))
                }
            }
            .onEnded { _ in
                selectedPoint = nil
            }
    }
}
struct MeterYearlyComparisonChart: View {
    let points: [MeterConsumptionChartDataPoint]
    let unit: String
    let color: Color

    var body: some View {
        SectionCard {
            VStack(alignment: .leading, spacing: AppTheme.Spacing.medium) {
                Text(AppStrings.meterDetailYearlyComparisonTitle)
                    .font(AppTheme.Typography.cardTitle)
                    .foregroundStyle(AppTheme.Colors.primaryText)

                if points.count < 2 {
                    EmptyStateView(
                        title: AppStrings.meterDetailYearlyComparisonTitle,
                        message: AppStrings.meterDetailYearlyComparisonEmpty,
                        icon: "chart.bar"
                    )
                } else {
                    Text(latestYearText)
                        .font(.system(size: 34, weight: .bold, design: .rounded))
                        .foregroundStyle(AppTheme.Colors.primaryText)

                    Chart(points) { point in
                        BarMark(
                            x: .value(String(localized: AppStrings.analyticsChartDateAxis), point.label),
                            y: .value(String(localized: AppStrings.analyticsChartValueAxis), point.chartValue)
                        )
                        .foregroundStyle(color.gradient)
                        .clipShape(RoundedRectangle(cornerRadius: AppTheme.Spacing.small))
                    }
                    .frame(height: 180)
                    .chartYAxis(.hidden)
                    .chartLegend(.hidden)
                    .accessibilityLabel(Text(AppStrings.meterDetailYearlyComparisonTitle))
                }
            }
        }
    }

    private var latestYearText: String {
        guard let latestPoint = points.last else {
            return ""
        }

        return "\(AnalyticsFormatters.decimalString(for: latestPoint.value)) \(unit)"
    }
}
struct MeterYearJourneyView: View {
    let items: [MonthlyJourneyItem]
    let unit: String
    let color: Color

    private let columns = [GridItem(.adaptive(minimum: 92), spacing: AppTheme.Spacing.small)]

    var body: some View {
        SectionCard {
            VStack(alignment: .leading, spacing: AppTheme.Spacing.medium) {
                Text(AppStrings.meterDetailYearJourneyTitle)
                    .font(AppTheme.Typography.cardTitle)
                    .foregroundStyle(AppTheme.Colors.primaryText)

                LazyVGrid(columns: columns, spacing: AppTheme.Spacing.small) {
                    ForEach(items) { item in
                        journeyCard(for: item)
                    }
                }
            }
        }
    }

    private func journeyCard(for item: MonthlyJourneyItem) -> some View {
        VStack(alignment: .leading, spacing: AppTheme.Spacing.small) {
            Text(item.monthLabel)
                .font(AppTheme.Typography.caption)
                .foregroundStyle(AppTheme.Colors.secondaryText)

            Text(valueText(for: item))
                .font(AppTheme.Typography.callout.weight(.semibold))
                .foregroundStyle(AppTheme.Colors.primaryText)
                .lineLimit(1)

            GeometryReader { proxy in
                Capsule()
                    .fill(color.opacity(0.16))
                    .overlay(alignment: .leading) {
                        Capsule()
                            .fill(statusColor(for: item.status))
                            .frame(width: max(proxy.size.width * item.level, 4))
                    }
            }
            .frame(height: 7)

            Text(statusText(for: item.status))
                .font(AppTheme.Typography.caption)
                .foregroundStyle(AppTheme.Colors.secondaryText)
                .lineLimit(1)
        }
        .padding(AppTheme.Spacing.small)
        .background(Color(.tertiarySystemGroupedBackground))
        .clipShape(RoundedRectangle(cornerRadius: AppTheme.Spacing.medium))
        .accessibilityElement(children: .combine)
    }

    private func valueText(for item: MonthlyJourneyItem) -> String {
        guard let value = item.value else {
            return String(localized: AppStrings.dashboardNoReadingValue)
        }

        return "\(AnalyticsFormatters.decimalString(for: value)) \(unit)"
    }

    private func statusText(for status: ConsumptionStatus) -> LocalizedStringResource {
        switch status {
        case .normal:
            AppStrings.meterDetailStatusNormal
        case .low:
            AppStrings.meterDetailStatusLow
        case .elevated:
            AppStrings.meterDetailStatusElevated
        case .noData:
            AppStrings.meterDetailStatusNoData
        }
    }

    private func statusColor(for status: ConsumptionStatus) -> Color {
        switch status {
        case .normal:
            color
        case .low:
            AppTheme.Colors.accent
        case .elevated:
            AppTheme.Colors.warning
        case .noData:
            AppTheme.Colors.secondaryText.opacity(0.35)
        }
    }
}
