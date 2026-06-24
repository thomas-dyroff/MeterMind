import SwiftUI

/// Detail screen for a meter with analytics charts.
struct MeterDetailView: View {
    // MARK: - Properties

    @ObservedObject var viewModel: MeterDetailViewModel
    let editViewModelFactory: (@escaping () -> Void) -> EditMeterViewModel?
    let readingListViewModelFactory: () -> ReadingListViewModel
    let onSave: () -> Void

    @State private var isPresentingEditMeter = false

    // MARK: - Body

    var body: some View {
        ScrollView {
            VStack(spacing: AppTheme.Spacing.medium) {
                headerCard
                historyLink
                chartList
            }
            .padding(AppTheme.Spacing.medium)
        }
        .background(AppTheme.Colors.background)
        .navigationTitle(Text(viewModel.name))
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button {
                    isPresentingEditMeter = true
                } label: {
                    Image(systemName: "pencil")
                }
                .accessibilityLabel(Text(AppStrings.meterDetailEdit))
            }
        }
        .sheet(isPresented: $isPresentingEditMeter) {
            if let editViewModel = editViewModelFactory({
                onSave()
                viewModel.load()
                isPresentingEditMeter = false
            }) {
                EditMeterView(viewModel: editViewModel)
            } else {
                EmptyStateView(
                    title: AppStrings.meterDetailTitle,
                    message: AppStrings.errorGeneric,
                    icon: "exclamationmark.triangle"
                )
                .padding(AppTheme.Spacing.medium)
            }
        }
        .task {
            viewModel.load()
        }
    }

    private var headerCard: some View {
        SectionCard {
            VStack(alignment: .leading, spacing: AppTheme.Spacing.medium) {
                Text(viewModel.name)
                    .font(AppTheme.Typography.cardTitle)
                    .foregroundStyle(AppTheme.Colors.primaryText)

                HStack(alignment: .firstTextBaseline, spacing: AppTheme.Spacing.small) {
                    Text(viewModel.latestReadingText)
                        .font(.system(size: 36, weight: .bold, design: .rounded))
                        .foregroundStyle(AppTheme.Colors.primaryText)
                        .monospacedDigit()

                    Text(viewModel.unit)
                        .font(AppTheme.Typography.callout.weight(.semibold))
                        .foregroundStyle(AppTheme.Colors.secondaryText)
                }

                Text(latestReadingMetaText)
                    .font(AppTheme.Typography.caption)
                    .foregroundStyle(AppTheme.Colors.secondaryText)

                Divider()

                detailRow(title: AppStrings.meterTypeField, value: viewModel.typeName)
                detailRow(title: AppStrings.meterSerialNumberField, value: viewModel.serialNumber)
            }
        }
    }

    private var historyLink: some View {
        NavigationLink {
            ReadingListView(viewModel: readingListViewModelFactory())
        } label: {
            SectionCard {
                HStack {
                    Label(AppStrings.meterDetailHistoryShow, systemImage: "list.bullet.rectangle")
                        .font(AppTheme.Typography.cardTitle)
                        .foregroundStyle(AppTheme.Colors.primaryText)

                    Spacer()

                    Image(systemName: "chevron.right")
                        .foregroundStyle(AppTheme.Colors.secondaryText)
                }
            }
        }
        .buttonStyle(.plain)
    }

    private var chartList: some View {
        VStack(spacing: AppTheme.Spacing.medium) {
            ForEach(viewModel.chartSections) { section in
                MeterConsumptionChart(
                    title: section.title,
                    dataPoints: section.dataPoints,
                    unit: section.unit,
                    periodType: section.periodType
                )
            }
        }
    }

    private var latestReadingMetaText: String {
        String(
            format: String(localized: AppStrings.meterDetailLatestReading),
            viewModel.latestReadingDateText
        )
    }

    private func detailRow(title: LocalizedStringResource, value: String) -> some View {
        VStack(alignment: .leading, spacing: AppTheme.Spacing.extraSmall) {
            Text(title)
                .font(AppTheme.Typography.caption)
                .foregroundStyle(AppTheme.Colors.secondaryText)

            Text(value)
                .font(AppTheme.Typography.body)
                .foregroundStyle(AppTheme.Colors.primaryText)
        }
    }
}
