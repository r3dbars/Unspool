import Foundation

public struct ExportPathResolver {
    public var fileManager: FileManager
    public var customExportDirectory: URL?
    public var applicationSupportDirectory: URL
    public var documentsDirectory: URL

    public init(
        fileManager: FileManager = .default,
        customExportDirectory: URL? = nil,
        applicationSupportDirectory: URL = FileManager.default.urls(for: .applicationSupportDirectory, in: .userDomainMask)[0]
            .appendingPathComponent("Unspool", isDirectory: true),
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
}
