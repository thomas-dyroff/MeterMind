import XCTest
@testable import MeterMind

final class MeterValidatorTests: XCTestCase {
    func testEmptyNameIsInvalid() {
        let formData = MeterFormData(name: " ", type: .water, unit: "m3")

        let errors = MeterValidator.validate(formData)

        XCTAssertTrue(errors.contains(.emptyName))
    }

    func testEmptyUnitIsInvalid() {
        let formData = MeterFormData(name: "Water", type: .water, unit: " ")

        let errors = MeterValidator.validate(formData)

        XCTAssertTrue(errors.contains(.emptyUnit))
    }

    func testValidMeterDataIsValid() {
        let formData = MeterFormData(name: "Water", type: .water, unit: "m3")

        let errors = MeterValidator.validate(formData)

        XCTAssertTrue(errors.isEmpty)
    }
}
