//
//  AppStateManagerTests.swift
//  contextTests
//
//  Created by Ignacio Tartavull on 7/3/25.
//

import Testing
import Foundation
import XCTest
@testable import context

@MainActor
final class AppStateManagerTests: XCTestCase {
    var appState: AppStateManager!
    
    override func setUpWithError() throws {
        appState = AppStateManager()
    }

    override func tearDownWithError() throws {
        appState = nil
    }

    // MARK: - UI State Tests
    
    func testPanelToggleButtons() throws {
        // Test initial state - chat should start minimized
        XCTAssertTrue(appState.state.ui.showProjects, "Projects panel should be visible by default")
        XCTAssertTrue(appState.state.ui.showChart, "Chart panel should be visible by default")
        XCTAssertFalse(appState.state.ui.showChat, "Chat panel should start minimized")
        
        // Test toggling chat panel on
        appState.updateUI(["showChat": true])
        XCTAssertTrue(appState.state.ui.showChat, "Chat panel should be visible after toggling on")
        
        // Test toggling chat panel off
        appState.updateUI(["showChat": false])
        XCTAssertFalse(appState.state.ui.showChat, "Chat panel should be hidden after toggling off")
        
        // Test toggling projects panel
        appState.updateUI(["showProjects": false])
        XCTAssertFalse(appState.state.ui.showProjects, "Projects panel should be hidden after toggling off")
        
        appState.updateUI(["showProjects": true])
        XCTAssertTrue(appState.state.ui.showProjects, "Projects panel should be visible after toggling on")
        
        // Test toggling chart panel
        appState.updateUI(["showChart": false])
        XCTAssertFalse(appState.state.ui.showChart, "Chart panel should be hidden after toggling off")
        
        appState.updateUI(["showChart": true])
        XCTAssertTrue(appState.state.ui.showChart, "Chart panel should be visible after toggling on")
    }
    
    func testMultiplePanelToggles() throws {
        // Test toggling multiple panels at once
        appState.updateUI([
            "showProjects": false,
            "showChart": false,
            "showChat": true
        ])
        
        XCTAssertFalse(appState.state.ui.showProjects, "Projects panel should be hidden")
        XCTAssertFalse(appState.state.ui.showChart, "Chart panel should be hidden")
        XCTAssertTrue(appState.state.ui.showChat, "Chat panel should be visible")
        
        // Test toggling all panels back on
        appState.updateUI([
            "showProjects": true,
            "showChart": true,
            "showChat": true
        ])
        
        XCTAssertTrue(appState.state.ui.showProjects, "Projects panel should be visible")
        XCTAssertTrue(appState.state.ui.showChart, "Chart panel should be visible")
        XCTAssertTrue(appState.state.ui.showChat, "Chat panel should be visible")
    }
    
    func testProjectsCollapsedState() throws {
        // Test projects panel collapse functionality
        XCTAssertFalse(appState.state.ui.projectsCollapsed, "Projects panel should not be collapsed by default")
        
        appState.updateUI(["projectsCollapsed": true])
        XCTAssertTrue(appState.state.ui.projectsCollapsed, "Projects panel should be collapsed")
        
        appState.updateUI(["projectsCollapsed": false])
        XCTAssertFalse(appState.state.ui.projectsCollapsed, "Projects panel should be expanded")
    }

    // MARK: - Project Management Tests
    
    func testCreateProject() throws {
        let initialCount = appState.state.projects.count
        
        appState.createProject(title: "Test Project", description: "Test Description")
        
        XCTAssertEqual(appState.state.projects.count, initialCount + 1, "Should have one more project")
        XCTAssertNotNil(appState.state.selectedProjectId, "Should have selected the new project")
        
        let selectedProject = appState.selectedProject
        XCTAssertNotNil(selectedProject, "Should be able to get selected project")
        XCTAssertEqual(selectedProject?.title, "Test Project", "Project title should match")
        XCTAssertEqual(selectedProject?.description, "Test Description", "Project description should match")
    }
    
