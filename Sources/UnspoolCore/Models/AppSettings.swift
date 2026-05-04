import Foundation

public struct AppSettings: Equatable, Sendable {
    public var entriesDirectory: URL
    public var compostDirectory: URL
    public var contextExportDirectory: URL?
    public var localAIEnabled: Bool
    public var localAIEndpointURL: URL
    public var localAIModelName: String

    public init(
        entriesDirectory: URL = EntryStore.preferredEntriesDirectory(),
        compostDirectory: URL = CompostReviewStore.defaultCompostDirectory(),
        contextExportDirectory: URL? = nil,
        localAIEnabled: Bool = false,
        localAIEndpointURL: URL = URL(string: LocalModelDefaults.endpointURLString)!,
        localAIModelName: String = LocalModelDefaults.modelName
    ) {
        self.entriesDirectory = entriesDirectory
        self.compostDirectory = compostDirectory
        self.contextExportDirectory = contextExportDirectory
        self.localAIEnabled = localAIEnabled
        self.localAIEndpointURL = localAIEndpointURL
        self.localAIModelName = localAIModelName
    }
}
