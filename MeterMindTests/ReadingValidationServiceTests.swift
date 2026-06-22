import XCTest
@testable import MeterMind

final class ReadingValidationServiceTests: XCTestCase {
    private let service = ReadingValidationService(largeJumpThreshold: 100)

    func testValidValueIsAccepted() {
        let latestReading = Reading(date: .now, value: 50)
        let formData = ReadingFormData(valueText: "75")

        let result = service.validateReading(formData: formData, latestReading: latestReading)

        XCTAssertEqual(result, .valid(75))
    }

    func testValueBelowLatestIsInvalid() {
        let latestReading = Reading(date: .now, value: 50)
        let formData = ReadingFormData(valueText: "49")

        let result = service.validateReading(formData: formData, latestReading: latestReading)

        XCTAssertEqual(result, .invalid([.valueBelowLatest]))
    }

    func testLargeJumpIsDetected() {
        let latestReading = Reading(date: .now, value: 50)

        let isLargeJump = service.detectLargeJump(newValue: 151, latestReading: latestReading)

        XCTAssertTrue(isLargeJump)
    }

    func testNegativeValueIsInvalid() {
        let formData = ReadingFormData(valueText: "-1")

        let result = service.validateReading(formData: formData, latestReading: nil)

        XCTAssertEqual(result, .invalid([.negativeValue]))
    }

    func testEmptyValueIsInvalid() {
        let formData = ReadingFormData(valueText: " ")

        let result = service.validateReading(formData: formData, latestReading: nil)

        XCTAssertEqual(result, .invalid([.emptyValue]))
    }
}
