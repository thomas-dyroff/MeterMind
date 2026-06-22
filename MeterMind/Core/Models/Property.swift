import Foundation
import SwiftData

/// A SwiftData model representing a property that can own meters.
@Model
final class Property {
    /// Stable identifier for the property.
    var id: UUID

    /// User-facing property name.
    var name: String

    /// Creation timestamp for sorting and auditing.
    var createdAt: Date

    /// Meters assigned to this property.
    @Relationship(deleteRule: .cascade, inverse: \Meter.property)
    var meters: [Meter]

    /// Creates a property model.
    init(
        id: UUID = UUID(),
        name: String,
        createdAt: Date = .now,
        meters: [Meter] = []
    ) {
        self.id = id
        self.name = name
        self.createdAt = createdAt
        self.meters = meters
    }
}
