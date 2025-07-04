# Context Architecture

This document describes the technical architecture of the Context application, a native macOS app built with SwiftUI that implements recursive task decomposition to optimize LLM interactions.

## Overview

Context is built as a native macOS application using SwiftUI that implements recursive task decomposition to optimize LLM interactions. The architecture is designed to:

1. **Prevent context degradation** by keeping conversations short and focused
2. **Enable parallel task execution** through isolated task contexts
3. **Provide visual task management** with a hierarchical tree interface
4. **Leverage native macOS features** for optimal performance and integration

## High-Level Architecture

```
┌─────────────────────────────────────────────────────────┐
│                    SwiftUI Views                        │
│  ┌──────────────────┐    ┌──────────────────────────┐  │
│  │ ProjectsView     │    │   ContentView            │  │
│  │ (Task Tree)      │    │   ├─ ChartView           │  │
│  │                  │    │   └─ ChatView            │  │
│  └──────────────────┘    └──────────────────────────┘  │
└─────────────────────────────────────────────────────────┘
                            │ @Published
┌─────────────────────────────────────────────────────────┐
│                 AppStateManager                         │
│  ┌────────────────┐  ┌─────────────┐  ┌─────────────┐  │
│  │ Project CRUD   │  │ Task CRUD   │  │Message CRUD │  │
│  └────────────────┘  └─────────────┘  └─────────────┘  │
│           │                  │                │          │
│  ┌────────────────────────────────────────────────────┐ │
│  │              In-Memory Data Models                 │ │
│  │  AppState | Projects | Tasks | Messages           │ │
│  └────────────────────────────────────────────────────┘ │
└─────────────────────────────────────────────────────────┘
```

## Core Components

### 1. SwiftUI Views (`context/Views/`)

The user interface is built with SwiftUI views that provide a native macOS experience:

#### ContentView.swift
- Main application layout with split-pane design
- Manages panel visibility and sizing
- Coordinates between ProjectsView, ChartView, and ChatView
- Handles window toolbar and navigation

#### ProjectsView.swift
- Displays hierarchical task tree
- Handles project and task selection
- Provides task creation and management UI
- Supports drag-and-drop operations

#### ChartView.swift
- Visual representation of task relationships
- Interactive task node manipulation
- Real-time status updates
- Zoom and pan capabilities

#### ChatView.swift
- Conversation interface for selected tasks
- Message display with role-based styling
- Input handling and message composition
- Streaming response support (planned)

### 2. State Management (`context/AppStateManager.swift`)

The app uses a centralized state management approach with SwiftUI's reactive architecture:

#### AppStateManager
```swift
@MainActor
class AppStateManager: ObservableObject {
    @Published var state: AppState
    
    // Project Management
    func createProject(title: String, description: String)
    func updateProject(projectId: String, updates: [String: Any])
    func deleteProject(_ projectId: String)
    
    // Task Management
    func createTask(projectId: String, title: String, ...)
    func updateTask(projectId: String, taskId: String, ...)
    func deleteTask(projectId: String, taskId: String)
    
    // Message Management
    func addMessage(projectId: String, taskId: String, message: Message)
}
```

#### Reactive Updates
- Uses `@Published` properties for automatic UI updates
- SwiftUI views observe state changes through `@StateObject` and `@EnvironmentObject`
- All state mutations happen on the main actor for thread safety

### 3. Data Models (`context/Models.swift`)

The app uses a hierarchical data structure optimized for task decomposition:

#### Core Models
```swift
struct AppState: Codable {
    var projects: [String: Project]
    var selectedProjectId: String?
    var selectedTaskId: String?
    var ui: UIState
}

struct Project: Identifiable, Codable {
    let id: String
    var title: String
    var description: String
    var status: ProjectStatus
    var tasks: [String: Task]
    var rootTaskIds: [String]
    // ... timestamps
}

struct Task: Identifiable, Codable {
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
    // ... timestamps
}

struct Message: Identifiable, Codable {
    let id: String
    let role: MessageRole
    let content: String
    let timestamp: Date
}
```

