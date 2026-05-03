import DailyPagesCore
import XCTest

final class ContextExportStoreTests: XCTestCase {
    func testUsesClaudeBrainRawFolderIfPresent() throws {
        let root = try temporaryDirectory()
        let documents = root.appendingPathComponent("Documents", isDirectory: true)
        let raw = documents
            .appendingPathComponent("claudebrain", isDirectory: true)
            .appendingPathComponent("raw", isDirectory: true)
        try FileManager.default.createDirectory(at: raw, withIntermediateDirectories: true)

        let store = ContextExportStore(
            applicationSupportDirectory: root.appendingPathComponent("Application Support", isDirectory: true),
            documentsDirectory: documents
        )

        XCTAssertEqual(store.exportDirectory.path, raw.path)
    }

    func testFallsBackToApplicationSupportExportFolder() throws {
        let root = try temporaryDirectory()
        let appSupport = root.appendingPathComponent("Application Support", isDirectory: true)
        let documents = root.appendingPathComponent("Documents", isDirectory: true)

        let store = ContextExportStore(
            applicationSupportDirectory: appSupport,
            documentsDirectory: documents
        )

        XCTAssertEqual(
            store.exportDirectory.path,
            appSupport.appendingPathComponent("AI Context Exports", isDirectory: true).path
        )
    }

    func testExportWritesOnlySelectedContext() throws {
        let root = try temporaryDirectory()
        let appSupport = root.appendingPathComponent("Application Support", isDirectory: true)
        let store = ContextExportStore(applicationSupportDirectory: appSupport, documentsDirectory: root)
        let entry = DailyEntry(date: fixedDate("2026-05-02"), body: "Full private body that should not be exported.")

        let fileURL = try store.export(context: "Selected memory only.", for: entry)
        let exported = try String(contentsOf: fileURL, encoding: .utf8)

        XCTAssertTrue(exported.contains("Selected memory only."))
        XCTAssertFalse(exported.contains(entry.body))
        XCTAssertTrue(exported.contains("Privacy note"))
    }
}
