import SwiftUI

/// Shared form fields for creating and editing readings.
struct ReadingFormView: View {
    // MARK: - Properties

    @Binding var formData: ReadingFormData
    let meterUnit: String
    let validationErrors: [ReadingValidationError]
    let warningMessage: LocalizedStringResource?
    let onInputChanged: () -> Void

    @FocusState private var isValueFocused: Bool

    // MARK: - Body

    var body: some View {
        SectionCard {
            DatePicker(
                String(localized: AppStrings.readingDateField),
                selection: $formData.date,
                displayedComponents: .date
            )

            VStack(alignment: .leading, spacing: AppTheme.Spacing.small) {
                Text(AppStrings.readingValueField)
                    .font(AppTheme.Typography.callout)
                    .foregroundStyle(AppTheme.Colors.secondaryText)

                HStack {
                    TextField(String(localized: AppStrings.readingValueField), text: $formData.valueText)
                        .keyboardType(.decimalPad)
                        .font(AppTheme.Typography.screenTitle)
                        .focused($isValueFocused)
                        .onChange(of: formData.valueText) {
                            onInputChanged()
                        }

                    Text(meterUnit)
                        .font(AppTheme.Typography.cardTitle)
                        .foregroundStyle(AppTheme.Colors.secondaryText)
                }
            }

            TextField(String(localized: AppStrings.readingNoteField), text: $formData.note, axis: .vertical)
                .lineLimit(3, reservesSpace: true)

            messageList
        }
        .onAppear {
            isValueFocused = true
        }
    }

    private var messageList: some View {
        VStack(alignment: .leading, spacing: AppTheme.Spacing.extraSmall) {
            ForEach(validationErrors) { error in
                Text(error.message)
                    .font(AppTheme.Typography.callout)
                    .foregroundStyle(AppTheme.Colors.error)
            }

            if let warningMessage {
                Text(warningMessage)
                    .font(AppTheme.Typography.callout)
                    .foregroundStyle(AppTheme.Colors.warning)
            }
        }
    }
}
