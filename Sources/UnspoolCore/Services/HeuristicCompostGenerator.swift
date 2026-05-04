import Foundation

public enum HeuristicCompostGenerator {
    private static let bottleneckWords = ["blocked", "blocking", "bottleneck", "stuck", "constraint", "hard", "can't", "cannot", "friction"]
    private static let openLoopWords = ["worry", "anxious", "unfinished", "open loop", "keeps coming back", "distracted", "overwhelmed", "pressure"]
    private static let decisionWords = ["decide", "decided", "decision", "choose", "choice", "unclear", "whether", "option"]
    private static let reversibleMoveWords = ["try", "test", "experiment", "small", "next", "todo", "action", "commit", "ship"]
    private static let redBarWords = ["red bar", "failure", "failed", "risk", "constraint", "uncomfortable", "avoid", "hard thing"]
    private static let greenBarWords = ["green bar", "signal", "proof", "progress", "working", "traction", "relief", "done"]

    public static func generate(for entry: DailyEntry) -> CompostReview {
        let paragraphs = paragraphs(from: entry.body)
        let bottleneck = matchingParagraphs(paragraphs, keywords: bottleneckWords)
        let openLoops = matchingParagraphs(paragraphs, keywords: openLoopWords)
        let decisions = matchingParagraphs(paragraphs, keywords: decisionWords)
        let smallestMove = matchingParagraphs(paragraphs, keywords: reversibleMoveWords)
        let nextRedBar = matchingParagraphs(paragraphs, keywords: redBarWords)
        let greenBarSignal = matchingParagraphs(paragraphs, keywords: greenBarWords)

        if bottleneck.isEmpty,
           openLoops.isEmpty,
           decisions.isEmpty,
           smallestMove.isEmpty,
           nextRedBar.isEmpty,
           greenBarSignal.isEmpty {
            return CompostReview.manualTemplate(for: entry)
        }

        return CompostReview(
            entryDate: entry.date,
            sourceWordCount: entry.wordCount,
            generationMode: .heuristic,
            bottleneck: bottleneck,
            openLoops: openLoops,
            decisions: decisions,
            smallestReversibleMove: smallestMove,
            nextRedBar: nextRedBar,
            greenBarSignal: greenBarSignal
        )
    }

    private static func paragraphs(from text: String) -> [String] {
        text.components(separatedBy: "\n\n")
            .map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }
            .filter { !$0.isEmpty }
    }

    private static func matchingParagraphs(_ paragraphs: [String], keywords: [String]) -> [String] {
        paragraphs.filter { paragraph in
            let lowered = paragraph.lowercased()
            return keywords.contains { lowered.contains($0) }
        }
    }
}
