import Foundation

/// View model for analytics period selection and comparisons.
@MainActor
final class AnalyticsViewModel: ObservableObject {
    // MARK: - Properties

    @Published var selectedPeriod: AnalyticsPeriod = .month {
        didSet {
            updateSelectedAggregation()
        }
    }
    @Published private(set) var consumptionData: [AnalyticsDataPoint] = []
    @Published private(set) var costData: [CostDataPoint] = []
    @Published private(set) var monthComparisonData: [AnalyticsDataPoint] = []
    @Published private(set) var yearComparisonData: [AnalyticsDataPoint] = []
    @Published private(set) var comparisonText = "-"
    @Published private(set) var hasData = false
    @Published var errorMessage: LocalizedStringResource?

    private let meterRepository: MeterRepositoryProtocol
    private let readingRepository: ReadingRepositoryProtocol
    private let consumptionService: ConsumptionService
    private let aggregationService: AggregationService
    private let costAnalysisService: CostAnalysisService
    private var intervals: [ConsumptionInterval] = []

    // MARK: - Initialization

    init(dependencies: AppDependencies) {
        self.meterRepository = dependencies.repositories.meterRepository
        self.readingRepository = dependencies.repositories.readingRepository
        self.consumptionService = dependencies.services.consumptionService
        self.aggregationService = dependencies.services.aggregationService
        self.costAnalysisService = dependencies.services.costAnalysisService
    }

    // MARK: - Actions

    /// Loads analytics data.
    func loadAnalytics() {
        do {
            let meters = try meterRepository.fetchAll()
            intervals = try meters.flatMap { meter in
                let readings = try readingRepository.fetchByMeter(meter)
                return consumptionService.calculateConsumption(readings: readings, meter: meter)
            }
            costData = costAnalysisService.monthlyCosts(
                costs: meters.flatMap { meter in
                    let meterIntervals = intervals.filter { $0.meterId == meter.id }
                    return costAnalysisService.calculateCosts(intervals: meterIntervals, tariffs: meter.tariffs)
                }
            )
            monthComparisonData = comparisonData(component: .month)
            yearComparisonData = comparisonData(component: .year)
            updateSelectedAggregation()
            hasData = !intervals.isEmpty
            errorMessage = nil
        } catch {
            errorMessage = AppStrings.errorGeneric
        }
    }

    private func updateSelectedAggregation() {
        switch selectedPeriod {
        case .week:
            consumptionData = aggregationService.weeklyAggregation(intervals: intervals)
            comparisonText = "-"
        case .month:
            consumptionData = aggregationService.monthlyAggregation(intervals: intervals)
            comparisonText = percentageComparison(component: .month)
        case .year:
            consumptionData = aggregationService.yearlyAggregation(intervals: intervals)
            comparisonText = percentageComparison(component: .year)
        }
    }

    private func comparisonData(component: Calendar.Component) -> [AnalyticsDataPoint] {
        let calendar = Calendar.current
        let currentDate = Date.now
        guard let currentInterval = calendar.dateInterval(of: component, for: currentDate),
              let previousDate = calendar.date(byAdding: .year, value: -1, to: currentDate),
              let previousInterval = calendar.dateInterval(of: component, for: previousDate) else {
            return []
        }

        return [
            AnalyticsDataPoint(
                date: previousInterval.start,
                value: consumptionService.calculatePeriodConsumption(
                    intervals: intervals,
                    dateInterval: previousInterval
                )
            ),
            AnalyticsDataPoint(
                date: currentInterval.start,
                value: consumptionService.calculatePeriodConsumption(
                    intervals: intervals,
                    dateInterval: currentInterval
                )
            )
        ]
    }

    private func percentageComparison(component: Calendar.Component) -> String {
        let data = comparisonData(component: component)
        guard data.count == 2, data[0].value != 0 else {
            return "-"
        }

        let percentage = ((data[1].value - data[0].value) / data[0].value) * 100
        return AnalyticsFormatters.percentString(for: percentage)
    }
}
