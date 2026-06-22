import Foundation

/// Calculates consumption from meter readings.
struct ConsumptionService {
    private let calendar: Calendar

    /// Creates a consumption service.
    init(calendar: Calendar = .current) {
        self.calendar = calendar
    }

    /// Calculates consumption intervals from consecutive readings.
    func calculateConsumption(readings: [Reading], meter: Meter) -> [ConsumptionInterval] {
        let sortedReadings = readings.sorted { $0.date < $1.date }
        guard sortedReadings.count > 1 else {
            return []
        }

        return zip(sortedReadings, sortedReadings.dropFirst()).map { previousReading, currentReading in
            ConsumptionInterval(
                meterId: meter.id,
                meterName: meter.name,
                unit: meter.unit,
                startDate: previousReading.date,
                endDate: currentReading.date,
                value: currentReading.value - previousReading.value
            )
        }
    }

    /// Calculates total consumption for intervals ending inside a date interval.
    func calculatePeriodConsumption(
        intervals: [ConsumptionInterval],
        dateInterval: DateInterval
    ) -> Decimal {
        intervals
            .filter { dateInterval.contains($0.endDate) }
            .map(\.value)
            .reduce(0, +)
    }

    /// Calculates total consumption for the current month.
    func calculateCurrentMonthConsumption(
        intervals: [ConsumptionInterval],
        referenceDate: Date = .now
    ) -> Decimal {
        guard let dateInterval = calendar.dateInterval(of: .month, for: referenceDate) else {
            return 0
        }

        return calculatePeriodConsumption(intervals: intervals, dateInterval: dateInterval)
    }

    /// Calculates total consumption for the current year.
    func calculateCurrentYearConsumption(
        intervals: [ConsumptionInterval],
        referenceDate: Date = .now
    ) -> Decimal {
        guard let dateInterval = calendar.dateInterval(of: .year, for: referenceDate) else {
            return 0
        }

        return calculatePeriodConsumption(intervals: intervals, dateInterval: dateInterval)
    }
}
