//
//  AppStateManagerTests.swift
//  contextTests
//
//  Created by Ignacio Tartavull on 7/3/25.
//

import Testing
import Foundation
@testable import context

@MainActor
struct AppStateManagerTests {
    
    // MARK: - Setup Helper
    
    func createTestAppStateManager() -> AppStateManager {
        let manager = AppStateManager()
        // Start with empty state for predictable testing
        manager.state = AppState()
        return manager
    }
    
    // MARK: - Project Management Tests
    
    @Test func testCreateProject() async throws {
        let manager = createTestAppStateManager()
        
        #expect(manager.state.projects.isEmpty)
        #expect(manager.state.selectedProjectId == nil)
        
        manager.createProject(title: "Test Project", description: "Test Description")
        
        #expect(manager.state.projects.count == 1)
        #expect(manager.state.selectedProjectId != nil)
        
        let project = manager.selectedProject!
        #expect(project.title == "Test Project")
        #expect(project.description == "Test Description")
        #expect(project.status == .active)
        #expect(project.tasks.count == 1) // Root task created
        #expect(project.rootTaskIds.count == 1)
    }
    
    @Test func testSelectProject() async throws {
        let manager = createTestAppStateManager()
        
        manager.createProject(title: "Project 1", description: "Description 1")
        let project1Id = manager.state.selectedProjectId!
        
        manager.createProject(title: "Project 2", description: "Description 2")
        let project2Id = manager.state.selectedProjectId!
        
        // Should be on project 2 now
        #expect(manager.state.selectedProjectId == project2Id)
        
        // Select project 1
        manager.selectProject(project1Id)
        #expect(manager.state.selectedProjectId == project1Id)
        #expect(manager.state.selectedTaskId == nil) // Task should be reset
        
        // Select nil
        manager.selectProject(nil)
        #expect(manager.state.selectedProjectId == nil)
    }
    
    @Test func testUpdateProject() async throws {
        let manager = createTestAppStateManager()
        
        manager.createProject(title: "Original Title", description: "Original Description")
        let projectId = manager.state.selectedProjectId!
        
        manager.updateProject(projectId: projectId, updates: [
            "title": "Updated Title",
            "description": "Updated Description",
            "status": "completed"
        ])
        
        let project = manager.state.projects[projectId]!
        #expect(project.title == "Updated Title")
        #expect(project.description == "Updated Description")
        #expect(project.status == .completed)
    }
    
    @Test func testDeleteProject() async throws {
        let manager = createTestAppStateManager()
        
        manager.createProject(title: "Project to Delete", description: "Description")
        let projectId = manager.state.selectedProjectId!
        
        #expect(manager.state.projects.count == 1)
        #expect(manager.state.selectedProjectId == projectId)
        
        manager.deleteProject(projectId)
        
        #expect(manager.state.projects.isEmpty)
        #expect(manager.state.selectedProjectId == nil)
        #expect(manager.state.selectedTaskId == nil)
    }
    
    // MARK: - Task Management Tests
    
    @Test func testCreateTask() async throws {
        let manager = createTestAppStateManager()
        
        manager.createProject(title: "Test Project", description: "Description")
        let projectId = manager.state.selectedProjectId!
        
        let initialTaskCount = manager.state.projects[projectId]!.tasks.count
        
        manager.createTask(
            projectId: projectId,
            title: "New Task",
            description: "New Task Description",
            nodeType: .spawn,
            position: Task.Position(x: 300, y: 400)
        )
        
        let project = manager.state.projects[projectId]!
        #expect(project.tasks.count == initialTaskCount + 1)
        #expect(manager.state.selectedTaskId != nil)
        
        let newTask = manager.selectedTask!
        #expect(newTask.title == "New Task")
        #expect(newTask.description == "New Task Description")
        #expect(newTask.nodeType == .spawn)
        #expect(newTask.position.x == 300)
        #expect(newTask.position.y == 400)
    }
    
