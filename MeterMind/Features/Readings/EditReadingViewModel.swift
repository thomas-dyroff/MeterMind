import Foundation

/// View model for editing a reading.
@MainActor
final class EditReadingViewModel: ObservableObject {
    // MARK: - Properties

    @Published var formData: ReadingFormData
    @Published private(set) var validationErrors: [ReadingValidationError] = []
    @Published var warningMessage: LocalizedStringResource?
    @Published var errorMessage: LocalizedStringResource?

    let meterUnit: String

    private let reading: Reading
    private let meter: Meter
    private let readingRepository: ReadingRepositoryProtocol
    private let validationService: ReadingValidationService
    private let onSave: () -> Void
    private var hasConfirmedLargeJump = false

    // MARK: - Initialization

    init(
        reading: Reading,
        meter: Meter,
        readingRepository: ReadingRepositoryProtocol,
        validationService: ReadingValidationService,
        onSave: @escaping () -> Void
    ) {
        self.reading = reading
        self.meter = meter
        self.meterUnit = MeterUnit.symbol(for: meter.unit)
        self.readingRepository = readingRepository
        self.validationService = validationService
        self.onSave = onSave
        self.formData = ReadingFormData(
            date: reading.date,
            valueText: ReadingFormatters.valueString(for: reading.value),
            note: reading.note ?? ""
        )
    }

    // MARK: - Actions

    /// Validates and persists changes to the reading.
    func save() {
        do {
            let neighbors = try chronologicalNeighbors(for: formData.date)
            switch validationService.validateReading(
                formData: formData,
                previousReading: neighbors.previous,
                nextReading: neighbors.next,
                currentReadingId: reading.id
            ) {
            case .valid(let value):
                if validationService.detectLargeJump(
                    newValue: value,
                    previousReading: neighbors.previous,
                    currentReadingId: reading.id
                ), !hasConfirmedLargeJump {
                    warningMessage = AppStrings.validationReadingLargeJump
                    hasConfirmedLargeJump = true
                    return
                }

                try readingRepository.update(reading, with: formData, value: value)
                resetMessages()
                onSave()
            case .invalid(let errors):
                validationErrors = errors
                warningMessage = nil
            }
        } catch {
            errorMessage = AppStrings.errorGeneric
        }
    }

    /// Resets large-jump confirmation when input changes.
    func markInputChanged() {
        hasConfirmedLargeJump = false
        warningMessage = nil
    }

    private func chronologicalNeighbors(for date: Date) throws -> (previous: Reading?, next: Reading?) {
        let readings = try readingRepository.fetchByMeter(meter)
            .filter { $0.id != reading.id }
            .sorted { $0.date < $1.date }
        let previousReading = readings.last { $0.date <= date }
        let nextReading = readings.first { $0.date > date }

        return (previousReading, nextReading)
    }

    private func resetMessages() {
        validationErrors = []
        warningMessage = nil
        errorMessage = nil
    }
}
