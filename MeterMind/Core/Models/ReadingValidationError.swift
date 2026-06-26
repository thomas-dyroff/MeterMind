import Foundation

/// Validation errors for reading form data.
enum ReadingValidationError: Error, Equatable, Identifiable {
    case emptyValue
    case nonNumericValue
    case negativeValue
    case valueBelowLatest
    case valueAboveNext

    /// Stable identifier for list rendering.
    var id: String {
        switch self {
        case .emptyValue:
            "emptyValue"
        case .nonNumericValue:
            "nonNumericValue"
        case .negativeValue:
            "negativeValue"
        case .valueBelowLatest:
            "valueBelowLatest"
        case .valueAboveNext:
            "valueAboveNext"
        }
    }

    /// Localized message describing the validation error.
    var message: LocalizedStringResource {
        switch self {
        case .emptyValue:
            AppStrings.validationReadingValueRequired
        case .nonNumericValue:
            AppStrings.validationReadingValueNumeric
        case .negativeValue:
            AppStrings.validationReadingValueNonNegative
        case .valueBelowLatest:
            AppStrings.validationReadingValueBelowLatest
        case .valueAboveNext:
            AppStrings.validationReadingValueAboveNext
        }
    }
}
