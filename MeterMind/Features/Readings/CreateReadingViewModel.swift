import Foundation

/// View model for creating a reading.
@MainActor
final class CreateReadingViewModel: ObservableObject {
    // MARK: - Properties

    @Published var formData = ReadingFormData()
    @Published private(set) var validationErrors: [ReadingValidationError] = []
    @Published var warningMessage: LocalizedStringResource?
    @Published var errorMessage: LocalizedStringResource?

    let meterName: String
    let meterUnit: String

    private let meter: Meter
    private let readingRepository: ReadingRepositoryProtocol
    private let validationService: ReadingValidationService
    private let onSave: () -> Void
    private var hasConfirmedLargeJump = false

    // MARK: - Initialization

    init(
        meter: Meter,
        readingRepository: ReadingRepositoryProtocol,
        validationService: ReadingValidationService,
        onSave: @escaping () -> Void
    ) {
        self.meter = meter
        self.meterName = meter.name
        self.meterUnit = MeterUnit.symbol(for: meter.unit)
        self.readingRepository = readingRepository
        self.validationService = validationService
        self.onSave = onSave
    }

    // MARK: - Actions

    /// Validates and persists the new reading.
    func save() {
        do {
            let neighbors = try chronologicalNeighbors(for: formData.date)
            switch validationService.validateReading(
                formData: formData,
                previousReading: neighbors.previous,
                nextReading: neighbors.next
            ) {
            case .valid(let value):
                if validationService.detectLargeJump(newValue: value, previousReading: neighbors.previous),
                   !hasConfirmedLargeJump {
                    warningMessage = AppStrings.validationReadingLargeJump
                    hasConfirmedLargeJump = true
                    return
                }

                _ = try readingRepository.create(formData, value: value, meter: meter)
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
