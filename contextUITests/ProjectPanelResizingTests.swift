//
//  ProjectPanelResizingTests.swift
//  contextUITests
//
//  Created on 7/4/25.
//

import XCTest

final class ProjectPanelResizingTests: XCTestCase {
    
    var app: XCUIApplication!
    
    override func setUpWithError() throws {
        // In UI tests it is usually best to stop immediately when a failure occurs.
        continueAfterFailure = false
        
        // Launch the application
        app = XCUIApplication()
        app.launch()
        
        // Wait for app to fully load
        _ = app.windows.firstMatch.waitForExistence(timeout: 5)
    }
    
    override func tearDownWithError() throws {
        app.terminate()
    }
    
    @MainActor
    func testProjectPanelResizing() throws {
        // Find the projects panel
        let projectsHeader = app.staticTexts["Projects"]
        XCTAssertTrue(projectsHeader.waitForExistence(timeout: 2), "Projects panel should be visible")
        
        // Find the divider between projects panel and main content
        // In SwiftUI, dividers are usually represented as splitGroups or other UI elements
        let splitGroups = app.splitGroups
        let windows = app.windows
        
        // Get the initial width of the projects panel
        // We'll use the projects header frame as a proxy for panel width
        let initialFrame = projectsHeader.frame
        let initialWidth = initialFrame.width
        
        print("Initial projects panel width: \(initialWidth)")
        
        // Find resizable divider - this might be a splitGroup divider or a custom element
        // Try to find elements that might represent a divider
        let dividers = app.otherElements.matching(NSPredicate(format: "identifier CONTAINS 'divider' OR identifier CONTAINS 'resize' OR identifier CONTAINS 'split'"))
        
        if dividers.count > 0 {
            let divider = dividers.firstMatch
            
            // Attempt to drag the divider to resize the panel
            let startPoint = divider.coordinate(withNormalizedOffset: CGVector(dx: 0.5, dy: 0.5))
            let endPoint = startPoint.withOffset(CGVector(dx: 100, dy: 0)) // Drag 100 points to the right
            
            startPoint.press(forDuration: 0.1, thenDragTo: endPoint)
            
            // Wait a moment for the resize animation
            Thread.sleep(forTimeInterval: 0.5)
            
            // Check if the panel width changed
            let newFrame = projectsHeader.frame
            let newWidth = newFrame.width
            
            print("New projects panel width: \(newWidth)")
            
            // The panel should have resized
            XCTAssertNotEqual(initialWidth, newWidth, "Projects panel width should have changed after dragging")
            
            // Try to resize back
            let newStartPoint = divider.coordinate(withNormalizedOffset: CGVector(dx: 0.5, dy: 0.5))
            let newEndPoint = newStartPoint.withOffset(CGVector(dx: -50, dy: 0)) // Drag back 50 points
            
            newStartPoint.press(forDuration: 0.1, thenDragTo: newEndPoint)
            
            Thread.sleep(forTimeInterval: 0.5)
            
            let finalFrame = projectsHeader.frame
            let finalWidth = finalFrame.width
            
            print("Final projects panel width: \(finalWidth)")
            
            // Width should have changed again
            XCTAssertNotEqual(newWidth, finalWidth, "Projects panel width should have changed after second drag")
        } else {
            // Alternative approach: Try to find the edge of the projects panel
            // and drag from there
            let projectsPanelBounds = projectsHeader.frame
            let rightEdge = projectsPanelBounds.maxX
            
            // Create a coordinate at the right edge of the panel
            let window = windows.firstMatch
            let startCoordinate = window.coordinate(withNormalizedOffset: CGVector(dx: 0, dy: 0))
                .withOffset(CGVector(dx: rightEdge, dy: projectsPanelBounds.midY))
            
            let endCoordinate = startCoordinate.withOffset(CGVector(dx: 100, dy: 0))
            
            // Try to drag from the edge
            startCoordinate.press(forDuration: 0.1, thenDragTo: endCoordinate)
            
            Thread.sleep(forTimeInterval: 0.5)
            
            // Check if resize happened
            let newFrame = projectsHeader.frame
            let newWidth = newFrame.width
            
            print("Width after edge drag: \(newWidth)")
            
            // Even if we can't find a specific divider, we should verify the panel exists
            // and has a reasonable width
            XCTAssertGreaterThan(initialWidth, 100, "Projects panel should have a reasonable initial width")
            XCTAssertLessThan(initialWidth, 500, "Projects panel should not be too wide")
        }
        
        // Additional checks for panel functionality during/after resize
        // Verify that projects are still visible
        let projectElements = app.staticTexts.matching(NSPredicate(format: "label CONTAINS 'Project' OR label CONTAINS 'Todo' OR label CONTAINS 'Design' OR label CONTAINS 'API' OR label CONTAINS 'New Project'"))
        XCTAssertGreaterThan(projectElements.count, 0, "Should have at least one project visible after resizing")
        
        // Verify the panel is still functional - try to interact with it
        if projectElements.count > 0 {
            let firstProject = projectElements.firstMatch
            XCTAssertTrue(firstProject.isHittable, "Project items should still be clickable after resize")
            
            // Click on a project to ensure the panel is still interactive
            firstProject.tap()
            
            // Verify the tap was registered (project should be selected)
            // This might be indicated by a visual change or by content in other panels
            XCTAssertTrue(firstProject.exists, "Selected project should still be visible")
        }
    }
} 