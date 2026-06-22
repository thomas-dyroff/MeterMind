import Foundation

/// View model for dashboard KPIs and chart data.
@MainActor
final class DashboardViewModel: ObservableObject {
    // MARK: - Properties

    @Published private(set) var meterCountText = "0"
    @Published private(set) var latestReadingText = "-"
    @Published private(set) var currentMonthConsumptionText = "0"
    @Published private(set) var currentYearConsumptionText = "0"
    @Published private(set) var currentMonthCostText: String?
    @Published private(set) var consumptionChartData: [AnalyticsDataPoint] = []
    @Published private(set) var costChartData: [CostDataPoint] = []
    @Published private(set) var hasData = false
    @Published var errorMessage: LocalizedStringResource?

    private let meterRepository: MeterRepositoryProtocol
    private let readingRepository: ReadingRepositoryProtocol
    private let consumptionService: ConsumptionService
    private let aggregationService: AggregationService
    private let costAnalysisService: CostAnalysisService

    // MARK: - Initialization

    init(dependencies: AppDependencies) {
        self.meterRepository = dependencies.repositories.meterRepository
        self.readingRepository = dependencies.repositories.readingRepository
        self.consumptionService = dependencies.services.consumptionService
        self.aggregationService = dependencies.services.aggregationService
        self.costAnalysisService = dependencies.services.costAnalysisService
    }

    // MARK: - Actions

    /// Loads dashboard KPIs and charts.
    func loadDashboard() {
        do {
            let meters = try meterRepository.fetchAll()
            let readings = try readingRepository.fetchAll()
            let intervals = try allConsumptionIntervals(for: meters)
            let costs = allCosts(for: meters, intervals: intervals)

            meterCountText = "\(meters.count)"
            latestReadingText = readings.first.map { AnalyticsFormatters.dateString(for: $0.date) } ?? "-"
            currentMonthConsumptionText = AnalyticsFormatters.decimalString(
                for: consumptionService.calculateCurrentMonthConsumption(intervals: intervals)
            )
            currentYearConsumptionText = AnalyticsFormatters.decimalString(
                for: consumptionService.calculateCurrentYearConsumption(intervals: intervals)
            )
            currentMonthCostText = currentMonthCost(from: costs)
            consumptionChartData = aggregationService.monthlyAggregation(intervals: intervals)
            costChartData = costAnalysisService.monthlyCosts(costs: costs)
            hasData = !readings.isEmpty
            errorMessage = nil
        } catch {
            errorMessage = AppStrings.errorGeneric
        }
    }

    private func allConsumptionIntervals(for meters: [Meter]) throws -> [ConsumptionInterval] {
        try meters.flatMap { meter in
            let readings = try readingRepository.fetchByMeter(meter)
            return consumptionService.calculateConsumption(readings: readings, meter: meter)
        }
    }

    private func allCosts(for meters: [Meter], intervals: [ConsumptionInterval]) -> [CostDataPoint] {
        meters.flatMap { meter in
            let meterIntervals = intervals.filter { $0.meterId == meter.id }
            return costAnalysisService.calculateCosts(intervals: meterIntervals, tariffs: meter.tariffs)
        }
    }

    private func currentMonthCost(from costs: [CostDataPoint]) -> String? {
        guard !costs.isEmpty,
              let dateInterval = Calendar.current.dateInterval(of: .month, for: .now) else {
            return nil
        }

        let monthlyCosts = costs.filter { dateInterval.contains($0.date) }
        guard !monthlyCosts.isEmpty else {
            return nil
        }

        let value = monthlyCosts.map(\.value).reduce(0, +)
        let currency = monthlyCosts.first?.currency ?? ""
        return "\(AnalyticsFormatters.decimalString(for: value)) \(currency)"
    }
}
