//
//  contextTests.swift
//  contextTests
//
//  Created by Ignacio Tartavull on 7/3/25.
//

import Testing
import Foundation
@testable import context

struct contextTests {
    
    // MARK: - Model Tests
    
    @Test func testMessageCreation() async throws {
        let message = Message(
            id: "test-id",
            role: .user,
            content: "Test message",
            timestamp: Date()
        )
        
        #expect(message.id == "test-id")
        #expect(message.role == .user)
        #expect(message.content == "Test message")
        #expect(message.timestamp != nil)
    }
    
    @Test func testMessageRoles() async throws {
        let userMessage = Message(id: "1", role: .user, content: "User", timestamp: Date())
        let assistantMessage = Message(id: "2", role: .assistant, content: "Assistant", timestamp: Date())
        
        #expect(userMessage.role == .user)
        #expect(assistantMessage.role == .assistant)
        #expect(Message.MessageRole.allCases.count == 2)
    }
    
    @Test func testConversationCreation() async throws {
        let conversation = Conversation()
        
        #expect(conversation.id.isEmpty == false)
        #expect(conversation.messages.isEmpty == true)
        #expect(conversation.lastActivity != nil)
    }
    
    @Test func testTaskCreation() async throws {
        let task = Task(
            title: "Test Task",
            description: "Test Description",
            nodeType: .original,
            position: Task.Position(x: 100, y: 200)
        )
        
        #expect(task.title == "Test Task")
        #expect(task.description == "Test Description")
        #expect(task.status == .pending)
        #expect(task.nodeType == .original)
        #expect(task.executionMode == .interactive)
        #expect(task.parentId == nil)
        #expect(task.childIds.isEmpty == true)
        #expect(task.position.x == 100)
        #expect(task.position.y == 200)
        #expect(task.conversation.messages.isEmpty == true)
    }
    
    @Test func testTaskWithParent() async throws {
        let parentTask = Task(title: "Parent", description: "Parent task")
        let childTask = Task(
            title: "Child",
            description: "Child task",
            nodeType: .spawn,
            parentId: parentTask.id
        )
        
        #expect(childTask.parentId == parentTask.id)
        #expect(childTask.nodeType == .spawn)
    }
    
    @Test func testTaskStatuses() async throws {
        let pendingTask = Task(title: "Pending", description: "")
        #expect(pendingTask.status == .pending)
        
        let statuses = Task.TaskStatus.allCases
        #expect(statuses.contains(.pending))
        #expect(statuses.contains(.active))
        #expect(statuses.contains(.completed))
        #expect(statuses.contains(.failed))
        #expect(statuses.count == 4)
    }
    
    @Test func testTaskNodeTypes() async throws {
        let originalTask = Task(title: "Original", description: "", nodeType: .original)
        let cloneTask = Task(title: "Clone", description: "", nodeType: .clone)
        let spawnTask = Task(title: "Spawn", description: "", nodeType: .spawn)
        
        #expect(originalTask.nodeType == .original)
        #expect(cloneTask.nodeType == .clone)
        #expect(spawnTask.nodeType == .spawn)
        
        let nodeTypes = Task.NodeType.allCases
        #expect(nodeTypes.count == 3)
    }
    
    @Test func testProjectCreation() async throws {
        let project = Project(title: "Test Project", description: "Test Description")
        
        #expect(project.title == "Test Project")
        #expect(project.description == "Test Description")
        #expect(project.status == .active)
        #expect(project.tasks.count == 1) // Should create root task
        #expect(project.rootTaskIds.count == 1)
        #expect(project.createdAt != nil)
        #expect(project.updatedAt != nil)
        
        // Check root task
        let rootTaskId = project.rootTaskIds.first!
        let rootTask = project.tasks[rootTaskId]!
        #expect(rootTask.title == "Test Project")
        #expect(rootTask.description == "Test Description")
        #expect(rootTask.nodeType == .original)
    }
    
