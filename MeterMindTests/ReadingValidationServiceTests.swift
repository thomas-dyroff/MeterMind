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

    func testBackdatedValueBetweenChronologicalNeighborsIsValid() {
        let previousReading = Reading(date: Date(timeIntervalSince1970: 100), value: 50)
        let nextReading = Reading(date: Date(timeIntervalSince1970: 300), value: 90)
        let formData = ReadingFormData(date: Date(timeIntervalSince1970: 200), valueText: "75")

        let result = service.validateReading(
            formData: formData,
            previousReading: previousReading,
            nextReading: nextReading
        )

        XCTAssertEqual(result, .valid(75))
    }

    func testBackdatedValueAboveNextReadingIsInvalid() {
        let previousReading = Reading(date: Date(timeIntervalSince1970: 100), value: 50)
        let nextReading = Reading(date: Date(timeIntervalSince1970: 300), value: 90)
        let formData = ReadingFormData(date: Date(timeIntervalSince1970: 200), valueText: "95")

        let result = service.validateReading(
            formData: formData,
            previousReading: previousReading,
            nextReading: nextReading
        )

        XCTAssertEqual(result, .invalid([.valueAboveNext]))
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
