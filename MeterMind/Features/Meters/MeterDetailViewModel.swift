import Foundation

/// View model for displaying meter details.
@MainActor
final class MeterDetailViewModel: ObservableObject {
    // MARK: - Properties

    private let meter: Meter

    var name: String {
        meter.name
    }

    var typeName: String {
        if meter.type == .custom, let customTypeName = meter.customTypeName {
            return customTypeName
        }
        return String(localized: meter.type.localizedTitle)
    }

    var unit: String {
        meter.unit
    }

    var serialNumber: String {
        meter.serialNumber ?? String(localized: AppStrings.meterNotProvided)
    }

    // MARK: - Initialization

    init(meter: Meter) {
        self.meter = meter
    }
}
