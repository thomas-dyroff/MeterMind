import Foundation

/// View model for a meter's reading history.
@MainActor
final class ReadingListViewModel: ObservableObject {
    // MARK: - Properties

    @Published private(set) var readings: [Reading] = []
    @Published var errorMessage: LocalizedStringResource?

    let meter: Meter
    private let readingRepository: ReadingRepositoryProtocol
    private let validationService: ReadingValidationService

    // MARK: - Initialization

    init(
        meter: Meter,
        readingRepository: ReadingRepositoryProtocol,
        validationService: ReadingValidationService
    ) {
        self.meter = meter
        self.readingRepository = readingRepository
        self.validationService = validationService
    }

    // MARK: - Actions

    /// Loads readings for the meter.
    func loadReadings() {
        do {
            readings = try readingRepository.fetchByMeter(meter)
            errorMessage = nil
        } catch {
            errorMessage = AppStrings.errorGeneric
        }
    }

    /// Deletes readings at the provided offsets.
    func deleteReadings(at offsets: IndexSet) {
        do {
            for index in offsets {
                try readingRepository.delete(readings[index])
            }
            loadReadings()
        } catch {
            errorMessage = AppStrings.errorGeneric
        }
    }

    /// Creates a detail view model.
    func detailViewModel(for reading: Reading) -> ReadingDetailViewModel {
        ReadingDetailViewModel(reading: reading, meterUnit: meter.unit)
    }

    /// Creates a create-reading view model.
    func createViewModel(onSave: @escaping () -> Void) -> CreateReadingViewModel {
        CreateReadingViewModel(
            meter: meter,
            readingRepository: readingRepository,
            validationService: validationService,
            onSave: onSave
        )
    }

    /// Creates an edit-reading view model.
    func editViewModel(for reading: Reading, onSave: @escaping () -> Void) -> EditReadingViewModel {
        EditReadingViewModel(
            reading: reading,
            meter: meter,
            readingRepository: readingRepository,
            validationService: validationService,
            onSave: onSave
        )
    }
}
