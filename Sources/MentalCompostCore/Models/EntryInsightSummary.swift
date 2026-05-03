import Foundation

public struct EntryInsightSummary: Equatable, Sendable {
    public var reviewedAt: Date
    public var bottleneck: String
    public var nextRedBar: String
    public var greenBarSignal: String

    public init(
        reviewedAt: Date = Date(),
        bottleneck: String = "",
        nextRedBar: String = "",
        greenBarSignal: String = ""
    ) {
        self.reviewedAt = reviewedAt
        self.bottleneck = bottleneck
        self.nextRedBar = nextRedBar
        self.greenBarSignal = greenBarSignal
    }
}
