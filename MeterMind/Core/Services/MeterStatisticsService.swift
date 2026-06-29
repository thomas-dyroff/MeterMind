import Foundation

/// Builds simplified household consumption statistics from reading intervals.
struct MeterStatisticsService {
    private let calendar: Calendar

    /// Creates a statistics service.
    init(calendar: Calendar = .current) {
        self.calendar = calendar
    }

    /// Monthly consumption aggregated from valid intervals.
    func monthlyConsumption(intervals: [ConsumptionInterval]) -> [AnalyticsDataPoint] {
        aggregate(intervals: intervals, component: .month)
    }

    /// Yearly consumption aggregated from valid intervals.
    func yearlyConsumption(intervals: [ConsumptionInterval]) -> [AnalyticsDataPoint] {
        aggregate(intervals: intervals, component: .year)
    }

    /// Comparison between the latest two values in a series.
    func previousPeriodComparison(points: [AnalyticsDataPoint]) -> PeriodComparison? {
        let sortedPoints = points.sorted { $0.date < $1.date }
        guard sortedPoints.count >= 2,
              let previousPoint = sortedPoints.dropLast().last,
              let currentPoint = sortedPoints.last else {
            return nil
        }

        return comparison(current: currentPoint.value, previous: previousPoint.value)
    }

    /// Comparison between the latest two yearly values.
    func yearlyComparison(points: [AnalyticsDataPoint]) -> PeriodComparison? {
        previousPeriodComparison(points: points)
    }

    /// Builds twelve monthly journey cards for the year containing `referenceDate`.
    func yearlyJourney(
        monthlyPoints: [AnalyticsDataPoint],
        referenceDate: Date
    ) -> [MonthlyJourneyItem] {
        guard let yearInterval = calendar.dateInterval(of: .year, for: referenceDate) else {
            return []
        }

        let valuesByMonth = Dictionary(
            uniqueKeysWithValues: monthlyPoints.map { (monthStart(for: $0.date), $0.value) }
        )
        let currentYearMonths = (0..<12).compactMap {
            calendar.date(byAdding: .month, value: $0, to: yearInterval.start)
        }
        let values = currentYearMonths.compactMap { valuesByMonth[monthStart(for: $0)] }
        let average = averageValue(values)
        let maxValue = values.max().map(decimalDouble) ?? 0

        return currentYearMonths.map { month in
            let currentMonthStart = monthStart(for: month)
            let value = valuesByMonth[currentMonthStart]
            let previousMonth = calendar.date(byAdding: .month, value: -1, to: currentMonthStart).flatMap {
                valuesByMonth[monthStart(for: $0)]
            }
            let previousYear = calendar.date(byAdding: .year, value: -1, to: currentMonthStart).flatMap {
                valuesByMonth[monthStart(for: $0)]
            }
            let level = value.map { decimalDouble($0) / max(maxValue, 1) } ?? 0

            return MonthlyJourneyItem(
                date: currentMonthStart,
                monthLabel: currentMonthStart.formatted(.dateTime.month(.abbreviated)),
                value: value,
                previousMonthComparison: previousMonth.flatMap { comparison(current: value, previous: $0) },
                previousYearComparison: previousYear.flatMap { comparison(current: value, previous: $0) },
                level: min(max(level, 0), 1),
                status: status(for: value, average: average)
            )
        }
    }

    /// Builds a compact summary from readings and monthly consumption.
    func summary(readings: [Reading], monthlyPoints: [AnalyticsDataPoint]) -> MeterStatisticsSummary {
        let values = monthlyPoints.map(\.value)
        let highestPoint = monthlyPoints.max { $0.value < $1.value }
        let lowestPoint = monthlyPoints.min { $0.value < $1.value }

        return MeterStatisticsSummary(
            average: averageValue(values),
            highestMonth: highestPoint?.date.formatted(.dateTime.month(.wide)),
            lowestMonth: lowestPoint?.date.formatted(.dateTime.month(.wide)),
            readingCount: readings.count
        )
    }

    /// Generates one positive, rule-based insight.
    func generateInsight(
        monthlyPoints: [AnalyticsDataPoint],
        readings: [Reading],
        referenceDate: Date
    ) -> MeterInsight {
        guard monthlyPoints.count >= 2 else {
            return .needsMoreReadings
        }

        if let latestReadingDate = readings.sorted(by: { $0.date > $1.date }).first?.date {
            let days = calendar.dateComponents([.day], from: latestReadingDate, to: referenceDate).day ?? 0
            if days >= 30 {
                return .staleReading(days: days)
            }
        }

        if let comparison = previousPeriodComparison(points: monthlyPoints), comparison.isDecrease {
            return .lowerThanPrevious(percentage: abs(comparison.percentageDelta))
        }

        let sortedPoints = monthlyPoints.sorted { $0.date < $1.date }
        if let latestPoint = sortedPoints.last,
           let minimumValue = sortedPoints.map(\.value).min(),
           latestPoint.value == minimumValue {
            return .lowestConsumption
        }

        return .none
    }

    private func aggregate(
        intervals: [ConsumptionInterval],
        component: Calendar.Component
    ) -> [AnalyticsDataPoint] {
        let validIntervals = intervals.filter { $0.value >= 0 }
        let groupedValues = Dictionary(grouping: validIntervals) { interval in
            calendar.dateInterval(of: component, for: interval.endDate)?.start ?? interval.endDate
        }

        return groupedValues
            .map { date, intervals in
                AnalyticsDataPoint(date: date, value: intervals.map(\.value).reduce(0, +))
            }
            .sorted { $0.date < $1.date }
    }

    private func comparison(current: Decimal?, previous: Decimal?) -> PeriodComparison? {
        guard let current, let previous, previous != 0 else {
            return nil
        }

        return PeriodComparison(
            currentValue: current,
            previousValue: previous,
            percentageDelta: ((current - previous) / previous) * 100
        )
    }

    private func averageValue(_ values: [Decimal]) -> Decimal? {
        guard !values.isEmpty else {
            return nil
        }

        return values.reduce(0, +) / Decimal(values.count)
    }

    private func status(for value: Decimal?, average: Decimal?) -> ConsumptionStatus {
        guard let value, let average, average > 0 else {
            return value == nil ? .noData : .normal
        }

        if value < average * Decimal(0.85) {
            return .low
        }
        if value > average * Decimal(1.15) {
            return .elevated
        }
        return .normal
    }

    private func monthStart(for date: Date) -> Date {
        calendar.dateInterval(of: .month, for: date)?.start ?? date
    }

    private func decimalDouble(_ value: Decimal) -> Double {
        NSDecimalNumber(decimal: value).doubleValue
    }
}
