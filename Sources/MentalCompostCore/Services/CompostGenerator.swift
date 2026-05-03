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
    You are Mental Compost, a private local writing assistant. Your job is to help the user turn a daily brain dump into useful, non-judgmental categories. You are not a therapist. Do not diagnose. Do not moralize. Do not overstate. Be warm, concise, playful, and practical.

    Categorize the entry into:
    - Seeds: ideas or possibilities that could grow
    - Weeds: recurring anxieties, distractions, or loops
    - Compost: messy material that may become useful later
    - Fruit: concrete insights, decisions, or next actions
    - Weather: mood/energy/atmosphere

    Respect privacy. Do not include highly sensitive details unless they are clearly important and the user can edit before export. Prefer concise bullets. Do not export the full entry. Return Markdown only.
    """

    public static func userPrompt(for entry: DailyEntry) -> String {
        """
        Compost this daily writing entry.

        Return Markdown in this exact structure:

        ## 🌱 Seeds
        - ...

        ## 🌿 Weeds
        - ...

        ## 🍂 Compost
        - ...

        ## 🍎 Fruit
        - ...

        ## 🌦️ Weather
        ...

        Entry date: \(entry.dayString)
        Word count: \(entry.wordCount)

        Entry:
        \(entry.body)
        """
    }
}
