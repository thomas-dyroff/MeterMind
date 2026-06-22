import Foundation
import SwiftData

/// Repository interface for property persistence.
@MainActor
protocol PropertyRepositoryProtocol {
    /// Creates and persists a property.
    func create(name: String) throws -> Property

    /// Persists updates for a property.
    func update(_ property: Property, name: String) throws

    /// Deletes a property.
    func delete(_ property: Property) throws

    /// Fetches all properties sorted by creation date.
    func fetchAll() throws -> [Property]

    /// Fetches a property by identifier.
    func fetchById(_ id: UUID) throws -> Property?
}

/// SwiftData-backed property repository.
@MainActor
final class SwiftDataPropertyRepository: PropertyRepositoryProtocol {
    private let modelContext: ModelContext

    /// Creates a repository backed by a SwiftData model context.
    init(modelContext: ModelContext) {
        self.modelContext = modelContext
    }

    /// Creates and persists a property.
    func create(name: String) throws -> Property {
        let property = Property(name: name.trimmingCharacters(in: .whitespacesAndNewlines))
        modelContext.insert(property)
        try modelContext.save()
        return property
    }

    /// Persists updates for a property.
    func update(_ property: Property, name: String) throws {
        property.name = name.trimmingCharacters(in: .whitespacesAndNewlines)
        try modelContext.save()
    }

    /// Deletes a property.
    func delete(_ property: Property) throws {
        modelContext.delete(property)
        try modelContext.save()
    }

    /// Fetches all properties sorted by creation date.
    func fetchAll() throws -> [Property] {
        let descriptor = FetchDescriptor<Property>(
            sortBy: [SortDescriptor(\.createdAt, order: .forward)]
        )
        return try modelContext.fetch(descriptor)
    }

    /// Fetches a property by identifier.
    func fetchById(_ id: UUID) throws -> Property? {
        var descriptor = FetchDescriptor<Property>(
            predicate: #Predicate { property in
                property.id == id
            }
        )
        descriptor.fetchLimit = 1
        return try modelContext.fetch(descriptor).first
    }
}
