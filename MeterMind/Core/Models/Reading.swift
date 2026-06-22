import Foundation
import SwiftData

/// A SwiftData model representing a meter reading.
@Model
final class Reading {
    /// Stable identifier for the reading.
    var id: UUID

    /// Reading date.
    var date: Date

    /// Captured meter value.
    var value: Decimal

    /// Optional user note.
    var note: String?

    /// Creation timestamp for sorting and auditing.
    var createdAt: Date

    /// Meter owning this reading.
    var meter: Meter?

    /// Creates a reading model.
    init(
        id: UUID = UUID(),
        date: Date,
        value: Decimal,
        note: String? = nil,
        createdAt: Date = .now,
        meter: Meter? = nil
    ) {
        self.id = id
        self.date = date
        self.value = value
        self.note = note
        self.createdAt = createdAt
        self.meter = meter
    }
}
