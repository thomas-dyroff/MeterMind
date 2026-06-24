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
            let latestReading = try readingRepository.fetchLatestReading(for: meter)
            switch validationService.validateReading(formData: formData, latestReading: latestReading) {
            case .valid(let value):
                if validationService.detectLargeJump(newValue: value, latestReading: latestReading),
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

    private func resetMessages() {
        validationErrors = []
        warningMessage = nil
        errorMessage = nil
    }
}
