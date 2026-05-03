import DailyPagesCore
import Foundation

func fixedDate(_ day: String) -> Date {
    DateSupport.date(fromDayString: day)!
}

func temporaryDirectory() throws -> URL {
    let url = FileManager.default.temporaryDirectory
        .appendingPathComponent(UUID().uuidString, isDirectory: true)
    try FileManager.default.createDirectory(at: url, withIntermediateDirectories: true)
    return url
}
