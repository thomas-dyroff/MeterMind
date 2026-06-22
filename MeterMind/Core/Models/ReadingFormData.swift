import Foundation

/// Input data used to create or update a reading.
struct ReadingFormData: Equatable {
    /// Reading date.
    var date: Date

    /// Raw text input for the reading value.
    var valueText: String

    /// Optional note.
    var note: String

    /// Creates a reading form value.
    init(date: Date = .now, valueText: String = "", note: String = "") {
        self.date = date
        self.valueText = valueText
        self.note = note
    }
}
