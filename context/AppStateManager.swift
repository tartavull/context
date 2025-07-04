import Foundation
import SwiftUI

@MainActor
class AppStateManager: ObservableObject {
    @Published var state: AppState
    
    init() {
        self.state = AppState()
        
        // Auto-select first project or create empty project if none exists
        DispatchQueue.main.async {
            self.initializeProjectSelection()
        }
    }
    
    // MARK: - Project Selection Initialization
    
    func initializeProjectSelection() {
        if state.projects.isEmpty {
            // No projects exist, create an empty project
            createProject(title: "New Project", description: "Get started with your first project")
        } else if state.selectedProjectId == nil {
            // Projects exist but none selected, select the first one
            let sortedProjects = state.projects.values.sorted { $0.createdAt < $1.createdAt }
            if let firstProject = sortedProjects.first {
                selectProject(firstProject.id)
                
                // Also select the root task if available
                if let rootTaskId = firstProject.rootTaskIds.first {
                    state.selectedTaskId = rootTaskId
                }
            }
        }
    }
    
    // MARK: - Project Management
    
    func selectProject(_ projectId: String?) {
        state.selectedProjectId = projectId
        state.selectedTaskId = nil // Reset selected task when changing projects
    }
    
    func selectTask(_ taskId: String?) {
        state.selectedTaskId = taskId
    }
    
    func createProject(title: String, description: String) {
        let newProject = Project(title: title, description: description)
        state.projects[newProject.id] = newProject
        state.selectedProjectId = newProject.id
        
        // Auto-select the root task
        if let rootTaskId = newProject.rootTaskIds.first {
            state.selectedTaskId = rootTaskId
        }
    }
    
    func updateProject(projectId: String, updates: [String: Any]) {
        guard var project = state.projects[projectId] else { return }
        
        if let title = updates["title"] as? String {
            project.title = title
        }
        if let description = updates["description"] as? String {
            project.description = description
        }
        if let status = updates["status"] as? String,
           let projectStatus = Project.ProjectStatus(rawValue: status) {
            project.status = projectStatus
        }
        
        project.updatedAt = Date()
        state.projects[projectId] = project
    }
    
    func deleteProject(_ projectId: String) {
        state.projects.removeValue(forKey: projectId)
        if state.selectedProjectId == projectId {
            state.selectedProjectId = nil
            state.selectedTaskId = nil
            
            // Auto-select another project or create a new one
            if state.projects.isEmpty {
                // No projects left, create a new empty project
                createProject(title: "New Project", description: "Get started with your first project")
            } else {
                // Select the first available project
                let sortedProjects = state.projects.values.sorted { $0.createdAt < $1.createdAt }
                if let firstProject = sortedProjects.first {
                    selectProject(firstProject.id)
                    
                    // Also select the root task if available
                    if let rootTaskId = firstProject.rootTaskIds.first {
                        state.selectedTaskId = rootTaskId
                    }
                }
            }
        }
    }
    
    // MARK: - Task Management
    
    func createTask(projectId: String, title: String, description: String, nodeType: Task.NodeType, parentId: String? = nil, position: Task.Position = Task.Position(x: 100, y: 100)) {
        guard var project = state.projects[projectId] else { return }
        
        let newTask = Task(title: title, description: description, nodeType: nodeType, parentId: parentId, position: position)
        
        // Update parent task's childIds if this is a child task
        if let parentId = parentId, var parentTask = project.tasks[parentId] {
            parentTask.childIds.append(newTask.id)
            parentTask.updatedAt = Date()
            project.tasks[parentId] = parentTask
        }
        
        project.tasks[newTask.id] = newTask
        
        // Update root task IDs if this is a root task
        if parentId == nil {
            project.rootTaskIds.append(newTask.id)
        }
        
        // Recalculate layout
        recalculateLayout(for: &project)
        
        project.updatedAt = Date()
        state.projects[projectId] = project
        state.selectedTaskId = newTask.id
    }
    
    func updateTask(projectId: String, taskId: String, updates: [String: Any]) {
        guard var project = state.projects[projectId],
              var task = project.tasks[taskId] else { return }
        
        if let title = updates["title"] as? String {
            task.title = title
        }
        if let description = updates["description"] as? String {
            task.description = description
        }
        if let status = updates["status"] as? String,
           let taskStatus = Task.TaskStatus(rawValue: status) {
            task.status = taskStatus
        }
        if let position = updates["position"] as? Task.Position {
            task.position = position
        }
        
        task.updatedAt = Date()
        project.tasks[taskId] = task
        project.updatedAt = Date()
        state.projects[projectId] = project
    }
    
    func deleteTask(projectId: String, taskId: String) {
        guard var project = state.projects[projectId],
              let task = project.tasks[taskId] else { return }
        
        // Remove from parent's childIds
        if let parentId = task.parentId, var parentTask = project.tasks[parentId] {
            parentTask.childIds.removeAll { $0 == taskId }
            parentTask.updatedAt = Date()
            project.tasks[parentId] = parentTask
        }
        
        // Remove from root task IDs
        project.rootTaskIds.removeAll { $0 == taskId }
        
        // Remove the task
        project.tasks.removeValue(forKey: taskId)
        
        project.updatedAt = Date()
        state.projects[projectId] = project
        
        if state.selectedTaskId == taskId {
            state.selectedTaskId = nil
        }
    }
    
