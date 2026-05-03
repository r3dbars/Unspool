import Foundation

public struct ContextExportStore {
    public var fileManager: FileManager
    public var customExportDirectory: URL?
    public var applicationSupportDirectory: URL
    public var documentsDirectory: URL

    public init(
        fileManager: FileManager = .default,
        customExportDirectory: URL? = nil,
        applicationSupportDirectory: URL = FileManager.default.urls(for: .applicationSupportDirectory, in: .userDomainMask)[0]
            .appendingPathComponent("Daily Pages", isDirectory: true),
        documentsDirectory: URL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
    ) {
        self.fileManager = fileManager
        self.customExportDirectory = customExportDirectory
        self.applicationSupportDirectory = applicationSupportDirectory
        self.documentsDirectory = documentsDirectory
    }

    public var exportDirectory: URL {
        if let customExportDirectory {
            return customExportDirectory
        }

        let claudeBrainRaw = documentsDirectory
            .appendingPathComponent("claudebrain", isDirectory: true)
            .appendingPathComponent("raw", isDirectory: true)

        if fileManager.fileExists(atPath: claudeBrainRaw.path) {
            return claudeBrainRaw
        }

        return applicationSupportDirectory
            .appendingPathComponent("AI Context Exports", isDirectory: true)
    }

    public func export(context: String, for entry: DailyEntry) throws -> URL {
        let destinationDirectory = exportDirectory
        try fileManager.createDirectory(at: destinationDirectory, withIntermediateDirectories: true)
        let fileURL = destinationDirectory
            .appendingPathComponent("\(entry.dayString)-daily-pages-ai-context.md")

        let markdown = """
        # Daily Pages AI Context - \(entry.dayString)

        Source: Daily Pages
        Date: \(entry.dayString)
        Word count: \(entry.wordCount)
        Privacy note: User explicitly selected/promoted this content for AI context.

        ## Context selected by user

        \(context)
        """

        try markdown.write(to: fileURL, atomically: true, encoding: .utf8)
        return fileURL
    }
}
