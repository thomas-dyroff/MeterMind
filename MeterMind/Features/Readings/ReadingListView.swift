import SwiftUI

/// History screen for readings of a meter.
struct ReadingListView: View {
    // MARK: - Properties

    @ObservedObject var viewModel: ReadingListViewModel
    @State private var isPresentingCreateReading = false

    // MARK: - Body

    var body: some View {
        Group {
            if viewModel.readings.isEmpty {
                emptyState
            } else {
                readingList
            }
        }
        .background(AppTheme.Colors.background)
        .navigationTitle(Text(AppStrings.readingHistoryTitle))
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button {
                    isPresentingCreateReading = true
                } label: {
                    Image(systemName: "plus")
                }
                .accessibilityLabel(Text(AppStrings.readingAddButton))
            }
        }
        .sheet(isPresented: $isPresentingCreateReading) {
            CreateReadingView(
                viewModel: viewModel.createViewModel {
                    viewModel.loadReadings()
                    isPresentingCreateReading = false
                }
            )
        }
        .task {
            viewModel.loadReadings()
        }
    }

    private var emptyState: some View {
        VStack(spacing: AppTheme.Spacing.large) {
            SectionCard {
                EmptyStateView(
                    title: AppStrings.readingHistoryTitle,
                    message: AppStrings.readingsEmptyMessage,
                    icon: "list.bullet.rectangle"
                )
            }

            PrimaryButton(title: AppStrings.readingAddButton) {
                isPresentingCreateReading = true
            }
        }
        .padding(AppTheme.Spacing.medium)
    }

    private var readingList: some View {
        List {
            ForEach(viewModel.readings) { reading in
                NavigationLink {
                    ReadingDetailView(
                        viewModel: viewModel.detailViewModel(for: reading),
                        editViewModelFactory: { onSave in
                            viewModel.editViewModel(for: reading, onSave: onSave)
                        },
                        onSave: viewModel.loadReadings
                    )
                } label: {
                    ReadingRowView(reading: reading, unit: MeterUnit.symbol(for: viewModel.meter.unit))
                }
            }
            .onDelete(perform: viewModel.deleteReadings)
        }
        .scrollContentBackground(.hidden)
    }
}
