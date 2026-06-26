import SwiftUI

/// Meter-centered dashboard start screen.
struct DashboardView: View {
    // MARK: - Properties

    @ObservedObject var viewModel: DashboardViewModel

    // MARK: - Body

    var body: some View {
        NavigationStack {
            Group {
                if viewModel.isEditingDashboard {
                    DashboardEditView(viewModel: viewModel)
                } else if viewModel.cards.isEmpty {
                    emptyState
                } else {
                    meterCards
                }
            }
            .background(AppTheme.Colors.background)
            .navigationTitle(Text(AppStrings.dashboardTitle))
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    if viewModel.isEditingDashboard {
                        Button {
                            viewModel.finishEditingDashboard()
                        } label: {
                            Text(AppStrings.dashboardDoneButton)
                        }
                    } else {
                        Button {
                            viewModel.startEditingDashboard()
                        } label: {
                            Image(systemName: "slider.horizontal.3")
                        }
                        .accessibilityLabel(Text(AppStrings.dashboardEditButton))
                    }
                }
            }
            .onAppear {
                viewModel.loadDashboard()
            }
        }
    }

    private var meterCards: some View {
        ScrollView {
            LazyVStack(spacing: AppTheme.Spacing.medium) {
                ForEach(viewModel.cards) { card in
                    NavigationLink {
                        meterDestination(for: card)
                    } label: {
                        MeterDashboardCard(viewData: card)
                    }
                    .buttonStyle(.plain)
                }
            }
            .padding(AppTheme.Spacing.medium)
        }
    }

    private var emptyState: some View {
        VStack(spacing: AppTheme.Spacing.large) {
            SectionCard {
                EmptyStateView(
                    title: AppStrings.dashboardTitle,
                    message: emptyStateMessage,
                    icon: "gauge.with.dots.needle.bottom.50percent"
                )
            }

            if !viewModel.editCards.isEmpty {
                PrimaryButton(title: AppStrings.dashboardEditDashboardButton) {
                    viewModel.startEditingDashboard()
                }
            }
        }
        .padding(AppTheme.Spacing.medium)
    }

    private var emptyStateMessage: LocalizedStringResource {
        viewModel.editCards.isEmpty ? AppStrings.dashboardEmptyMessage : AppStrings.dashboardNoVisibleMetersMessage
    }

    @ViewBuilder
    private func meterDestination(for card: DashboardCardViewData) -> some View {
        if let meter = viewModel.meter(for: card) {
            MeterDetailView(
                viewModel: viewModel.detailViewModel(for: card) ?? MeterDetailViewModel(meter: meter),
                editViewModelFactory: { onSave in
                    viewModel.editViewModel(for: card.meterId, onSave: onSave)
                },
                readingListViewModelFactory: {
                    viewModel.readingListViewModel(for: meter, limit: 30)
                }
            )
        } else {
            EmptyStateView(
                title: AppStrings.meterDetailTitle,
                message: AppStrings.errorGeneric,
                icon: "exclamationmark.triangle"
            )
        }
    }
}