## Key Design Patterns

### 1. MVVM Architecture

The app follows the Model-View-ViewModel pattern:
- **Model**: Data structures in `Models.swift`
- **View**: SwiftUI views in `Views/` directory
- **ViewModel**: `AppStateManager` acts as the central view model

### 2. Reactive State Management

```swift
// State changes automatically trigger UI updates
appState.createTask(projectId: projectId, title: "New Task", ...)
// ↓ @Published property changes
// ↓ SwiftUI views automatically re-render
```

### 3. Task Hierarchy Management

Tasks are organized in a tree structure with:
- Parent-child relationships via `parentId` and `childIds`
- Root tasks tracked in project's `rootTaskIds`
- Automatic layout calculation for visual positioning

### 4. Context Isolation

Each task maintains its own conversation:
- Prevents context pollution between tasks
- Allows parallel execution (planned)
- Enables focused, short conversations
- Maintains optimal LLM performance

## Data Flow

### 1. User Interaction Flow
```
User Input → SwiftUI View → AppStateManager → Data Model Update → @Published → UI Refresh
```

### 2. Task Creation Flow
```
User Creates Task → AppStateManager.createTask() → Update Project.tasks → 
Calculate Layout → Update UI State → SwiftUI Re-renders
```

### 3. Message Flow (Planned)
```
User Message → ChatView → AppStateManager.addMessage() → 
AI Processing → Response Streaming → UI Updates
```

## Performance Optimizations

### 1. SwiftUI Optimizations
- Efficient use of `@Published` to minimize unnecessary re-renders
- View identity management with stable IDs
- Lazy loading for large task trees

### 2. Memory Management
- In-memory data storage for fast access
- Automatic memory cleanup for unused views
- Efficient data structures for hierarchical relationships

### 3. Layout Calculation
- Optimized tree layout algorithm
- Minimal recalculation on changes
- Cached position calculations

## Future Enhancements

### Planned AI Integration
1. **LLM API Integration**: Direct API calls to OpenAI, Anthropic, etc.
2. **Streaming Responses**: Real-time AI response streaming
3. **Task Decomposition**: Automatic task breakdown logic
4. **Autonomous Execution**: Background task processing

### Native macOS Features
1. **Menu Bar Integration**: Quick access and status updates
2. **Spotlight Integration**: Search across all tasks and conversations
3. **Shortcuts Support**: Automation and workflow integration
4. **iCloud Sync**: Cross-device synchronization (optional)

### Performance Improvements
1. **Core Data Integration**: Persistent storage for large datasets
2. **Background Processing**: Async task execution
3. **Memory Optimization**: Efficient handling of large task trees
4. **Search Indexing**: Fast full-text search capabilities

## Development Guidelines

### Code Organization
```
context/
├── contextApp.swift          # App entry point
├── ContentView.swift         # Main layout
├── AppStateManager.swift     # State management
├── Models.swift             # Data models
└── Views/
    ├── ProjectsView.swift   # Project/task tree
    ├── ChartView.swift      # Visual task representation
    └── ChatView.swift       # Conversation interface
```

### SwiftUI Best Practices
- Use `@StateObject` for owned state
- Use `@EnvironmentObject` for shared state
- Prefer `@Published` over manual state updates
- Keep views focused and composable

### State Management Rules
- All mutations happen in `AppStateManager`
- Use immutable data structures where possible
- Maintain referential integrity in task relationships
- Validate data consistency on state changes

### Testing Strategy (Planned)
- Unit tests for `AppStateManager` methods
- SwiftUI view testing with ViewInspector
- Integration tests for data flow
- UI automation tests for critical paths

---

This architecture leverages SwiftUI's reactive nature and macOS's native capabilities to create a performant, maintainable application that scales with task complexity while maintaining the core principle of keeping LLM conversations short and focused. 