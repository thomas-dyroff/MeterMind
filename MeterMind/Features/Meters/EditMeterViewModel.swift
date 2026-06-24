import Foundation

/// View model for editing a meter.
@MainActor
final class EditMeterViewModel: ObservableObject {
    // MARK: - Properties

    @Published var formData: MeterFormData
    @Published private(set) var validationErrors: [MeterValidationError] = []
    @Published var errorMessage: LocalizedStringResource?

    private let meterId: UUID
    private let meterRepository: MeterRepositoryProtocol
    private let onSave: () -> Void

    // MARK: - Initialization

    init(
        meter: Meter,
        meterRepository: MeterRepositoryProtocol,
        onSave: @escaping () -> Void
    ) {
        self.meterId = meter.id
        self.meterRepository = meterRepository
        self.onSave = onSave
        self.formData = MeterFormData(
            name: meter.name,
            type: meter.type,
            customTypeName: meter.customTypeName ?? "",
            unit: MeterUnit.persistedRawValue(for: meter.unit),
            serialNumber: meter.serialNumber ?? ""
        )
    }

    init?(
        meterId: UUID,
        meterRepository: MeterRepositoryProtocol,
        onSave: @escaping () -> Void
    ) {
        guard let meter = try? meterRepository.fetchById(meterId) else {
            return nil
        }

        self.meterId = meterId
        self.meterRepository = meterRepository
        self.onSave = onSave
        self.formData = MeterFormData(
            name: meter.name,
            type: meter.type,
            customTypeName: meter.customTypeName ?? "",
            unit: MeterUnit.persistedRawValue(for: meter.unit),
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
            guard let meter = try meterRepository.fetchById(meterId) else {
                errorMessage = AppStrings.errorGeneric
                return
            }

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
