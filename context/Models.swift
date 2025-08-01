import Foundation

// MARK: - Core Data Models

struct Message: Identifiable, Codable {
    let id: String
    let role: MessageRole
    let content: String
    let timestamp: Date

    enum MessageRole: String, Codable, CaseIterable {
        case user
        case assistant
    }
}

struct Conversation: Identifiable, Codable {
    let id: String
    var messages: [Message]
    var lastActivity: Date

    init(id: String = UUID().uuidString) {
        self.id = id
        self.messages = []
        self.lastActivity = Date()
    }
}

struct ProjectTask: Identifiable, Codable {
    let id: String
    var title: String
    var description: String
    var status: TaskStatus
    var nodeType: NodeType
    var executionMode: ExecutionMode
    var parentId: String?
    var childIds: [String]
    var position: Position
    var conversation: Conversation
    let createdAt: Date
    var updatedAt: Date

    enum TaskStatus: String, Codable, CaseIterable {
        case pending
        case active
        case completed
        case failed
    }

    enum NodeType: String, Codable, CaseIterable {
        case original
        case clone
        case spawn
    }

    enum ExecutionMode: String, Codable, CaseIterable {
        case interactive
        case autonomous
    }

    struct Position: Codable {
        var x: Double
        var y: Double
    }

    init(title: String, description: String, nodeType: NodeType = .original,
         parentId: String? = nil, position: Position = Position(x: 0, y: 0)) {
        self.id = "task-\(Int(Date().timeIntervalSince1970))-\(UUID().uuidString.prefix(9))"
        self.title = title
        self.description = description
        self.status = .pending
        self.nodeType = nodeType
        self.executionMode = .interactive
        self.parentId = parentId
        self.childIds = []
        self.position = position
        self.conversation = Conversation()
        self.createdAt = Date()
        self.updatedAt = Date()
    }
}

struct Project: Identifiable, Codable {
    let id: String
    var title: String
    var description: String
    var status: ProjectStatus
    var tasks: [String: ProjectTask]
    var rootTaskIds: [String]
    let createdAt: Date
    var updatedAt: Date

    enum ProjectStatus: String, Codable, CaseIterable {
        case active
        case pending
        case completed
        case failed
    }

    init(title: String, description: String) {
        self.id = "project-\(Int(Date().timeIntervalSince1970))-\(UUID().uuidString.prefix(9))"
        self.title = title
        self.description = description
        self.status = .active

        // Create root task
        let rootTask = ProjectTask(
            title: title,
            description: description,
            position: ProjectTask.Position(x: 20, y: 20)
        )
        self.tasks = [rootTask.id: rootTask]
        self.rootTaskIds = [rootTask.id]

        self.createdAt = Date()
        self.updatedAt = Date()
    }
}

// MARK: - Drawer Types

enum DrawerState {
    case open
    case closed
}

enum DrawerType {
    case templates
    case images
    case models
}

// MARK: - UI State

struct UIState: Codable {
    var showProjects: Bool = false // Start with projects panel hidden
    var showChart: Bool = true // Always show chart panel
    var showChat: Bool = true // Always show chat panel
    var projectsCollapsed: Bool = false
    var projectsPanelSize: Double = 30.0
    
    // Drawer states
    var templatesDrawerOpen: Bool = false
    var imagesDrawerOpen: Bool = false
    var modelsDrawerOpen: Bool = false
    var selectedModel: String = "claude-4-sonnet"
    
    // Expansion states (not persisted)
    var editingTemplateId: String? {
        get { _editingTemplateId }
        set { _editingTemplateId = newValue }
    }
    
    private var _editingTemplateId: String? = nil
    
    // Frame tracking (not persisted)
    var inputViewFrame: CGRect {
        get { _inputViewFrame }
        set { _inputViewFrame = newValue }
    }
    
    private var _inputViewFrame: CGRect = .zero
    
    private enum CodingKeys: String, CodingKey {
        case showProjects, showChart, showChat
        case projectsCollapsed, projectsPanelSize
        case templatesDrawerOpen, imagesDrawerOpen, modelsDrawerOpen
        case selectedModel
    }
}

// MARK: - App State

struct AppState: Codable {
    var projects: [String: Project]
    var selectedProjectId: String?
    var selectedTaskId: String?
    var ui: UIState

    init() {
        self.projects = [:]
        self.selectedProjectId = nil
        self.selectedTaskId = nil
        self.ui = UIState()
    }
}

// MARK: - Sample Data

