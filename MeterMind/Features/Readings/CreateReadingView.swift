import SwiftUI

/// Screen for creating a reading.
struct CreateReadingView: View {
    // MARK: - Properties

    @ObservedObject var viewModel: CreateReadingViewModel
    @Environment(\.dismiss) private var dismiss

    // MARK: - Body

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: AppTheme.Spacing.large) {
                    SectionCard {
                        Text(viewModel.meterName)
                            .font(AppTheme.Typography.cardTitle)
                            .foregroundStyle(AppTheme.Colors.primaryText)
                    }

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
            .navigationTitle(Text(AppStrings.readingCreateTitle))
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
