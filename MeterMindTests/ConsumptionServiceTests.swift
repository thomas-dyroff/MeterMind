import XCTest
@testable import MeterMind

final class ConsumptionServiceTests: XCTestCase {
    private let service = ConsumptionService(calendar: Calendar(identifier: .gregorian))

    func testNormalConsumption() {
        let meter = makeMeter()
        let readings = [
            Reading(date: makeDate(year: 2026, month: 1, day: 1), value: 100),
            Reading(date: makeDate(year: 2026, month: 2, day: 1), value: 120)
        ]

        let intervals = service.calculateConsumption(readings: readings, meter: meter)

        XCTAssertEqual(intervals.count, 1)
        XCTAssertEqual(intervals.first?.value, 20)
    }

    func testIdenticalValuesProduceZeroConsumption() {
        let meter = makeMeter()
        let readings = [
            Reading(date: makeDate(year: 2026, month: 1, day: 1), value: 100),
            Reading(date: makeDate(year: 2026, month: 2, day: 1), value: 100)
        ]

        let intervals = service.calculateConsumption(readings: readings, meter: meter)

        XCTAssertEqual(intervals.first?.value, 0)
    }

    func testSingleReadingProducesNoConsumption() {
        let meter = makeMeter()
        let readings = [Reading(date: makeDate(year: 2026, month: 1, day: 1), value: 100)]

        let intervals = service.calculateConsumption(readings: readings, meter: meter)

        XCTAssertTrue(intervals.isEmpty)
    }

    func testEmptyHistoryProducesNoConsumption() {
        let intervals = service.calculateConsumption(readings: [], meter: makeMeter())

        XCTAssertTrue(intervals.isEmpty)
    }
}
