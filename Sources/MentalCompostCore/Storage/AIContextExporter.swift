import Foundation

public struct AIContextExporter {
    public var resolver: ExportPathResolver

    public init(resolver: ExportPathResolver = ExportPathResolver()) {
        self.resolver = resolver
    }

    public func export(selectedContext: String, for review: CompostReview) throws -> URL {
        let destinationDirectory = resolver.exportDirectory
        try resolver.fileManager.createDirectory(at: destinationDirectory, withIntermediateDirectories: true)
        let fileURL = destinationDirectory
            .appendingPathComponent("\(review.dayString)-mental-compost-ai-context.md")

        let markdown = """
        # Mental Compost AI Context — \(review.dayString)

        Source: Mental Compost
        Date: \(review.dayString)
        Word count: \(review.sourceWordCount)
        Privacy note: The user explicitly selected/promoted this content for AI context.

        ## Context selected by user

        \(selectedContext)
        """

        try markdown.write(to: fileURL, atomically: true, encoding: .utf8)
        return fileURL
    }
}