    func testUpdateProject() throws {
        appState.createProject(title: "Original Title", description: "Original Description")
        
        guard let projectId = appState.state.selectedProjectId else {
            XCTFail("Should have a selected project")
            return
        }
        
        appState.updateProject(projectId: projectId, updates: [
            "title": "Updated Title",
            "description": "Updated Description"
        ])
        
        let updatedProject = appState.selectedProject
        XCTAssertEqual(updatedProject?.title, "Updated Title", "Title should be updated")
        XCTAssertEqual(updatedProject?.description, "Updated Description", "Description should be updated")
    }
    
    func testDeleteProject() throws {
        appState.createProject(title: "Test Project", description: "Test Description")
        
        guard let projectId = appState.state.selectedProjectId else {
            XCTFail("Should have a selected project")
            return
        }
        
        let initialCount = appState.state.projects.count
        
        appState.deleteProject(projectId)
        
        XCTAssertEqual(appState.state.projects.count, initialCount - 1, "Should have one less project")
        XCTAssertNil(appState.state.selectedProjectId, "Should not have a selected project")
        XCTAssertNil(appState.selectedProject, "Should not be able to get selected project")
    }

    // MARK: - Auto-selection Tests
    
    func testAutoSelectionOnEmptyState() throws {
        // Create a new AppStateManager with empty state
        let emptyAppState = AppStateManager()
        emptyAppState.state = AppState() // Start with empty state
        
        // Trigger initialization
        emptyAppState.initializeProjectSelection()
        
        // Should have created a project and selected it
        XCTAssertFalse(emptyAppState.state.projects.isEmpty, "Should have created a project")
        XCTAssertNotNil(emptyAppState.state.selectedProjectId, "Should have selected the created project")
        XCTAssertNotNil(emptyAppState.state.selectedTaskId, "Should have selected the root task")
        
        let selectedProject = emptyAppState.selectedProject
        XCTAssertEqual(selectedProject?.title, "New Project", "Should have created project with default title")
    }
    
    func testAutoSelectionWithExistingProjects() throws {
        // Create projects manually
        appState.createProject(title: "First Project", description: "First")
        appState.createProject(title: "Second Project", description: "Second")
        
        // Clear selection
        appState.state.selectedProjectId = nil
        appState.state.selectedTaskId = nil
        
        // Trigger initialization
        appState.initializeProjectSelection()
        
        // Should have selected the first project (by creation date)
        XCTAssertNotNil(appState.state.selectedProjectId, "Should have selected a project")
        XCTAssertNotNil(appState.state.selectedTaskId, "Should have selected the root task")
        
        let selectedProject = appState.selectedProject
        XCTAssertEqual(selectedProject?.title, "First Project", "Should have selected the first project")
    }
    
    func testAutoSelectionAfterDeletingLastProject() throws {
        // Create a single project
        appState.createProject(title: "Only Project", description: "Only")
        
        guard let projectId = appState.state.selectedProjectId else {
            XCTFail("Should have a selected project")
            return
        }
        
        // Delete the only project
        appState.deleteProject(projectId)
        
        // Should have created a new project and selected it
        XCTAssertFalse(appState.state.projects.isEmpty, "Should have created a new project")
        XCTAssertNotNil(appState.state.selectedProjectId, "Should have selected the new project")
        XCTAssertNotNil(appState.state.selectedTaskId, "Should have selected the root task")
        
        let selectedProject = appState.selectedProject
        XCTAssertEqual(selectedProject?.title, "New Project", "Should have created project with default title")
    }
    
    func testAutoSelectionAfterDeletingOneOfManyProjects() throws {
        // Create multiple projects
        appState.createProject(title: "First Project", description: "First")
        let firstProjectId = appState.state.selectedProjectId!
        
        appState.createProject(title: "Second Project", description: "Second")
        let secondProjectId = appState.state.selectedProjectId!
        
        // Delete the currently selected project (second)
        appState.deleteProject(secondProjectId)
        
        // Should have selected the remaining project (first)
        XCTAssertNotNil(appState.state.selectedProjectId, "Should have selected a project")
        XCTAssertEqual(appState.state.selectedProjectId, firstProjectId, "Should have selected the first project")
        XCTAssertNotNil(appState.state.selectedTaskId, "Should have selected the root task")
        
        let selectedProject = appState.selectedProject
        XCTAssertEqual(selectedProject?.title, "First Project", "Should have selected the first project")
    }

