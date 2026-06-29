import Foundation

/// View model for displaying meter details and consumption analytics.
@MainActor
final class MeterDetailViewModel: ObservableObject {
    // MARK: - Properties

    @Published private(set) var meter: Meter?
    @Published private(set) var latestReadingValue: Decimal?
    @Published private(set) var latestReadingDate: Date?
    @Published private(set) var recentReadings: [Reading] = []
    @Published private(set) var chartSections: [MeterConsumptionChartViewData] = []
    @Published private(set) var monthlyTrendPoints: [MeterConsumptionChartDataPoint] = []
    @Published private(set) var yearlyComparisonPoints: [MeterConsumptionChartDataPoint] = []
    @Published private(set) var yearlyJourneyItems: [MonthlyJourneyItem] = []
    @Published private(set) var summaryItems: [MeterSummaryItem] = []
    @Published private(set) var insightText: String?
    @Published private(set) var primaryConsumptionValue: Decimal?
    @Published private(set) var currentYearConsumptionValue: Decimal?
    @Published private(set) var totalConsumptionValue: Decimal?
    @Published private(set) var primaryComparison: PeriodComparison?
    @Published var errorMessage: LocalizedStringResource?

    let meterId: UUID

    private let meterRepository: MeterRepositoryProtocol?
    private let readingRepository: ReadingRepositoryProtocol?
    private let consumptionService: ConsumptionService
    private let aggregationService: AggregationService
    private let statisticsService: MeterStatisticsService
    private let calendar: Calendar

    private static let historyLimit = 30

    var name: String {
        meter?.name ?? ""
    }

    var typeName: String {
        guard let meter else {
            return ""
        }

        if meter.type == .custom, let customTypeName = meter.customTypeName {
            return customTypeName
        }
        return String(localized: meter.type.localizedTitle)
    }

    var unit: String {
        guard let meter else {
            return ""
        }

        return MeterUnit.symbol(for: meter.unit)
    }

    var serialNumber: String {
        meter?.serialNumber ?? String(localized: AppStrings.meterNotProvided)
    }

    var latestReadingText: String {
        guard let latestReadingValue else {
            return String(localized: AppStrings.dashboardNoReadingValue)
        }

        return AnalyticsFormatters.decimalString(for: latestReadingValue)
    }

    var latestReadingDateText: String {
        guard let latestReadingDate else {
            return String(localized: AppStrings.dashboardNoReadingDate)
        }

        return AnalyticsFormatters.dateString(for: latestReadingDate)
    }

    // MARK: - Initialization

    init(meter: Meter) {
        self.meter = meter
        self.meterId = meter.id
        self.meterRepository = nil
        self.readingRepository = nil
        self.consumptionService = ConsumptionService()
        self.aggregationService = AggregationService()
        self.statisticsService = MeterStatisticsService()
        self.calendar = .current
    }

    init(
        meterId: UUID,
        meterRepository: MeterRepositoryProtocol,
        readingRepository: ReadingRepositoryProtocol,
        consumptionService: ConsumptionService = ConsumptionService(),
        aggregationService: AggregationService = AggregationService(),
        statisticsService: MeterStatisticsService? = nil,
        calendar: Calendar = .current
    ) {
        self.meterId = meterId
        self.meterRepository = meterRepository
        self.readingRepository = readingRepository
        self.consumptionService = consumptionService
        self.aggregationService = aggregationService
        self.statisticsService = statisticsService ?? MeterStatisticsService(calendar: calendar)
        self.calendar = calendar
    }

    // MARK: - Actions

