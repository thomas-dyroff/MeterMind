import SwiftUI

/// Shared form fields for creating and editing meters.
struct MeterFormView: View {
    // MARK: - Properties

    @Binding var formData: MeterFormData
    let validationErrors: [MeterValidationError]

    // MARK: - Body

    var body: some View {
        SectionCard {
            Text(AppStrings.meterFormSectionDetails)
                .font(AppTheme.Typography.cardTitle)
                .foregroundStyle(AppTheme.Colors.primaryText)

            TextField(String(localized: AppStrings.meterNameField), text: $formData.name)
                .textInputAutocapitalization(.words)

            Picker(String(localized: AppStrings.meterTypeField), selection: $formData.type) {
                ForEach(MeterType.allCases) { type in
                    Text(type.localizedTitle)
                        .tag(type)
                }
            }

            if formData.type == .custom {
                TextField(
                    String(localized: AppStrings.meterCustomTypeField),
                    text: $formData.customTypeName
                )
                .textInputAutocapitalization(.words)
            }

            Picker(String(localized: AppStrings.meterUnitField), selection: unitSelection) {
                ForEach(MeterUnit.allCases) { unit in
                    Text(unit.localizedLabel)
                        .tag(unit)
                }
            }

            TextField(
                String(localized: AppStrings.meterSerialNumberField),
                text: $formData.serialNumber
            )
            .textInputAutocapitalization(.characters)

            validationErrorList
        }
    }

    private var validationErrorList: some View {
        VStack(alignment: .leading, spacing: AppTheme.Spacing.extraSmall) {
            ForEach(validationErrors) { error in
                Text(error.message)
                    .font(AppTheme.Typography.callout)
                    .foregroundStyle(AppTheme.Colors.error)
            }
        }
    }

    private var unitSelection: Binding<MeterUnit> {
        Binding(
            get: {
                MeterUnit.fallbackUnit(for: formData.unit)
            },
            set: { newUnit in
                formData.unit = newUnit.rawValue
            }
        )
    }
}
