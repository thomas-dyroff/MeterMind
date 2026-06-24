import Foundation
import SwiftUI

/// View model for meter-centered dashboard cards.
@MainActor
final class DashboardViewModel: ObservableObject {
    // MARK: - Properties

    @Published private(set) var cards: [DashboardCardViewData] = []
    @Published private(set) var editCards: [DashboardCardViewData] = []
    @Published private(set) var isEditingDashboard = false
    @Published var errorMessage: LocalizedStringResource?

    private let meterRepository: MeterRepositoryProtocol
    private let readingRepository: ReadingRepositoryProtocol
    private let consumptionService: ConsumptionService
    private let aggregationService: AggregationService
    private let readingValidationService: ReadingValidationService
    private let calendar: Calendar

    // MARK: - Initialization

    init(dependencies: AppDependencies) {
        self.meterRepository = dependencies.repositories.meterRepository
        self.readingRepository = dependencies.repositories.readingRepository
        self.consumptionService = dependencies.services.consumptionService
        self.aggregationService = dependencies.services.aggregationService
        self.readingValidationService = dependencies.services.readingValidationService
        self.calendar = .current
    }

    init(
        meterRepository: MeterRepositoryProtocol,
        readingRepository: ReadingRepositoryProtocol,
        consumptionService: ConsumptionService = ConsumptionService(),
        aggregationService: AggregationService = AggregationService(),
        readingValidationService: ReadingValidationService = ReadingValidationService(),
        calendar: Calendar = .current
    ) {
        self.meterRepository = meterRepository
        self.readingRepository = readingRepository
        self.consumptionService = consumptionService
        self.aggregationService = aggregationService
        self.readingValidationService = readingValidationService
        self.calendar = calendar
    }

    // MARK: - Actions

    /// Loads one dashboard card per meter.
    func loadDashboard(referenceDate: Date = .now) {
        do {
            let meters = try sortedMeters()
            let allCards = try meters.map { meter in
                try cardViewData(for: meter, referenceDate: referenceDate)
            }
            editCards = allCards
            cards = allCards.filter(\.isVisibleOnDashboard)
            errorMessage = nil
        } catch {
            errorMessage = AppStrings.errorGeneric
        }
    }

    /// Enters dashboard edit mode.
    func startEditingDashboard() {
        isEditingDashboard = true
    }

    /// Leaves dashboard edit mode.
    func finishEditingDashboard() {
        isEditingDashboard = false
        loadDashboard()
    }

    /// Toggles the dashboard visibility for a meter card.
    func setDashboardVisibility(for card: DashboardCardViewData, isVisible: Bool) {
        do {
            guard let meter = try meterRepository.fetchById(card.meterId) else {
                return
            }

            try meterRepository.updateDashboardPreferences(
                meter,
                dashboardSortOrder: meter.dashboardSortOrder,
                isVisibleOnDashboard: isVisible
            )
            loadDashboard()
            isEditingDashboard = true
        } catch {
            errorMessage = AppStrings.errorGeneric
        }
    }

    /// Reorders dashboard cards and persists their sort order.
    func moveDashboardCards(from source: IndexSet, to destination: Int) {
        var reorderedCards = editCards
        reorderedCards.move(fromOffsets: source, toOffset: destination)

        do {
            for (index, card) in reorderedCards.enumerated() {
                guard let meter = try meterRepository.fetchById(card.meterId) else {
                    continue
                }

                try meterRepository.updateDashboardPreferences(
                    meter,
                    dashboardSortOrder: index,
                    isVisibleOnDashboard: meter.isVisibleOnDashboard
                )
            }
            editCards = reorderedCards.enumerated().map { index, card in
                card.updatingDashboardPreferences(
                    dashboardSortOrder: index,
                    isVisibleOnDashboard: card.isVisibleOnDashboard
                )
            }
            cards = editCards.filter(\.isVisibleOnDashboard)
        } catch {
            errorMessage = AppStrings.errorGeneric
        }
    }

    /// Creates a detail view model for a selected meter card.
    func detailViewModel(for card: DashboardCardViewData) -> MeterDetailViewModel? {
        MeterDetailViewModel(
            meterId: card.meterId,
            meterRepository: meterRepository,
            readingRepository: readingRepository,
            consumptionService: consumptionService,
            aggregationService: aggregationService,
            calendar: calendar
        )
    }

    /// Creates a create-meter view model.
    func createViewModel(onSave: @escaping () -> Void) -> CreateMeterViewModel {
        CreateMeterViewModel(meterRepository: meterRepository, onSave: onSave)
    }

    /// Creates an edit-meter view model.
    func editViewModel(for card: DashboardCardViewData, onSave: @escaping () -> Void) -> EditMeterViewModel? {
        EditMeterViewModel(meterId: card.meterId, meterRepository: meterRepository, onSave: onSave)
    }

    /// Creates an edit-meter view model.
    func editViewModel(for meterId: UUID, onSave: @escaping () -> Void) -> EditMeterViewModel? {
        EditMeterViewModel(meterId: meterId, meterRepository: meterRepository, onSave: onSave)
    }

