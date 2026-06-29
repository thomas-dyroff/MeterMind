import SwiftUI

/// Compact metric card for a single meter on the dashboard.
struct MeterDashboardCard: View {
    // MARK: - Properties

    let viewData: DashboardCardViewData

    // MARK: - Body

    var body: some View {
        VStack(alignment: .leading, spacing: AppTheme.Spacing.large) {
            header
            valueRow
            footer
        }
        .padding(AppTheme.Spacing.large)
        .background(AppTheme.Colors.surface)
        .clipShape(RoundedRectangle(cornerRadius: AppTheme.Spacing.large))
        .overlay(
            RoundedRectangle(cornerRadius: AppTheme.Spacing.large)
                .stroke(Color(.separator).opacity(0.25), lineWidth: 1)
        )
        .shadow(color: Color.black.opacity(0.04), radius: 10, x: 0, y: 4)
    }

    private var header: some View {
        HStack(spacing: AppTheme.Spacing.medium) {
            ZStack {
                Circle()
                    .fill(viewData.iconColor)
                    .frame(width: 56, height: 56)

                Image(systemName: viewData.iconName)
                    .font(.system(size: 25, weight: .semibold))
                    .foregroundStyle(AppTheme.Colors.buttonText)
            }
            .accessibilityElement(children: .ignore)
            .accessibilityLabel(Text(viewData.meterType.localizedTitle))

            VStack(alignment: .leading, spacing: AppTheme.Spacing.extraSmall) {
                Text(viewData.meterName)
                    .font(AppTheme.Typography.cardTitle)
                    .foregroundStyle(AppTheme.Colors.primaryText)
                    .lineLimit(1)

                Text(viewData.meterType.localizedTitle)
                    .font(AppTheme.Typography.callout)
                    .foregroundStyle(AppTheme.Colors.secondaryText)
                    .lineLimit(1)
            }

            Spacer(minLength: AppTheme.Spacing.small)
        }
    }

    private var valueRow: some View {
        HStack(alignment: .bottom, spacing: AppTheme.Spacing.medium) {
            VStack(alignment: .leading, spacing: AppTheme.Spacing.small) {
                HStack(alignment: .firstTextBaseline, spacing: AppTheme.Spacing.small) {
                    Text(latestReadingText)
                        .font(.system(size: 36, weight: .bold, design: .rounded))
                        .foregroundStyle(AppTheme.Colors.primaryText)
                        .monospacedDigit()
                        .minimumScaleFactor(0.75)
                        .lineLimit(1)

                    Text(viewData.unit)
                        .font(AppTheme.Typography.callout.weight(.semibold))
                        .foregroundStyle(AppTheme.Colors.secondaryText)
                        .lineLimit(1)
                }

                Text(latestReadingDateText)
                    .font(AppTheme.Typography.caption)
                    .foregroundStyle(AppTheme.Colors.secondaryText)
                    .lineLimit(1)
            }

            Spacer(minLength: AppTheme.Spacing.small)

            if viewData.monthlyConsumptionValues.count >= 4 {
                MeterSparklineChart(
                    values: viewData.monthlyConsumptionValues,
                    lineColor: viewData.iconColor
                )
                .frame(width: 112, height: 58)
            }
        }
    }

    private var footer: some View {
        HStack(spacing: AppTheme.Spacing.medium) {
            metricBlock(
                title: AppStrings.dashboardConsumptionSinceLast,
                value: latestConsumptionText,
                icon: "minus.forwardslash.plus"
            )

            if let trendText {
                metricBlock(
                    title: AppStrings.dashboardTrendTitle,
                    value: trendText,
                    icon: trendIconName
                )
            }
        }
    }

    private var latestReadingText: String {
        guard let latestReadingValue = viewData.latestReadingValue else {
            return String(localized: AppStrings.dashboardNoReadingValue)
        }

        return AnalyticsFormatters.decimalString(for: latestReadingValue)
    }

    private var latestReadingDateText: String {
        guard let latestReadingDate = viewData.latestReadingDate else {
            return String(localized: AppStrings.dashboardNoReadingDate)
        }

        return String(
            format: String(localized: AppStrings.dashboardLatestReadingFormat),
            AnalyticsFormatters.dateString(for: latestReadingDate)
        )
    }

    private var latestConsumptionText: String {
        guard let value = viewData.latestConsumptionValue else {
            return String(localized: AppStrings.dashboardNoReadingValue)
        }

        return "\(AnalyticsFormatters.decimalString(for: value)) \(viewData.unit)"
    }

    private var trendText: String? {
        guard let trend = viewData.latestTrend else {
            return nil
        }

        let prefix = trend.isDecrease ? "↓" : "↑"
        let value = AnalyticsFormatters.decimalString(for: abs(trend.percentageDelta))
        return "\(prefix) \(value) %"
    }

    private var trendIconName: String {
        viewData.latestTrend?.isDecrease == true ? "arrow.down.right" : "arrow.up.right"
    }

    private func metricBlock(title: LocalizedStringResource, value: String, icon: String) -> some View {
        HStack(spacing: AppTheme.Spacing.small) {
            Image(systemName: icon)
                .foregroundStyle(viewData.iconColor)

            VStack(alignment: .leading, spacing: AppTheme.Spacing.extraSmall) {
                Text(title)
                    .font(AppTheme.Typography.caption)
                    .foregroundStyle(AppTheme.Colors.secondaryText)
                    .lineLimit(1)

                Text(value)
                    .font(AppTheme.Typography.callout.weight(.semibold))
                    .foregroundStyle(AppTheme.Colors.primaryText)
                    .lineLimit(1)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
}

#Preview {
    MeterDashboardCard(
        viewData: DashboardCardViewData(
            meterId: UUID(),
            meterName: "Strom",
            meterType: .electricityImport,
            iconName: "bolt.fill",
            iconColor: Color(red: 0.06, green: 0.36, blue: 0.32),
            latestReadingValue: 4_758,
            latestReadingDate: .now,
            latestConsumptionValue: 120,
            latestTrend: PeriodComparison(currentValue: 120, previousValue: 130, percentageDelta: -8),
            unit: "kWh",
            dashboardSortOrder: 0,
            isVisibleOnDashboard: true,
            monthlyConsumptionValues: (0..<12).map { index in
                AnalyticsDataPoint(
                    date: Calendar.current.date(byAdding: .month, value: index - 11, to: .now) ?? .now,
                    value: Decimal(80 + (index * 7))
                )
            }
        )
    )
    .padding()
    .background(AppTheme.Colors.background)
}
