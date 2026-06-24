import Foundation

/// Supported meter units for readings and analytics.
enum MeterUnit: String, CaseIterable, Identifiable {
    case kilowattHour = "kWh"
    case cubicMeter
    case liter
    case ton
    case kilogram

    /// Stable identifier for picker usage.
    var id: String {
        rawValue
    }

    /// Localized display label for forms.
    var localizedLabel: LocalizedStringResource {
        switch self {
        case .kilowattHour:
            AppStrings.meterUnitKilowattHour
        case .cubicMeter:
            AppStrings.meterUnitCubicMeter
        case .liter:
            AppStrings.meterUnitLiter
        case .ton:
            AppStrings.meterUnitTon
        case .kilogram:
            AppStrings.meterUnitKilogram
        }
    }

    /// Compact unit symbol used in cards, lists, and charts.
    var symbol: String {
        String(localized: localizedLabel)
    }

    /// Returns whether a persisted raw value is one of the supported units.
    static func isSupported(_ rawValue: String) -> Bool {
        unit(for: rawValue) != nil
    }

    /// Resolves persisted values, including legacy variants such as "m3".
    static func unit(for rawValue: String) -> MeterUnit? {
        let normalizedValue = rawValue.trimmingCharacters(in: .whitespacesAndNewlines)
        if let unit = MeterUnit(rawValue: normalizedValue) {
            return unit
        }

        switch normalizedValue.lowercased() {
        case "m3", "m³":
            return .cubicMeter
        case "l":
            return .liter
        case "t":
            return .ton
        case "kg":
            return .kilogram
        default:
            return nil
        }
    }

    /// Returns a safe fallback unit for legacy or unknown persisted values.
    static func fallbackUnit(for rawValue: String) -> MeterUnit {
        unit(for: rawValue) ?? .kilowattHour
    }

    /// Returns the localized symbol for a persisted unit value.
    static func symbol(for rawValue: String) -> String {
        fallbackUnit(for: rawValue).symbol
    }

    /// Returns the canonical raw value to persist for a supported unit.
    static func persistedRawValue(for rawValue: String) -> String {
        fallbackUnit(for: rawValue).rawValue
    }
}
