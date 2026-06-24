import Foundation

/// Supported chart periods on the meter detail screen.
enum MeterDetailChartPeriod: String, CaseIterable, Identifiable {
    case week
    case month
    case quarter
    case year

    /// Stable identifier.
    var id: String {
        rawValue
    }
}

/// One display-ready consumption chart point.
struct MeterConsumptionChartDataPoint: Identifiable, Equatable {
    /// Stable identifier.
    let id: UUID

    /// Date represented by the point.
    let date: Date

    /// Consumption value.
    let value: Decimal

    /// Display label for the point.
    let label: String

    /// Creates a chart point.
    init(id: UUID = UUID(), date: Date, value: Decimal, label: String) {
        self.id = id
        self.date = date
        self.value = value
        self.label = label
    }

    /// Value converted for Swift Charts.
    var chartValue: Double {
        NSDecimalNumber(decimal: value).doubleValue
    }
}

/// Display-ready chart section data.
struct MeterConsumptionChartViewData: Identifiable, Equatable {
    /// Stable identifier.
    let id: MeterDetailChartPeriod

    /// Localized chart title.
    let title: LocalizedStringResource

    /// Unit shown next to values.
    let unit: String

    /// Chart period type.
    let periodType: MeterDetailChartPeriod

    /// Consumption points.
    let dataPoints: [MeterConsumptionChartDataPoint]
}
