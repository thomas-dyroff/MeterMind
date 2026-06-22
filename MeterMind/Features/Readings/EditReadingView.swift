import SwiftUI

/// Screen for editing a reading.
struct EditReadingView: View {
    // MARK: - Properties

    @ObservedObject var viewModel: EditReadingViewModel
    @Environment(\.dismiss) private var dismiss

    // MARK: - Body

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: AppTheme.Spacing.large) {
                    ReadingFormView(
                        formData: $viewModel.formData,
                        meterUnit: viewModel.meterUnit,
                        validationErrors: viewModel.validationErrors,
                        warningMessage: viewModel.warningMessage,
                        onInputChanged: viewModel.markInputChanged
                    )

                    PrimaryButton(title: AppStrings.readingSaveButton) {
                        viewModel.save()
                    }
                }
                .padding(AppTheme.Spacing.medium)
            }
            .background(AppTheme.Colors.background)
            .navigationTitle(Text(AppStrings.readingEditTitle))
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button {
                        dismiss()
                    } label: {
                        Text(AppStrings.meterCancelButton)
                    }
                }
            }
        }
    }
}
