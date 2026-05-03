import Foundation

public enum CompostGenerationMode: String, Sendable {
    case localAI
    case heuristic
    case manual
}

public struct CompostReview: Identifiable, Equatable, Sendable {
    public var id: String
    public var entryDate: Date
    public var sourceWordCount: Int
    public var generatedAt: Date
    public var generationMode: CompostGenerationMode
    public var seeds: [String]
    public var weeds: [String]
    public var compost: [String]
    public var fruit: [String]
    public var weather: [String]
    public var userEditedMarkdown: String?
    public var exportedAt: Date?

    public init(
        id: String? = nil,
        entryDate: Date,
        sourceWordCount: Int,
        generatedAt: Date = Date(),
        generationMode: CompostGenerationMode,
        seeds: [String] = [],
        weeds: [String] = [],
        compost: [String] = [],
        fruit: [String] = [],
        weather: [String] = [],
        userEditedMarkdown: String? = nil,
        exportedAt: Date? = nil
    ) {
        let normalizedDate = DateSupport.startOfDay(for: entryDate)
        self.id = id ?? DateSupport.dayString(for: normalizedDate)
        self.entryDate = normalizedDate
        self.sourceWordCount = sourceWordCount
        self.generatedAt = generatedAt
        self.generationMode = generationMode
        self.seeds = seeds
        self.weeds = weeds
        self.compost = compost
        self.fruit = fruit
        self.weather = weather
        self.userEditedMarkdown = userEditedMarkdown
        self.exportedAt = exportedAt
    }

    public var dayString: String {
        DateSupport.dayString(for: entryDate)
    }

    public var markdownBody: String {
        if let userEditedMarkdown, !userEditedMarkdown.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            return userEditedMarkdown
        }

        return """
        ## 🌱 Seeds
        \(bulletList(seeds))

        ## 🌿 Weeds
        \(bulletList(weeds))

        ## 🍂 Compost
        \(bulletList(compost))

        ## 🍎 Fruit
        \(bulletList(fruit))

        ## 🌦️ Weather
        \(weather.isEmpty ? "Today felt..." : weather.joined(separator: "\n"))
        """
    }

    public func withEditedMarkdown(_ markdown: String, mode: CompostGenerationMode? = nil) -> CompostReview {
        CompostReview(
            id: id,
            entryDate: entryDate,
            sourceWordCount: sourceWordCount,
            generatedAt: generatedAt,
            generationMode: mode ?? generationMode,
            seeds: seeds,
            weeds: weeds,
            compost: compost,
            fruit: fruit,
            weather: weather,
            userEditedMarkdown: markdown,
            exportedAt: exportedAt
        )
    }

    public func markedExported(at date: Date = Date()) -> CompostReview {
        CompostReview(
            id: id,
            entryDate: entryDate,
            sourceWordCount: sourceWordCount,
            generatedAt: generatedAt,
            generationMode: generationMode,
            seeds: seeds,
            weeds: weeds,
            compost: compost,
            fruit: fruit,
            weather: weather,
            userEditedMarkdown: userEditedMarkdown,
            exportedAt: date
        )
    }

    public static func manualTemplate(for entry: DailyEntry) -> CompostReview {
        CompostReview(
            entryDate: entry.date,
            sourceWordCount: entry.wordCount,
            generationMode: .manual,
            userEditedMarkdown: manualTemplateMarkdown
        )
    }

    public static let manualTemplateMarkdown = """
    ## 🌱 Seeds
    -

    ## 🌿 Weeds
    -

    ## 🍂 Compost
    -

    ## 🍎 Fruit
    -

    ## 🌦️ Weather
    Today felt...
    """

    private func bulletList(_ values: [String]) -> String {
        if values.isEmpty {
            return "-"
        }
        return values.map { "- \($0)" }.joined(separator: "\n")
    }
}

