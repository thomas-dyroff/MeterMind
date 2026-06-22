import XCTest
@testable import MeterMind

final class CostAnalysisServiceTests: XCTestCase {
    private let service = CostAnalysisService()

    func testCalculateCostsWithTariff() {
        let interval = makeInterval(date: makeDate(year: 2026, month: 1, day: 10), value: 100)
        let tariff = Tariff(pricePerUnit: 2, currency: "EUR", validFrom: makeDate(year: 2026, month: 1, day: 1))

        let costs = service.calculateCosts(intervals: [interval], tariffs: [tariff])

        XCTAssertEqual(costs.count, 1)
        XCTAssertEqual(costs.first?.value, 200)
    }

    func testCalculateCostsWithoutTariffReturnsEmptyResult() {
        let interval = makeInterval(date: makeDate(year: 2026, month: 1, day: 10), value: 100)

        let costs = service.calculateCosts(intervals: [interval], tariffs: [])

        XCTAssertTrue(costs.isEmpty)
    }

    func testCalculateCostsWithMultipleTariffPeriods() {
        let intervals = [
            makeInterval(date: makeDate(year: 2026, month: 1, day: 10), value: 100),
            makeInterval(date: makeDate(year: 2026, month: 2, day: 10), value: 100)
        ]
        let tariffs = [
            Tariff(pricePerUnit: 1, currency: "EUR", validFrom: makeDate(year: 2026, month: 1, day: 1)),
            Tariff(pricePerUnit: 2, currency: "EUR", validFrom: makeDate(year: 2026, month: 2, day: 1))
        ]

        let costs = service.calculateCosts(intervals: intervals, tariffs: tariffs)

        XCTAssertEqual(costs.map(\.value), [100, 200])
    }
}

func makeMeter() -> Meter {
    Meter(name: "Power", type: .electricityImport, unit: "kWh")
}

func makeInterval(date: Date, value: Decimal) -> ConsumptionInterval {
    ConsumptionInterval(
        meterId: UUID(),
        meterName: "Power",
        unit: "kWh",
        startDate: date,
        endDate: date,
        value: value
    )
}

func makeDate(year: Int, month: Int, day: Int) -> Date {
    var components = DateComponents()
    components.calendar = Calendar(identifier: .gregorian)
    components.timeZone = TimeZone(secondsFromGMT: 0)
    components.year = year
    components.month = month
    components.day = day
    return components.date ?? Date(timeIntervalSince1970: 0)
}
