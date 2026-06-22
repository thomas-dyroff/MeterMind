import Foundation

/// View model for selecting a meter before capturing a reading.
@MainActor
final class ReadingsViewModel: ObservableObject {
    // MARK: - Properties

    @Published private(set) var meters: [Meter] = []
    @Published var errorMessage: LocalizedStringResource?

    private let dependencies: AppDependencies
    private let meterRepository: MeterRepositoryProtocol

    // MARK: - Initialization

    init(dependencies: AppDependencies) {
        self.dependencies = dependencies
        self.meterRepository = dependencies.repositories.meterRepository
    }

    // MARK: - Actions

    /// Loads meters available for reading capture.
    func loadMeters() {
        do {
            meters = try meterRepository.fetchAll()
            errorMessage = nil
        } catch {
            errorMessage = AppStrings.errorGeneric
        }
    }

    /// Creates a view model for capturing a reading for the selected meter.
    func createReadingViewModel(for meter: Meter, onSave: @escaping () -> Void) -> CreateReadingViewModel {
        CreateReadingViewModel(
            meter: meter,
            readingRepository: dependencies.repositories.readingRepository,
            validationService: dependencies.services.readingValidationService,
            onSave: onSave
        )
    }
}
