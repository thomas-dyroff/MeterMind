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
            uniqueKeysWithValues: aggregationService.monthlyAggregation(intervals: intervals)
                .filter { $0.value > 0 }
                .map { point in
                    (point.date, point.value)
                }
        )
        guard !monthlyValues.isEmpty else {
            return []
        }

        let knownValuesByIndex = Dictionary(
            uniqueKeysWithValues: monthStarts.enumerated().compactMap { index, monthStart in
                monthlyValues[monthStart].map { value in
                    (index, value)
                }
            }
        )

        // Missing dashboard months are estimated only for the compact sparkline. The actual consumption data
        // remains unchanged; this prevents visual zero drops while using nearby months in both directions.
        return monthStarts.enumerated().map { index, monthStart in
            AnalyticsDataPoint(
                date: monthStart,
                value: knownValuesByIndex[index] ?? estimatedMonthlyConsumption(
                    at: index,
                    knownValuesByIndex: knownValuesByIndex
                )
            )
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

private extension DashboardViewModel {
    func estimatedMonthlyConsumption(
        at index: Int,
        knownValuesByIndex: [Int: Decimal]
    ) -> Decimal {
        let knownValues = knownValuesByIndex.mapValues { decimalDouble($0) }
        let weightedAverage = weightedMovingAverage(at: index, knownValuesByIndex: knownValues)
        let previousKnown = knownValues
            .filter { $0.key < index }
            .max { $0.key < $1.key }
        let nextKnown = knownValues
            .filter { $0.key > index }
            .min { $0.key < $1.key }
        let estimate: Double

        if let previousKnown, let nextKnown {
            estimate = interpolatedEstimate(
                at: index,
                previousKnown: previousKnown,
                nextKnown: nextKnown,
                weightedAverage: weightedAverage
            )
        } else if let previousKnown {
            estimate = extrapolatedEstimate(
                at: index,
                nearestKnown: previousKnown,
                weightedAverage: weightedAverage,
                direction: 1
            )
        } else if let nextKnown {
            estimate = extrapolatedEstimate(
                at: index,
                nearestKnown: nextKnown,
                weightedAverage: weightedAverage,
                direction: -1
            )
        } else {
            estimate = weightedAverage
        }

        let minimumValue = max((knownValues.values.min() ?? 1) * 0.2, 0.01)
        return Decimal(max(estimate, minimumValue))
    }

    func interpolatedEstimate(
        at index: Int,
        previousKnown: (key: Int, value: Double),
        nextKnown: (key: Int, value: Double),
        weightedAverage: Double
    ) -> Double {
        let gapLength = Double(nextKnown.key - previousKnown.key)
        guard gapLength > 0 else {
            return weightedAverage
        }

        let progress = Double(index - previousKnown.key) / gapLength
        let linearValue = previousKnown.value + ((nextKnown.value - previousKnown.value) * progress)
        let curveAmplitude = max(abs(nextKnown.value - previousKnown.value) * 0.12, weightedAverage * 0.06)
        let curveDirection = nextKnown.value >= previousKnown.value ? 1.0 : -1.0
        let curvedOffset = sin(.pi * progress) * curveAmplitude * curveDirection

        return (linearValue * 0.72) + (weightedAverage * 0.28) + curvedOffset
    }

    func extrapolatedEstimate(
        at index: Int,
        nearestKnown: (key: Int, value: Double),
        weightedAverage: Double,
        direction: Double
    ) -> Double {
        let distance = Double(abs(index - nearestKnown.key))
        let blend = min(distance / 6.0, 0.75)
        let seasonalOffset = sin((Double(index) + 1.0) * 0.73) * weightedAverage * 0.04 * direction

        return (nearestKnown.value * (1.0 - blend)) + (weightedAverage * blend) + seasonalOffset
    }

    func weightedMovingAverage(at index: Int, knownValuesByIndex: [Int: Double]) -> Double {
        let weightedValues = knownValuesByIndex.map { knownIndex, value in
            let distance = max(abs(Double(index - knownIndex)), 1.0)
            let weight = 1.0 / pow(distance, 1.4)
            return (value: value, weight: weight)
        }
        let totalWeight = weightedValues.map(\.weight).reduce(0, +)
        guard totalWeight > 0 else {
            return 0
        }

        return weightedValues.map { $0.value * $0.weight }.reduce(0, +) / totalWeight
    }

    func decimalDouble(_ value: Decimal) -> Double {
        NSDecimalNumber(decimal: value).doubleValue
    }
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
