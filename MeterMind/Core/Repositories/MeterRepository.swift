import Foundation
import SwiftData

/// Repository interface for meter persistence.
@MainActor
protocol MeterRepositoryProtocol {
    /// Creates and persists a meter.
    func create(_ formData: MeterFormData, property: Property?) throws -> Meter

    /// Persists updates for a meter.
    func update(_ meter: Meter, with formData: MeterFormData, property: Property?) throws

    /// Deletes a meter.
    func delete(_ meter: Meter) throws

    /// Fetches all meters sorted by creation date.
    func fetchAll() throws -> [Meter]

    /// Fetches a meter by identifier.
    func fetchById(_ id: UUID) throws -> Meter?

    /// Fetches meters belonging to a property.
    func fetchByProperty(_ property: Property) throws -> [Meter]
}

/// SwiftData-backed meter repository.
@MainActor
final class SwiftDataMeterRepository: MeterRepositoryProtocol {
    private let modelContext: ModelContext

    /// Creates a repository backed by a SwiftData model context.
    init(modelContext: ModelContext) {
        self.modelContext = modelContext
    }

    /// Creates and persists a meter.
    func create(_ formData: MeterFormData, property: Property? = nil) throws -> Meter {
        let errors = MeterValidator.validate(formData)
        if let error = errors.first {
            throw error
        }

        let meter = Meter(
            name: sanitized(formData.name),
            type: formData.type,
            customTypeName: optionalSanitized(formData.customTypeName),
            unit: sanitized(formData.unit),
            serialNumber: optionalSanitized(formData.serialNumber),
            property: property
        )
        modelContext.insert(meter)
        try modelContext.save()
        return meter
    }

    /// Persists updates for a meter.
    func update(_ meter: Meter, with formData: MeterFormData, property: Property? = nil) throws {
        let errors = MeterValidator.validate(formData)
        if let error = errors.first {
            throw error
        }

        meter.name = sanitized(formData.name)
        meter.type = formData.type
        meter.customTypeName = optionalSanitized(formData.customTypeName)
        meter.unit = sanitized(formData.unit)
        meter.serialNumber = optionalSanitized(formData.serialNumber)
        meter.property = property
        try modelContext.save()
    }

    /// Deletes a meter.
    func delete(_ meter: Meter) throws {
        modelContext.delete(meter)
        try modelContext.save()
    }

    /// Fetches all meters sorted by creation date.
    func fetchAll() throws -> [Meter] {
        let descriptor = FetchDescriptor<Meter>(
            sortBy: [SortDescriptor(\.createdAt, order: .reverse)]
        )
        return try modelContext.fetch(descriptor)
    }

    /// Fetches a meter by identifier.
    func fetchById(_ id: UUID) throws -> Meter? {
        var descriptor = FetchDescriptor<Meter>(
            predicate: #Predicate { meter in
                meter.id == id
            }
        )
        descriptor.fetchLimit = 1
        return try modelContext.fetch(descriptor).first
    }

    /// Fetches meters belonging to a property.
    func fetchByProperty(_ property: Property) throws -> [Meter] {
        let propertyId = property.id
        let descriptor = FetchDescriptor<Meter>(
            predicate: #Predicate { meter in
                meter.property?.id == propertyId
            },
            sortBy: [SortDescriptor(\.createdAt, order: .reverse)]
        )
        return try modelContext.fetch(descriptor)
    }

    private func sanitized(_ value: String) -> String {
        value.trimmingCharacters(in: .whitespacesAndNewlines)
    }

    private func optionalSanitized(_ value: String) -> String? {
        let sanitizedValue = sanitized(value)
        return sanitizedValue.isEmpty ? nil : sanitizedValue
    }
}
