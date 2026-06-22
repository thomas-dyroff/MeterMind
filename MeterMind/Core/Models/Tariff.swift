import Foundation
import SwiftData

/// A SwiftData model representing a tariff for later premium calculations.
@Model
final class Tariff {
    /// Stable identifier for the tariff.
    var id: UUID

    /// Price per unit. Calculations are implemented later.
    var pricePerUnit: Decimal

    /// Currency code, such as EUR.
    var currency: String

    /// Start date for tariff validity.
    var validFrom: Date

    /// Creation timestamp for sorting and auditing.
    var createdAt: Date

    /// Meter owning this tariff.
    var meter: Meter?

    /// Creates a tariff model.
    init(
        id: UUID = UUID(),
        pricePerUnit: Decimal,
        currency: String,
        validFrom: Date,
        createdAt: Date = .now,
        meter: Meter? = nil
    ) {
        self.id = id
        self.pricePerUnit = pricePerUnit
        self.currency = currency
        self.validFrom = validFrom
        self.createdAt = createdAt
        self.meter = meter
    }
}
