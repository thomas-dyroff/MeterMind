import SwiftData
import XCTest
@testable import MeterMind

@MainActor
final class MeterRepositoryTests: XCTestCase {
    private var modelContainer: ModelContainer!
    private var repository: SwiftDataMeterRepository!

    override func setUpWithError() throws {
        try super.setUpWithError()
        let configuration = ModelConfiguration(isStoredInMemoryOnly: true)
        modelContainer = try ModelContainer(
            for: Property.self,
            Meter.self,
            Reading.self,
            Tariff.self,
            configurations: configuration
        )
        repository = SwiftDataMeterRepository(modelContext: modelContainer.mainContext)
    }

    override func tearDownWithError() throws {
        repository = nil
        modelContainer = nil
        try super.tearDownWithError()
    }

    func testCreatePersistsMeter() throws {
        let meter = try repository.create(validFormData(), property: nil)

        let fetchedMeters = try repository.fetchAll()
        XCTAssertEqual(fetchedMeters.count, 1)
        XCTAssertEqual(fetchedMeters.first?.id, meter.id)
        XCTAssertEqual(fetchedMeters.first?.name, "Main Power")
    }

    func testUpdatePersistsChanges() throws {
        let meter = try repository.create(validFormData(), property: nil)
        let updatedFormData = MeterFormData(
            name: "Updated Power",
            type: .gas,
            unit: "m3",
            serialNumber: "ABC-123"
        )

        try repository.update(meter, with: updatedFormData, property: nil)

        let fetchedMeter = try XCTUnwrap(repository.fetchById(meter.id))
        XCTAssertEqual(fetchedMeter.name, "Updated Power")
        XCTAssertEqual(fetchedMeter.type, .gas)
        XCTAssertEqual(fetchedMeter.unit, "m3")
        XCTAssertEqual(fetchedMeter.serialNumber, "ABC-123")
    }

    func testDeleteRemovesMeter() throws {
        let meter = try repository.create(validFormData(), property: nil)

        try repository.delete(meter)

        XCTAssertTrue(try repository.fetchAll().isEmpty)
    }

    private func validFormData() -> MeterFormData {
        MeterFormData(
            name: "Main Power",
            type: .electricityImport,
            unit: "kWh"
        )
    }
}
