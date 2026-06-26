import XCTest
@testable import MeterMind

@MainActor
final class ReadingViewModelDateValidationTests: XCTestCase {
    func testCreateReadingAllowsBackdatedValueBetweenNeighbors() {
        let meter = Meter(name: "Water", type: .water, unit: MeterUnit.cubicMeter.rawValue)
        let previousDate = Date(timeIntervalSince1970: 100)
        let middleDate = Date(timeIntervalSince1970: 200)
        let nextDate = Date(timeIntervalSince1970: 300)
        let repository = MockDateValidationReadingRepository(readings: [
            Reading(date: previousDate, value: 100, meter: meter),
            Reading(date: nextDate, value: 150, meter: meter)
        ])
        var didSave = false
        let viewModel = CreateReadingViewModel(
            meter: meter,
            readingRepository: repository,
            validationService: ReadingValidationService(),
            onSave: {
                didSave = true
            }
        )

        viewModel.formData = ReadingFormData(date: middleDate, valueText: "125")
        viewModel.save()

        XCTAssertTrue(didSave)
        XCTAssertTrue(viewModel.validationErrors.isEmpty)
        XCTAssertEqual(repository.createdReadings.count, 1)
        XCTAssertEqual(repository.createdReadings.first?.date, middleDate)
        XCTAssertEqual(repository.createdReadings.first?.value, 125)
    }

    func testCreateReadingBlocksBackdatedValueAboveNextReading() {
        let meter = Meter(name: "Water", type: .water, unit: MeterUnit.cubicMeter.rawValue)
        let previousDate = Date(timeIntervalSince1970: 100)
        let middleDate = Date(timeIntervalSince1970: 200)
        let nextDate = Date(timeIntervalSince1970: 300)
        let repository = MockDateValidationReadingRepository(readings: [
            Reading(date: previousDate, value: 100, meter: meter),
            Reading(date: nextDate, value: 150, meter: meter)
        ])
        let viewModel = CreateReadingViewModel(
            meter: meter,
            readingRepository: repository,
            validationService: ReadingValidationService(),
            onSave: {}
        )

        viewModel.formData = ReadingFormData(date: middleDate, valueText: "175")
        viewModel.save()

        XCTAssertEqual(viewModel.validationErrors, [.valueAboveNext])
        XCTAssertTrue(repository.createdReadings.isEmpty)
    }
}

@MainActor
private final class MockDateValidationReadingRepository: ReadingRepositoryProtocol {
    private var readings: [Reading]
    private(set) var createdReadings: [Reading] = []

    init(readings: [Reading]) {
        self.readings = readings
    }

    func create(_ formData: ReadingFormData, value: Decimal, meter: Meter) throws -> Reading {
        let reading = Reading(date: formData.date, value: value, note: formData.note, meter: meter)
        readings.append(reading)
        createdReadings.append(reading)
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
        readings.filter { $0.meter?.id == meter.id }.sorted { $0.date > $1.date }
    }

    func fetchLatestReading(for meter: Meter) throws -> Reading? {
        try fetchByMeter(meter).first
    }
}
