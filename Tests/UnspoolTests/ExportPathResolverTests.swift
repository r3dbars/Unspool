import UnspoolCore
import XCTest

final class ExportPathResolverTests: XCTestCase {
    func testUsesClaudeBrainRawFolderIfPresent() throws {
        let root = try temporaryDirectory()
        let documents = root.appendingPathComponent("Documents", isDirectory: true)
        let raw = documents
            .appendingPathComponent("claudebrain", isDirectory: true)
            .appendingPathComponent("raw", isDirectory: true)
        try FileManager.default.createDirectory(at: raw, withIntermediateDirectories: true)

        let resolver = ExportPathResolver(
            applicationSupportDirectory: root.appendingPathComponent("Application Support", isDirectory: true),
            documentsDirectory: documents
        )

        XCTAssertEqual(resolver.exportDirectory.path, raw.path)
    }

    func testFallsBackToApplicationSupportExportFolder() throws {
        let root = try temporaryDirectory()
        let appSupport = root.appendingPathComponent("Application Support", isDirectory: true)
        let documents = root.appendingPathComponent("Documents", isDirectory: true)

        let resolver = ExportPathResolver(
            applicationSupportDirectory: appSupport,
            documentsDirectory: documents
        )

        XCTAssertEqual(
            resolver.exportDirectory.path,
            appSupport.appendingPathComponent("AI Context Exports", isDirectory: true).path
        )
    }

    func testExporterWritesOnlySelectedCompost() throws {
        let root = try temporaryDirectory()
        let appSupport = root.appendingPathComponent("Application Support", isDirectory: true)
        let resolver = ExportPathResolver(applicationSupportDirectory: appSupport, documentsDirectory: root)
        let exporter = AIContextExporter(resolver: resolver)
        let review = CompostReview(
            entryDate: fixedDate("2026-05-02"),
            sourceWordCount: 812,
            generationMode: .heuristic,
            userEditedMarkdown: "Compost review only."
        )

        let fileURL = try exporter.export(selectedContext: "Selected compost only.", for: review)
        let exported = try String(contentsOf: fileURL, encoding: .utf8)

        XCTAssertTrue(exported.contains("Selected compost only."))
        XCTAssertFalse(exported.contains("Full private body"))
        XCTAssertTrue(exported.contains("Privacy note"))
    }
}
