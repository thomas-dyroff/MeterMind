import Foundation

/// Formatting helpers for analytics values.
enum AnalyticsFormatters {
    /// Returns a compact decimal string.
    static func decimalString(for value: Decimal) -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        formatter.maximumFractionDigits = 2
        formatter.minimumFractionDigits = 0
        return formatter.string(from: NSDecimalNumber(decimal: value)) ?? NSDecimalNumber(decimal: value).stringValue
    }

    /// Returns a localized date string.
    static func dateString(for date: Date) -> String {
        date.formatted(date: .abbreviated, time: .omitted)
    }

    /// Returns a localized month string.
    static func monthString(for date: Date) -> String {
        date.formatted(.dateTime.month(.abbreviated).year())
    }

    /// Returns a percentage string with sign.
    static func percentString(for value: Decimal) -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .percent
        formatter.maximumFractionDigits = 0
        formatter.positivePrefix = "+"
        return formatter.string(from: NSDecimalNumber(decimal: value / 100)) ?? ""
    }
}
