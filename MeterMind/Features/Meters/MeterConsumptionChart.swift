import Charts
import SwiftUI

/// Reusable meter consumption chart with touch selection.
struct MeterConsumptionChart: View {
    // MARK: - Properties

    let title: LocalizedStringResource
    let dataPoints: [MeterConsumptionChartDataPoint]
    let unit: String
    let periodType: MeterDetailChartPeriod

    @State private var selectedPoint: MeterConsumptionChartDataPoint?

    // MARK: - Body

    var body: some View {
        SectionCard {
            VStack(alignment: .leading, spacing: AppTheme.Spacing.medium) {
                Text(title)
                    .font(AppTheme.Typography.cardTitle)
                    .foregroundStyle(AppTheme.Colors.primaryText)

                if dataPoints.isEmpty {
                    EmptyStateView(
                        title: title,
                        message: AppStrings.meterDetailChartEmpty,
                        icon: "chart.xyaxis.line"
                    )
                } else {
                    chart
                        .frame(height: 180)
                }
            }
        }
    }

    private var chart: some View {
        Chart {
            ForEach(dataPoints) { point in
                chartMark(for: point)
            }

            if let selectedPoint {
                RuleMark(x: .value(String(localized: AppStrings.analyticsChartDateAxis), selectedPoint.date))
                    .foregroundStyle(AppTheme.Colors.secondaryText.opacity(0.35))
                    .annotation(position: .top, alignment: .center) {
                        selectedAnnotation(for: selectedPoint)
                    }

                PointMark(
                    x: .value(String(localized: AppStrings.analyticsChartDateAxis), selectedPoint.date),
                    y: .value(String(localized: AppStrings.analyticsChartValueAxis), selectedPoint.chartValue)
                )
                .foregroundStyle(AppTheme.Colors.accent)
                .symbolSize(36)
            }
        }
        .chartXAxis {
            AxisMarks(values: .automatic(desiredCount: 4)) { _ in
                AxisValueLabel()
                    .foregroundStyle(AppTheme.Colors.secondaryText)
            }
        }
        .chartYAxis {
            AxisMarks(position: .leading) { _ in
                AxisGridLine()
                    .foregroundStyle(Color(.separator).opacity(0.35))
                AxisValueLabel()
                    .foregroundStyle(AppTheme.Colors.secondaryText)
            }
        }
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
    }

    @ChartContentBuilder
    private func chartMark(for point: MeterConsumptionChartDataPoint) -> some ChartContent {
        switch periodType {
        case .week, .month:
            LineMark(
                x: .value(String(localized: AppStrings.analyticsChartDateAxis), point.date),
                y: .value(String(localized: AppStrings.analyticsChartValueAxis), point.chartValue)
            )
            .interpolationMethod(.catmullRom)
            .foregroundStyle(AppTheme.Colors.accent)
            .lineStyle(StrokeStyle(lineWidth: 2, lineCap: .round, lineJoin: .round))
        case .quarter, .year:
            BarMark(
                x: .value(String(localized: AppStrings.analyticsChartDateAxis), point.date),
                y: .value(String(localized: AppStrings.analyticsChartValueAxis), point.chartValue)
            )
            .foregroundStyle(AppTheme.Colors.accent)
        }
    }

    private func selectionGesture(proxy: ChartProxy, frame: CGRect) -> some Gesture {
        DragGesture(minimumDistance: 0)
            .onChanged { value in
                let xPosition = value.location.x - frame.origin.x
                guard let date = proxy.value(atX: xPosition, as: Date.self) else {
                    return
                }

                selectedPoint = nearestPoint(to: date)
            }
            .onEnded { _ in
                selectedPoint = nil
            }
    }

    private func selectedAnnotation(for point: MeterConsumptionChartDataPoint) -> some View {
        Text(selectionText(for: point))
            .font(AppTheme.Typography.caption)
            .foregroundStyle(AppTheme.Colors.primaryText)
            .padding(.horizontal, AppTheme.Spacing.small)
            .padding(.vertical, AppTheme.Spacing.extraSmall)
            .background(AppTheme.Colors.surface)
            .clipShape(RoundedRectangle(cornerRadius: AppTheme.Spacing.cornerRadius))
            .overlay(
                RoundedRectangle(cornerRadius: AppTheme.Spacing.cornerRadius)
                    .stroke(Color(.separator).opacity(0.35), lineWidth: 1)
            )
    }

    private func selectionText(for point: MeterConsumptionChartDataPoint) -> String {
        "\(AnalyticsFormatters.decimalString(for: point.value)) \(unit) · \(point.label)"
    }

    private func nearestPoint(to date: Date) -> MeterConsumptionChartDataPoint? {
        dataPoints.min { firstPoint, secondPoint in
            abs(firstPoint.date.timeIntervalSince(date)) < abs(secondPoint.date.timeIntervalSince(date))
        }
    }
}