    /// Creates a reading history view model for a meter card.
    func readingListViewModel(for card: DashboardCardViewData, limit: Int? = nil) -> ReadingListViewModel? {
        guard let meter = meter(for: card) else {
            return nil
        }

        return ReadingListViewModel(
            meter: meter,
            readingRepository: readingRepository,
            validationService: readingValidationService,
            limit: limit
        )
    }

    /// Creates a reading history view model for a meter.
    func readingListViewModel(for meter: Meter, limit: Int? = nil) -> ReadingListViewModel {
        ReadingListViewModel(
            meter: meter,
            readingRepository: readingRepository,
            validationService: readingValidationService,
            limit: limit
        )
    }

    /// Returns the 12 calendar months ending with the month containing `referenceDate`.
    func monthlyConsumptionLast12Months(
        intervals: [ConsumptionInterval],
        referenceDate: Date
    ) -> [AnalyticsDataPoint] {
        guard let currentMonthStart = calendar.dateInterval(of: .month, for: referenceDate)?.start else {
            return []
        }

        let monthStarts = (0..<Self.monthCount).compactMap { offset in
            calendar.date(byAdding: .month, value: offset - Self.monthCount + 1, to: currentMonthStart)
        }
        let monthlyValues = Dictionary(
            uniqueKeysWithValues: aggregationService.monthlyAggregation(intervals: intervals).map { point in
                (point.date, point.value)
            }
        )

        // Missing months are represented as zero to keep the sparkline width stable across all cards.
        return monthStarts.map { monthStart in
            AnalyticsDataPoint(date: monthStart, value: monthlyValues[monthStart] ?? 0)
        }
    }

    private func cardViewData(for meter: Meter, referenceDate: Date) throws -> DashboardCardViewData {
        let readings = try readingRepository.fetchByMeter(meter)
        let latestReading = readings.sorted { $0.date > $1.date }.first
        let intervals = consumptionService.calculateConsumption(readings: readings, meter: meter)

        return DashboardCardViewData(
            meterId: meter.id,
            meterName: meter.name,
            meterType: meter.type,
            iconName: iconName(for: meter.type),
            iconColor: iconColor(for: meter.type),
            latestReadingValue: latestReading?.value,
            latestReadingDate: latestReading?.date,
            unit: MeterUnit.symbol(for: meter.unit),
            dashboardSortOrder: meter.dashboardSortOrder,
            isVisibleOnDashboard: meter.isVisibleOnDashboard,
            monthlyConsumptionValues: monthlyConsumptionLast12Months(
                intervals: intervals,
                referenceDate: referenceDate
            )
        )
    }

    /// Resolves a dashboard card back to its persisted meter.
    func meter(for card: DashboardCardViewData) -> Meter? {
        do {
            return try meterRepository.fetchById(card.meterId)
        } catch {
            errorMessage = AppStrings.errorGeneric
            return nil
        }
    }

    private func iconName(for type: MeterType) -> String {
        switch type {
        case .electricityImport, .pvFeedIn:
            "bolt.fill"
        case .gas:
            "flame.fill"
        case .water:
            "drop.fill"
        case .districtHeating:
            "thermometer.medium"
        case .heatingOil:
            "fuelpump.fill"
        case .custom:
            "gauge.with.dots.needle.bottom.50percent"
        }
    }

    private func iconColor(for type: MeterType) -> Color {
        switch type {
        case .electricityImport, .pvFeedIn:
            Color(red: 0.06, green: 0.36, blue: 0.32)
        case .gas:
            Color(red: 0.10, green: 0.48, blue: 0.58)
        case .water:
            Color(red: 0.17, green: 0.66, blue: 0.77)
        case .districtHeating:
            AppTheme.Colors.warning
        case .heatingOil:
            Color(red: 0.42, green: 0.47, blue: 0.34)
        case .custom:
            AppTheme.Colors.secondaryText
        }
    }

    private func sortedMeters() throws -> [Meter] {
        try meterRepository.fetchAll().sorted { firstMeter, secondMeter in
            if firstMeter.dashboardSortOrder == secondMeter.dashboardSortOrder {
                return firstMeter.createdAt < secondMeter.createdAt
            }

            return firstMeter.dashboardSortOrder < secondMeter.dashboardSortOrder
        }
    }

    private static let monthCount = 12
}

private extension DashboardCardViewData {
    func updatingDashboardPreferences(
        dashboardSortOrder: Int,
        isVisibleOnDashboard: Bool
    ) -> DashboardCardViewData {
        DashboardCardViewData(
            meterId: meterId,
            meterName: meterName,
            meterType: meterType,
            iconName: iconName,
            iconColor: iconColor,
            latestReadingValue: latestReadingValue,
            latestReadingDate: latestReadingDate,
            unit: unit,
            dashboardSortOrder: dashboardSortOrder,
            isVisibleOnDashboard: isVisibleOnDashboard,
            monthlyConsumptionValues: monthlyConsumptionValues
        )
    }
}
