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
    private let limit: Int?

    // MARK: - Initialization

    init(
        meter: Meter,
        readingRepository: ReadingRepositoryProtocol,
        validationService: ReadingValidationService,
        limit: Int? = nil
    ) {
        self.meter = meter
        self.readingRepository = readingRepository
        self.validationService = validationService
        self.limit = limit
    }

    // MARK: - Actions

    /// Loads readings for the meter.
    func loadReadings() {
        do {
            let fetchedReadings = try readingRepository.fetchByMeter(meter)
            if let limit {
                readings = Array(fetchedReadings.prefix(limit))
            } else {
                readings = fetchedReadings
            }
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
        ReadingDetailViewModel(reading: reading, meterUnit: MeterUnit.symbol(for: meter.unit))
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
