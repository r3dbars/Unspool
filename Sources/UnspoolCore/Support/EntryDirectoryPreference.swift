import Foundation

public enum EntryDirectoryPreference {
    public static let userDefaultsKey = "customEntriesDirectoryPath"
    public static let didChangeNotification = Notification.Name("EntryDirectoryPreferenceDidChange")

    public static func defaultDirectory() -> URL {
        FileManager.default.urls(for: .applicationSupportDirectory, in: .userDomainMask)[0]
            .appendingPathComponent("Unspool", isDirectory: true)
            .appendingPathComponent("Entries", isDirectory: true)
    }

    public static func preferredDirectory(userDefaults: UserDefaults = .standard) -> URL {
        guard let path = userDefaults.string(forKey: userDefaultsKey),
              !path.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
            return defaultDirectory()
        }

        return URL(fileURLWithPath: path).standardizedFileURL
    }

    public static func setPreferredDirectory(_ directory: URL?, userDefaults: UserDefaults = .standard) {
        if let directory {
            userDefaults.set(directory.standardizedFileURL.path, forKey: userDefaultsKey)
        } else {
            userDefaults.removeObject(forKey: userDefaultsKey)
        }

        NotificationCenter.default.post(name: didChangeNotification, object: nil)
    }
}
