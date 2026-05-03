import Foundation

public enum HeuristicCompostGenerator {
    private static let seedWords = ["idea", "maybe", "could", "build", "app", "project", "experiment", "try", "someday"]
    private static let weedWords = ["worry", "anxious", "stuck", "afraid", "overwhelmed", "frustrated", "pressure"]
    private static let compostWords = ["failed", "messy", "hard", "confused", "tension", "struggle", "mistake"]
    private static let fruitWords = ["decided", "next", "todo", "action", "ship", "finish", "commit", "important"]
    private static let weatherWords = ["tired", "energized", "scattered", "calm", "excited", "heavy", "restless"]

    public static func generate(for entry: DailyEntry) -> CompostReview {
        let paragraphs = paragraphs(from: entry.body)
        let seeds = matchingParagraphs(paragraphs, keywords: seedWords)
        let weeds = matchingParagraphs(paragraphs, keywords: weedWords)
        let compost = matchingParagraphs(paragraphs, keywords: compostWords)
        let fruit = matchingParagraphs(paragraphs, keywords: fruitWords)
        let weather = weatherSummary(from: entry.body)

        if seeds.isEmpty, weeds.isEmpty, compost.isEmpty, fruit.isEmpty, weather.isEmpty {
            return CompostReview.manualTemplate(for: entry)
        }

        return CompostReview(
            entryDate: entry.date,
            sourceWordCount: entry.wordCount,
            generationMode: .heuristic,
            seeds: seeds,
            weeds: weeds,
            compost: compost,
            fruit: fruit,
            weather: weather.isEmpty ? ["Today felt..."] : weather
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

    private static func weatherSummary(from text: String) -> [String] {
        let lowered = text.lowercased()
        let matches = weatherWords.filter { lowered.contains($0) }
        guard !matches.isEmpty else { return [] }
        return ["Today’s weather: \(matches.joined(separator: ", "))."]
    }
}
