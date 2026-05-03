import Foundation

public enum AIContextDraftGenerator {
    public static let keywords = [
        "idea", "remember", "todo", "goal", "project", "decision", "insight",
        "worry", "launch", "transcripted", "claudebrain", "ai", "customer",
        "bug", "feature"
    ]

    public static func draft(for entry: DailyEntry) -> String {
        let candidates = usefulParagraphs(from: entry.body)
        let header = """
        Daily Pages context draft
        Date: \(entry.dayString)
        Word count: \(entry.wordCount)

        """

        if candidates.isEmpty {
            return header + """
            No obvious AI-context paragraphs were found.

            Add only the ideas, decisions, todos, or project context you want your AI tools to remember.
            """
        }

        return header + candidates.joined(separator: "\n\n")
    }

    public static func usefulParagraphs(from text: String) -> [String] {
        text.components(separatedBy: "\n\n")
            .map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }
            .filter { !$0.isEmpty }
            .filter { paragraph in
                let lowered = paragraph.lowercased()
                return keywords.contains { lowered.contains($0) }
            }
    }
}
