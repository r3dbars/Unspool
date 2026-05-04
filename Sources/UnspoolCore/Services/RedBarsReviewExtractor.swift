import Foundation

public enum RedBarsReviewExtractor {
    public static func insightSummary(from review: CompostReview, reviewedAt: Date = Date()) -> EntryInsightSummary {
        let markdown = review.markdownBody
        return EntryInsightSummary(
            reviewedAt: reviewedAt,
            bottleneck: firstBullet(in: markdown, heading: "Bottleneck"),
            nextRedBar: firstBullet(in: markdown, heading: "Next Red Bar"),
            greenBarSignal: firstBullet(in: markdown, heading: "Green Bar Signal")
        )
    }

    private static func firstBullet(in markdown: String, heading: String) -> String {
        let lines = markdown.components(separatedBy: .newlines)
        guard let headingIndex = lines.firstIndex(where: { normalizedHeading($0) == heading.lowercased() }) else {
            return ""
        }

        for line in lines.dropFirst(headingIndex + 1) {
            let trimmed = line.trimmingCharacters(in: .whitespacesAndNewlines)
            if trimmed.hasPrefix("### ") || trimmed.hasPrefix("## ") {
                break
            }
            if trimmed.hasPrefix("-") {
                return trimmed
                    .dropFirst()
                    .trimmingCharacters(in: .whitespacesAndNewlines)
            }
            if !trimmed.isEmpty {
                return trimmed
            }
        }

        return ""
    }

    private static func normalizedHeading(_ line: String) -> String {
        line
            .replacingOccurrences(of: "#", with: "")
            .trimmingCharacters(in: .whitespacesAndNewlines)
            .lowercased()
    }
}
