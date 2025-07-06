# Getting Started with Context

Get Context running and understand the codebase in under 10 minutes.

## Prerequisites

- **macOS 15.4+** (native macOS app)
- **Xcode 16.0+** (includes Swift 6.0)
- **Git** (for cloning)

## Quick Setup

```bash
# 1. Clone the repository
git clone https://github.com/tartavull/context.git
cd context

# 2. Open in Xcode
open context.xcodeproj

# 3. Build and run (Cmd+R in Xcode)
```

## What You'll See

1. **Native macOS window** with split-pane interface
2. **Left pane**: Projects and task tree navigation
3. **Center pane**: Visual task chart representation
4. **Right pane**: Chat interface for selected task (overlay)

## Project Structure

```
context/
├── context.xcodeproj/           # Xcode project file
├── context/                     # Main app source
│   ├── contextApp.swift        # App entry point (@main)
│   ├── ContentView.swift       # Main UI layout
│   ├── AppStateManager.swift   # Centralized state management
│   ├── Models.swift            # Data models (Project, Task, Message)
│   └── Views/                  # SwiftUI view components
│       ├── ProjectsView.swift  # Task tree sidebar
│       ├── Chat/               # Chat interface components
│       └── Tree/               # Task visualization components
└── docs/                       # Documentation
```

### Key Files

- **`contextApp.swift`**: App entry point
- **`ContentView.swift`**: Main split-pane layout
- **`AppStateManager.swift`**: ObservableObject managing all app state
- **`Models.swift`**: Core data structures for projects, tasks, and messages
- **`Views/`**: SwiftUI view components organized by feature

## Key Concepts

### SwiftUI Architecture
Context uses SwiftUI's declarative UI with reactive state management:

```swift
// AppStateManager is an ObservableObject
@StateObject private var appState = AppStateManager()

// Views automatically update when @Published properties change
@Published var state: AppState
```

### Project and Task Hierarchy
- **Projects**: Top-level containers for related tasks
- **Tasks**: Individual work items organized in a tree structure
- **Messages**: Conversation history for each task

## Development Workflow

### Making Changes
1. **UI Changes**: Edit SwiftUI views in the `Views/` directory
2. **State Changes**: Update `AppStateManager.swift` methods
3. **Data Models**: Modify structures in `Models.swift`
4. **Test**: Use `Cmd+R` to rebuild and test

### Working with State
All state changes should go through `AppStateManager`:
```swift
// Good: Use AppStateManager methods
appState.createTask(projectId: projectId, title: "New Task")

// Avoid: Direct state manipulation
```