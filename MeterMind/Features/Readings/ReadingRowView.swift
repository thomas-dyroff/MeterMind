import SwiftUI

/// Compact row for a reading in history lists.
struct ReadingRowView: View {
    // MARK: - Properties

    let reading: Reading
    let unit: String

    // MARK: - Body

    var body: some View {
        VStack(alignment: .leading, spacing: AppTheme.Spacing.extraSmall) {
            HStack {
                Text(ReadingFormatters.dateString(for: reading.date))
                    .font(AppTheme.Typography.cardTitle)
                    .foregroundStyle(AppTheme.Colors.primaryText)

                Spacer()

                Text("\(ReadingFormatters.valueString(for: reading.value)) \(unit)")
                    .font(AppTheme.Typography.cardTitle)
                    .foregroundStyle(AppTheme.Colors.accent)
            }

            if let note = reading.note {
                Text(note)
                    .font(AppTheme.Typography.callout)
                    .foregroundStyle(AppTheme.Colors.secondaryText)
                    .lineLimit(1)
            }
        }
        .padding(.vertical, AppTheme.Spacing.extraSmall)
    }
}
