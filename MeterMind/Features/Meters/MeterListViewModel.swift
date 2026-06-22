import Foundation

/// View model for the meter list screen.
@MainActor
final class MeterListViewModel: ObservableObject {
    // MARK: - Properties

    @Published private(set) var meters: [Meter] = []
    @Published var errorMessage: LocalizedStringResource?

    private let meterRepository: MeterRepositoryProtocol
    private let readingRepository: ReadingRepositoryProtocol
    private let readingValidationService: ReadingValidationService

    // MARK: - Initialization

    init(dependencies: AppDependencies) {
        self.meterRepository = dependencies.repositories.meterRepository
        self.readingRepository = dependencies.repositories.readingRepository
        self.readingValidationService = dependencies.services.readingValidationService
    }

    // MARK: - Actions

    /// Loads all meters.
    func loadMeters() {
        do {
            meters = try meterRepository.fetchAll()
            errorMessage = nil
        } catch {
            errorMessage = AppStrings.errorGeneric
        }
    }

    /// Deletes meters at the provided offsets.
    func deleteMeters(at offsets: IndexSet) {
        do {
            for index in offsets {
                try meterRepository.delete(meters[index])
            }
            loadMeters()
        } catch {
            errorMessage = AppStrings.errorGeneric
        }
    }

    /// Creates a detail view model for a selected meter.
    func detailViewModel(for meter: Meter) -> MeterDetailViewModel {
        MeterDetailViewModel(meter: meter)
    }

    /// Creates a create-meter view model.
    func createViewModel(onSave: @escaping () -> Void) -> CreateMeterViewModel {
        CreateMeterViewModel(meterRepository: meterRepository, onSave: onSave)
    }

    /// Creates an edit-meter view model.
    func editViewModel(for meter: Meter, onSave: @escaping () -> Void) -> EditMeterViewModel {
        EditMeterViewModel(meter: meter, meterRepository: meterRepository, onSave: onSave)
    }

    /// Creates a reading history view model for a meter.
    func readingListViewModel(for meter: Meter) -> ReadingListViewModel {
        ReadingListViewModel(
            meter: meter,
            readingRepository: readingRepository,
            validationService: readingValidationService
        )
    }
}
