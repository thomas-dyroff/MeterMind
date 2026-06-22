import SwiftUI

/// Entry screen for selecting a meter and capturing a reading.
struct ReadingsView: View {
    // MARK: - Properties

    @ObservedObject var viewModel: ReadingsViewModel
    @State private var selectedMeter: Meter?

    // MARK: - Body

    var body: some View {
        NavigationStack {
            Group {
                if viewModel.meters.isEmpty {
                    emptyState
                } else {
                    meterSelectionList
                }
            }
            .background(AppTheme.Colors.background)
            .navigationTitle(Text(AppStrings.readingsTitle))
            .sheet(item: $selectedMeter) { meter in
                CreateReadingView(
                    viewModel: viewModel.createReadingViewModel(for: meter) {
                        selectedMeter = nil
                    }
                )
            }
            .task {
                viewModel.loadMeters()
            }
        }
    }

    private var emptyState: some View {
        SectionCard {
            EmptyStateView(
                title: AppStrings.readingsTitle,
                message: AppStrings.readingsNoMetersMessage,
                icon: "plus.circle"
            )
        }
        .padding(AppTheme.Spacing.medium)
    }

    private var meterSelectionList: some View {
        List {
            Section {
                ForEach(viewModel.meters) { meter in
                    Button {
                        selectedMeter = meter
                    } label: {
                        MeterRowView(meter: meter)
                    }
                }
            } header: {
                Text(AppStrings.readingsSelectMeterTitle)
            }
        }
        .scrollContentBackground(.hidden)
    }
}
