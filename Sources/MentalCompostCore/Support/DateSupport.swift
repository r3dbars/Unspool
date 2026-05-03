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

    public static func dayString(for date: Date) -> String {
        dayFormatter.string(from: date)
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