    /// Loads meter details, recent history, and chart data.
    func load(referenceDate: Date = .now) {
        guard let meterRepository, let readingRepository else {
            return
        }

        do {
            guard let loadedMeter = try meterRepository.fetchById(meterId) else {
                errorMessage = AppStrings.errorGeneric
                return
            }

            let readings = try readingRepository.fetchByMeter(loadedMeter)
            let sortedReadings = readings.sorted { $0.date > $1.date }
            let intervals = consumptionService.calculateConsumption(readings: readings, meter: loadedMeter)
            let monthlyConsumption = statisticsService.monthlyConsumption(intervals: intervals)
            let yearlyConsumption = statisticsService.yearlyConsumption(intervals: intervals)
            let unit = MeterUnit.symbol(for: loadedMeter.unit)

            meter = loadedMeter
            latestReadingValue = sortedReadings.first?.value
            latestReadingDate = sortedReadings.first?.date
            recentReadings = Array(sortedReadings.prefix(Self.historyLimit))
            chartSections = makeChartSections(
                intervals: intervals,
                unit: unit,
                referenceDate: referenceDate
            )
            monthlyTrendPoints = monthlyConsumption.map { point in
                MeterConsumptionChartDataPoint(
                    date: point.date,
                    value: point.value,
                    label: point.date.formatted(.dateTime.month(.abbreviated).year())
                )
            }
            yearlyComparisonPoints = yearlyConsumption.map { point in
                MeterConsumptionChartDataPoint(
                    date: point.date,
                    value: point.value,
                    label: point.date.formatted(.dateTime.year())
                )
            }
            yearlyJourneyItems = statisticsService.yearlyJourney(
                monthlyPoints: monthlyConsumption,
                referenceDate: referenceDate
            )
            primaryConsumptionValue = monthlyConsumption.last?.value
            currentYearConsumptionValue = yearlyConsumption.last?.value
            totalConsumptionValue = monthlyConsumption.map(\.value).reduce(0, +)
            primaryComparison = statisticsService.previousPeriodComparison(points: monthlyConsumption)
            summaryItems = makeSummaryItems(
                summary: statisticsService.summary(readings: readings, monthlyPoints: monthlyConsumption),
                unit: unit
            )
            insightText = insightDisplayText(
                statisticsService.generateInsight(
                    monthlyPoints: monthlyConsumption,
                    readings: readings,
                    referenceDate: referenceDate
                )
            )
            errorMessage = nil
        } catch {
            errorMessage = AppStrings.errorGeneric
        }
    }

    var primaryConsumptionText: String {
        focusConsumptionText(for: .month)
    }

    func focusConsumptionText(for period: MeterDetailFocusPeriod) -> String {
        let value: Decimal?
        switch period {
        case .month:
            value = primaryConsumptionValue
        case .year:
            value = currentYearConsumptionValue
        case .total:
            value = totalConsumptionValue
        }

        guard let value else {
            return String(localized: AppStrings.dashboardNoReadingValue)
        }

        return "\(AnalyticsFormatters.decimalString(for: value)) \(unit)"
    }

    func focusSubtitle(for period: MeterDetailFocusPeriod) -> LocalizedStringResource {
        switch period {
        case .month:
            AppStrings.meterDetailMainConsumptionMonth
        case .year:
            AppStrings.meterDetailMainConsumptionYear
        case .total:
            AppStrings.meterDetailMainConsumptionTotal
        }
    }

    var primaryComparisonText: String? {
        guard primaryConsumptionValue != nil else {
            return nil
        }

        guard let primaryComparison else {
            return nil
        }

        let direction = primaryComparison.isDecrease ? "↓" : "↑"
        let value = AnalyticsFormatters.decimalString(for: abs(primaryComparison.percentageDelta))
        return String(format: String(localized: AppStrings.meterDetailMainComparison), direction, value)
    }

    /// Creates an edit-meter view model.
    func editViewModel(meterRepository: MeterRepositoryProtocol, onSave: @escaping () -> Void) -> EditMeterViewModel? {
        guard let meter else {
            return nil
        }

        return EditMeterViewModel(meter: meter, meterRepository: meterRepository, onSave: onSave)
    }

