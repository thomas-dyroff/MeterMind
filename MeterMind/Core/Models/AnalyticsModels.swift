import Foundation

/// A calculated consumption interval between two readings.
struct ConsumptionInterval: Identifiable, Equatable {
    /// Stable identifier.
    let id: UUID

    /// Meter identifier.
    let meterId: UUID

    /// Meter display name.
    let meterName: String

    /// Meter unit.
    let unit: String

    /// Previous reading date.
    let startDate: Date

    /// Current reading date.
    let endDate: Date

    /// Calculated consumption.
    let value: Decimal

    /// Creates a consumption interval.
    init(
        id: UUID = UUID(),
        meterId: UUID,
        meterName: String,
        unit: String,
        startDate: Date,
        endDate: Date,
        value: Decimal
    ) {
        self.id = id
        self.meterId = meterId
        self.meterName = meterName
        self.unit = unit
        self.startDate = startDate
        self.endDate = endDate
        self.value = value
    }
}

/// Aggregated numeric data for charts and KPIs.
struct AnalyticsDataPoint: Identifiable, Equatable {
    /// Stable identifier.
    let id: UUID

    /// Period start date.
    let date: Date

    /// Aggregated value.
    let value: Decimal

    /// Creates an analytics data point.
    init(id: UUID = UUID(), date: Date, value: Decimal) {
        self.id = id
        self.date = date
        self.value = value
    }

    /// Value converted for Swift Charts.
    var chartValue: Double {
        NSDecimalNumber(decimal: value).doubleValue
    }
}

/// Cost data for charts and KPIs.
struct CostDataPoint: Identifiable, Equatable {
    /// Stable identifier.
    let id: UUID

    /// Date associated with the calculated cost.
    let date: Date

    /// Calculated cost.
    let value: Decimal

    /// Currency code.
    let currency: String

    /// Creates a cost data point.
    init(id: UUID = UUID(), date: Date, value: Decimal, currency: String) {
        self.id = id
        self.date = date
        self.value = value
        self.currency = currency
    }

    /// Value converted for Swift Charts.
    var chartValue: Double {
        NSDecimalNumber(decimal: value).doubleValue
    }
}

/// Supported analytics periods.
enum AnalyticsPeriod: String, CaseIterable, Identifiable {
    case week
    case month
    case year

    /// Stable identifier.
    var id: String {
        rawValue
    }

    /// Localized period title.
    var localizedTitle: LocalizedStringResource {
        switch self {
        case .week:
            AppStrings.analyticsPeriodWeek
        case .month:
            AppStrings.analyticsPeriodMonth
        case .year:
            AppStrings.analyticsPeriodYear
        }
    }
}
