import Foundation

public enum DateSupport {
    public static let calendar: Calendar = {
        var calendar = Calendar(identifier: .gregorian)
        calendar.timeZone = .current
        return calendar
    }()

    private static let dayFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.calendar = Calendar(identifier: .gregorian)
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.timeZone = .current
        formatter.dateFormat = "yyyy-MM-dd"
        return formatter
    }()

    private static let sessionFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.calendar = Calendar(identifier: .gregorian)
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.timeZone = .current
        formatter.dateFormat = "yyyy-MM-dd-HHmmss"
        return formatter
    }()

    private static let sessionTimeFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.calendar = Calendar(identifier: .gregorian)
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.timeZone = .current
        formatter.dateFormat = "HHmmss"
        return formatter
    }()

    private static let entryTimeFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.calendar = Calendar(identifier: .gregorian)
        formatter.locale = .current
        formatter.timeZone = .current
        formatter.dateStyle = .none
        formatter.timeStyle = .short
        return formatter
    }()

    public static func dayString(for date: Date) -> String {
        dayFormatter.string(from: date)
    }

    public static func sessionID(for date: Date = Date()) -> String {
        sessionFormatter.string(from: date)
    }

    public static func sessionID(forEntryDate entryDate: Date, createdAt: Date = Date()) -> String {
        "\(dayString(for: entryDate))-\(sessionTimeFormatter.string(from: createdAt))"
    }

    public static func timeString(for date: Date) -> String {
        entryTimeFormatter.string(from: date)
    }

    public static func date(fromDayString value: String) -> Date? {
        dayFormatter.date(from: value)
    }

    public static func startOfDay(for date: Date) -> Date {
        calendar.startOfDay(for: date)
    }

    public static func addingDays(_ days: Int, to date: Date) -> Date {
        calendar.date(byAdding: .day, value: days, to: startOfDay(for: date)) ?? date
    }
}
