import Foundation
import SwiftData

/// Repository interface for reading persistence.
@MainActor
protocol ReadingRepositoryProtocol {
    /// Creates and persists a reading for a meter.
    func create(_ formData: ReadingFormData, value: Decimal, meter: Meter) throws -> Reading

    /// Persists updates for a reading.
    func update(_ reading: Reading, with formData: ReadingFormData, value: Decimal) throws

    /// Deletes a reading.
    func delete(_ reading: Reading) throws

    /// Fetches all readings sorted by date.
    func fetchAll() throws -> [Reading]

    /// Fetches a reading by identifier.
    func fetchById(_ id: UUID) throws -> Reading?

    /// Fetches readings belonging to a meter.
    func fetchByMeter(_ meter: Meter) throws -> [Reading]

    /// Fetches the latest reading for a meter.
    func fetchLatestReading(for meter: Meter) throws -> Reading?
}

/// SwiftData-backed reading repository.
@MainActor
final class SwiftDataReadingRepository: ReadingRepositoryProtocol {
    private let modelContext: ModelContext

    /// Creates a repository backed by a SwiftData model context.
    init(modelContext: ModelContext) {
        self.modelContext = modelContext
    }

    /// Creates and persists a reading for a meter.
    func create(_ formData: ReadingFormData, value: Decimal, meter: Meter) throws -> Reading {
        let reading = Reading(
            date: formData.date,
            value: value,
            note: optionalSanitized(formData.note),
            meter: meter
        )
        modelContext.insert(reading)
        try modelContext.save()
        return reading
    }

    /// Persists updates for a reading.
    func update(_ reading: Reading, with formData: ReadingFormData, value: Decimal) throws {
        reading.date = formData.date
        reading.value = value
        reading.note = optionalSanitized(formData.note)
        try modelContext.save()
    }

    /// Deletes a reading.
    func delete(_ reading: Reading) throws {
        modelContext.delete(reading)
        try modelContext.save()
    }

    /// Fetches all readings sorted by date.
    func fetchAll() throws -> [Reading] {
        let descriptor = FetchDescriptor<Reading>(
            sortBy: [SortDescriptor(\.date, order: .reverse)]
        )
        return try modelContext.fetch(descriptor)
    }

    /// Fetches a reading by identifier.
    func fetchById(_ id: UUID) throws -> Reading? {
        var descriptor = FetchDescriptor<Reading>(
            predicate: #Predicate { reading in
                reading.id == id
            }
        )
        descriptor.fetchLimit = 1
        return try modelContext.fetch(descriptor).first
    }

    /// Fetches readings belonging to a meter.
    func fetchByMeter(_ meter: Meter) throws -> [Reading] {
        let meterId = meter.id
        let descriptor = FetchDescriptor<Reading>(
            predicate: #Predicate { reading in
                reading.meter?.id == meterId
            },
            sortBy: [SortDescriptor(\.date, order: .reverse)]
        )
        return try modelContext.fetch(descriptor)
    }

    /// Fetches the latest reading for a meter.
    func fetchLatestReading(for meter: Meter) throws -> Reading? {
        let meterId = meter.id
        var descriptor = FetchDescriptor<Reading>(
            predicate: #Predicate { reading in
                reading.meter?.id == meterId
            },
            sortBy: [SortDescriptor(\.date, order: .reverse)]
        )
        descriptor.fetchLimit = 1
        return try modelContext.fetch(descriptor).first
    }

    private func optionalSanitized(_ value: String) -> String? {
        let sanitizedValue = value.trimmingCharacters(in: .whitespacesAndNewlines)
        return sanitizedValue.isEmpty ? nil : sanitizedValue
    }
}
