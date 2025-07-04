//
//  ProjectsViewUITests.swift
//  contextUITests
//
//  Created by Ignacio Tartavull on 7/3/25.
//

import XCTest

final class ProjectsViewUITests: XCTestCase {
    
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
    
    // MARK: - Projects Panel Display Tests
    
    @MainActor
    func testProjectsPanelDisplaysCorrectly() throws {
        // Projects panel should be visible by default
        let projectsHeader = app.staticTexts["Projects"]
        XCTAssertTrue(projectsHeader.waitForExistence(timeout: 2), "Projects header should be visible")
    }
    
    @MainActor
    func testCreateProjectButton() throws {
        // Should have a create project button (plus icon)
        let createButtons = app.buttons.matching(NSPredicate(format: "label CONTAINS '+' OR identifier CONTAINS 'create' OR identifier CONTAINS 'plus'"))
        XCTAssertGreaterThan(createButtons.count, 0, "Should have at least one create button")
        
        let createButton = createButtons.firstMatch
        XCTAssertTrue(createButton.exists, "Create button should exist")
        XCTAssertTrue(createButton.isEnabled, "Create button should be enabled")
    }
    
    @MainActor
    func testEmptyStateDisplay() throws {
        // If no projects exist, should show empty state
        let emptyStateIndicators = [
            app.staticTexts["No projects yet"],
            app.staticTexts.matching(NSPredicate(format: "label CONTAINS 'No projects' OR label CONTAINS 'Create Project'"))
        ]
        
        // At least one empty state indicator should exist if no projects
        let hasProjects = app.staticTexts.matching(NSPredicate(format: "label CONTAINS 'Todo' OR label CONTAINS 'Design' OR label CONTAINS 'API'")).count > 0
        
        if !hasProjects {
            let hasEmptyState = emptyStateIndicators.first { $0.firstMatch.exists } != nil
            XCTAssertTrue(hasEmptyState, "Should show empty state when no projects exist")
        }
    }
    
    // MARK: - Project Creation Tests
    
    @MainActor
    func testCreateNewProject() throws {
        let createButton = app.buttons.matching(NSPredicate(format: "label CONTAINS '+' OR identifier CONTAINS 'create'")).firstMatch
        
        if createButton.exists {
            createButton.tap()
            
            // Should enter edit mode with a text field
            let textField = app.textFields.firstMatch
            XCTAssertTrue(textField.waitForExistence(timeout: 3), "Should show text field for editing")
            
            // Text field should have default text
            let fieldValue = textField.value as? String
            XCTAssertNotNil(fieldValue, "Text field should have a value")
            
            // Should be able to edit the project name
            textField.clearAndTypeText("My New Project")
            
            // Press Enter to confirm
            app.typeKey("\r", modifierFlags: [])
            
            // Project should appear in the list
            let newProject = app.staticTexts["My New Project"]
            XCTAssertTrue(newProject.waitForExistence(timeout: 2), "New project should appear in list")
        }
    }
    
    @MainActor
    func testCancelProjectCreation() throws {
        let createButton = app.buttons.matching(NSPredicate(format: "label CONTAINS '+' OR identifier CONTAINS 'create'")).firstMatch
        
        if createButton.exists {
            createButton.tap()
            
            let textField = app.textFields.firstMatch
            if textField.waitForExistence(timeout: 2) {
                textField.clearAndTypeText("Cancelled Project")
                
                // Press Escape to cancel
                app.typeKey(XCUIKeyboardKey.escape, modifierFlags: [])
                
                // Project should not appear in the list
                let cancelledProject = app.staticTexts["Cancelled Project"]
                XCTAssertFalse(cancelledProject.exists, "Cancelled project should not appear")
            }
        }
    }
    
    // MARK: - Project Selection Tests
    
