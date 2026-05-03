import Foundation

public struct DailyEntry: Identifiable, Equatable, Sendable {
    public var id: String
    public var date: Date
    public var body: String
    public var wordCount: Int
    public var createdAt: Date
    public var updatedAt: Date
    public var reachedGoal: Bool
    public var compostedAt: Date?
    public var exportedAt: Date?
    public var moodBefore: String?
    public var moodAfter: String?

    public init(
        id: String? = nil,
        date: Date,
        body: String = "",
        wordCount: Int? = nil,
        createdAt: Date = Date(),
        updatedAt: Date = Date(),
        reachedGoal: Bool? = nil,
        compostedAt: Date? = nil,
        exportedAt: Date? = nil,
        moodBefore: String? = nil,
        moodAfter: String? = nil
    ) {
        let normalizedDate = DateSupport.startOfDay(for: date)
        let computedWordCount = wordCount ?? WordCounter.count(body)
        self.id = id ?? DateSupport.dayString(for: normalizedDate)
        self.date = normalizedDate
        self.body = body
        self.wordCount = computedWordCount
        self.createdAt = createdAt
        self.updatedAt = updatedAt
        self.reachedGoal = reachedGoal ?? (computedWordCount >= 750)
        self.compostedAt = compostedAt
        self.exportedAt = exportedAt
        self.moodBefore = moodBefore
        self.moodAfter = moodAfter
    }

    public var dayString: String {
        DateSupport.dayString(for: date)
    }

    public func withBody(_ newBody: String, now: Date = Date()) -> DailyEntry {
        DailyEntry(
            id: id,
            date: date,
            body: newBody,
            createdAt: createdAt,
            updatedAt: now,
            compostedAt: compostedAt,
            exportedAt: exportedAt,
            moodBefore: moodBefore,
            moodAfter: moodAfter
        )
    }

    public func markedExported(at date: Date = Date()) -> DailyEntry {
        DailyEntry(
            id: id,
            date: self.date,
            body: body,
            wordCount: wordCount,
            createdAt: createdAt,
            updatedAt: updatedAt,
            reachedGoal: reachedGoal,
            compostedAt: compostedAt,
            exportedAt: date,
            moodBefore: moodBefore,
            moodAfter: moodAfter
        )
    }

    public func markedComposted(at date: Date = Date()) -> DailyEntry {
        DailyEntry(
            id: id,
            date: self.date,
            body: body,
            wordCount: wordCount,
            createdAt: createdAt,
            updatedAt: updatedAt,
            reachedGoal: reachedGoal,
            compostedAt: date,
            exportedAt: exportedAt,
            moodBefore: moodBefore,
            moodAfter: moodAfter
        )
    }
}
