import Charts
import SwiftUI

/// Compact line chart for monthly meter consumption.
struct MeterSparklineChart: View {
    // MARK: - Properties

    let values: [AnalyticsDataPoint]
    let lineColor: Color

    // MARK: - Body

    var body: some View {
        Chart {
            ForEach(values) { point in
                LineMark(
                    x: .value(String(localized: AppStrings.analyticsChartDateAxis), point.date),
                    y: .value(String(localized: AppStrings.analyticsChartValueAxis), point.chartValue)
                )
                .interpolationMethod(.catmullRom)
                .foregroundStyle(lineColor)
                .lineStyle(StrokeStyle(lineWidth: 2, lineCap: .round, lineJoin: .round))
            }

            if let lastPoint = values.last {
                PointMark(
                    x: .value(String(localized: AppStrings.analyticsChartDateAxis), lastPoint.date),
                    y: .value(String(localized: AppStrings.analyticsChartValueAxis), lastPoint.chartValue)
                )
                .foregroundStyle(lineColor)
                .symbolSize(24)
            }
        }
        .chartXAxis(.hidden)
        .chartYAxis(.hidden)
        .chartLegend(.hidden)
        .chartPlotStyle { plotArea in
            plotArea
                .background(Color.clear)
        }
        .accessibilityLabel(Text(AppStrings.dashboardSparklineAccessibilityLabel))
    }
}
