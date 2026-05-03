import Foundation

public struct OpenAICompatibleLocalAIClient: LocalAIClient {
    public var endpointURL: URL
    public var timeout: TimeInterval
    public var allowNonLocalEndpoint: Bool
    private let session: URLSession

    public init(
        endpointURL: URL = URL(string: "http://localhost:8080/v1/chat/completions")!,
        timeout: TimeInterval = 45,
        allowNonLocalEndpoint: Bool = false,
        session: URLSession = .shared
    ) {
        self.endpointURL = endpointURL
        self.timeout = timeout
        self.allowNonLocalEndpoint = allowNonLocalEndpoint
        self.session = session
    }

    public func chatCompletion(model: String, messages: [LocalAIMessage], temperature: Double) async throws -> String {
        guard allowNonLocalEndpoint || endpointURL.isLocalhost else {
            throw LocalAIClientError.nonLocalEndpoint
        }

        var request = URLRequest(url: endpointURL)
        request.httpMethod = "POST"
        request.timeoutInterval = timeout
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = try JSONEncoder().encode(
            ChatCompletionRequest(model: model, messages: messages, temperature: temperature)
        )

        do {
            let (data, response) = try await session.data(for: request)
            guard let httpResponse = response as? HTTPURLResponse,
                  (200..<300).contains(httpResponse.statusCode) else {
                throw LocalAIClientError.unavailable
            }
            let decoded = try JSONDecoder().decode(ChatCompletionResponse.self, from: data)
            guard let content = decoded.choices.first?.message.content, !content.isEmpty else {
                throw LocalAIClientError.invalidResponse
            }
            return content
        } catch let error as LocalAIClientError {
            throw error
        } catch {
            throw LocalAIClientError.unavailable
        }
    }

    private struct ChatCompletionRequest: Encodable {
        var model: String
        var messages: [LocalAIMessage]
        var temperature: Double
    }

    private struct ChatCompletionResponse: Decodable {
        var choices: [Choice]

        struct Choice: Decodable {
            var message: Message
        }

        struct Message: Decodable {
            var content: String
        }
    }
}

private extension URL {
    var isLocalhost: Bool {
        guard let host = host()?.lowercased() else { return false }
        return host == "localhost" || host == "127.0.0.1" || host == "::1"
    }
}
