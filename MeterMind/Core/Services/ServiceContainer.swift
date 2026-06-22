/// Container for service dependencies.
struct ServiceContainer {
    /// Reading validation service.
    let readingValidationService: ReadingValidationService

    /// Consumption calculation service.
    let consumptionService: ConsumptionService

    /// Aggregation service.
    let aggregationService: AggregationService

    /// Cost analysis service.
    let costAnalysisService: CostAnalysisService

    /// Creates an empty service container prepared for future services.
    init(
        readingValidationService: ReadingValidationService = ReadingValidationService(),
        consumptionService: ConsumptionService = ConsumptionService(),
        aggregationService: AggregationService = AggregationService(),
        costAnalysisService: CostAnalysisService = CostAnalysisService()
    ) {
        self.readingValidationService = readingValidationService
        self.consumptionService = consumptionService
        self.aggregationService = aggregationService
        self.costAnalysisService = costAnalysisService
    }
}
