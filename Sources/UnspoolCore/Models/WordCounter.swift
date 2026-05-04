import Foundation

public enum WordCounter {
    public static func count(_ text: String) -> Int {
        let trimCharacters = CharacterSet(charactersIn: "#*-_`[](){}<>.,!?;:\"“”")
        return text
            .split(whereSeparator: { $0.isWhitespace })
            .map { String($0).trimmingCharacters(in: trimCharacters) }
            .filter { !$0.isEmpty }
            .count
    }
}