extension AppState {
    static let sample: AppState = {
        var state = AppState()

        // Create sample projects
        let project1 = Project(
            title: "Build Todo App",
            description: "Create a modern todo application with React"
        )
        let project2 = Project(
            title: "Design System",
            description: "Build a comprehensive design system"
        )
        let project3 = Project(
            title: "API Integration",
            description: "Integrate with external APIs"
        )

        // Add sample tasks to project 1
        var updatedProject1 = project1

        // Get the root task and update it
        if let rootTaskId = project1.rootTaskIds.first {
            updatedProject1.tasks[rootTaskId]?.status = .active

            // Create child tasks
            let task2 = ProjectTask(
                title: "Design UI Components",
                description: "Create reusable UI components for the todo app",
                nodeType: .spawn,
                parentId: rootTaskId,
                position: ProjectTask.Position(x: 350, y: 110)
            )

            let task3 = ProjectTask(
                title: "Implement State Management",
                description: "Set up state management with Context API",
                nodeType: .clone,
                parentId: rootTaskId,
                position: ProjectTask.Position(x: 350, y: 290)
            )

            // Update the root task to have children
            updatedProject1.tasks[rootTaskId]?.childIds = [task2.id, task3.id]

            // Add the new tasks
            updatedProject1.tasks[task2.id] = task2
            updatedProject1.tasks[task3.id] = task3

            // Update task 2 status
            updatedProject1.tasks[task2.id]?.status = .completed

            // Add sample messages to root task
            let sampleMessage1 = Message(
                id: UUID().uuidString,
                role: .user,
                content: "Let's build a todo app with React",
                timestamp: Date().addingTimeInterval(-3600)
            )
            let sampleMessage2 = Message(
                id: UUID().uuidString,
                role: .assistant,
                content: "Great! I'll help you build a modern todo app. " +
                    "Let's start by planning the components and state management.",
                timestamp: Date().addingTimeInterval(-3500)
            )

            updatedProject1.tasks[rootTaskId]?.conversation.messages = [sampleMessage1, sampleMessage2]
            updatedProject1.tasks[rootTaskId]?.conversation.lastActivity = Date().addingTimeInterval(-3500)

            // Add sample messages to task 2
            let designMessage1 = Message(
                id: UUID().uuidString,
                role: .user,
                content: "Can you help me design the UI components?",
                timestamp: Date().addingTimeInterval(-3000)
            )
            let designMessage2 = Message(
                id: UUID().uuidString,
                role: .assistant,
                content: "Absolutely! Let's create a TodoItem component, TodoList, and AddTodo form. " +
                    "I'll use modern React patterns.",
                timestamp: Date().addingTimeInterval(-2900)
            )

            updatedProject1.tasks[task2.id]?.conversation.messages = [designMessage1, designMessage2]
            updatedProject1.tasks[task2.id]?.conversation.lastActivity = Date().addingTimeInterval(-2900)

            // Add sample messages to task 3
            let stateMessage1 = Message(
                id: UUID().uuidString,
                role: .user,
                content: "How should we handle state management?",
                timestamp: Date().addingTimeInterval(-1800)
            )
            let stateMessage2 = Message(
                id: UUID().uuidString,
                role: .assistant,
                content: "For this todo app, I recommend using React's Context API with useReducer " +
                    "for state management. It's perfect for this scale.",
                timestamp: Date().addingTimeInterval(-1700)
            )

            updatedProject1.tasks[task3.id]?.conversation.messages = [stateMessage1, stateMessage2]
            updatedProject1.tasks[task3.id]?.conversation.lastActivity = Date().addingTimeInterval(-1700)
        }

        // Update project 2 with sample data
        var updatedProject2 = project2
        updatedProject2.status = .pending

        // Update project 3 with sample data
        var updatedProject3 = project3
        updatedProject3.status = .completed

        if let rootTaskId = project3.rootTaskIds.first {
            updatedProject3.tasks[rootTaskId]?.status = .completed

            // Add sample messages to project 3
            let apiMessage1 = Message(
                id: UUID().uuidString,
                role: .user,
                content: "I need to integrate with a REST API",
                timestamp: Date().addingTimeInterval(-259200)
            )
            let apiMessage2 = Message(
                id: UUID().uuidString,
                role: .assistant,
                content: "I'll help you set up proper API integration with fetch, error handling, " +
                    "and loading states.",
                timestamp: Date().addingTimeInterval(-259100)
            )

            updatedProject3.tasks[rootTaskId]?.conversation.messages = [apiMessage1, apiMessage2]
            updatedProject3.tasks[rootTaskId]?.conversation.lastActivity = Date().addingTimeInterval(-259100)
        }

        // Add projects to state
        state.projects[updatedProject1.id] = updatedProject1
        state.projects[updatedProject2.id] = updatedProject2
        state.projects[updatedProject3.id] = updatedProject3

        return state
    }()
}
