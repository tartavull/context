import Foundation
import SwiftUI

@MainActor
class AppStateManager: ObservableObject {
    @Published var state: AppState

    init() {
        self.state = AppState.sample

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

    func createTask(
        projectId: String,
        title: String,
        description: String,
        nodeType: ProjectTask.NodeType,
        parentId: String? = nil,
        position: ProjectTask.Position = ProjectTask.Position(x: 100, y: 100)
    ) {
        guard var project = state.projects[projectId] else { return }

        let newTask = ProjectTask(
            title: title,
            description: description,
            nodeType: nodeType,
            parentId: parentId,
            position: position
        )

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
           let taskStatus = ProjectTask.TaskStatus(rawValue: status) {
            task.status = taskStatus
        }
        if let position = updates["position"] as? ProjectTask.Position {
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

        let clonedTask = ProjectTask(
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

        let spawnedTask = ProjectTask(
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
        if let showProjects = updates["showProjects"] as? Bool {
            state.ui.showProjects = showProjects
        }
        if let showChart = updates["showChart"] as? Bool {
            state.ui.showChart = showChart
        }
        if let showChat = updates["showChat"] as? Bool {
            state.ui.showChat = showChat
        }
        if let projectsCollapsed = updates["projectsCollapsed"] as? Bool {
            state.ui.projectsCollapsed = projectsCollapsed
        }
        if let projectsPanelSize = updates["projectsPanelSize"] as? Double {
            state.ui.projectsPanelSize = projectsPanelSize
        }
        if let templatesDrawerOpen = updates["templatesDrawerOpen"] as? Bool {
            state.ui.templatesDrawerOpen = templatesDrawerOpen
        }
        if let imagesDrawerOpen = updates["imagesDrawerOpen"] as? Bool {
            state.ui.imagesDrawerOpen = imagesDrawerOpen
        }
        if let modelsDrawerOpen = updates["modelsDrawerOpen"] as? Bool {
            state.ui.modelsDrawerOpen = modelsDrawerOpen
        }
        if let inputViewFrame = updates["inputViewFrame"] as? CGRect {
            state.ui.inputViewFrame = inputViewFrame
        }
        if let selectedModel = updates["selectedModel"] as? String {
            state.ui.selectedModel = selectedModel
        }
        if let editingTemplateId = updates["editingTemplateId"] as? String? {
            state.ui.editingTemplateId = editingTemplateId
        }
    }

    // MARK: - Drawer State Management
    
    func toggleDrawer(_ drawerType: DrawerType) {
        switch drawerType {
        case .templates:
            let newState = !state.ui.templatesDrawerOpen
            updateUI([
                "templatesDrawerOpen": newState,
                "imagesDrawerOpen": false,
                "modelsDrawerOpen": false
            ])
        case .images:
            let newState = !state.ui.imagesDrawerOpen
            updateUI([
                "templatesDrawerOpen": false,
                "imagesDrawerOpen": newState,
                "modelsDrawerOpen": false
            ])
        case .models:
            let newState = !state.ui.modelsDrawerOpen
            updateUI([
                "templatesDrawerOpen": false,
                "imagesDrawerOpen": false,
                "modelsDrawerOpen": newState
            ])
        }
    }
    
    func closeAllDrawers() {
        updateUI([
            "templatesDrawerOpen": false,
            "imagesDrawerOpen": false,
            "modelsDrawerOpen": false
        ])
    }
    
    func setInputViewFrame(_ frame: CGRect) {
        state.ui.inputViewFrame = frame
    }
    
    func setSelectedModel(_ model: String) {
        updateUI(["selectedModel": model])
    }
    
    func setEditingTemplateId(_ templateId: String?) {
        withAnimation(.easeInOut(duration: 3.0)) {
            updateUI(["editingTemplateId": templateId])
        }
    }

    // MARK: - Getters

    var selectedProject: Project? {
        guard let projectId = state.selectedProjectId else { return nil }
        return state.projects[projectId]
    }

    var selectedTask: ProjectTask? {
        guard let projectId = state.selectedProjectId,
              let taskId = state.selectedTaskId,
              let project = state.projects[projectId] else { return nil }
        return project.tasks[taskId]
    }

    func getProjectTasks(_ projectId: String) -> [ProjectTask] {
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
        tasks: [String: ProjectTask],
        rootTaskIds: [String],
        columnWidth: Double = 280,
        nodeHeight: Double = 160,
        verticalSpacing: Double = 20,
        startX: Double = 20,
        startY: Double = 20
    ) -> [String: ProjectTask.Position] {
        var positions: [String: ProjectTask.Position] = [:]

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
            for childId in task.childIds where !visited.contains(childId) {
                queue.append((taskId: childId, level: level + 1))
            }
        }

        // Calculate positions for each level
        for (levelIndex, levelTasks) in levels.enumerated() {
            let x = startX + (Double(levelIndex) * columnWidth)

            // Start Y position from the top
            var currentY = startY

            // Position each task in this level
            for (taskIndex, taskId) in levelTasks.enumerated() {
                positions[taskId] = ProjectTask.Position(
                    x: x,
                    y: currentY + (Double(taskIndex) * (nodeHeight + verticalSpacing))
                )
            }
        }

        return positions
    }
}
