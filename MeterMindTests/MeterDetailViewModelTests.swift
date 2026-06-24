import XCTest
@testable import MeterMind

@MainActor
final class MeterDetailViewModelTests: XCTestCase {
    func testLoadsCorrectMeter() {
        let meter = detailMeter(name: "Main Power")
        let viewModel = makeViewModel(meter: meter)

        viewModel.load(referenceDate: detailDate(year: 2026, month: 1, day: 3))

        XCTAssertEqual(viewModel.meterId, meter.id)
        XCTAssertEqual(viewModel.name, "Main Power")
        XCTAssertEqual(viewModel.unit, "kWh")
    }

    func testLatestReadingIsDeterminedByDate() {
        let meter = detailMeter()
        let readings = [
            Reading(date: detailDate(year: 2026, month: 1, day: 1), value: 100, meter: meter),
            Reading(date: detailDate(year: 2026, month: 1, day: 3), value: 125, meter: meter),
            Reading(date: detailDate(year: 2026, month: 1, day: 2), value: 112, meter: meter)
        ]
        let viewModel = makeViewModel(meter: meter, readings: readings)

        viewModel.load(referenceDate: detailDate(year: 2026, month: 1, day: 3))

        XCTAssertEqual(viewModel.latestReadingValue, 125)
        XCTAssertEqual(viewModel.latestReadingDate, detailDate(year: 2026, month: 1, day: 3))
    }

    func testHistoryIsLimitedTo30Entries() {
        let meter = detailMeter()
        let readings = (0..<35).compactMap { offset in
            detailCalendar.date(byAdding: .day, value: offset, to: detailDate(year: 2026, month: 1, day: 1)).map {
                Reading(date: $0, value: Decimal(offset), meter: meter)
            }
        }
        let viewModel = makeViewModel(meter: meter, readings: readings)

        viewModel.load(referenceDate: detailDate(year: 2026, month: 2, day: 4))

        XCTAssertEqual(viewModel.recentReadings.count, 30)
        XCTAssertEqual(viewModel.recentReadings.first?.date, detailDate(year: 2026, month: 2, day: 4))
    }

    func testWeeklyAggregationCreatesDailyValuesForCurrentWeek() {
        let meter = detailMeter()
        let readings = [
            Reading(date: detailDate(year: 2026, month: 1, day: 1), value: 100, meter: meter),
            Reading(date: detailDate(year: 2026, month: 1, day: 2), value: 112, meter: meter),
            Reading(date: detailDate(year: 2026, month: 1, day: 3), value: 125, meter: meter)
        ]
        let viewModel = makeViewModel(meter: meter, readings: readings)

        viewModel.load(referenceDate: detailDate(year: 2026, month: 1, day: 3))

        let weekPoints = chartPoints(in: viewModel, period: .week)
        XCTAssertEqual(weekPoints.count, 7)
        XCTAssertEqual(pointValue(on: detailDate(year: 2026, month: 1, day: 2), in: weekPoints), 12)
        XCTAssertEqual(pointValue(on: detailDate(year: 2026, month: 1, day: 3), in: weekPoints), 13)
    }

    func testMonthlyAggregationCreatesDailyValuesForCurrentMonth() {
        let meter = detailMeter()
        let readings = [
            Reading(date: detailDate(year: 2026, month: 1, day: 1), value: 100, meter: meter),
            Reading(date: detailDate(year: 2026, month: 1, day: 2), value: 112, meter: meter),
            Reading(date: detailDate(year: 2026, month: 1, day: 3), value: 125, meter: meter)
        ]
        let viewModel = makeViewModel(meter: meter, readings: readings)

        viewModel.load(referenceDate: detailDate(year: 2026, month: 1, day: 3))

        let monthPoints = chartPoints(in: viewModel, period: .month)
        XCTAssertEqual(monthPoints.count, 31)
        XCTAssertEqual(pointValue(on: detailDate(year: 2026, month: 1, day: 2), in: monthPoints), 12)
    }

    func testQuarterAggregationCreatesMonthlyValues() {
        let meter = detailMeter()
        let readings = quarterReadings(for: meter)
        let viewModel = makeViewModel(meter: meter, readings: readings)

        viewModel.load(referenceDate: detailDate(year: 2026, month: 2, day: 10))

        let quarterPoints = chartPoints(in: viewModel, period: .quarter)
        XCTAssertEqual(quarterPoints.count, 3)
        XCTAssertEqual(pointValue(on: detailDate(year: 2026, month: 1, day: 1), in: quarterPoints), 40)
        XCTAssertEqual(pointValue(on: detailDate(year: 2026, month: 2, day: 1), in: quarterPoints), 60)
    }

    func testYearAggregationCreatesMonthlyValues() {
        let meter = detailMeter()
        let readings = quarterReadings(for: meter)
        let viewModel = makeViewModel(meter: meter, readings: readings)

        viewModel.load(referenceDate: detailDate(year: 2026, month: 2, day: 10))

        let yearPoints = chartPoints(in: viewModel, period: .year)
        XCTAssertEqual(yearPoints.count, 12)
        XCTAssertEqual(pointValue(on: detailDate(year: 2026, month: 1, day: 1), in: yearPoints), 40)
        XCTAssertEqual(pointValue(on: detailDate(year: 2026, month: 2, day: 1), in: yearPoints), 60)
    }