    @Test func testCreateChildTask() async throws {
        let manager = createTestAppStateManager()
        
        manager.createProject(title: "Test Project", description: "Description")
        let projectId = manager.state.selectedProjectId!
        let project = manager.state.projects[projectId]!
        let parentTaskId = project.rootTaskIds.first!
        
        manager.createTask(
            projectId: projectId,
            title: "Child Task",
            description: "Child Description",
            nodeType: .clone,
            parentId: parentTaskId,
            position: Task.Position(x: 500, y: 600)
        )
        
        let updatedProject = manager.state.projects[projectId]!
        let parentTask = updatedProject.tasks[parentTaskId]!
        let childTask = manager.selectedTask!
        
        #expect(parentTask.childIds.contains(childTask.id))
        #expect(childTask.parentId == parentTaskId)
        #expect(childTask.nodeType == .clone)
    }
    
    @Test func testUpdateTask() async throws {
        let manager = createTestAppStateManager()
        
        manager.createProject(title: "Test Project", description: "Description")
        let projectId = manager.state.selectedProjectId!
        let project = manager.state.projects[projectId]!
        let taskId = project.rootTaskIds.first!
        
        manager.updateTask(projectId: projectId, taskId: taskId, updates: [
            "title": "Updated Task Title",
            "status": "completed",
            "position": Task.Position(x: 700, y: 800)
        ])
        
        let updatedTask = manager.state.projects[projectId]!.tasks[taskId]!
        #expect(updatedTask.title == "Updated Task Title")
        #expect(updatedTask.status == .completed)
        #expect(updatedTask.position.x == 700)
        #expect(updatedTask.position.y == 800)
    }
    
    @Test func testDeleteTask() async throws {
        let manager = createTestAppStateManager()
        
        manager.createProject(title: "Test Project", description: "Description")
        let projectId = manager.state.selectedProjectId!
        let project = manager.state.projects[projectId]!
        let parentTaskId = project.rootTaskIds.first!
        
        // Create a child task
        manager.createTask(
            projectId: projectId,
            title: "Child Task",
            description: "Child Description",
            nodeType: .spawn,
            parentId: parentTaskId
        )
        let childTaskId = manager.state.selectedTaskId!
        
        // Verify child was added
        let parentTask = manager.state.projects[projectId]!.tasks[parentTaskId]!
        #expect(parentTask.childIds.contains(childTaskId))
        
        // Delete the child task
        manager.deleteTask(projectId: projectId, taskId: childTaskId)
        
        // Verify child was removed
        let updatedProject = manager.state.projects[projectId]!
        let updatedParentTask = updatedProject.tasks[parentTaskId]!
        #expect(!updatedParentTask.childIds.contains(childTaskId))
        #expect(updatedProject.tasks[childTaskId] == nil)
        #expect(manager.state.selectedTaskId == nil)
    }
    
    @Test func testCloneTask() async throws {
        let manager = createTestAppStateManager()
        
        manager.createProject(title: "Test Project", description: "Description")
        let projectId = manager.state.selectedProjectId!
        let project = manager.state.projects[projectId]!
        let originalTaskId = project.rootTaskIds.first!
        
        let initialTaskCount = project.tasks.count
        
        manager.cloneTask(projectId: projectId, taskId: originalTaskId)
        
        let updatedProject = manager.state.projects[projectId]!
        #expect(updatedProject.tasks.count == initialTaskCount + 1)
        
        let clonedTask = manager.selectedTask!
        let originalTask = updatedProject.tasks[originalTaskId]!
        
        #expect(clonedTask.title.contains("Clone"))
        #expect(clonedTask.description == originalTask.description)
        #expect(clonedTask.nodeType == .clone)
        #expect(clonedTask.parentId == originalTask.parentId)
    }
    
    @Test func testSpawnTask() async throws {
        let manager = createTestAppStateManager()
        
        manager.createProject(title: "Test Project", description: "Description")
        let projectId = manager.state.selectedProjectId!
        let project = manager.state.projects[projectId]!
        let parentTaskId = project.rootTaskIds.first!
        
        manager.spawnTask(
            projectId: projectId,
            parentTaskId: parentTaskId,
            title: "Spawned Task",
            description: "Spawned Description"
        )
        
        let updatedProject = manager.state.projects[projectId]!
        let parentTask = updatedProject.tasks[parentTaskId]!
        let spawnedTask = manager.selectedTask!
        
        #expect(parentTask.childIds.contains(spawnedTask.id))
        #expect(spawnedTask.parentId == parentTaskId)
        #expect(spawnedTask.title == "Spawned Task")
        #expect(spawnedTask.description == "Spawned Description")
        #expect(spawnedTask.nodeType == .spawn)
    }
    
