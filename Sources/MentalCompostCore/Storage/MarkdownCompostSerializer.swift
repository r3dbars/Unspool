import Foundation

public enum MarkdownCompostSerializer {
    public static func markdown(for review: CompostReview) -> String {
        var lines: [String] = [
            "---",
            "app: Unspool",
            "type: compost-review",
            "date: \(review.dayString)",
            "sourceWordCount: \(review.sourceWordCount)",
            "generationMode: \(review.generationMode.rawValue)",
            "generatedAt: \(isoString(review.generatedAt))"
        ]

        if let exportedAt = review.exportedAt {
            lines.append("exportedAt: \(isoString(exportedAt))")
        }

        lines.append(contentsOf: [
            "---",
            "",
            "# Red Bars Review — \(review.dayString)",
            "",
            review.markdownBody
        ])

        return lines.joined(separator: "\n")
    }

    public static func review(from markdown: String, fallbackDate: Date? = nil) throws -> CompostReview {
        guard markdown.hasPrefix("---\n"),
              let frontmatterEnd = markdown.range(of: "\n---\n", range: markdown.index(markdown.startIndex, offsetBy: 4)..<markdown.endIndex)
        else {
            throw MarkdownCompostSerializerError.missingFrontmatter
        }

        let frontmatter = String(markdown[markdown.index(markdown.startIndex, offsetBy: 4)..<frontmatterEnd.lowerBound])
        let metadata = parseMetadata(frontmatter)
        let day = metadata["date"].flatMap(DateSupport.date(fromDayString:)) ?? fallbackDate ?? Date()
        let sourceWordCount = Int(metadata["sourceWordCount"] ?? "") ?? 0
        let generatedAt = metadata["generatedAt"].flatMap(dateFromISO) ?? Date()
        let exportedAt = metadata["exportedAt"].flatMap(dateFromISO)
        let mode = metadata["generationMode"].flatMap(CompostGenerationMode.init(rawValue:)) ?? .manual
        let body = parseBody(String(markdown[frontmatterEnd.upperBound...]))

        return CompostReview(
            entryDate: day,
            sourceWordCount: sourceWordCount,
            generatedAt: generatedAt,
            generationMode: mode,
            userEditedMarkdown: body,
            exportedAt: exportedAt
        )
    }

    public static func save(_ review: CompostReview, to fileURL: URL) throws {
        try FileManager.default.createDirectory(
            at: fileURL.deletingLastPathComponent(),
            withIntermediateDirectories: true
        )
        try markdown(for: review).write(to: fileURL, atomically: true, encoding: .utf8)
    }

    public static func load(from fileURL: URL) throws -> CompostReview {
        let markdown = try String(contentsOf: fileURL, encoding: .utf8)
        let fallbackDay = fileURL.lastPathComponent.replacingOccurrences(of: "-compost.md", with: "")
        let fallbackDate = DateSupport.date(fromDayString: fallbackDay)
        return try review(from: markdown, fallbackDate: fallbackDate)
    }

    private static func parseMetadata(_ frontmatter: String) -> [String: String] {
        Dictionary(uniqueKeysWithValues: frontmatter.split(separator: "\n").compactMap { line in
            guard let separator = line.firstIndex(of: ":") else { return nil }
            let key = String(line[..<separator]).trimmingCharacters(in: .whitespaces)
            let value = String(line[line.index(after: separator)...]).trimmingCharacters(in: .whitespaces)
            return (key, value)
        })
    }

    private static func parseBody(_ contentAfterFrontmatter: String) -> String {
        var lines = contentAfterFrontmatter.components(separatedBy: "\n")
        while lines.first?.isEmpty == true {
            lines.removeFirst()
        }
        if lines.first?.hasPrefix("# Mental Compost Review") == true || lines.first?.hasPrefix("# Red Bars Review") == true {
            lines.removeFirst()
        }
        if lines.first?.isEmpty == true {
            lines.removeFirst()
        }
        return lines.joined(separator: "\n")
    }

    private static func isoString(_ date: Date) -> String {
        ISO8601DateFormatter().string(from: date)
    }

    private static func dateFromISO(_ value: String) -> Date? {
        ISO8601DateFormatter().date(from: value)
    }
}

public enum MarkdownCompostSerializerError: Error, Equatable {
    case missingFrontmatter
}
