import XCTest
@testable import MeterMind

final class AggregationServiceTests: XCTestCase {
    private let service = AggregationService(calendar: Calendar(identifier: .gregorian))

    func testWeeklyAggregation() {
        let intervals = [
            makeInterval(date: makeDate(year: 2026, month: 1, day: 5), value: 10),
            makeInterval(date: makeDate(year: 2026, month: 1, day: 6), value: 15),
            makeInterval(date: makeDate(year: 2026, month: 1, day: 12), value: 20)
        ]

        let data = service.weeklyAggregation(intervals: intervals)

        XCTAssertEqual(data.count, 2)
        XCTAssertEqual(data[0].value, 25)
        XCTAssertEqual(data[1].value, 20)
    }

    func testMonthlyAggregation() {
        let intervals = [
            makeInterval(date: makeDate(year: 2026, month: 1, day: 5), value: 10),
            makeInterval(date: makeDate(year: 2026, month: 1, day: 20), value: 15),
            makeInterval(date: makeDate(year: 2026, month: 2, day: 1), value: 20)
        ]

        let data = service.monthlyAggregation(intervals: intervals)

        XCTAssertEqual(data.count, 2)
        XCTAssertEqual(data[0].value, 25)
        XCTAssertEqual(data[1].value, 20)
    }

    func testYearlyAggregation() {
        let intervals = [
            makeInterval(date: makeDate(year: 2025, month: 12, day: 31), value: 10),
            makeInterval(date: makeDate(year: 2026, month: 1, day: 1), value: 15),
            makeInterval(date: makeDate(year: 2026, month: 2, day: 1), value: 20)
        ]

        let data = service.yearlyAggregation(intervals: intervals)

        XCTAssertEqual(data.count, 2)
        XCTAssertEqual(data[0].value, 10)
        XCTAssertEqual(data[1].value, 35)
    }
}
