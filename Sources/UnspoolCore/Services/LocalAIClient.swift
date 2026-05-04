import Foundation

public struct LocalAIMessage: Codable, Equatable, Sendable {
    public var role: String
    public var content: String

    public init(role: String, content: String) {
        self.role = role
        self.content = content
    }
}

public protocol LocalAIClient: Sendable {
    func chatCompletion(model: String, messages: [LocalAIMessage], temperature: Double) async throws -> String
}

public enum LocalAIClientError: Error, Equatable {
    case unavailable
    case invalidResponse
    case nonLocalEndpoint
}
