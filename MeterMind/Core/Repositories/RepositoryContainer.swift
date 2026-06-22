import SwiftData

/// Container for repository dependencies.
@MainActor
struct RepositoryContainer {
    /// Property repository.
    let propertyRepository: PropertyRepositoryProtocol

    /// Meter repository.
    let meterRepository: MeterRepositoryProtocol

    /// Reading repository.
    let readingRepository: ReadingRepositoryProtocol

    /// Creates repositories backed by a SwiftData model container.
    init(modelContainer: ModelContainer) {
        let modelContext = modelContainer.mainContext
        self.propertyRepository = SwiftDataPropertyRepository(modelContext: modelContext)
        self.meterRepository = SwiftDataMeterRepository(modelContext: modelContext)
        self.readingRepository = SwiftDataReadingRepository(modelContext: modelContext)
    }
}
