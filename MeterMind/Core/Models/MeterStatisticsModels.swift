import Foundation

/// Relative comparison between two periods.
struct PeriodComparison: Equatable {
    /// Current period value.
    let currentValue: Decimal

    /// Previous comparable period value.
    let previousValue: Decimal

    /// Percentage delta from previous to current.
    let percentageDelta: Decimal

    /// Whether the current value is lower than the previous value.
    var isDecrease: Bool {
        percentageDelta < 0
    }
}

/// Status for a monthly journey card.
enum ConsumptionStatus: String, Equatable {
    case normal
    case low
    case elevated
    case noData
}

/// Display-ready monthly journey item.
struct MonthlyJourneyItem: Identifiable, Equatable {
    /// Stable identifier.
    let id: UUID

    /// Month start date.
    let date: Date

    /// Month label.
    let monthLabel: String

    /// Consumption value for the month.
    let value: Decimal?

    /// Comparison to the previous month.
    let previousMonthComparison: PeriodComparison?

    /// Comparison to the same month in the previous year.
    let previousYearComparison: PeriodComparison?

    /// Relative visual level between 0 and 1.
    let level: Double

    /// Consumption status.
    let status: ConsumptionStatus

    /// Creates a journey item.
    init(
        id: UUID = UUID(),
        date: Date,
        monthLabel: String,
        value: Decimal?,
        previousMonthComparison: PeriodComparison?,
        previousYearComparison: PeriodComparison?,
        level: Double,
        status: ConsumptionStatus
    ) {
        self.id = id
        self.date = date
        self.monthLabel = monthLabel
        self.value = value
        self.previousMonthComparison = previousMonthComparison
        self.previousYearComparison = previousYearComparison
        self.level = level
        self.status = status
    }
}

/// Compact summary for a meter's statistics.
struct MeterStatisticsSummary: Equatable {
    /// Average monthly consumption.
    let average: Decimal?

    /// Highest month label.
    let highestMonth: String?

    /// Lowest month label.
    let lowestMonth: String?

    /// Number of readings.
    let readingCount: Int
}

/// Rule-based insight variants.
enum MeterInsight: Equatable {
    case lowerThanPrevious(percentage: Decimal)
    case lowestConsumption
    case needsMoreReadings
    case staleReading(days: Int)
    case none
}
