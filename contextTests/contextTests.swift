//
//  contextTests.swift
//  contextTests
//
//  Created on 7/4/25.
//

import XCTest
@testable import context

@MainActor
final class ContextTests: XCTestCase {

    var appStateManager: AppStateManager!

    override func setUp() {
        super.setUp()
        appStateManager = AppStateManager()
    }

    override func tearDown() {
        appStateManager = nil
        super.tearDown()
    }

    // MARK: - Panel Toggle Tests

    func testInitialPanelState() {
        // Panel should be hidden by default
        XCTAssertFalse(appStateManager.state.ui.showProjects, "Projects panel should be hidden initially")
        XCTAssertEqual(appStateManager.state.ui.projectsPanelSize, 30.0, "Panel should have default size")
    }

    // MARK: - Panel Resize Tests

    func testPanelResizeToValidSize() {
        let testSizes: [Double] = [25.0, 30.0, 35.0, 40.0, 45.0]

        for size in testSizes {
            appStateManager.updateUI(["projectsPanelSize": size])
            XCTAssertEqual(appStateManager.state.ui.projectsPanelSize, size,
                           "Panel size should be set to \(size)")
        }
    }

    func testPanelResizeConstraints() {
        // Test minimum constraint (assuming 20.0 is minimum based on 200px / 10)
        let minSize = 20.0
        appStateManager.updateUI(["projectsPanelSize": minSize])
        XCTAssertEqual(appStateManager.state.ui.projectsPanelSize, minSize,
                       "Panel should accept minimum size")

        // Test below minimum (should still be accepted by updateUI, constraints handled in UI)
        appStateManager.updateUI(["projectsPanelSize": 10.0])
        XCTAssertEqual(appStateManager.state.ui.projectsPanelSize, 10.0,
                       "updateUI should accept any value, constraints handled in UI layer")

        // Test maximum constraint (assuming 50.0 is reasonable max based on 500px / 10)
        let maxSize = 50.0
        appStateManager.updateUI(["projectsPanelSize": maxSize])
        XCTAssertEqual(appStateManager.state.ui.projectsPanelSize, maxSize,
                       "Panel should accept maximum size")
    }

    func testPanelResizeIncremental() {
        let initialSize = 30.0
        appStateManager.updateUI(["projectsPanelSize": initialSize])

        // Increase size
        let increasedSize = initialSize + 5.0
        appStateManager.updateUI(["projectsPanelSize": increasedSize])
        XCTAssertEqual(appStateManager.state.ui.projectsPanelSize, increasedSize,
                       "Panel size should increase correctly")

        // Decrease size
        let decreasedSize = increasedSize - 3.0
        appStateManager.updateUI(["projectsPanelSize": decreasedSize])
        XCTAssertEqual(appStateManager.state.ui.projectsPanelSize, decreasedSize,
                       "Panel size should decrease correctly")
    }

    func testPanelResizePreservesOtherUIState() {
        // Set initial UI state
        let initialShowChart = true
        let initialShowChat = true
        appStateManager.updateUI([
            "showChart": initialShowChart,
            "showChat": initialShowChat
        ])

        // Resize panel
        appStateManager.updateUI(["projectsPanelSize": 35.0])

        // Verify other UI state is preserved
        XCTAssertEqual(appStateManager.state.ui.showChart, initialShowChart,
                       "Chart visibility should be preserved during resize")
        XCTAssertEqual(appStateManager.state.ui.showChat, initialShowChat,
                       "Chat visibility should be preserved during resize")
        XCTAssertEqual(appStateManager.state.ui.projectsPanelSize, 35.0,
                       "Panel size should be updated")
    }

    // MARK: - Combined Toggle and Resize Tests

    func testResizeWhileHidden() {
        // Hide panel
        appStateManager.updateUI(["showProjects": false])
        XCTAssertFalse(appStateManager.state.ui.showProjects)

        // Resize while hidden
        let newSize = 45.0
        appStateManager.updateUI(["projectsPanelSize": newSize])
        XCTAssertEqual(appStateManager.state.ui.projectsPanelSize, newSize,
                       "Panel should be resizable even when hidden")

        // Show panel
        appStateManager.updateUI(["showProjects": true])
        XCTAssertTrue(appStateManager.state.ui.showProjects, "Panel should be visible")
        XCTAssertEqual(appStateManager.state.ui.projectsPanelSize, newSize,
                       "Panel should maintain size set while hidden")
    }

    // MARK: - UI State Batch Updates

    func testBatchUIUpdates() {
        let updates = [
            "showProjects": true,
            "projectsPanelSize": 42.0,
            "showChart": false,
            "showChat": true
        ] as [String: Any]

        appStateManager.updateUI(updates)

        XCTAssertTrue(appStateManager.state.ui.showProjects, "Projects should be visible")
        XCTAssertEqual(appStateManager.state.ui.projectsPanelSize, 42.0, "Panel size should be updated")
        XCTAssertFalse(appStateManager.state.ui.showChart, "Chart should be hidden")
        XCTAssertTrue(appStateManager.state.ui.showChat, "Chat should be visible")
    }

    func testInvalidUIUpdates() {
        let initialState = appStateManager.state.ui

        // Try to update with invalid types (should be ignored)
        let invalidUpdates = [
            "showProjects": "invalid_string",
            "projectsPanelSize": "not_a_number"
        ] as [String: Any]

        appStateManager.updateUI(invalidUpdates)

        // State should remain unchanged
        XCTAssertEqual(appStateManager.state.ui.showProjects, initialState.showProjects,
                       "Invalid boolean update should be ignored")
        XCTAssertEqual(appStateManager.state.ui.projectsPanelSize, initialState.projectsPanelSize,
                       "Invalid double update should be ignored")
    }
}

// MARK: - Panel Logic Tests

extension ContextTests {

    func testPanelLogicConsistency() {
        // Test the logical consistency of panel states

        // When projects panel is hidden, chart should still be visible
        appStateManager.updateUI(["showProjects": false])
        XCTAssertFalse(appStateManager.state.ui.showProjects)
        XCTAssertTrue(appStateManager.state.ui.showChart, "Chart should remain visible when projects panel is hidden")

        // When both panels are hidden, app should still function
        appStateManager.updateUI(["showChart": false])
        XCTAssertFalse(appStateManager.state.ui.showProjects)
        XCTAssertFalse(appStateManager.state.ui.showChart)
        // App should still be in a valid state
        XCTAssertNotNil(appStateManager.state, "App state should remain valid")
    }

}
