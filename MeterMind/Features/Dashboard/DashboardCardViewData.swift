import SwiftUI

/// Presentation data for one meter card on the dashboard.
struct DashboardCardViewData: Identifiable {
    /// Meter identifier used for navigation.
    let meterId: UUID

    /// User-facing meter name.
    let meterName: String

    /// Meter category.
    let meterType: MeterType

    /// SF Symbol name for the meter type.
    let iconName: String

    /// Accent color for the meter type.
    let iconColor: Color

    /// Latest captured reading value, if available.
    let latestReadingValue: Decimal?

    /// Latest captured reading date, if available.
    let latestReadingDate: Date?

    /// Consumption between the latest two readings.
    let latestConsumptionValue: Decimal?

    /// Trend compared with the previous consumption period.
    let latestTrend: PeriodComparison?

    /// Unit used by this meter.
    let unit: String

    /// Sort order used by dashboard edit mode.
    let dashboardSortOrder: Int

    /// Whether this meter is visible on the dashboard.
    let isVisibleOnDashboard: Bool

    /// Monthly consumption values for the last 12 calendar months.
    let monthlyConsumptionValues: [AnalyticsDataPoint]

    /// Stable identifier for SwiftUI lists.
    var id: UUID {
        meterId
    }
}