    // MARK: - Message Management Tests
    
    @Test func testAddMessage() async throws {
        let manager = createTestAppStateManager()
        
        manager.createProject(title: "Test Project", description: "Description")
        let projectId = manager.state.selectedProjectId!
        let project = manager.state.projects[projectId]!
        let taskId = project.rootTaskIds.first!
        
        let message = Message(
            id: "test-message",
            role: .user,
            content: "Test message content",
            timestamp: Date()
        )
        
        #expect(manager.state.projects[projectId]!.tasks[taskId]!.conversation.messages.isEmpty)
        
        manager.addMessage(projectId: projectId, taskId: taskId, message: message)
        
        let updatedTask = manager.state.projects[projectId]!.tasks[taskId]!
        #expect(updatedTask.conversation.messages.count == 1)
        #expect(updatedTask.conversation.messages.first!.content == "Test message content")
        #expect(updatedTask.conversation.lastActivity != nil)
    }
    
    // MARK: - UI State Tests
    
    @Test func testUpdateUI() async throws {
        let manager = createTestAppStateManager()
        
        #expect(manager.state.ui.showProjects == true)
        #expect(manager.state.ui.showChart == true)
        #expect(manager.state.ui.showChat == true)
        #expect(manager.state.ui.projectsCollapsed == false)
        #expect(manager.state.ui.projectsPanelSize == 30.0)
        
        manager.updateUI([
            "showProjects": false,
            "showChart": false,
            "projectsCollapsed": true,
            "projectsPanelSize": 25.0
        ])
        
        #expect(manager.state.ui.showProjects == false)
        #expect(manager.state.ui.showChart == false)
        #expect(manager.state.ui.showChat == true) // Not updated
        #expect(manager.state.ui.projectsCollapsed == true)
        #expect(manager.state.ui.projectsPanelSize == 25.0)
    }
    
    // MARK: - Getter Tests
    
    @Test func testSelectedProjectGetter() async throws {
        let manager = createTestAppStateManager()
        
        #expect(manager.selectedProject == nil)
        
        manager.createProject(title: "Test Project", description: "Description")
        #expect(manager.selectedProject != nil)
        #expect(manager.selectedProject!.title == "Test Project")
        
        manager.selectProject(nil)
        #expect(manager.selectedProject == nil)
    }
    
    @Test func testSelectedTaskGetter() async throws {
        let manager = createTestAppStateManager()
        
        #expect(manager.selectedTask == nil)
        
        manager.createProject(title: "Test Project", description: "Description")
        let projectId = manager.state.selectedProjectId!
        let project = manager.state.projects[projectId]!
        let taskId = project.rootTaskIds.first!
        
        manager.selectTask(taskId)
        #expect(manager.selectedTask != nil)
        #expect(manager.selectedTask!.id == taskId)
        
        manager.selectTask(nil)
        #expect(manager.selectedTask == nil)
    }
    
    @Test func testGetProjectTasks() async throws {
        let manager = createTestAppStateManager()
        
        manager.createProject(title: "Test Project", description: "Description")
        let projectId = manager.state.selectedProjectId!
        
        let tasks = manager.getProjectTasks(projectId)
        #expect(tasks.count == 1) // Root task
        
        // Add another task
        manager.createTask(
            projectId: projectId,
            title: "Another Task",
            description: "Description",
            nodeType: .spawn
        )
        
        let updatedTasks = manager.getProjectTasks(projectId)
        #expect(updatedTasks.count == 2)
        
        // Test with non-existent project
        let emptyTasks = manager.getProjectTasks("non-existent")
        #expect(emptyTasks.isEmpty)
    }
} 