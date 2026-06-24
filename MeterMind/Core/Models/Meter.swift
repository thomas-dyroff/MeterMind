import Foundation
import SwiftData

/// A SwiftData model representing a utility meter.
@Model
final class Meter {
    /// Stable identifier for the meter.
    var id: UUID

    /// User-facing meter name.
    var name: String

    /// Supported or custom meter type.
    var type: MeterType

    /// User-provided type name when `type` is custom.
    var customTypeName: String?

    /// Unit used for readings, such as kWh or m3.
    var unit: String

    /// Optional serial number printed on the meter.
    var serialNumber: String?

    /// Creation timestamp for sorting and auditing.
    var createdAt: Date

    /// Sort order used by the dashboard composition.
    var dashboardSortOrder: Int = 0

    /// Controls whether this meter appears on the dashboard.
    var isVisibleOnDashboard: Bool = true

    /// Optional owning property. Property management is introduced later.
    var property: Property?

    /// Readings assigned to this meter.
    @Relationship(deleteRule: .cascade, inverse: \Reading.meter)
    var readings: [Reading]

    /// Tariffs assigned to this meter.
    @Relationship(deleteRule: .cascade, inverse: \Tariff.meter)
    var tariffs: [Tariff]

    /// Creates a meter model.
    init(
        id: UUID = UUID(),
        name: String,
        type: MeterType,
        customTypeName: String? = nil,
        unit: String,
        serialNumber: String? = nil,
        createdAt: Date = .now,
        dashboardSortOrder: Int = 0,
        isVisibleOnDashboard: Bool = true,
        property: Property? = nil,
        readings: [Reading] = [],
        tariffs: [Tariff] = []
    ) {
        self.id = id
        self.name = name
        self.type = type
        self.customTypeName = customTypeName
        self.unit = unit
        self.serialNumber = serialNumber
        self.createdAt = createdAt
        self.dashboardSortOrder = dashboardSortOrder
        self.isVisibleOnDashboard = isVisibleOnDashboard
        self.property = property
        self.readings = readings
        self.tariffs = tariffs
    }
}
