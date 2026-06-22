import SwiftUI

/// Compact row for a meter in the list.
struct MeterRowView: View {
    // MARK: - Properties

    let meter: Meter

    // MARK: - Body

    var body: some View {
        VStack(alignment: .leading, spacing: AppTheme.Spacing.extraSmall) {
            Text(meter.name)
                .font(AppTheme.Typography.cardTitle)
                .foregroundStyle(AppTheme.Colors.primaryText)

            Text(meterDisplaySubtitle)
                .font(AppTheme.Typography.callout)
                .foregroundStyle(AppTheme.Colors.secondaryText)
        }
        .padding(.vertical, AppTheme.Spacing.extraSmall)
    }

    private var meterDisplaySubtitle: String {
        let typeName = meter.type == .custom
            ? meter.customTypeName ?? String(localized: meter.type.localizedTitle)
            : String(localized: meter.type.localizedTitle)
        return "\(typeName) · \(meter.unit)"
    }
}
