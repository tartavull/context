//
//  ProjectPanelResizingTests.swift
//  contextUITests
//
//  Created on 7/4/25.
//

import XCTest

final class ProjectPanelResizingTests: XCTestCase {
    
    var app: XCUIApplication?
    
    override func setUpWithError() throws {
        continueAfterFailure = false
        app = XCUIApplication()
        app?.launch()
        
        // Wait for app to fully load
        XCTAssertTrue(app?.windows.firstMatch.waitForExistence(timeout: 10) == true, "App window should appear")
        Thread.sleep(forTimeInterval: 2.0)
    }
    
    override func tearDownWithError() throws {
        app?.terminate()
    }
    
    func testProjectPanelToggleButton() throws {
        guard let app = app else { return }
        
        // Find and test the toggle button
        let toggleButton = app.buttons["Toggle Projects Panel"]
        XCTAssertTrue(toggleButton.waitForExistence(timeout: 5), "Toggle button should exist")
        
        // Get initial state of projects panel
        let projectsPanel = app.otherElements["projects-panel"]
        let initialPanelVisible = projectsPanel.exists
        
        // Tap the toggle button
        toggleButton.tap()
        Thread.sleep(forTimeInterval: 1.0)
        
        // Verify the panel state changed
        let finalPanelVisible = projectsPanel.exists
        XCTAssertNotEqual(initialPanelVisible, finalPanelVisible, "Panel visibility should change after toggle")
    }
    
    func testProjectPanelResizing() throws {
        guard let app = app else { return }
        
        // Ensure projects panel is visible
        let projectsPanel = app.otherElements["projects-panel"]
        XCTAssertTrue(projectsPanel.waitForExistence(timeout: 5), "Projects panel should be visible")
        
        // Find the resize handle
        let resizeHandle = app.otherElements["projects-panel-resize-handle"]
        XCTAssertTrue(resizeHandle.waitForExistence(timeout: 5), "Resize handle should exist")
        
        // Get initial panel size
        let initialFrame = projectsPanel.frame
        
        // Perform resize by dragging the handle
        let startPoint = resizeHandle.coordinate(withNormalizedOffset: CGVector(dx: 0.5, dy: 0.5))
        let endPoint = startPoint.withOffset(CGVector(dx: 50, dy: 0))
        
        startPoint.press(forDuration: 0.1, thenDragTo: endPoint)
        Thread.sleep(forTimeInterval: 1.0)
        
        // Verify the panel size changed
        let finalFrame = projectsPanel.frame
        XCTAssertNotEqual(initialFrame.width, finalFrame.width, "Panel width should change after resize")
    }
}
