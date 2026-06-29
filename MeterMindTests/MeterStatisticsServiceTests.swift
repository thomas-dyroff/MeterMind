import XCTest
@testable import MeterMind

final class MeterStatisticsServiceTests: XCTestCase {
    private let calendar: Calendar = {
        var calendar = Calendar(identifier: .gregorian)
        calendar.timeZone = TimeZone(secondsFromGMT: 0) ?? .current
        return calendar
    }()

    func testMonthlyConsumptionAggregatesPositiveIntervals() {
        let service = MeterStatisticsService(calendar: calendar)
        let meterId = UUID()
        let intervals = [
            interval(meterId: meterId, date: date(year: 2026, month: 1, day: 10), value: 10),
            interval(meterId: meterId, date: date(year: 2026, month: 1, day: 20), value: 15),
            interval(meterId: meterId, date: date(year: 2026, month: 2, day: 10), value: 5)
        ]

        let points = service.monthlyConsumption(intervals: intervals)

        XCTAssertEqual(points.count, 2)
        XCTAssertEqual(points[0].value, 25)
        XCTAssertEqual(points[1].value, 5)
    }

    func testNegativeIntervalsAreIgnoredAsResets() {
        let service = MeterStatisticsService(calendar: calendar)
        let meterId = UUID()
        let intervals = [
            interval(meterId: meterId, date: date(year: 2026, month: 1, day: 10), value: 10),
            interval(meterId: meterId, date: date(year: 2026, month: 1, day: 20), value: -80)
        ]

        let points = service.monthlyConsumption(intervals: intervals)

        XCTAssertEqual(points.count, 1)
        XCTAssertEqual(points.first?.value, 10)
    }

    func testPreviousPeriodComparisonCalculatesPercentage() {
        let service = MeterStatisticsService(calendar: calendar)
        let points = [
            AnalyticsDataPoint(date: date(year: 2026, month: 1, day: 1), value: 100),
            AnalyticsDataPoint(date: date(year: 2026, month: 2, day: 1), value: 80)
        ]

        let comparison = service.previousPeriodComparison(points: points)

        XCTAssertEqual(comparison?.percentageDelta, -20)
        XCTAssertTrue(comparison?.isDecrease == true)
    }

    func testYearlyJourneyCreatesTwelveCards() {
        let service = MeterStatisticsService(calendar: calendar)
        let points = [
            AnalyticsDataPoint(date: date(year: 2026, month: 1, day: 1), value: 100),
            AnalyticsDataPoint(date: date(year: 2026, month: 2, day: 1), value: 80)
        ]

        let journey = service.yearlyJourney(
            monthlyPoints: points,
            referenceDate: date(year: 2026, month: 6, day: 1)
        )

        XCTAssertEqual(journey.count, 12)
        XCTAssertEqual(journey[0].value, 100)
        XCTAssertEqual(journey[1].value, 80)
        XCTAssertEqual(journey[2].status, .noData)
    }

    func testGenerateInsightDetectsLowerConsumption() {
        let service = MeterStatisticsService(calendar: calendar)
        let points = [
            AnalyticsDataPoint(date: date(year: 2026, month: 1, day: 1), value: 100),
            AnalyticsDataPoint(date: date(year: 2026, month: 2, day: 1), value: 80)
        ]
        let readings = [
            Reading(date: date(year: 2026, month: 2, day: 20), value: 180)
        ]

        let insight = service.generateInsight(
            monthlyPoints: points,
            readings: readings,
            referenceDate: date(year: 2026, month: 2, day: 21)
        )

        XCTAssertEqual(insight, .lowerThanPrevious(percentage: 20))
    }

    private func interval(meterId: UUID, date: Date, value: Decimal) -> ConsumptionInterval {
        ConsumptionInterval(
            meterId: meterId,
            meterName: "Power",
            unit: "kWh",
            startDate: date,
            endDate: date,
            value: value
        )
    }

    private func date(year: Int, month: Int, day: Int) -> Date {
        var components = DateComponents()
        components.calendar = calendar
        components.timeZone = TimeZone(secondsFromGMT: 0)
        components.year = year
        components.month = month
        components.day = day
        return components.date ?? Date(timeIntervalSince1970: 0)
    }
}