    func testChartDataContainsCorrectUnit() {
        let meter = detailMeter(unit: "m3")
        let readings = quarterReadings(for: meter)
        let viewModel = makeViewModel(meter: meter, readings: readings)

        viewModel.load(referenceDate: detailDate(year: 2026, month: 2, day: 10))

        XCTAssertTrue(viewModel.chartSections.allSatisfy { $0.unit == "m³" })
    }

    func testMeterWithoutEnoughDataProducesEmptyChartData() {
        let meter = detailMeter()
        let readings = [
            Reading(date: detailDate(year: 2026, month: 1, day: 1), value: 100, meter: meter)
        ]
        let viewModel = makeViewModel(meter: meter, readings: readings)

        viewModel.load(referenceDate: detailDate(year: 2026, month: 1, day: 3))

        XCTAssertTrue(viewModel.chartSections.allSatisfy { $0.dataPoints.isEmpty })
    }

    private func makeViewModel(meter: Meter, readings: [Reading] = []) -> MeterDetailViewModel {
        MeterDetailViewModel(
            meterId: meter.id,
            meterRepository: MockMeterDetailMeterRepository(meter: meter),
            readingRepository: MockMeterDetailReadingRepository(meter: meter, readings: readings),
            consumptionService: ConsumptionService(calendar: detailCalendar),
            aggregationService: AggregationService(calendar: detailCalendar),
            calendar: detailCalendar
        )
    }
}

private let detailCalendar: Calendar = {
    var calendar = Calendar(identifier: .gregorian)
    calendar.timeZone = TimeZone(secondsFromGMT: 0) ?? .current
    calendar.firstWeekday = 2
    return calendar
}()

private func detailMeter(name: String = "Power", unit: String = "kWh") -> Meter {
    Meter(name: name, type: .electricityImport, unit: unit)
}

private func detailDate(year: Int, month: Int, day: Int) -> Date {
    var components = DateComponents()
    components.calendar = detailCalendar
    components.timeZone = TimeZone(secondsFromGMT: 0)
    components.year = year
    components.month = month
    components.day = day
    return components.date ?? Date(timeIntervalSince1970: 0)
}

private func quarterReadings(for meter: Meter) -> [Reading] {
    [
        Reading(date: detailDate(year: 2026, month: 1, day: 1), value: 100, meter: meter),
        Reading(date: detailDate(year: 2026, month: 1, day: 15), value: 140, meter: meter),
        Reading(date: detailDate(year: 2026, month: 2, day: 1), value: 200, meter: meter)
    ]
}


@MainActor
private func chartPoints(
    in viewModel: MeterDetailViewModel,
    period: MeterDetailChartPeriod
) -> [MeterConsumptionChartDataPoint] {
    viewModel.chartSections.first { $0.periodType == period }?.dataPoints ?? []
}

private func pointValue(on date: Date, in points: [MeterConsumptionChartDataPoint]) -> Decimal? {
    points.first { detailCalendar.isDate($0.date, inSameDayAs: date) }?.value
}

@MainActor
private final class MockMeterDetailMeterRepository: MeterRepositoryProtocol {
    private let meter: Meter

    init(meter: Meter) {
        self.meter = meter
    }

    func create(_ formData: MeterFormData, property: Property?) throws -> Meter {
        meter
    }

    func update(_ meter: Meter, with formData: MeterFormData, property: Property?) throws {}

    func delete(_ meter: Meter) throws {}

    func updateDashboardPreferences(
        _ meter: Meter,
        dashboardSortOrder: Int,
        isVisibleOnDashboard: Bool
    ) throws {}

    func fetchAll() throws -> [Meter] {
        [meter]
    }

    func fetchById(_ id: UUID) throws -> Meter? {
        meter.id == id ? meter : nil
    }

    func fetchByProperty(_ property: Property) throws -> [Meter] {
        []
    }
}

@MainActor
private final class MockMeterDetailReadingRepository: ReadingRepositoryProtocol {
    private let meter: Meter
    private var readings: [Reading]

    init(meter: Meter, readings: [Reading]) {
        self.meter = meter
        self.readings = readings
    }

    func create(_ formData: ReadingFormData, value: Decimal, meter: Meter) throws -> Reading {
        let reading = Reading(date: formData.date, value: value, note: formData.note, meter: meter)
        readings.append(reading)
        return reading
    }

    func update(_ reading: Reading, with formData: ReadingFormData, value: Decimal) throws {
        reading.date = formData.date
        reading.value = value
        reading.note = formData.note
    }

    func delete(_ reading: Reading) throws {
        readings.removeAll { $0.id == reading.id }
    }

    func fetchAll() throws -> [Reading] {
        readings.sorted { $0.date > $1.date }
    }

    func fetchById(_ id: UUID) throws -> Reading? {
        readings.first { $0.id == id }
    }

    func fetchByMeter(_ meter: Meter) throws -> [Reading] {
        guard meter.id == self.meter.id else {
            return []
        }

        return readings.sorted { $0.date > $1.date }
    }

    func fetchLatestReading(for meter: Meter) throws -> Reading? {
        try fetchByMeter(meter).first
    }
}
