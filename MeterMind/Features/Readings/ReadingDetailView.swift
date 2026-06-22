import SwiftUI

/// Detail screen for a reading.
struct ReadingDetailView: View {
    // MARK: - Properties

    @ObservedObject var viewModel: ReadingDetailViewModel
    let editViewModelFactory: (@escaping () -> Void) -> EditReadingViewModel
    let onSave: () -> Void

    @State private var isPresentingEditReading = false

    // MARK: - Body

    var body: some View {
        ScrollView {
            SectionCard {
                detailRow(title: AppStrings.readingDateField, value: viewModel.date)
                detailRow(title: AppStrings.readingValueField, value: viewModel.value)
                detailRow(title: AppStrings.readingNoteField, value: viewModel.note)
            }
            .padding(AppTheme.Spacing.medium)
        }
        .background(AppTheme.Colors.background)
        .navigationTitle(Text(AppStrings.readingDetailTitle))
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button {
                    isPresentingEditReading = true
                } label: {
                    Text(AppStrings.meterEditButton)
                }
            }
        }
        .sheet(isPresented: $isPresentingEditReading) {
            EditReadingView(
                viewModel: editViewModelFactory {
                    onSave()
                    isPresentingEditReading = false
                }
            )
        }
    }

    private func detailRow(title: LocalizedStringResource, value: String) -> some View {
        VStack(alignment: .leading, spacing: AppTheme.Spacing.extraSmall) {
            Text(title)
                .font(AppTheme.Typography.callout)
                .foregroundStyle(AppTheme.Colors.secondaryText)

            Text(value)
                .font(AppTheme.Typography.body)
                .foregroundStyle(AppTheme.Colors.primaryText)
        }
    }
}
