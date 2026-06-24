import SwiftData
import XCTest
@testable import MeterMind

@MainActor
final class MeterUnitTests: XCTestCase {
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

    func testMeterUnitAcceptsOnlySupportedUnits() {
        XCTAssertTrue(MeterUnit.isSupported(MeterUnit.kilowattHour.rawValue))
        XCTAssertTrue(MeterUnit.isSupported(MeterUnit.cubicMeter.rawValue))
        XCTAssertTrue(MeterUnit.isSupported(MeterUnit.liter.rawValue))
        XCTAssertTrue(MeterUnit.isSupported(MeterUnit.ton.rawValue))
        XCTAssertTrue(MeterUnit.isSupported(MeterUnit.kilogram.rawValue))
        XCTAssertFalse(MeterUnit.isSupported("gallon"))
    }

    func testMeterUnitFallbackUsesKilowattHourForUnknownUnit() {
        XCTAssertEqual(MeterUnit.fallbackUnit(for: "gallon"), .kilowattHour)
    }

    func testMeterUnitResolvesLegacyCubicMeterValues() {
        XCTAssertEqual(MeterUnit.unit(for: "m3"), .cubicMeter)
        XCTAssertEqual(MeterUnit.unit(for: "m³"), .cubicMeter)
    }

    func testEditMeterViewModelSavesChangesWithoutChangingIdentifier() throws {
        let meter = try repository.create(
            MeterFormData(name: "Power", type: .electricityImport, unit: MeterUnit.kilowattHour.rawValue),
            property: nil
        )
        let originalId = meter.id
        var didSave = false
        let viewModel = try XCTUnwrap(
            EditMeterViewModel(meterId: originalId, meterRepository: repository) {
                didSave = true
            }
        )

        viewModel.formData.name = "Updated Power"
        viewModel.formData.unit = MeterUnit.kilogram.rawValue
        viewModel.save()

        let fetchedMeter = try XCTUnwrap(repository.fetchById(originalId))
        XCTAssertTrue(didSave)
        XCTAssertEqual(fetchedMeter.id, originalId)
        XCTAssertEqual(fetchedMeter.name, "Updated Power")
        XCTAssertEqual(fetchedMeter.unit, MeterUnit.kilogram.rawValue)
    }
}
