import AppIntents

struct GatedAppEntity: AppEntity {
    static let typeDisplayRepresentation: TypeDisplayRepresentation = "App"
    static let defaultQuery = GatedAppQuery()

    var id: UUID
    var name: String

    var displayRepresentation: DisplayRepresentation {
        DisplayRepresentation(title: "\(name)")
    }

    init(_ app: GatedApp) {
        id = app.id
        name = app.name
    }
}

struct GatedAppQuery: EntityQuery {
    func entities(for identifiers: [UUID]) async throws -> [GatedAppEntity] {
        GateStore.apps.filter { identifiers.contains($0.id) }.map(GatedAppEntity.init)
    }

    func suggestedEntities() async throws -> [GatedAppEntity] {
        GateStore.apps.map(GatedAppEntity.init)
    }
}

/// Run from a Shortcuts "When <app> is opened" automation.
/// Brings One Second to the front for a breathing session, unless the user
/// just finished one for this app (which is how we avoid an endless loop).
struct BreatheBeforeOpeningIntent: AppIntent {
    static let title: LocalizedStringResource = "Breathe Before Opening"
    static let description = IntentDescription(
        "Take a few slow breaths before an app opens. Use this in a \"When app is opened\" automation."
    )
    static let supportedModes: IntentModes = [.background, .foreground(.dynamic)]

    @Parameter(title: "App")
    var app: GatedAppEntity

    static var parameterSummary: some ParameterSummary {
        Summary("Breathe before opening \(\.$app)")
    }

    @MainActor
    func perform() async throws -> some IntentResult {
        guard !GateStore.hasPass(for: app.id), let gated = GateStore.app(withID: app.id) else {
            return .result()
        }
        try await continueInForeground(alwaysConfirm: false)
        Router.shared.pending = gated
        return .result()
    }
}