    private func makeChartSections(
        intervals: [ConsumptionInterval],
        unit: String,
        referenceDate: Date
    ) -> [MeterConsumptionChartViewData] {
        [
            MeterConsumptionChartViewData(
                id: .week,
                title: AppStrings.meterDetailChartWeek,
                unit: unit,
                periodType: .week,
                dataPoints: weekPoints(intervals: intervals, referenceDate: referenceDate)
            ),
            MeterConsumptionChartViewData(
                id: .month,
                title: AppStrings.meterDetailChartMonth,
                unit: unit,
                periodType: .month,
                dataPoints: monthPoints(intervals: intervals, referenceDate: referenceDate)
            ),
            MeterConsumptionChartViewData(
                id: .quarter,
                title: AppStrings.meterDetailChartQuarter,
                unit: unit,
                periodType: .quarter,
                dataPoints: quarterPoints(intervals: intervals, referenceDate: referenceDate)
            ),
            MeterConsumptionChartViewData(
                id: .year,
                title: AppStrings.meterDetailChartYear,
                unit: unit,
                periodType: .year,
                dataPoints: yearPoints(intervals: intervals, referenceDate: referenceDate)
            )
        ]
    }

    private func weekPoints(intervals: [ConsumptionInterval], referenceDate: Date) -> [MeterConsumptionChartDataPoint] {
        var mondayCalendar = calendar
        mondayCalendar.firstWeekday = 2
        guard let weekInterval = mondayCalendar.dateInterval(of: .weekOfYear, for: referenceDate) else {
            return []
        }
        guard hasIntervals(in: weekInterval, intervals: intervals) else {
            return []
        }

        let dailyValues = valuesByDay(in: weekInterval, intervals: intervals)
        return (0..<7).compactMap { dayOffset in
            guard let date = mondayCalendar.date(byAdding: .day, value: dayOffset, to: weekInterval.start) else {
                return nil
            }

            return MeterConsumptionChartDataPoint(
                date: date,
                value: dailyValues[dayStart(for: date)] ?? 0,
                label: date.formatted(.dateTime.weekday(.abbreviated))
            )
        }
    }

    private func monthPoints(intervals: [ConsumptionInterval], referenceDate: Date) -> [MeterConsumptionChartDataPoint] {
        guard let monthInterval = calendar.dateInterval(of: .month, for: referenceDate) else {
            return []
        }
        guard hasIntervals(in: monthInterval, intervals: intervals) else {
            return []
        }

        let dailyValues = valuesByDay(in: monthInterval, intervals: intervals)
        let dayCount = calendar.dateComponents([.day], from: monthInterval.start, to: monthInterval.end).day ?? 0

        // The month chart uses daily buckets so short-term capture patterns remain visible.
        return (0..<dayCount).compactMap { dayOffset in
            guard let date = calendar.date(byAdding: .day, value: dayOffset, to: monthInterval.start) else {
                return nil
            }

            return MeterConsumptionChartDataPoint(
                date: date,
                value: dailyValues[dayStart(for: date)] ?? 0,
                label: date.formatted(.dateTime.day())
            )
        }
    }

    private func quarterPoints(intervals: [ConsumptionInterval], referenceDate: Date) -> [MeterConsumptionChartDataPoint] {
        guard let quarterInterval = quarterInterval(for: referenceDate) else {
            return []
        }
        guard hasIntervals(in: quarterInterval, intervals: intervals) else {
            return []
        }

        return monthlyPoints(in: quarterInterval, intervals: intervals)
    }

    private func yearPoints(intervals: [ConsumptionInterval], referenceDate: Date) -> [MeterConsumptionChartDataPoint] {
        guard let yearInterval = calendar.dateInterval(of: .year, for: referenceDate) else {
            return []
        }
        guard hasIntervals(in: yearInterval, intervals: intervals) else {
            return []
        }

        return monthlyPoints(in: yearInterval, intervals: intervals)
    }