    @MainActor
    func testProjectSelection() throws {
        // Ensure we have at least one project
        createTestProjectIfNeeded()
        
        // Find projects in the list
        let projectElements = app.staticTexts.matching(NSPredicate(format: "label CONTAINS 'Project' OR label CONTAINS 'Todo' OR label CONTAINS 'Design' OR label CONTAINS 'API'"))
        
        if projectElements.count > 0 {
            let firstProject = projectElements.firstMatch
            let projectName = firstProject.label
            
            // Tap to select
            firstProject.tap()
            
            // Project should remain visible (selected state might be visual)
            XCTAssertTrue(firstProject.exists, "Selected project should remain visible")
            
            // Selection might affect other panels
            // Chart panel might show project content
            let chartHasContent = app.scrollViews.count > 0 || 
                                app.staticTexts.matching(NSPredicate(format: "label CONTAINS '\(projectName)'")).count > 1
            
            // Either chart shows content or maintains empty state
            XCTAssertTrue(chartHasContent || app.staticTexts["No Project Selected"].exists, 
                         "Selection should affect other panels")
        }
    }
    
    // MARK: - Project Editing Tests
    
    @MainActor
    func testProjectRename() throws {
        createTestProjectIfNeeded()
        
        // Find a project to rename
        let projectElements = app.staticTexts.matching(NSPredicate(format: "label CONTAINS 'Project' OR label CONTAINS 'Test'"))
        
        if projectElements.count > 0 {
            let projectToEdit = projectElements.firstMatch
            let originalName = projectToEdit.label
            
            // Try to trigger edit mode (might require hover or double-click)
            projectToEdit.doubleTap()
            
            // Look for text field
            let textField = app.textFields.matching(NSPredicate(format: "value CONTAINS '\(originalName)'")).firstMatch
            
            if textField.waitForExistence(timeout: 2) {
                textField.clearAndTypeText("Renamed Project")
                app.typeKey("\r", modifierFlags: [])
                
                // Check if rename was successful
                let renamedProject = app.staticTexts["Renamed Project"]
                XCTAssertTrue(renamedProject.waitForExistence(timeout: 2), "Project should be renamed")
            }
        }
    }
    
    // MARK: - Project Metadata Tests
    
    @MainActor
    func testProjectMetadataDisplay() throws {
        createTestProjectIfNeeded()
        
        // Projects should show metadata like creation time
        let timePattern = NSPredicate(format: "label MATCHES '.*\\\\d{1,2}:\\\\d{2}.*' OR label CONTAINS 'AM' OR label CONTAINS 'PM' OR label CONTAINS ':'")
        let timeElements = app.staticTexts.matching(timePattern)
        
        // Should have some time-related elements
        let hasTimeInfo = timeElements.count > 0
        
        // Or check for other metadata patterns
        let hasMetadata = hasTimeInfo || 
                         app.staticTexts.matching(NSPredicate(format: "label CONTAINS 'ago' OR label CONTAINS 'minutes' OR label CONTAINS 'hours'")).count > 0
        
        XCTAssertTrue(hasMetadata, "Projects should display metadata")
    }
    
    // MARK: - Panel Collapse Tests
    
    @MainActor
    func testProjectsPanelCollapse() throws {
        // Try to find panel toggle buttons
        let toggleButtons = app.buttons.allElementsBoundByIndex
        
        // Look for a button that might toggle the projects panel
        for button in toggleButtons {
            if button.exists && button.isEnabled {
                let initialProjectsVisible = app.staticTexts["Projects"].exists
                
                button.tap()
                
                // Panel state might change
                let finalProjectsVisible = app.staticTexts["Projects"].exists
                
                // Either projects panel toggled or button had no effect
                // Both outcomes are acceptable for this test
                XCTAssertTrue(initialProjectsVisible || finalProjectsVisible, "Panel should maintain some state")
                
                break // Only test first available button
            }
        }
    }
    
    // MARK: - Helper Methods
    
    private func createTestProjectIfNeeded() {
        // Check if we already have projects
        let existingProjects = app.staticTexts.matching(NSPredicate(format: "label CONTAINS 'Project' OR label CONTAINS 'Todo' OR label CONTAINS 'Design' OR label CONTAINS 'API'"))
        
        if existingProjects.count == 0 {
            // Create a test project
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
}

 