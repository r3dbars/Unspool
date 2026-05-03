import Foundation

public struct MockLocalAIClient: LocalAIClient {
    public var result: Result<String, Error>

    public init(result: Result<String, Error>) {
        self.result = result
    }

    public func chatCompletion(model: String, messages: [LocalAIMessage], temperature: Double) async throws -> String {
        try result.get()
    }
}
