import XCTest
@testable import MeterMind

@MainActor
final class DashboardViewModelTests: XCTestCase {
    func testMonthlyConsumptionLast12MonthsReturnsFixedWindow() {
        let meter = makeDashboardMeter()
        let viewModel = makeViewModel(meters: [meter])
        let intervals = [
            dashboardInterval(
                meter: meter,
                date: makeDate(year: 2026, month: 1, day: 15),
                value: 30
            ),
            dashboardInterval(
                meter: meter,
                date: makeDate(year: 2026, month: 3, day: 15),
                value: 50
            )
        ]

        let values = viewModel.monthlyConsumptionLast12Months(
            intervals: intervals,
            referenceDate: makeDate(year: 2026, month: 3, day: 20)
        )

        XCTAssertEqual(values.count, 12)
        XCTAssertEqual(values.first?.date, makeDate(year: 2025, month: 4, day: 1))
        XCTAssertEqual(values.last?.date, makeDate(year: 2026, month: 3, day: 1))
        XCTAssertEqual(values[9].value, 30)
        XCTAssertEqual(values[10].value, 0)
        XCTAssertEqual(values[11].value, 50)
    }

    func testMeterWithoutReadingsCreatesEmptyCard() {
        let meter = makeDashboardMeter()
        let viewModel = makeViewModel(meters: [meter])

        viewModel.loadDashboard(referenceDate: makeDate(year: 2026, month: 3, day: 20))

        XCTAssertEqual(viewModel.cards.count, 1)
        XCTAssertEqual(viewModel.cards.first?.meterName, "Power")
        XCTAssertNil(viewModel.cards.first?.latestReadingValue)
        XCTAssertNil(viewModel.cards.first?.latestReadingDate)
        XCTAssertEqual(viewModel.cards.first?.monthlyConsumptionValues.count, 12)
        XCTAssertEqual(viewModel.cards.first?.monthlyConsumptionValues.map(\.value).reduce(0, +), 0)
    }

    func testMeterWithSingleReadingCreatesLatestReadingButNoConsumption() {
        let meter = makeDashboardMeter()
        let reading = Reading(
            date: makeDate(year: 2026, month: 3, day: 1),
            value: 120,
            meter: meter
        )
        let viewModel = makeViewModel(meters: [meter], readings: [meter.id: [reading]])

        viewModel.loadDashboard(referenceDate: makeDate(year: 2026, month: 3, day: 20))

        XCTAssertEqual(viewModel.cards.first?.latestReadingValue, 120)
        XCTAssertEqual(viewModel.cards.first?.latestReadingDate, reading.date)
        XCTAssertEqual(viewModel.cards.first?.monthlyConsumptionValues.map(\.value).reduce(0, +), 0)
    }

    func testMeterWithMultipleMonthsHistoryAggregatesConsumption() {
        let meter = makeDashboardMeter()
        let readings = [
            Reading(date: makeDate(year: 2026, month: 1, day: 1), value: 100, meter: meter),
            Reading(date: makeDate(year: 2026, month: 2, day: 1), value: 130, meter: meter),
            Reading(date: makeDate(year: 2026, month: 3, day: 1), value: 170, meter: meter)
        ]
        let viewModel = makeViewModel(meters: [meter], readings: [meter.id: readings])

        viewModel.loadDashboard(referenceDate: makeDate(year: 2026, month: 3, day: 20))

        let monthlyValues = viewModel.cards.first?.monthlyConsumptionValues.map(\.value)
        XCTAssertEqual(viewModel.cards.first?.latestReadingValue, 170)
        XCTAssertEqual(monthlyValues?[9], 0)
        XCTAssertEqual(monthlyValues?[10], 30)
        XCTAssertEqual(monthlyValues?[11], 40)
    }

    func testDashboardSortsByDashboardSortOrder() {
        let firstMeter = makeDashboardMeter(name: "Water", sortOrder: 2)
        let secondMeter = makeDashboardMeter(name: "Power", sortOrder: 0)
        let thirdMeter = makeDashboardMeter(name: "Gas", sortOrder: 1)
        let viewModel = makeViewModel(meters: [firstMeter, secondMeter, thirdMeter])

        viewModel.loadDashboard(referenceDate: makeDate(year: 2026, month: 3, day: 20))

        XCTAssertEqual(viewModel.cards.map(\.meterName), ["Power", "Gas", "Water"])
    }

    func testDashboardShowsOnlyVisibleMeters() {
        let visibleMeter = makeDashboardMeter(name: "Power", sortOrder: 0)
        let hiddenMeter = makeDashboardMeter(name: "Gas", sortOrder: 1, isVisible: false)
        let viewModel = makeViewModel(meters: [visibleMeter, hiddenMeter])

        viewModel.loadDashboard(referenceDate: makeDate(year: 2026, month: 3, day: 20))

        XCTAssertEqual(viewModel.cards.map(\.meterName), ["Power"])
        XCTAssertEqual(viewModel.editCards.map(\.meterName), ["Power", "Gas"])
    }

    func testHidingMeterRemovesItFromDashboardCards() {
        let meter = makeDashboardMeter()
        let viewModel = makeViewModel(meters: [meter])
        viewModel.loadDashboard(referenceDate: makeDate(year: 2026, month: 3, day: 20))

        let card = viewModel.cards[0]
        viewModel.setDashboardVisibility(for: card, isVisible: false)

        XCTAssertTrue(viewModel.cards.isEmpty)
        XCTAssertFalse(viewModel.editCards[0].isVisibleOnDashboard)
    }

