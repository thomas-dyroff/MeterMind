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
        guard let value = decimal(from: formData.valueText) else {
            let trimmedValue = formData.valueText.trimmingCharacters(in: .whitespacesAndNewlines)
            return .invalid([trimmedValue.isEmpty ? .emptyValue : .nonNumericValue])
        }

        if value < 0 {
            return .invalid([.negativeValue])
        }

        if let latestReading,
           latestReading.id != currentReadingId,
           value < latestReading.value {
            return .invalid([.valueBelowLatest])
        }

        return .valid(value)
    }

    /// Detects whether a value is unusually higher than the latest reading.
    func detectLargeJump(
        newValue: Decimal,
        latestReading: Reading?,
        currentReadingId: UUID? = nil
    ) -> Bool {
        guard let latestReading, latestReading.id != currentReadingId else {
            return false
        }

        return newValue > latestReading.value + largeJumpThreshold
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
