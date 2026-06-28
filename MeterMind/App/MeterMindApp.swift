import SwiftData
import SwiftUI

/// Application entry point for MeterMind.
@main
struct MeterMindApp: App {
    // MARK: - Properties

    private let dependencies: AppDependencies
    private let modelContainer: ModelContainer

    // MARK: - Initialization

    init() {
        let container = Self.makeModelContainer()
        self.modelContainer = container
        self.dependencies = AppDependencies.live(modelContainer: container)
    }

    // MARK: - Scene

    var body: some Scene {
        WindowGroup {
            AppRootView(
                viewModel: NavigationRootViewModel(dependencies: dependencies)
            )
            .modelContainer(modelContainer)
        }
    }

    // MARK: - SwiftData

    private static func makeModelContainer() -> ModelContainer {
        do {
            let configuration = ModelConfiguration(isStoredInMemoryOnly: false)
            return try ModelContainer(
                for: Property.self,
                Meter.self,
                Reading.self,
                Tariff.self,
                configurations: configuration
            )
        } catch {
            fatalError("Unable to create SwiftData model container: \(error.localizedDescription)")
        }
    }
}
