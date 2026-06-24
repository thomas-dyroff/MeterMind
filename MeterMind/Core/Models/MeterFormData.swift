import Foundation

/// Input data used to create or update a meter.
struct MeterFormData: Equatable {
    /// Meter name.
    var name: String

    /// Meter category.
    var type: MeterType

    /// Optional custom type name.
    var customTypeName: String

    /// Meter unit.
    var unit: String

    /// Optional serial number.
    var serialNumber: String

    /// Creates a meter form value.
    init(
        name: String = "",
        type: MeterType = .electricityImport,
        customTypeName: String = "",
        unit: String = MeterUnit.kilowattHour.rawValue,
        serialNumber: String = ""
    ) {
        self.name = name
        self.type = type
        self.customTypeName = customTypeName
        self.unit = unit
        self.serialNumber = serialNumber
    }
}
