import Combine
import Foundation

@MainActor
public final class EntryStore: ObservableObject {
    @Published public private(set) var todayEntry: DailyEntry
    @Published public private(set) var entries: [DailyEntry] = []
    @Published public var saveErrorMessage: String?

    public let entriesDirectory: URL
    private var autosaveWorkItem: DispatchWorkItem?

    public init(entriesDirectory: URL = EntryStore.defaultEntriesDirectory(), today: Date = Date()) {
        self.entriesDirectory = entriesDirectory
        self.todayEntry = DailyEntry(date: today)
        loadAll()
        loadToday(today)
    }

    nonisolated public static func defaultEntriesDirectory() -> URL {
        FileManager.default.urls(for: .applicationSupportDirectory, in: .userDomainMask)[0]
            .appendingPathComponent("Unspool", isDirectory: true)
            .appendingPathComponent("Entries", isDirectory: true)
    }

    public var previousEntries: [DailyEntry] {
        entries
            .filter { $0.id != todayEntry.id }
            .sorted { sortEntries($0, before: $1) }
    }

    public var currentStreak: Int {
        StreakCalculator.currentStreak(entries: visibleEntries, today: todayEntry.date)
    }

    public var statsSummary: EntryStatsSummary {
        EntryStatsSummary(entries: visibleEntries, today: todayEntry.date)
    }

    public var visibleEntries: [DailyEntry] {
        var byID = Dictionary(uniqueKeysWithValues: entries.map { ($0.id, $0) })
        byID[todayEntry.id] = todayEntry
        return Array(byID.values)
    }

    public func loadAll() {
        do {
            try FileManager.default.createDirectory(at: entriesDirectory, withIntermediateDirectories: true)
            let urls = try FileManager.default.contentsOfDirectory(
                at: entriesDirectory,
                includingPropertiesForKeys: nil
            )
            entries = urls
                .filter { $0.pathExtension == "md" }
                .compactMap { try? MarkdownEntrySerializer.load(from: $0) }
                .sorted { sortEntries($0, before: $1) }
        } catch {
            saveErrorMessage = "Could not load entries: \(error.localizedDescription)"
        }
    }

    public func loadToday(_ date: Date = Date()) {
        let key = DateSupport.dayString(for: date)
        let todaysEntries = entries
            .filter { $0.dayString == key }
            .sorted { sortEntries($0, before: $1) }

        if let latest = todaysEntries.first, !latest.reachedGoal {
            todayEntry = latest
        } else {
            todayEntry = newSessionEntry(for: date)
        }
    }

    public func updateTodayBody(_ body: String) {
        todayEntry = todayEntry.withBody(body)
        upsert(todayEntry)
        scheduleAutosave()
    }

    public func saveTodayNow() {
        save(entry: todayEntry)
    }

    public func markTodayExported() {
        todayEntry = todayEntry.markedExported()
        upsert(todayEntry)
        saveTodayNow()
    }

    public func markComposted(for date: Date, at compostedAt: Date = Date()) {
        let key = DateSupport.dayString(for: date)
        if todayEntry.dayString == key {
            todayEntry = todayEntry.markedComposted(at: compostedAt)
            upsert(todayEntry)
            saveTodayNow()
            return
        }

        guard let entry = entries.first(where: { $0.dayString == key }) else { return }
        save(entry: entry.markedComposted(at: compostedAt))
    }

    public func applyInsights(from review: CompostReview, reviewedAt: Date = Date()) {
        let summary = RedBarsReviewExtractor.insightSummary(from: review, reviewedAt: reviewedAt)
        let key = DateSupport.dayString(for: review.entryDate)
        if todayEntry.dayString == key {
            todayEntry = todayEntry
                .markedComposted(at: review.generatedAt)
                .withInsightSummary(summary)
            upsert(todayEntry)
            saveTodayNow()
            return
        }

        guard let entry = entries.first(where: { $0.dayString == key }) else { return }
        save(entry: entry.markedComposted(at: review.generatedAt).withInsightSummary(summary))
    }

    public func save(entry: DailyEntry) {
        guard shouldPersist(entry) else { return }

        do {
            let fileURL = fileURL(for: entry)
            try MarkdownEntrySerializer.save(entry, to: fileURL)
            saveErrorMessage = nil
            upsert(entry)
        } catch {
            saveErrorMessage = "Could not save: \(error.localizedDescription)"
        }
    }

    public func fileURL(for entry: DailyEntry) -> URL {
        entriesDirectory.appendingPathComponent("\(entry.id).md")
    }

    private func shouldPersist(_ entry: DailyEntry) -> Bool {
        !entry.body.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
            || FileManager.default.fileExists(atPath: fileURL(for: entry).path)
    }

    private func scheduleAutosave() {
        autosaveWorkItem?.cancel()
        let entryToSave = todayEntry
        let workItem = DispatchWorkItem { [weak self] in
            Task { @MainActor in
                self?.save(entry: entryToSave)
            }
        }
        autosaveWorkItem = workItem
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.7, execute: workItem)
    }

    private func upsert(_ entry: DailyEntry) {
        entries.removeAll { $0.id == entry.id }
        entries.append(entry)
        entries.sort { sortEntries($0, before: $1) }
    }

    private func newSessionEntry(for date: Date, now: Date = Date()) -> DailyEntry {
        let sessionID = uniqueSessionID(forEntryDate: date, createdAt: now)
        return DailyEntry(id: sessionID, date: date, createdAt: now, updatedAt: now)
    }

    private func uniqueSessionID(forEntryDate entryDate: Date, createdAt: Date) -> String {
        let baseID = DateSupport.sessionID(forEntryDate: entryDate, createdAt: createdAt)
        guard entries.contains(where: { $0.id == baseID }) else {
            return baseID
        }
        return "\(baseID)-\(UUID().uuidString.prefix(6))"
    }

    private func sortEntries(_ lhs: DailyEntry, before rhs: DailyEntry) -> Bool {
        if lhs.date != rhs.date {
            return lhs.date > rhs.date
        }
        return lhs.createdAt > rhs.createdAt
    }
}
