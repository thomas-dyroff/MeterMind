import Foundation

/// Supported meter categories.
enum MeterType: String, CaseIterable, Codable, Identifiable {
    case electricityImport
    case pvFeedIn
    case gas
    case water
    case districtHeating
    case heatingOil
    case custom

    /// Stable identifier for picker usage.
    var id: String {
        rawValue
    }

    /// Localized display title.
    var localizedTitle: LocalizedStringResource {
        switch self {
        case .electricityImport:
            AppStrings.meterTypeElectricityImport
        case .pvFeedIn:
            AppStrings.meterTypePVFeedIn
        case .gas:
            AppStrings.meterTypeGas
        case .water:
            AppStrings.meterTypeWater
        case .districtHeating:
            AppStrings.meterTypeDistrictHeating
        case .heatingOil:
            AppStrings.meterTypeHeatingOil
        case .custom:
            AppStrings.meterTypeCustom
        }
    }
}
