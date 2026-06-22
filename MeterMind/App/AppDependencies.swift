import SwiftData

/// Root dependency container for repositories and services.
struct AppDependencies {
    /// Repository dependencies used by view models.
    let repositories: RepositoryContainer

    /// Service dependencies used by view models.
    let services: ServiceContainer

    /// Creates the production dependency graph.
    @MainActor
    static func live(modelContainer: ModelContainer) -> AppDependencies {
        AppDependencies(
            repositories: RepositoryContainer(modelContainer: modelContainer),
            services: ServiceContainer()
        )
    }
}
