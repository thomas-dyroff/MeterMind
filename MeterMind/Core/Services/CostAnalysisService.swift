import Foundation

/// Calculates cost data from consumption intervals and tariffs.
struct CostAnalysisService {
    private let aggregationService: AggregationService

    /// Creates a cost analysis service.
    init(aggregationService: AggregationService = AggregationService()) {
        self.aggregationService = aggregationService
    }

    /// Calculates costs for consumption intervals using applicable tariffs.
    func calculateCosts(
        intervals: [ConsumptionInterval],
        tariffs: [Tariff]
    ) -> [CostDataPoint] {
        guard !tariffs.isEmpty else {
            return []
        }

        return intervals.compactMap { interval in
            guard let tariff = applicableTariff(for: interval.endDate, tariffs: tariffs) else {
                return nil
            }

            return CostDataPoint(
                date: interval.endDate,
                value: interval.value * tariff.pricePerUnit,
                currency: tariff.currency
            )
        }
    }

    /// Aggregates costs by month.
    func monthlyCosts(costs: [CostDataPoint]) -> [CostDataPoint] {
        aggregate(costs: costs, component: .month)
    }

    /// Aggregates costs by year.
    func yearlyCosts(costs: [CostDataPoint]) -> [CostDataPoint] {
        aggregate(costs: costs, component: .year)
    }

    private func applicableTariff(for date: Date, tariffs: [Tariff]) -> Tariff? {
        tariffs
            .filter { $0.validFrom <= date }
            .sorted { $0.validFrom > $1.validFrom }
            .first
    }

    private func aggregate(
        costs: [CostDataPoint],
        component: Calendar.Component
    ) -> [CostDataPoint] {
        let calendar = Calendar.current
        let groupedValues = Dictionary(grouping: costs) { cost in
            calendar.dateInterval(of: component, for: cost.date)?.start ?? cost.date
        }

        return groupedValues
            .map { date, costs in
                CostDataPoint(
                    date: date,
                    value: costs.map(\.value).reduce(0, +),
                    currency: costs.first?.currency ?? ""
                )
            }
            .sorted { $0.date < $1.date }
    }
}
