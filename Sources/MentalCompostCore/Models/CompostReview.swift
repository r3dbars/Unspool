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
    public var bottleneck: [String]
    public var openLoops: [String]
    public var decisions: [String]
    public var smallestReversibleMove: [String]
    public var nextRedBar: [String]
    public var greenBarSignal: [String]
    public var userEditedMarkdown: String?
    public var exportedAt: Date?

    public init(
        id: String? = nil,
        entryDate: Date,
        sourceWordCount: Int,
        generatedAt: Date = Date(),
        generationMode: CompostGenerationMode,
        bottleneck: [String] = [],
        openLoops: [String] = [],
        decisions: [String] = [],
        smallestReversibleMove: [String] = [],
        nextRedBar: [String] = [],
        greenBarSignal: [String] = [],
        userEditedMarkdown: String? = nil,
        exportedAt: Date? = nil
    ) {
        let normalizedDate = DateSupport.startOfDay(for: entryDate)
        self.id = id ?? DateSupport.dayString(for: normalizedDate)
        self.entryDate = normalizedDate
        self.sourceWordCount = sourceWordCount
        self.generatedAt = generatedAt
        self.generationMode = generationMode
        self.bottleneck = bottleneck
        self.openLoops = openLoops
        self.decisions = decisions
        self.smallestReversibleMove = smallestReversibleMove
        self.nextRedBar = nextRedBar
        self.greenBarSignal = greenBarSignal
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
        ## Red Bars Review

        ### Bottleneck
        \(bulletList(bottleneck))

        ### Open Loops
        \(bulletList(openLoops))

        ### Decisions
        \(bulletList(decisions))

        ### Smallest Reversible Move
        \(bulletList(smallestReversibleMove))

        ### Next Red Bar
        \(bulletList(nextRedBar))

        ### Green Bar Signal
        \(bulletList(greenBarSignal))
        """
    }

    public func withEditedMarkdown(_ markdown: String, mode: CompostGenerationMode? = nil) -> CompostReview {
        CompostReview(
            id: id,
            entryDate: entryDate,
            sourceWordCount: sourceWordCount,
            generatedAt: generatedAt,
            generationMode: mode ?? generationMode,
            bottleneck: bottleneck,
            openLoops: openLoops,
            decisions: decisions,
            smallestReversibleMove: smallestReversibleMove,
            nextRedBar: nextRedBar,
            greenBarSignal: greenBarSignal,
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
            bottleneck: bottleneck,
            openLoops: openLoops,
            decisions: decisions,
            smallestReversibleMove: smallestReversibleMove,
            nextRedBar: nextRedBar,
            greenBarSignal: greenBarSignal,
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
    ## Red Bars Review

    ### Bottleneck
    -

    ### Open Loops
    -

    ### Decisions
    -

    ### Smallest Reversible Move
    -

    ### Next Red Bar
    -

    ### Green Bar Signal
    -
    """

    private func bulletList(_ values: [String]) -> String {
        if values.isEmpty {
            return "-"
        }
        return values.map { "- \($0)" }.joined(separator: "\n")
    }
}