    @Test func testProjectStatuses() async throws {
        let project = Project(title: "Test", description: "")
        #expect(project.status == .active)
        
        let statuses = Project.ProjectStatus.allCases
        #expect(statuses.contains(.active))
        #expect(statuses.contains(.pending))
        #expect(statuses.contains(.completed))
        #expect(statuses.contains(.failed))
        #expect(statuses.count == 4)
    }
    
    @Test func testUIStateDefaults() async throws {
        let uiState = UIState()
        
        #expect(uiState.showProjects == true)
        #expect(uiState.showChart == true)
        #expect(uiState.showChat == true)
        #expect(uiState.projectsCollapsed == false)
        #expect(uiState.projectsPanelSize == 30.0)
    }
    
    @Test func testAppStateCreation() async throws {
        let appState = AppState()
        
        #expect(appState.projects.isEmpty == true)
        #expect(appState.selectedProjectId == nil)
        #expect(appState.selectedTaskId == nil)
        #expect(appState.ui.showProjects == true)
        #expect(appState.ui.showChart == true)
        #expect(appState.ui.showChat == true)
    }
    
    @Test func testSampleAppState() async throws {
        let sampleState = AppState.sample
        
        #expect(sampleState.projects.count == 3)
        #expect(sampleState.selectedProjectId == nil)
        #expect(sampleState.selectedTaskId == nil)
        
        // Check that sample projects exist
        let projects = Array(sampleState.projects.values)
        let projectTitles = projects.map { $0.title }
        #expect(projectTitles.contains("Build Todo App"))
        #expect(projectTitles.contains("Design System"))
        #expect(projectTitles.contains("API Integration"))
    }
    
    // MARK: - Codable Tests
    
    @Test func testMessageCodable() async throws {
        let message = Message(
            id: "test-id",
            role: .user,
            content: "Test content",
            timestamp: Date()
        )
        
        let encoder = JSONEncoder()
        let decoder = JSONDecoder()
        
        let data = try encoder.encode(message)
        let decodedMessage = try decoder.decode(Message.self, from: data)
        
        #expect(decodedMessage.id == message.id)
        #expect(decodedMessage.role == message.role)
        #expect(decodedMessage.content == message.content)
    }
    
    @Test func testTaskCodable() async throws {
        let task = Task(
            title: "Test Task",
            description: "Test Description",
            nodeType: .spawn,
            position: Task.Position(x: 150, y: 250)
        )
        
        let encoder = JSONEncoder()
        let decoder = JSONDecoder()
        
        let data = try encoder.encode(task)
        let decodedTask = try decoder.decode(Task.self, from: data)
        
        #expect(decodedTask.title == task.title)
        #expect(decodedTask.description == task.description)
        #expect(decodedTask.nodeType == task.nodeType)
        #expect(decodedTask.position.x == task.position.x)
        #expect(decodedTask.position.y == task.position.y)
    }
    
    @Test func testProjectCodable() async throws {
        let project = Project(title: "Test Project", description: "Test Description")
        
        let encoder = JSONEncoder()
        let decoder = JSONDecoder()
        
        let data = try encoder.encode(project)
        let decodedProject = try decoder.decode(Project.self, from: data)
        
        #expect(decodedProject.title == project.title)
        #expect(decodedProject.description == project.description)
        #expect(decodedProject.status == project.status)
        #expect(decodedProject.tasks.count == project.tasks.count)
        #expect(decodedProject.rootTaskIds.count == project.rootTaskIds.count)
    }
    
    @Test func testAppStateCodable() async throws {
        let appState = AppState.sample
        
        let encoder = JSONEncoder()
        let decoder = JSONDecoder()
        
        let data = try encoder.encode(appState)
        let decodedAppState = try decoder.decode(AppState.self, from: data)
        
        #expect(decodedAppState.projects.count == appState.projects.count)
        #expect(decodedAppState.ui.showProjects == appState.ui.showProjects)
        #expect(decodedAppState.ui.showChart == appState.ui.showChart)
        #expect(decodedAppState.ui.showChat == appState.ui.showChat)
    }
}
