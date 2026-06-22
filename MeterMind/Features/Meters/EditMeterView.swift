import SwiftUI

/// Screen for editing a meter.
struct EditMeterView: View {
    // MARK: - Properties

    @ObservedObject var viewModel: EditMeterViewModel
    @Environment(\.dismiss) private var dismiss

    // MARK: - Body

    var body: some View {
        NavigationStack {
            ScrollView {
                MeterFormView(
                    formData: $viewModel.formData,
                    validationErrors: viewModel.validationErrors
                )
                .padding(AppTheme.Spacing.medium)

                PrimaryButton(title: AppStrings.meterSaveButton) {
                    viewModel.save()
                }
                .padding(.horizontal, AppTheme.Spacing.medium)
            }
            .background(AppTheme.Colors.background)
            .navigationTitle(Text(AppStrings.editMeterTitle))
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