    // MARK: - Task Management Tests
    
    func testCreateTask() throws {
        appState.createProject(title: "Test Project", description: "Test Description")
        
        guard let projectId = appState.state.selectedProjectId else {
            XCTFail("Should have a selected project")
            return
        }
        
        let initialTaskCount = appState.getProjectTasks(projectId).count
        
        appState.createTask(
            projectId: projectId,
            title: "Test Task",
            description: "Test Task Description",
            nodeType: .original
        )
        
        let tasks = appState.getProjectTasks(projectId)
        XCTAssertEqual(tasks.count, initialTaskCount + 1, "Should have one more task")
        
        let selectedTask = appState.selectedTask
        XCTAssertNotNil(selectedTask, "Should have selected the new task")
        XCTAssertEqual(selectedTask?.title, "Test Task", "Task title should match")
        XCTAssertEqual(selectedTask?.description, "Test Task Description", "Task description should match")
        XCTAssertEqual(selectedTask?.nodeType, .original, "Task node type should match")
    }
    
    func testUpdateTask() throws {
        appState.createProject(title: "Test Project", description: "Test Description")
        
        guard let projectId = appState.state.selectedProjectId else {
            XCTFail("Should have a selected project")
            return
        }
        
        appState.createTask(
            projectId: projectId,
            title: "Original Task",
            description: "Original Description",
            nodeType: .original
        )
        
        guard let taskId = appState.state.selectedTaskId else {
            XCTFail("Should have a selected task")
            return
        }
        
        appState.updateTask(projectId: projectId, taskId: taskId, updates: [
            "title": "Updated Task",
            "description": "Updated Description"
        ])
        
        let updatedTask = appState.selectedTask
        XCTAssertEqual(updatedTask?.title, "Updated Task", "Task title should be updated")
        XCTAssertEqual(updatedTask?.description, "Updated Description", "Task description should be updated")
    }
    
    func testDeleteTask() throws {
        appState.createProject(title: "Test Project", description: "Test Description")
        
        guard let projectId = appState.state.selectedProjectId else {
            XCTFail("Should have a selected project")
            return
        }
        
        appState.createTask(
            projectId: projectId,
            title: "Test Task",
            description: "Test Description",
            nodeType: .original
        )
        
        guard let taskId = appState.state.selectedTaskId else {
            XCTFail("Should have a selected task")
            return
        }
        
        let initialTaskCount = appState.getProjectTasks(projectId).count
        
        appState.deleteTask(projectId: projectId, taskId: taskId)
        
        let tasks = appState.getProjectTasks(projectId)
        XCTAssertEqual(tasks.count, initialTaskCount - 1, "Should have one less task")
        XCTAssertNil(appState.state.selectedTaskId, "Should not have a selected task")
        XCTAssertNil(appState.selectedTask, "Should not be able to get selected task")
    }

    // MARK: - Message Management Tests
    
    func testAddMessage() throws {
        appState.createProject(title: "Test Project", description: "Test Description")
        
        guard let projectId = appState.state.selectedProjectId else {
            XCTFail("Should have a selected project")
            return
        }
        
        appState.createTask(
            projectId: projectId,
            title: "Test Task",
            description: "Test Description",
            nodeType: .original
        )
        
        guard let taskId = appState.state.selectedTaskId else {
            XCTFail("Should have a selected task")
            return
        }
        
        let message = Message(
            id: "test-message",
            role: .user,
            content: "Test message content",
            timestamp: Date()
        )
        
        appState.addMessage(projectId: projectId, taskId: taskId, message: message)
        
        let task = appState.selectedTask
        XCTAssertEqual(task?.conversation.messages.count, 1, "Should have one message")
        XCTAssertEqual(task?.conversation.messages.first?.content, "Test message content", "Message content should match")
        XCTAssertEqual(task?.conversation.messages.first?.role, .user, "Message role should match")
    }
} 