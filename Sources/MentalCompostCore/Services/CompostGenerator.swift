import Foundation

public struct CompostGenerator {
    public var localAIClient: LocalAIClient

    public init(localAIClient: LocalAIClient) {
        self.localAIClient = localAIClient
    }

    public func generateWithLocalAI(for entry: DailyEntry, model: String) async throws -> CompostReview {
        let content = try await localAIClient.chatCompletion(
            model: model,
            messages: [
                LocalAIMessage(role: "system", content: Self.systemPrompt),
                LocalAIMessage(role: "user", content: Self.userPrompt(for: entry))
            ],
            temperature: 0.4
        )

        return CompostReview(
            entryDate: entry.date,
            sourceWordCount: entry.wordCount,
            generationMode: .localAI,
            userEditedMarkdown: content.trimmingCharacters(in: .whitespacesAndNewlines)
        )
    }

    public static func generateHeuristic(for entry: DailyEntry) -> CompostReview {
        HeuristicCompostGenerator.generate(for: entry)
    }

    public static let systemPrompt = """
    Do not include hidden reasoning, thinking traces, analysis, or scratch work. Return only the requested Markdown.

    You are Mental Compost, a private local writing assistant. Your job is to help the user turn a daily brain dump into a practical Red Bars Review. You are not a therapist. Do not diagnose. Do not moralize. Do not overstate. Be warm, concise, direct, and useful.

    Use this loop:
    - Find the bottleneck
    - Chase the next red bar
    - Make the smallest reversible move
    - Look for the green bar signal

    Respect privacy. Do not include highly sensitive details unless they are clearly important and the user can edit before export. Prefer concise bullets. Do not export the full entry. Return Markdown only.
    """

    public static func userPrompt(for entry: DailyEntry) -> String {
        """
        /no_think

        Compost this daily writing entry into a Red Bars Review.

        Return Markdown in this exact structure:

        ## Red Bars Review

        ### Bottleneck
        - ...

        ### Open Loops
        - ...

        ### Decisions
        - ...

        ### Smallest Reversible Move
        - ...

        ### Next Red Bar
        - ...

        ### Green Bar Signal
        - ...

        Entry date: \(entry.dayString)
        Word count: \(entry.wordCount)

        Entry:
        \(entry.body)
        """
    }
}
