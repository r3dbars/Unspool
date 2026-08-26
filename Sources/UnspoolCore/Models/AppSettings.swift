import Foundation

public struct AppSettings: Equatable, Sendable {
    public var entriesDirectory: URL

    public init(
        entriesDirectory: URL = EntryStore.preferredEntriesDirectory()
    ) {
        self.entriesDirectory = entriesDirectory
    }
}
