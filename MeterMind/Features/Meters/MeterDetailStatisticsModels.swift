import Foundation

/// User-facing detail period selector.
enum MeterDetailFocusPeriod: String, CaseIterable, Identifiable {
    case month
    case year
    case total

    /// Stable identifier.
    var id: String {
        rawValue
    }

    /// Localized title.
    var title: LocalizedStringResource {
        switch self {
        case .month:
            AppStrings.meterDetailPeriodMonth
        case .year:
            AppStrings.meterDetailPeriodYear
        case .total:
            AppStrings.meterDetailPeriodTotal
        }
    }
}

/// Display data for a statistic row.
struct MeterSummaryItem: Identifiable, Equatable {
    /// Stable identifier.
    let id: String

    /// Localized label.
    let title: LocalizedStringResource

    /// Display value.
    let value: String
}
