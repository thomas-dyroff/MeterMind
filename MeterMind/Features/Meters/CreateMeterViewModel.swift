import Foundation

/// View model for creating a meter.
@MainActor
final class CreateMeterViewModel: ObservableObject {
    // MARK: - Properties

    @Published var formData = MeterFormData()
    @Published private(set) var validationErrors: [MeterValidationError] = []
    @Published var errorMessage: LocalizedStringResource?

    private let meterRepository: MeterRepositoryProtocol
    private let onSave: () -> Void

    // MARK: - Initialization

    init(meterRepository: MeterRepositoryProtocol, onSave: @escaping () -> Void) {
        self.meterRepository = meterRepository
        self.onSave = onSave
    }

    // MARK: - Actions

    /// Validates and persists the new meter.
    func save() {
        validationErrors = MeterValidator.validate(formData)
        guard validationErrors.isEmpty else {
            return
        }

        do {
            _ = try meterRepository.create(formData, property: nil)
            errorMessage = nil
            onSave()
        } catch let validationError as MeterValidationError {
            validationErrors = [validationError]
        } catch {
            errorMessage = AppStrings.errorGeneric
        }
    }
}