    func testShowingMeterAddsItBackToDashboardCards() {
        let meter = makeDashboardMeter(isVisible: false)
        let viewModel = makeViewModel(meters: [meter])
        viewModel.loadDashboard(referenceDate: makeDate(year: 2026, month: 3, day: 20))

        let card = viewModel.editCards[0]
        viewModel.setDashboardVisibility(for: card, isVisible: true)

        XCTAssertEqual(viewModel.cards.map(\.meterName), ["Power"])
        XCTAssertTrue(viewModel.editCards[0].isVisibleOnDashboard)
    }

    func testReorderingPersistsDashboardSortOrder() {
        let firstMeter = makeDashboardMeter(name: "Power", sortOrder: 0)
        let secondMeter = makeDashboardMeter(name: "Gas", sortOrder: 1)
        let thirdMeter = makeDashboardMeter(name: "Water", sortOrder: 2)
        let viewModel = makeViewModel(meters: [firstMeter, secondMeter, thirdMeter])
        viewModel.loadDashboard(referenceDate: makeDate(year: 2026, month: 3, day: 20))

        viewModel.moveDashboardCards(from: IndexSet(integer: 2), to: 0)

        XCTAssertEqual(viewModel.editCards.map(\.meterName), ["Water", "Power", "Gas"])
        XCTAssertEqual(thirdMeter.dashboardSortOrder, 0)
        XCTAssertEqual(firstMeter.dashboardSortOrder, 1)
        XCTAssertEqual(secondMeter.dashboardSortOrder, 2)
    }

    private func makeViewModel(
        meters: [Meter],
        readings: [UUID: [Reading]] = [:]
    ) -> DashboardViewModel {
        var calendar = Calendar(identifier: .gregorian)
        calendar.timeZone = TimeZone(secondsFromGMT: 0) ?? .current

        return DashboardViewModel(
            meterRepository: MockDashboardMeterRepository(meters: meters),
            readingRepository: MockDashboardReadingRepository(readings: readings),
            consumptionService: ConsumptionService(calendar: calendar),
            aggregationService: AggregationService(calendar: calendar),
            calendar: calendar
        )
    }
}

private func makeDashboardMeter(
    name: String = "Power",
    sortOrder: Int = 0,
    isVisible: Bool = true
) -> Meter {
    Meter(
        name: name,
        type: .electricityImport,
        unit: "kWh",
        dashboardSortOrder: sortOrder,
        isVisibleOnDashboard: isVisible
    )
}

private func dashboardInterval(meter: Meter, date: Date, value: Decimal) -> ConsumptionInterval {
    ConsumptionInterval(
        meterId: meter.id,
        meterName: meter.name,
        unit: meter.unit,
        startDate: date,
        endDate: date,
        value: value
    )
}

@MainActor
private final class MockDashboardMeterRepository: MeterRepositoryProtocol {
    private var meters: [Meter]

    init(meters: [Meter]) {
        self.meters = meters
    }

    func create(_ formData: MeterFormData, property: Property?) throws -> Meter {
        let meter = Meter(name: formData.name, type: formData.type, unit: formData.unit, property: property)
        meters.append(meter)
        return meter
    }

    func update(_ meter: Meter, with formData: MeterFormData, property: Property?) throws {
        meter.name = formData.name
        meter.type = formData.type
        meter.unit = formData.unit
        meter.property = property
    }

    func delete(_ meter: Meter) throws {
        meters.removeAll { $0.id == meter.id }
    }

    func updateDashboardPreferences(
        _ meter: Meter,
        dashboardSortOrder: Int,
        isVisibleOnDashboard: Bool
    ) throws {
        meter.dashboardSortOrder = dashboardSortOrder
        meter.isVisibleOnDashboard = isVisibleOnDashboard
    }

    func fetchAll() throws -> [Meter] {
        meters
    }

    func fetchById(_ id: UUID) throws -> Meter? {
        meters.first { $0.id == id }
    }

    func fetchByProperty(_ property: Property) throws -> [Meter] {
        meters.filter { $0.property?.id == property.id }
    }
}

@MainActor
private final class MockDashboardReadingRepository: ReadingRepositoryProtocol {
    private var readings: [UUID: [Reading]]

    init(readings: [UUID: [Reading]]) {
        self.readings = readings
    }

    func create(_ formData: ReadingFormData, value: Decimal, meter: Meter) throws -> Reading {
        let reading = Reading(date: formData.date, value: value, note: formData.note, meter: meter)
        readings[meter.id, default: []].append(reading)
        return reading
    }

    func update(_ reading: Reading, with formData: ReadingFormData, value: Decimal) throws {
        reading.date = formData.date
        reading.value = value
        reading.note = formData.note
    }

    func delete(_ reading: Reading) throws {
        for meterId in readings.keys {
            readings[meterId]?.removeAll { $0.id == reading.id }
        }
    }

    func fetchAll() throws -> [Reading] {
        readings.values.flatMap { $0 }.sorted { $0.date > $1.date }
    }

    func fetchById(_ id: UUID) throws -> Reading? {
        readings.values.flatMap { $0 }.first { $0.id == id }
    }

    func fetchByMeter(_ meter: Meter) throws -> [Reading] {
        readings[meter.id, default: []].sorted { $0.date > $1.date }
    }

    func fetchLatestReading(for meter: Meter) throws -> Reading? {
        try fetchByMeter(meter).first
    }
}
