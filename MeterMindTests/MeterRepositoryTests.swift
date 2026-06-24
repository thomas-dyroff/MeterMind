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

    func testCreateUsesDashboardDefaults() throws {
        let meter = try repository.create(validFormData(), property: nil)

        XCTAssertTrue(meter.isVisibleOnDashboard)
        XCTAssertEqual(meter.dashboardSortOrder, 0)
    }

    func testUpdatePersistsChanges() throws {
        let meter = try repository.create(validFormData(), property: nil)
        let updatedFormData = MeterFormData(
            name: "Updated Power",
            type: .gas,
            unit: MeterUnit.cubicMeter.rawValue,
            serialNumber: "ABC-123"
        )

        try repository.update(meter, with: updatedFormData, property: nil)

        let fetchedMeter = try XCTUnwrap(repository.fetchById(meter.id))
        XCTAssertEqual(fetchedMeter.name, "Updated Power")
        XCTAssertEqual(fetchedMeter.type, .gas)
        XCTAssertEqual(fetchedMeter.unit, MeterUnit.cubicMeter.rawValue)
        XCTAssertEqual(fetchedMeter.serialNumber, "ABC-123")
    }

    func testUpdateKeepsExistingMeterIdentifier() throws {
        let meter = try repository.create(validFormData(), property: nil)
        let originalId = meter.id

        try repository.update(
            meter,
            with: MeterFormData(name: "Renamed", type: .water, unit: MeterUnit.liter.rawValue),
            property: nil
        )

        let fetchedMeter = try XCTUnwrap(repository.fetchById(originalId))
        XCTAssertEqual(fetchedMeter.id, originalId)
        XCTAssertEqual(fetchedMeter.name, "Renamed")
    }

    func testDeleteRemovesMeter() throws {
        let meter = try repository.create(validFormData(), property: nil)

        try repository.delete(meter)

        XCTAssertTrue(try repository.fetchAll().isEmpty)
    }

    func testUpdateDashboardPreferencesPersistsChanges() throws {
        let meter = try repository.create(validFormData(), property: nil)

        try repository.updateDashboardPreferences(
            meter,
            dashboardSortOrder: 3,
            isVisibleOnDashboard: false
        )

        let fetchedMeter = try XCTUnwrap(repository.fetchById(meter.id))
        XCTAssertEqual(fetchedMeter.dashboardSortOrder, 3)
        XCTAssertFalse(fetchedMeter.isVisibleOnDashboard)
    }

    private func validFormData() -> MeterFormData {
        MeterFormData(
            name: "Main Power",
            type: .electricityImport,
            unit: "kWh"
        )
    }
}
