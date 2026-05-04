import Combine
import Foundation

@MainActor
public final class CompostReviewStore: ObservableObject {
    @Published public private(set) var reviews: [CompostReview] = []
    @Published public var saveErrorMessage: String?

    public let compostDirectory: URL

    public init(compostDirectory: URL = CompostReviewStore.defaultCompostDirectory()) {
        self.compostDirectory = compostDirectory
        loadAll()
    }

    nonisolated public static func defaultCompostDirectory() -> URL {
        FileManager.default.urls(for: .applicationSupportDirectory, in: .userDomainMask)[0]
            .appendingPathComponent("Unspool", isDirectory: true)
            .appendingPathComponent("Compost", isDirectory: true)
    }

    public func loadAll() {
        do {
            try FileManager.default.createDirectory(at: compostDirectory, withIntermediateDirectories: true)
            let urls = try FileManager.default.contentsOfDirectory(
                at: compostDirectory,
                includingPropertiesForKeys: nil
            )
            reviews = urls
                .filter { $0.pathExtension == "md" }
                .compactMap { try? MarkdownCompostSerializer.load(from: $0) }
                .sorted { $0.entryDate > $1.entryDate }
        } catch {
            saveErrorMessage = "Could not load compost reviews: \(error.localizedDescription)"
        }
    }

    public func review(for date: Date) -> CompostReview? {
        let key = DateSupport.dayString(for: date)
        return reviews.first { $0.dayString == key }
    }

    public func hasReview(for date: Date) -> Bool {
        review(for: date) != nil
    }

    public func save(_ review: CompostReview) {
        do {
            try MarkdownCompostSerializer.save(review, to: fileURL(for: review))
            saveErrorMessage = nil
            upsert(review)
        } catch {
            saveErrorMessage = "Could not save compost: \(error.localizedDescription)"
        }
    }

    public func fileURL(for review: CompostReview) -> URL {
        compostDirectory.appendingPathComponent("\(review.dayString)-compost.md")
    }

    private func upsert(_ review: CompostReview) {
        reviews.removeAll { $0.id == review.id }
        reviews.append(review)
        reviews.sort { $0.entryDate > $1.entryDate }
    }
}
