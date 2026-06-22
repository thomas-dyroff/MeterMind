import Foundation

/// View model for editing a meter.
@MainActor
final class EditMeterViewModel: ObservableObject {
    // MARK: - Properties

    @Published var formData: MeterFormData
    @Published private(set) var validationErrors: [MeterValidationError] = []
    @Published var errorMessage: LocalizedStringResource?

    private let meter: Meter
    private let meterRepository: MeterRepositoryProtocol
    private let onSave: () -> Void

    // MARK: - Initialization

    init(
        meter: Meter,
        meterRepository: MeterRepositoryProtocol,
        onSave: @escaping () -> Void
    ) {
        self.meter = meter
        self.meterRepository = meterRepository
        self.onSave = onSave
        self.formData = MeterFormData(
            name: meter.name,
            type: meter.type,
            customTypeName: meter.customTypeName ?? "",
            unit: meter.unit,
            serialNumber: meter.serialNumber ?? ""
        )
    }

    // MARK: - Actions

    /// Validates and persists changes to the meter.
    func save() {
        validationErrors = MeterValidator.validate(formData)
        guard validationErrors.isEmpty else {
            return
        }

        do {
            try meterRepository.update(meter, with: formData, property: meter.property)
            errorMessage = nil
            onSave()
        } catch let validationError as MeterValidationError {
            validationErrors = [validationError]
        } catch {
            errorMessage = AppStrings.errorGeneric
        }
    }
}
