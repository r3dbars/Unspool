import Foundation

public struct AppSettings: Equatable, Sendable {
    public var entriesDirectory: URL
    public var compostDirectory: URL
    public var contextExportDirectory: URL?
    public var localAIEnabled: Bool
    public var localAIEndpointURL: URL
    public var localAIModelName: String

    public init(
        entriesDirectory: URL = EntryStore.defaultEntriesDirectory(),
        compostDirectory: URL = CompostReviewStore.defaultCompostDirectory(),
        contextExportDirectory: URL? = nil,
        localAIEnabled: Bool = false,
        localAIEndpointURL: URL = URL(string: "http://localhost:8080/v1/chat/completions")!,
        localAIModelName: String = "local-model"
    ) {
        self.entriesDirectory = entriesDirectory
        self.compostDirectory = compostDirectory
        self.contextExportDirectory = contextExportDirectory
        self.localAIEnabled = localAIEnabled
        self.localAIEndpointURL = localAIEndpointURL
        self.localAIModelName = localAIModelName
    }
}
