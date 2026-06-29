import SwiftUI

/// Detail screen for a meter with simplified household statistics.
struct MeterDetailView: View {
    // MARK: - Properties

    @ObservedObject var viewModel: MeterDetailViewModel
    let editViewModelFactory: (@escaping () -> Void) -> EditMeterViewModel?
    let readingListViewModelFactory: () -> ReadingListViewModel

    @State private var selectedPeriod: MeterDetailFocusPeriod = .month
    @State private var isPresentingEditMeter = false

    // MARK: - Body

    var body: some View {
        ScrollView {
            VStack(spacing: AppTheme.Spacing.medium) {
                headerCard
                mainMetricCard
                historyLink
                MeterMonthlyTrendChart(
                    points: viewModel.monthlyTrendPoints,
                    unit: viewModel.unit,
                    color: accentColor
                )
                MeterYearlyComparisonChart(
                    points: viewModel.yearlyComparisonPoints,
                    unit: viewModel.unit,
                    color: accentColor
                )
                MeterYearJourneyView(
                    items: viewModel.yearlyJourneyItems,
                    unit: viewModel.unit,
                    color: accentColor
                )
                summaryCard
                insightCard
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
            HStack(alignment: .center, spacing: AppTheme.Spacing.medium) {
                ZStack {
                    Circle()
                        .fill(accentColor)
                        .frame(width: 64, height: 64)

                    Image(systemName: iconName)
                        .font(.system(size: 28, weight: .semibold))
                        .foregroundStyle(AppTheme.Colors.buttonText)
                }
                .accessibilityHidden(true)

                VStack(alignment: .leading, spacing: AppTheme.Spacing.small) {
                    Text(viewModel.name)
                        .font(AppTheme.Typography.cardTitle)
                        .foregroundStyle(AppTheme.Colors.primaryText)

                    Text(viewModel.typeName)
                        .font(AppTheme.Typography.callout)
                        .foregroundStyle(AppTheme.Colors.secondaryText)

                    HStack(alignment: .firstTextBaseline, spacing: AppTheme.Spacing.small) {
                        Text(viewModel.latestReadingText)
                            .font(.system(size: 34, weight: .bold, design: .rounded))
                            .foregroundStyle(AppTheme.Colors.primaryText)
                            .monospacedDigit()

                        Text(viewModel.unit)
                            .font(AppTheme.Typography.callout.weight(.semibold))
                            .foregroundStyle(AppTheme.Colors.secondaryText)
                    }

                    Text(latestReadingMetaText)
                        .font(AppTheme.Typography.caption)
                        .foregroundStyle(AppTheme.Colors.secondaryText)
                }
            }
        }
    }

    private var mainMetricCard: some View {
        SectionCard {
            VStack(alignment: .leading, spacing: AppTheme.Spacing.medium) {
                Picker(String(localized: AppStrings.meterDetailPeriodPicker), selection: $selectedPeriod) {
                    ForEach(MeterDetailFocusPeriod.allCases) { period in
                        Text(period.title).tag(period)
                    }
                }
                .pickerStyle(.segmented)

                Text(viewModel.focusConsumptionText(for: selectedPeriod))
                    .font(.system(size: 42, weight: .bold, design: .rounded))
                    .foregroundStyle(AppTheme.Colors.primaryText)
                    .monospacedDigit()

                Text(viewModel.focusSubtitle(for: selectedPeriod))
                    .font(AppTheme.Typography.callout)
                    .foregroundStyle(AppTheme.Colors.secondaryText)

                if selectedPeriod == .month, let comparison = viewModel.primaryComparisonText {
                    Text(comparison)
                        .font(AppTheme.Typography.cardTitle)
                        .foregroundStyle(accentColor)
                }
            }
        }
    }

    private var historyLink: some View {
        NavigationLink {
            ReadingListView(viewModel: readingListViewModelFactory())
        } label: {
            SectionCard {
                HStack {
                    Label(AppStrings.meterDetailHistoryShow, systemImage: "clock.arrow.circlepath")
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

    private var summaryCard: some View {
        SectionCard {
            VStack(alignment: .leading, spacing: AppTheme.Spacing.medium) {
                Text(AppStrings.meterDetailSummaryTitle)
                    .font(AppTheme.Typography.cardTitle)
                    .foregroundStyle(AppTheme.Colors.primaryText)

                LazyVGrid(columns: [GridItem(.adaptive(minimum: 130))], spacing: AppTheme.Spacing.medium) {
                    ForEach(viewModel.summaryItems) { item in
                        VStack(alignment: .leading, spacing: AppTheme.Spacing.extraSmall) {
                            Text(item.title)
                                .font(AppTheme.Typography.caption)
                                .foregroundStyle(AppTheme.Colors.secondaryText)

                            Text(item.value)
                                .font(AppTheme.Typography.cardTitle)
                                .foregroundStyle(AppTheme.Colors.primaryText)
                        }
                        .frame(maxWidth: .infinity, alignment: .leading)
                    }
                }
            }
        }
    }

    private var insightCard: some View {
        SectionCard {
            HStack(alignment: .top, spacing: AppTheme.Spacing.medium) {
                Image(systemName: "sparkle.magnifyingglass")
                    .font(.system(size: 24, weight: .semibold))
                    .foregroundStyle(accentColor)
                    .accessibilityHidden(true)

                VStack(alignment: .leading, spacing: AppTheme.Spacing.small) {
                    Text(AppStrings.meterDetailInsightTitle)
                        .font(AppTheme.Typography.cardTitle)
                        .foregroundStyle(AppTheme.Colors.primaryText)

                    Text(viewModel.insightText ?? String(localized: AppStrings.meterDetailInsightEmpty))
                        .font(AppTheme.Typography.body)
                        .foregroundStyle(AppTheme.Colors.secondaryText)
                        .fixedSize(horizontal: false, vertical: true)
                }
            }
        }
    }

    private var latestReadingMetaText: String {
        String(
            format: String(localized: AppStrings.meterDetailLatestReading),
            viewModel.latestReadingDateText
        )
    }

    private var accentColor: Color {
        switch viewModel.meter?.type {
        case .gas:
            Color(red: 0.10, green: 0.48, blue: 0.58)
        case .water:
            Color(red: 0.17, green: 0.66, blue: 0.77)
        case .districtHeating:
            AppTheme.Colors.warning
        case .heatingOil:
            Color(red: 0.42, green: 0.47, blue: 0.34)
        default:
            Color(red: 0.06, green: 0.36, blue: 0.32)
        }
    }

    private var iconName: String {
        switch viewModel.meter?.type {
        case .electricityImport:
            "bolt.fill"
        case .pvFeedIn:
            "sun.max.fill"
        case .gas:
            "flame.fill"
        case .water:
            "drop.fill"
        default:
            "gauge.with.dots.needle.bottom.50percent"
        }
    }
}
