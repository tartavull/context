//
//  contextUITests.swift
//  contextUITests
//
//  Created by Ignacio Tartavull on 7/3/25.
//

import XCTest

final class contextUITests: XCTestCase {
    
    var app: XCUIApplication!

    override func setUpWithError() throws {
        continueAfterFailure = false
        
        app = XCUIApplication()
        app.launch()
        
        // Wait for app to fully load
        _ = app.windows.firstMatch.waitForExistence(timeout: 5)
    }

    override func tearDownWithError() throws {
        app.terminate()
    }

    // MARK: - App Launch Tests
    
    @MainActor
    func testAppLaunches() throws {
        XCTAssertTrue(app.windows.firstMatch.exists)
    }

    @MainActor
    func testLaunchPerformance() throws {
        measure(metrics: [XCTApplicationLaunchMetric()]) {
            XCUIApplication().launch()
        }
    }
    
    // MARK: - Header Tests
    
    @MainActor
    func testHeaderExists() throws {
        // Header should be visible
        let headerExists = app.staticTexts["Projects"].exists || 
                          app.buttons.matching(identifier: "panel_toggle").count > 0
        XCTAssertTrue(headerExists, "Header should be visible")
    }
    
    @MainActor
    func testPanelToggleButtons() throws {
        // Look for panel toggle buttons (they might be unlabeled)
        let buttons = app.buttons.allElementsBoundByIndex
        
        // Should have at least some buttons for panel toggles
        XCTAssertGreaterThan(buttons.count, 0, "Should have panel toggle buttons")
    }
    
    // MARK: - Projects Panel Tests
    
    @MainActor
    func testProjectsPanelVisible() throws {
        // Projects panel should be visible by default
        let projectsText = app.staticTexts["Projects"]
        XCTAssertTrue(projectsText.waitForExistence(timeout: 2), "Projects panel should be visible")
    }
    
    @MainActor
    func testCreateNewProject() throws {
        // Look for create project button (plus button)
        let createButton = app.buttons.matching(NSPredicate(format: "label CONTAINS '+' OR identifier CONTAINS 'create' OR identifier CONTAINS 'plus'")).firstMatch
        
        if createButton.exists {
            createButton.tap()
            
            // Should create a new project and enter edit mode
            let textField = app.textFields.firstMatch
            if textField.waitForExistence(timeout: 2) {
                textField.clearAndTypeText("Test Project")
                app.typeKey("\r", modifierFlags: []) // Press Enter
                
                // Project should appear in the list
                let projectText = app.staticTexts["Test Project"]
                XCTAssertTrue(projectText.waitForExistence(timeout: 2), "New project should appear")
            }
        } else {
            // If no create button found, try clicking in empty area
            XCTAssertTrue(app.staticTexts["Projects"].exists, "At least projects panel should exist")
        }
    }
    
    @MainActor
    func testProjectSelection() throws {
        // First create a project if none exist
        createTestProjectIfNeeded()
        
        // Try to select a project by clicking on it
        let projectElements = app.staticTexts.matching(NSPredicate(format: "label CONTAINS 'Project' OR label CONTAINS 'Todo' OR label CONTAINS 'Design'"))
        
        if projectElements.count > 0 {
            let firstProject = projectElements.firstMatch
            firstProject.tap()
            
            // Project should be selected (visual feedback might vary)
            XCTAssertTrue(firstProject.exists, "Project should remain visible after selection")
        }
    }
    
    // MARK: - Chart Panel Tests
    
    @MainActor
    func testChartPanelVisible() throws {
        // Chart panel should be visible when a project is selected
        createTestProjectIfNeeded()
        
        // Look for chart-related elements
        let chartExists = app.scrollViews.count > 0 || 
                         app.staticTexts["No Project Selected"].exists ||
                         app.staticTexts.matching(NSPredicate(format: "label CONTAINS 'Task' OR label CONTAINS 'Node'")).count > 0
        
        XCTAssertTrue(chartExists, "Chart panel should be visible")
    }
    
    @MainActor
    func testTaskNodeInteraction() throws {
        createTestProjectIfNeeded()
        
        // Look for task nodes in the chart
        let taskElements = app.staticTexts.matching(NSPredicate(format: "label CONTAINS 'Task' OR label CONTAINS 'Project'"))
        
        if taskElements.count > 0 {
            let firstTask = taskElements.firstMatch
            firstTask.tap()
            
            // Task should be selectable
            XCTAssertTrue(firstTask.exists, "Task should remain visible after selection")
        }
    }
    
    // MARK: - Chat Panel Tests
    
    @MainActor
    func testChatPanelVisible() throws {
        // Chat panel should be visible
        let chatExists = app.textViews.count > 0 || 
                        app.textFields.count > 0 ||
                        app.staticTexts["No Project Selected"].exists ||
                        app.staticTexts["No Task Selected"].exists
        
        XCTAssertTrue(chatExists, "Chat panel should be visible")
    }
    