    func cloneTask(projectId: String, taskId: String) {
        guard var project = state.projects[projectId],
              let originalTask = project.tasks[taskId] else { return }
        
        let clonedTask = Task(
            title: "\(originalTask.title) (Clone)",
            description: originalTask.description,
            nodeType: .clone,
            parentId: originalTask.parentId,
            position: originalTask.position
        )
        
        // Update parent task's childIds if this is a child task
        if let parentId = originalTask.parentId, var parentTask = project.tasks[parentId] {
            parentTask.childIds.append(clonedTask.id)
            parentTask.updatedAt = Date()
            project.tasks[parentId] = parentTask
        }
        
        project.tasks[clonedTask.id] = clonedTask
        
        // Update root task IDs if this is a root task
        if originalTask.parentId == nil {
            project.rootTaskIds.append(clonedTask.id)
        }
        
        // Recalculate layout
        recalculateLayout(for: &project)
        
        project.updatedAt = Date()
        state.projects[projectId] = project
        state.selectedTaskId = clonedTask.id
    }
    
    func spawnTask(projectId: String, parentTaskId: String, title: String, description: String) {
        guard var project = state.projects[projectId],
              var parentTask = project.tasks[parentTaskId] else { return }
        
        let spawnedTask = Task(
            title: title,
            description: description,
            nodeType: .spawn,
            parentId: parentTaskId,
            position: parentTask.position
        )
        
        parentTask.childIds.append(spawnedTask.id)
        parentTask.updatedAt = Date()
        project.tasks[parentTaskId] = parentTask
        project.tasks[spawnedTask.id] = spawnedTask
        
        // Recalculate layout
        recalculateLayout(for: &project)
        
        project.updatedAt = Date()
        state.projects[projectId] = project
        state.selectedTaskId = spawnedTask.id
    }
    
    // MARK: - Message Management
    
    func addMessage(projectId: String, taskId: String, message: Message) {
        guard var project = state.projects[projectId],
              var task = project.tasks[taskId] else { return }
        
        task.conversation.messages.append(message)
        task.conversation.lastActivity = Date()
        task.updatedAt = Date()
        
        project.tasks[taskId] = task
        project.updatedAt = Date()
        state.projects[projectId] = project
    }
    
    // MARK: - UI State Management
    
    func updateUI(_ updates: [String: Any]) {
        // showProjects is always true - no toggle needed
        // showChart is always true - no toggle needed
        // showChat is always true - no toggle needed
        if let projectsCollapsed = updates["projectsCollapsed"] as? Bool {
            state.ui.projectsCollapsed = projectsCollapsed
        }
        if let projectsPanelSize = updates["projectsPanelSize"] as? Double {
            state.ui.projectsPanelSize = projectsPanelSize
        }
    }
    
    // MARK: - Getters
    
    var selectedProject: Project? {
        guard let projectId = state.selectedProjectId else { return nil }
        return state.projects[projectId]
    }
    
    var selectedTask: Task? {
        guard let projectId = state.selectedProjectId,
              let taskId = state.selectedTaskId,
              let project = state.projects[projectId] else { return nil }
        return project.tasks[taskId]
    }
    
    func getProjectTasks(_ projectId: String) -> [Task] {
        guard let project = state.projects[projectId] else { return [] }
        return Array(project.tasks.values)
    }
    
    // MARK: - Layout Calculation
    
    private func recalculateLayout(for project: inout Project) {
        let positions = calculateTreeLayout(
            tasks: project.tasks,
            rootTaskIds: project.rootTaskIds
        )
        
        for (taskId, position) in positions {
            if var task = project.tasks[taskId] {
                task.position = position
                task.updatedAt = Date()
                project.tasks[taskId] = task
            }
        }
    }
    
    private func calculateTreeLayout(
        tasks: [String: Task],
        rootTaskIds: [String],
        columnWidth: Double = 280,
        nodeHeight: Double = 160,
        verticalSpacing: Double = 20,
        startX: Double = 50,
        startY: Double = 50
    ) -> [String: Task.Position] {
        var positions: [String: Task.Position] = [:]
        
        // Build tree structure by levels
        var levels: [[String]] = []
        var visited: Set<String> = []
        
        // BFS to organize nodes by level
        var queue: [(taskId: String, level: Int)] = []
        
        // Start with root tasks
        for rootId in rootTaskIds {
            queue.append((taskId: rootId, level: 0))
        }
        
        while !queue.isEmpty {
            let (taskId, level) = queue.removeFirst()
            
            if visited.contains(taskId) { continue }
            visited.insert(taskId)
            
            guard let task = tasks[taskId] else { continue }
            
            // Ensure we have enough levels
            while levels.count <= level {
                levels.append([])
            }
            
            levels[level].append(taskId)
            
            // Add children to queue
            for childId in task.childIds {
                if !visited.contains(childId) {
                    queue.append((taskId: childId, level: level + 1))
                }
            }
        }
        
        // Calculate positions for each level
        for (levelIndex, levelTasks) in levels.enumerated() {
            let x = startX + (Double(levelIndex) * columnWidth)
            
            // Calculate total height needed for this level
            let totalNodesHeight = Double(levelTasks.count) * nodeHeight
            let totalSpacingHeight = Double(levelTasks.count - 1) * verticalSpacing
            let totalHeight = totalNodesHeight + totalSpacingHeight
            
            // Start Y position to center the level vertically
            var currentY = startY
            if levelTasks.count > 1 {
                // If we have multiple nodes, distribute them evenly
                currentY = max(startY, 200 - (totalHeight / 2))
            } else {
                // Single node, center it around y=200
                currentY = 200 - (nodeHeight / 2)
            }
            
            // Position each task in this level
            for (taskIndex, taskId) in levelTasks.enumerated() {
                positions[taskId] = Task.Position(
                    x: x,
                    y: currentY + (Double(taskIndex) * (nodeHeight + verticalSpacing))
                )
            }
        }
        
        return positions
    }
} 