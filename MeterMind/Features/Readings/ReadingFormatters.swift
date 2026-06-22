import Foundation

/// Formatting helpers for reading presentation.
enum ReadingFormatters {
    /// Returns a localized date string.
    static func dateString(for date: Date) -> String {
        date.formatted(date: .abbreviated, time: .omitted)
    }

    /// Returns a stable decimal string for reading values.
    static func valueString(for value: Decimal) -> String {
        NSDecimalNumber(decimal: value).stringValue
    }
}