    private func valuesByDay(
        in dateInterval: DateInterval,
        intervals: [ConsumptionInterval]
    ) -> [Date: Decimal] {
        Dictionary(
            grouping: aggregationService.dailyAggregation(intervals: intervals)
                .filter { dateInterval.contains($0.date) },
            by: { $0.date }
        ).mapValues { points in
            points.map(\.value).reduce(0, +)
        }
    }

    private func hasIntervals(in dateInterval: DateInterval, intervals: [ConsumptionInterval]) -> Bool {
        intervals.contains { dateInterval.contains($0.endDate) }
    }

    private func monthlyPoints(
        in dateInterval: DateInterval,
        intervals: [ConsumptionInterval]
    ) -> [MeterConsumptionChartDataPoint] {
        let monthlyValues = Dictionary(
            uniqueKeysWithValues: aggregationService.monthlyAggregation(intervals: intervals)
                .filter { dateInterval.contains($0.date) }
                .map { ($0.date, $0.value) }
        )
        let monthCount = calendar.dateComponents([.month], from: dateInterval.start, to: dateInterval.end).month ?? 0

        return (0..<monthCount).compactMap { monthOffset in
            guard let date = calendar.date(byAdding: .month, value: monthOffset, to: dateInterval.start) else {
                return nil
            }

            return MeterConsumptionChartDataPoint(
                date: date,
                value: monthlyValues[monthStart(for: date)] ?? 0,
                label: date.formatted(.dateTime.month(.abbreviated))
            )
        }
    }

    private func quarterInterval(for date: Date) -> DateInterval? {
        let month = calendar.component(.month, from: date)
        let quarterStartMonth = ((month - 1) / 3) * 3 + 1
        var components = calendar.dateComponents([.year], from: date)
        components.month = quarterStartMonth
        components.day = 1

        guard let start = calendar.date(from: components),
              let end = calendar.date(byAdding: .month, value: 3, to: start) else {
            return nil
        }

        return DateInterval(start: start, end: end)
    }

    private func dayStart(for date: Date) -> Date {
        calendar.startOfDay(for: date)
    }

    private func monthStart(for date: Date) -> Date {
        calendar.dateInterval(of: .month, for: date)?.start ?? date
    }

    private func makeSummaryItems(summary: MeterStatisticsSummary, unit: String) -> [MeterSummaryItem] {
        [
            MeterSummaryItem(
                id: "average",
                title: AppStrings.meterDetailSummaryAverage,
                value: summary.average.map { "\(AnalyticsFormatters.decimalString(for: $0)) \(unit)" }
                    ?? String(localized: AppStrings.dashboardNoReadingValue)
            ),
            MeterSummaryItem(
                id: "highest",
                title: AppStrings.meterDetailSummaryHighest,
                value: summary.highestMonth ?? String(localized: AppStrings.dashboardNoReadingValue)
            ),
            MeterSummaryItem(
                id: "lowest",
                title: AppStrings.meterDetailSummaryLowest,
                value: summary.lowestMonth ?? String(localized: AppStrings.dashboardNoReadingValue)
            ),
            MeterSummaryItem(
                id: "readings",
                title: AppStrings.meterDetailSummaryReadings,
                value: "\(summary.readingCount)"
            )
        ]
    }

    private func insightDisplayText(_ insight: MeterInsight) -> String? {
        switch insight {
        case .lowerThanPrevious(let percentage):
            return String(
                format: String(localized: AppStrings.meterDetailInsightLowerConsumption),
                AnalyticsFormatters.decimalString(for: percentage)
            )
        case .lowestConsumption:
            return String(localized: AppStrings.meterDetailInsightLowestConsumption)
        case .needsMoreReadings:
            return String(localized: AppStrings.meterDetailInsightNeedsMoreReadings)
        case .staleReading(let days):
            return String(format: String(localized: AppStrings.meterDetailInsightStaleReading), days)
        case .none:
            return nil
        }
    }
}
