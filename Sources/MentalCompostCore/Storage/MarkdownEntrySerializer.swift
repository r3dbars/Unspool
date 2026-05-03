import Foundation

public enum MarkdownEntrySerializer {
    public static func markdown(for entry: DailyEntry) -> String {
        var lines: [String] = [
            "---",
            "app: Unspool",
            "type: daily-entry",
            "date: \(entry.dayString)",
            "wordCount: \(entry.wordCount)",
            "reachedGoal: \(entry.reachedGoal)",
            "createdAt: \(isoString(entry.createdAt))",
            "updatedAt: \(isoString(entry.updatedAt))"
        ]

        if let compostedAt = entry.compostedAt {
            lines.append("compostedAt: \(isoString(compostedAt))")
        }
        if let exportedAt = entry.exportedAt {
            lines.append("exportedAt: \(isoString(exportedAt))")
        }
        if let insightSummary = entry.insightSummary {
            lines.append("insightsReviewedAt: \(isoString(insightSummary.reviewedAt))")
            appendMetadataLine("insightBottleneck", value: insightSummary.bottleneck, to: &lines)
            appendMetadataLine("insightNextRedBar", value: insightSummary.nextRedBar, to: &lines)
            appendMetadataLine("insightGreenBarSignal", value: insightSummary.greenBarSignal, to: &lines)
        }
        if let moodBefore = entry.moodBefore, !moodBefore.isEmpty {
            lines.append("moodBefore: \(escapedMetadataValue(moodBefore))")
        }
        if let moodAfter = entry.moodAfter, !moodAfter.isEmpty {
            lines.append("moodAfter: \(escapedMetadataValue(moodAfter))")
        }

        lines.append(contentsOf: [
            "---",
            "",
            "# Unspool — \(entry.dayString)",
            "",
            entry.body
        ])

        return lines.joined(separator: "\n")
    }

    public static func entry(from markdown: String, fallbackDate: Date? = nil) throws -> DailyEntry {
        guard markdown.hasPrefix("---\n"),
              let frontmatterEnd = markdown.range(of: "\n---\n", range: markdown.index(markdown.startIndex, offsetBy: 4)..<markdown.endIndex)
        else {
            throw MarkdownEntrySerializerError.missingFrontmatter
        }

        let frontmatter = String(markdown[markdown.index(markdown.startIndex, offsetBy: 4)..<frontmatterEnd.lowerBound])
        let metadata = parseMetadata(frontmatter)
        let day = metadata["date"].flatMap(DateSupport.date(fromDayString:))
            ?? fallbackDate
            ?? Date()

        let createdAt = metadata["createdAt"].flatMap(dateFromISO) ?? Date()
        let updatedAt = metadata["updatedAt"].flatMap(dateFromISO) ?? createdAt
        let compostedAt = metadata["compostedAt"].flatMap(dateFromISO)
        let exportedAt = metadata["exportedAt"].flatMap(dateFromISO)
        let insightSummary = metadata["insightsReviewedAt"].flatMap(dateFromISO).map {
            EntryInsightSummary(
                reviewedAt: $0,
                bottleneck: metadata["insightBottleneck"] ?? "",
                nextRedBar: metadata["insightNextRedBar"] ?? "",
                greenBarSignal: metadata["insightGreenBarSignal"] ?? ""
            )
        }
        let body = parseBody(String(markdown[frontmatterEnd.upperBound...]))

        return DailyEntry(
            date: day,
            body: body,
            createdAt: createdAt,
            updatedAt: updatedAt,
            compostedAt: compostedAt,
            exportedAt: exportedAt,
            moodBefore: metadata["moodBefore"],
            moodAfter: metadata["moodAfter"],
            insightSummary: insightSummary
        )
    }

    public static func save(_ entry: DailyEntry, to fileURL: URL) throws {
        try FileManager.default.createDirectory(
            at: fileURL.deletingLastPathComponent(),
            withIntermediateDirectories: true
        )
        try markdown(for: entry).write(to: fileURL, atomically: true, encoding: .utf8)
    }

    public static func load(from fileURL: URL) throws -> DailyEntry {
        let markdown = try String(contentsOf: fileURL, encoding: .utf8)
        let fallbackDate = DateSupport.date(fromDayString: fileURL.deletingPathExtension().lastPathComponent)
        return try entry(from: markdown, fallbackDate: fallbackDate)
    }

    private static func parseMetadata(_ frontmatter: String) -> [String: String] {
        Dictionary(uniqueKeysWithValues: frontmatter.split(separator: "\n").compactMap { line in
            guard let separator = line.firstIndex(of: ":") else { return nil }
            let key = String(line[..<separator]).trimmingCharacters(in: .whitespaces)
            let value = String(line[line.index(after: separator)...]).trimmingCharacters(in: .whitespaces)
            return (key, unescapedMetadataValue(value))
        })
    }

    private static func parseBody(_ contentAfterFrontmatter: String) -> String {
        var lines = contentAfterFrontmatter.components(separatedBy: "\n")
        while lines.first?.isEmpty == true {
            lines.removeFirst()
        }
        if lines.first?.hasPrefix("# Unspool") == true || lines.first?.hasPrefix("# Mental Compost") == true {
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

    private static func escapedMetadataValue(_ value: String) -> String {
        value
            .replacingOccurrences(of: "\n", with: "\\n")
            .replacingOccurrences(of: "\"", with: "\\\"")
    }

    private static func unescapedMetadataValue(_ value: String) -> String {
        value
            .replacingOccurrences(of: "\\\"", with: "\"")
            .replacingOccurrences(of: "\\n", with: "\n")
            .trimmingCharacters(in: CharacterSet(charactersIn: "\""))
    }

    private static func appendMetadataLine(_ key: String, value: String, to lines: inout [String]) {
        let trimmed = value.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return }
        lines.append("\(key): \"\(escapedMetadataValue(trimmed))\"")
    }
}

public enum MarkdownEntrySerializerError: Error, Equatable {
    case missingFrontmatter
}
