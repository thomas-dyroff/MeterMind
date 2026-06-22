import Foundation

/// Validation errors for meter form data.
enum MeterValidationError: Error, Equatable, Identifiable {
    case emptyName
    case nameTooLong
    case emptyUnit
    case unitTooLong

    /// Stable identifier for list rendering.
    var id: String {
        switch self {
        case .emptyName:
            "emptyName"
        case .nameTooLong:
            "nameTooLong"
        case .emptyUnit:
            "emptyUnit"
        case .unitTooLong:
            "unitTooLong"
        }
    }

    /// Localized message describing the validation error.
    var message: LocalizedStringResource {
        switch self {
        case .emptyName:
            AppStrings.validationMeterNameRequired
        case .nameTooLong:
            AppStrings.validationMeterNameTooLong
        case .emptyUnit:
            AppStrings.validationMeterUnitRequired
        case .unitTooLong:
            AppStrings.validationMeterUnitTooLong
        }
    }
}
