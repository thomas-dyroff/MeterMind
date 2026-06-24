import SwiftUI

/// Compact row for configuring one dashboard meter.
struct DashboardEditRow: View {
    // MARK: - Properties

    let viewData: DashboardCardViewData
    let isVisible: Bool
    let onVisibilityChange: @MainActor (Bool) -> Void

    // MARK: - Body

    var body: some View {
        HStack(spacing: AppTheme.Spacing.medium) {
            Image(systemName: "line.3.horizontal")
                .foregroundStyle(AppTheme.Colors.secondaryText)
                .accessibilityHidden(true)

            ZStack {
                Circle()
                    .fill(viewData.iconColor)
                    .frame(width: 36, height: 36)

                Image(systemName: viewData.iconName)
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundStyle(AppTheme.Colors.buttonText)
            }

            VStack(alignment: .leading, spacing: AppTheme.Spacing.extraSmall) {
                Text(viewData.meterName)
                    .font(AppTheme.Typography.cardTitle)
                    .foregroundStyle(AppTheme.Colors.primaryText)

                Text(viewData.unit)
                    .font(AppTheme.Typography.caption)
                    .foregroundStyle(AppTheme.Colors.secondaryText)
            }

            Spacer()

            Toggle(isOn: visibilityBinding) {
                Text(AppStrings.dashboardShowToggle)
                    .font(AppTheme.Typography.caption)
            }
            .labelsHidden()
        }
        .padding(.vertical, AppTheme.Spacing.small)
    }

    private var visibilityBinding: Binding<Bool> {
        Binding(
            get: { isVisible },
            set: { newValue in
                Task { @MainActor in
                    onVisibilityChange(newValue)
                }
            }
        )
    }
}
