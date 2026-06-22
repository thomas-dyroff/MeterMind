import Foundation

/// Validates meter form data before persistence.
enum MeterValidator {
    private static let maxNameLength = 100
    private static let maxUnitLength = 20

    /// Returns all validation errors for the provided form data.
    static func validate(_ formData: MeterFormData) -> [MeterValidationError] {
        var errors: [MeterValidationError] = []

        let name = formData.name.trimmingCharacters(in: .whitespacesAndNewlines)
        let unit = formData.unit.trimmingCharacters(in: .whitespacesAndNewlines)

        if name.isEmpty {
            errors.append(.emptyName)
        } else if name.count > maxNameLength {
            errors.append(.nameTooLong)
        }

        if unit.isEmpty {
            errors.append(.emptyUnit)
        } else if unit.count > maxUnitLength {
            errors.append(.unitTooLong)
        }

        return errors
    }

    /// Returns whether the provided form data is valid.
    static func isValid(_ formData: MeterFormData) -> Bool {
        validate(formData).isEmpty
    }
}
