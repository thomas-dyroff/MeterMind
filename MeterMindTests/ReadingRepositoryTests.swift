import SwiftData
import XCTest
@testable import MeterMind

final class ReadingRepositoryTests: XCTestCase {
    @MainActor
    func testCreatePersistsReading() throws {
        let testContext = try makeTestContext()

        let reading = try testContext.readingRepository.create(
            validFormData(valueText: "123"),
            value: 123,
            meter: testContext.meter
        )

        let fetchedReadings = try testContext.readingRepository.fetchByMeter(testContext.meter)
        XCTAssertEqual(fetchedReadings.count, 1)
        XCTAssertEqual(fetchedReadings.first?.id, reading.id)
        XCTAssertEqual(fetchedReadings.first?.value, 123)
    }

    @MainActor
    func testUpdatePersistsChanges() throws {
        let testContext = try makeTestContext()
        let reading = try testContext.readingRepository.create(
            validFormData(valueText: "123"),
            value: 123,
            meter: testContext.meter
        )
        let updatedFormData = ReadingFormData(date: .now, valueText: "150", note: "Updated")

        try testContext.readingRepository.update(reading, with: updatedFormData, value: 150)

        let fetchedReading = try XCTUnwrap(testContext.readingRepository.fetchById(reading.id))
        XCTAssertEqual(fetchedReading.value, 150)
        XCTAssertEqual(fetchedReading.note, "Updated")
    }

    @MainActor
    func testDeleteRemovesReading() throws {
        let testContext = try makeTestContext()
        let reading = try testContext.readingRepository.create(
            validFormData(valueText: "123"),
            value: 123,
            meter: testContext.meter
        )

        try testContext.readingRepository.delete(reading)

        XCTAssertTrue(try testContext.readingRepository.fetchByMeter(testContext.meter).isEmpty)
    }

    @MainActor
    func testFetchLatestReadingReturnsNewestByDate() throws {
        let testContext = try makeTestContext()
        let olderDate = try XCTUnwrap(Calendar.current.date(byAdding: .day, value: -1, to: .now))
        _ = try testContext.readingRepository.create(
            ReadingFormData(date: olderDate, valueText: "100"),
            value: 100,
            meter: testContext.meter
        )
        let latestReading = try testContext.readingRepository.create(
            validFormData(valueText: "125"),
            value: 125,
            meter: testContext.meter
        )

        let fetchedLatestReading = try testContext.readingRepository.fetchLatestReading(for: testContext.meter)

        XCTAssertEqual(fetchedLatestReading?.id, latestReading.id)
    }

    @MainActor
    private func makeTestContext() throws -> ReadingRepositoryTestContext {
        let configuration = ModelConfiguration(isStoredInMemoryOnly: true)
        let modelContainer = try ModelContainer(
            for: Property.self,
            Meter.self,
            Reading.self,
            Tariff.self,
            configurations: configuration
        )
        let meterRepository = SwiftDataMeterRepository(modelContext: modelContainer.mainContext)
        let readingRepository = SwiftDataReadingRepository(modelContext: modelContainer.mainContext)
        let meter = try meterRepository.create(
            MeterFormData(name: "Power", type: .electricityImport, unit: "kWh"),
            property: nil
        )

        return ReadingRepositoryTestContext(
            modelContainer: modelContainer,
            readingRepository: readingRepository,
            meter: meter
        )
    }

    private func validFormData(valueText: String) -> ReadingFormData {
        ReadingFormData(date: .now, valueText: valueText, note: "Note")
    }
}

private struct ReadingRepositoryTestContext {
    let modelContainer: ModelContainer
    let readingRepository: SwiftDataReadingRepository
    let meter: Meter
}
