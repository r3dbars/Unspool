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
            .appendingPathComponent("Mental Compost", isDirectory: true)
            .appendingPathComponent("Entries", isDirectory: true)
    }

    public var previousEntries: [DailyEntry] {
        entries
            .filter { $0.dayString != todayEntry.dayString }
            .sorted { $0.date > $1.date }
    }

    public var currentStreak: Int {
        StreakCalculator.currentStreak(entries: visibleEntries, today: todayEntry.date)
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
                .sorted { $0.date > $1.date }
        } catch {
            saveErrorMessage = "Could not load entries: \(error.localizedDescription)"
        }
    }

    public func loadToday(_ date: Date = Date()) {
        let key = DateSupport.dayString(for: date)
        if let existing = entries.first(where: { $0.dayString == key }) {
            todayEntry = existing
        } else {
            todayEntry = DailyEntry(date: date)
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
        entriesDirectory.appendingPathComponent("\(entry.dayString).md")
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
        entries.sort { $0.date > $1.date }
    }
}
