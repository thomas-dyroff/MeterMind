import SwiftUI

/// Detail screen for a meter.
struct MeterDetailView: View {
    // MARK: - Properties

    @ObservedObject var viewModel: MeterDetailViewModel
    let editViewModelFactory: (@escaping () -> Void) -> EditMeterViewModel
    let readingListViewModelFactory: () -> ReadingListViewModel
    let onSave: () -> Void

    @State private var isPresentingEditMeter = false

    // MARK: - Body

    var body: some View {
        ScrollView {
            SectionCard {
                detailRow(title: AppStrings.meterNameField, value: viewModel.name)
                detailRow(title: AppStrings.meterTypeField, value: viewModel.typeName)
                detailRow(title: AppStrings.meterUnitField, value: viewModel.unit)
                detailRow(title: AppStrings.meterSerialNumberField, value: viewModel.serialNumber)
            }
            .padding(AppTheme.Spacing.medium)

            NavigationLink {
                ReadingListView(viewModel: readingListViewModelFactory())
            } label: {
                SectionCard {
                    HStack {
                        Label(AppStrings.readingHistoryTitle, systemImage: "list.bullet.rectangle")
                            .font(AppTheme.Typography.cardTitle)
                            .foregroundStyle(AppTheme.Colors.primaryText)

                        Spacer()

                        Image(systemName: "chevron.right")
                            .foregroundStyle(AppTheme.Colors.secondaryText)
                    }
                }
                .padding(.horizontal, AppTheme.Spacing.medium)
            }
        }
        .background(AppTheme.Colors.background)
        .navigationTitle(Text(AppStrings.meterDetailTitle))
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button {
                    isPresentingEditMeter = true
                } label: {
                    Text(AppStrings.meterEditButton)
                }
            }
        }
        .sheet(isPresented: $isPresentingEditMeter) {
            EditMeterView(
                viewModel: editViewModelFactory {
                    onSave()
                    isPresentingEditMeter = false
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
