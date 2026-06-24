import Foundation

/// Aggregates consumption intervals into calendar periods.
struct AggregationService {
    private let calendar: Calendar

    /// Creates an aggregation service.
    init(calendar: Calendar = .current) {
        self.calendar = calendar
    }

    /// Aggregates consumption by day.
    func dailyAggregation(intervals: [ConsumptionInterval]) -> [AnalyticsDataPoint] {
        aggregate(intervals: intervals, component: .day)
    }

    /// Aggregates consumption by week.
    func weeklyAggregation(intervals: [ConsumptionInterval]) -> [AnalyticsDataPoint] {
        aggregate(intervals: intervals, component: .weekOfYear)
    }

    /// Aggregates consumption by month.
    func monthlyAggregation(intervals: [ConsumptionInterval]) -> [AnalyticsDataPoint] {
        aggregate(intervals: intervals, component: .month)
    }

    /// Aggregates consumption by year.
    func yearlyAggregation(intervals: [ConsumptionInterval]) -> [AnalyticsDataPoint] {
        aggregate(intervals: intervals, component: .year)
    }

    private func aggregate(
        intervals: [ConsumptionInterval],
        component: Calendar.Component
    ) -> [AnalyticsDataPoint] {
        let groupedValues = Dictionary(grouping: intervals) { interval in
            calendar.dateInterval(of: component, for: interval.endDate)?.start ?? interval.endDate
        }

        return groupedValues
            .map { date, intervals in
                AnalyticsDataPoint(date: date, value: intervals.map(\.value).reduce(0, +))
            }
            .sorted { $0.date < $1.date }
    }
}
