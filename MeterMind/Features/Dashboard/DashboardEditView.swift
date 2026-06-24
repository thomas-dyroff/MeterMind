import SwiftUI

/// Dashboard configuration view for visibility and card order.
struct DashboardEditView: View {
    // MARK: - Properties

    @ObservedObject var viewModel: DashboardViewModel

    // MARK: - Body

    var body: some View {
        List {
            ForEach(viewModel.editCards) { card in
                DashboardEditRow(
                    viewData: card,
                    isVisible: card.isVisibleOnDashboard
                ) { isVisible in
                    viewModel.setDashboardVisibility(for: card, isVisible: isVisible)
                }
            }
            .onMove(perform: viewModel.moveDashboardCards)
        }
        .environment(\.editMode, .constant(.active))
        .scrollContentBackground(.hidden)
    }
}
