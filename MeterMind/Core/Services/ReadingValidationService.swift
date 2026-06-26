import Foundation

/// Result of validating reading input.
enum ReadingValidationResult: Equatable {
    case valid(Decimal)
    case invalid([ReadingValidationError])
}

/// Validates reading input and detects unusually large jumps.
struct ReadingValidationService {
    /// Default threshold used to detect unusually large reading jumps.
    static let defaultLargeJumpThreshold = Decimal(1_000)

    private let largeJumpThreshold: Decimal

    /// Creates a reading validation service.
    init(largeJumpThreshold: Decimal = Self.defaultLargeJumpThreshold) {
        self.largeJumpThreshold = largeJumpThreshold
    }

    /// Validates reading form input and returns either a parsed value or validation errors.
    func validateReading(
        formData: ReadingFormData,
        latestReading: Reading?,
        currentReadingId: UUID? = nil
    ) -> ReadingValidationResult {
        validateReading(
            formData: formData,
            previousReading: latestReading,
            nextReading: nil,
            currentReadingId: currentReadingId
        )
    }

    /// Validates reading form input against its chronological neighbors.
    func validateReading(
        formData: ReadingFormData,
        previousReading: Reading?,
        nextReading: Reading?,
        currentReadingId: UUID? = nil
    ) -> ReadingValidationResult {
        guard let value = decimal(from: formData.valueText) else {
            let trimmedValue = formData.valueText.trimmingCharacters(in: .whitespacesAndNewlines)
            return .invalid([trimmedValue.isEmpty ? .emptyValue : .nonNumericValue])
        }

        if value < 0 {
            return .invalid([.negativeValue])
        }

        if let previousReading,
           previousReading.id != currentReadingId,
           value < previousReading.value {
            return .invalid([.valueBelowLatest])
        }

        if let nextReading,
           nextReading.id != currentReadingId,
           value > nextReading.value {
            return .invalid([.valueAboveNext])
        }

        return .valid(value)
    }

    /// Detects whether a value is unusually higher than the latest reading.
    func detectLargeJump(
        newValue: Decimal,
        latestReading: Reading?,
        currentReadingId: UUID? = nil
    ) -> Bool {
        detectLargeJump(newValue: newValue, previousReading: latestReading, currentReadingId: currentReadingId)
    }

    /// Detects whether a value is unusually higher than the previous chronological reading.
    func detectLargeJump(
        newValue: Decimal,
        previousReading: Reading?,
        currentReadingId: UUID? = nil
    ) -> Bool {
        guard let previousReading, previousReading.id != currentReadingId else {
            return false
        }

        return newValue > previousReading.value + largeJumpThreshold
    }

    private func decimal(from text: String) -> Decimal? {
        let normalizedText = text
            .trimmingCharacters(in: .whitespacesAndNewlines)
            .replacingOccurrences(of: ",", with: ".")

        guard !normalizedText.isEmpty else {
            return nil
        }

        return Decimal(string: normalizedText, locale: Locale(identifier: "en_US_POSIX"))
    }
}
