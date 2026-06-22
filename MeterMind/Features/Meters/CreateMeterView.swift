import SwiftUI

/// Screen for creating a meter.
struct CreateMeterView: View {
    // MARK: - Properties

    @ObservedObject var viewModel: CreateMeterViewModel
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

                PrimaryButton(title: AppStrings.meterCreateButton) {
                    viewModel.save()
                }
                .padding(.horizontal, AppTheme.Spacing.medium)
            }
            .background(AppTheme.Colors.background)
            .navigationTitle(Text(AppStrings.createMeterTitle))
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