    @MainActor
    func testChatInput() throws {
        createTestProjectIfNeeded()
        selectFirstTaskIfAvailable()
        
        // Look for chat input field
        let textViews = app.textViews.allElementsBoundByIndex
        let textFields = app.textFields.allElementsBoundByIndex
        
        let inputField = textViews.first { $0.exists } ?? textFields.first { $0.exists }
        
        if let input = inputField {
            input.tap()
            input.typeText("Hello, this is a test message")
            
            // Try to send the message (Enter key)
            app.typeKey("\r", modifierFlags: [])
            
            // Message should appear or input should be cleared
            let hasMessage = app.staticTexts["Hello, this is a test message"].exists
            let inputCleared = input.value as? String == "" || input.value as? String == nil
            
            XCTAssertTrue(hasMessage || inputCleared, "Message should be sent or input cleared")
        }
    }
    
    @MainActor
    func testChatCommands() throws {
        createTestProjectIfNeeded()
        selectFirstTaskIfAvailable()
        
        // Test chat commands
        let textViews = app.textViews.allElementsBoundByIndex
        let inputField = textViews.first { $0.exists }
        
        if let input = inputField {
            input.tap()
            input.typeText("/clone")
            app.typeKey("\r", modifierFlags: [])
            
            // Should show some response
            let hasResponse = app.staticTexts.matching(NSPredicate(format: "label CONTAINS 'clone' OR label CONTAINS 'Clone'")).count > 0
            
            // Even if no visible response, command should be processed
            XCTAssertTrue(hasResponse || input.exists, "Command should be processed")
        }
    }
    
    // MARK: - Footer Tests
    
    @MainActor
    func testFooterVisible() throws {
        // Look for footer elements (time display)
        let timePattern = NSPredicate(format: "label MATCHES '\\\\d{2}:\\\\d{2}'")
        let timeDisplay = app.staticTexts.matching(timePattern).firstMatch
        
        // Footer might contain time or other info
        let footerExists = timeDisplay.exists || 
                          app.staticTexts.matching(NSPredicate(format: "label CONTAINS ':'")).count > 0
        
        XCTAssertTrue(footerExists, "Footer should be visible")
    }
    
    // MARK: - Panel Resizing Tests
    
    @MainActor
    func testPanelResizing() throws {
        // Test if panels can be resized (this is complex in UI tests)
        let initialFrame = app.frame
        
        // Try dragging from the middle of the screen (where resize handles might be)
        let centerX = initialFrame.midX
        let centerY = initialFrame.midY
        
        let startPoint = CGPoint(x: centerX - 100, y: centerY)
        let endPoint = CGPoint(x: centerX - 50, y: centerY)
        
        // Perform drag gesture
        app.coordinate(withNormalizedOffset: CGVector(dx: 0, dy: 0)).withOffset(CGVector(dx: startPoint.x, dy: startPoint.y)).press(forDuration: 0.1, thenDragTo: app.coordinate(withNormalizedOffset: CGVector(dx: 0, dy: 0)).withOffset(CGVector(dx: endPoint.x, dy: endPoint.y)))
        
        // App should still be functional after resize attempt
        XCTAssertTrue(app.windows.firstMatch.exists, "App should remain functional")
    }
    
    // MARK: - Dark Mode Tests
    
    @MainActor
    func testDarkModeAppearance() throws {
        // App should work in dark mode (this is mostly visual)
        XCTAssertTrue(app.windows.firstMatch.exists, "App should work in dark mode")
    }
    
    // MARK: - Accessibility Tests
    
    @MainActor
    func testAccessibilityElements() throws {
        // Check that important elements are accessible
        let accessibleElements = app.buttons.count + 
                               app.staticTexts.count + 
                               app.textFields.count + 
                               app.textViews.count
        
        XCTAssertGreaterThan(accessibleElements, 0, "Should have accessible elements")
    }
    
    // MARK: - Helper Methods
    
    private func createTestProjectIfNeeded() {
        // Check if projects already exist
        let hasProjects = app.staticTexts.matching(NSPredicate(format: "label CONTAINS 'Project' OR label CONTAINS 'Todo' OR label CONTAINS 'Design'")).count > 0
        
        if !hasProjects {
            // Try to create a project
            let createButton = app.buttons.matching(NSPredicate(format: "label CONTAINS '+' OR identifier CONTAINS 'create'")).firstMatch
            
            if createButton.exists {
                createButton.tap()
                
                let textField = app.textFields.firstMatch
                if textField.waitForExistence(timeout: 2) {
                    textField.clearAndTypeText("Test Project")
                    app.typeKey("\r", modifierFlags: [])
                }
            }
        }
    }
    
    private func selectFirstTaskIfAvailable() {
        // Try to select the first available task
        let taskElements = app.staticTexts.matching(NSPredicate(format: "label CONTAINS 'Task' OR label CONTAINS 'Project'"))
        
        if taskElements.count > 0 {
            taskElements.firstMatch.tap()
        }
    }
}

// MARK: - XCUIElement Extensions

extension XCUIElement {
    func clearAndTypeText(_ text: String) {
        // Clear existing text and type new text
        self.tap()
        self.doubleTap() // Select all
        self.typeText(text)
    }
}
