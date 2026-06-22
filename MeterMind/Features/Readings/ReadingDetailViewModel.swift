import Foundation

/// View model for displaying reading details.
@MainActor
final class ReadingDetailViewModel: ObservableObject {
    // MARK: - Properties

    private let reading: Reading
    private let meterUnit: String

    var date: String {
        ReadingFormatters.dateString(for: reading.date)
    }

    var value: String {
        "\(ReadingFormatters.valueString(for: reading.value)) \(meterUnit)"
    }

    var note: String {
        reading.note ?? String(localized: AppStrings.meterNotProvided)
    }

    // MARK: - Initialization

    init(reading: Reading, meterUnit: String) {
        self.reading = reading
        self.meterUnit = meterUnit
    }
}
