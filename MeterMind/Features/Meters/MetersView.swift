import SwiftUI

/// View for listing and managing meters.
struct MetersView: View {
    // MARK: - Properties

    @ObservedObject var viewModel: MeterListViewModel
    @State private var isPresentingCreateMeter = false

    // MARK: - Body

    var body: some View {
        NavigationStack {
            Group {
                if viewModel.meters.isEmpty {
                    emptyState
                } else {
                    meterList
                }
            }
            .background(AppTheme.Colors.background)
            .navigationTitle(Text(AppStrings.metersTitle))
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        isPresentingCreateMeter = true
                    } label: {
                        Image(systemName: "plus")
                    }
                    .accessibilityLabel(Text(AppStrings.metersAddButton))
                }
            }
            .sheet(isPresented: $isPresentingCreateMeter) {
                CreateMeterView(
                    viewModel: viewModel.createViewModel {
                        viewModel.loadMeters()
                        isPresentingCreateMeter = false
                    }
                )
            }
            .onAppear {
                viewModel.loadMeters()
            }
        }
    }

    private var emptyState: some View {
        VStack(spacing: AppTheme.Spacing.large) {
            SectionCard {
                EmptyStateView(
                    title: AppStrings.metersTitle,
                    message: AppStrings.metersEmptyMessage,
                    icon: "gauge.with.dots.needle.bottom.50percent"
                )
            }

            PrimaryButton(title: AppStrings.metersAddButton) {
                isPresentingCreateMeter = true
            }
        }
        .padding(AppTheme.Spacing.medium)
    }

    private var meterList: some View {
        List {
            ForEach(viewModel.meters) { meter in
                NavigationLink {
                    MeterDetailView(
                        viewModel: viewModel.detailViewModel(for: meter),
                        editViewModelFactory: { onSave in
                            viewModel.editViewModel(for: meter.id, onSave: onSave)
                        },
                        readingListViewModelFactory: {
                            viewModel.readingListViewModel(for: meter, limit: 30)
                        }
                    )
                } label: {
                    MeterRowView(meter: meter)
                }
            }
            .onDelete(perform: viewModel.deleteMeters)
        }
        .scrollContentBackground(.hidden)
    }
}
