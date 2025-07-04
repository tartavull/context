# Getting Started with Context

This guide will walk you through setting up and running the Context application, a native macOS app for recursive task decomposition and optimal LLM performance.

## Table of Contents

1. [Prerequisites](#prerequisites)
2. [Installation](#installation)
3. [Running the Application](#running-the-application)
4. [Project Structure](#project-structure)
5. [Key Concepts](#key-concepts)
6. [Development Workflow](#development-workflow)
7. [Troubleshooting](#troubleshooting)

## Prerequisites

### Required Software

1. **macOS 15.4 or later**
   - Context is a native macOS application
   - Requires recent macOS for SwiftUI features

2. **Xcode 16.0 or later**
   - Download from Mac App Store or Apple Developer portal
   - Includes Swift 6.0 compiler and SwiftUI tools

3. **Git**
   - For cloning the repository
   - Usually pre-installed on macOS

## Installation

### Step 1: Clone the Repository

```bash
git clone https://github.com/tartavull/context.git
cd context
```

### Step 2: Open in Xcode

```bash
# Open the Xcode project
open context.xcodeproj
```

Alternatively, you can:
- Launch Xcode
- Choose "Open a project or file"
- Navigate to the `context.xcodeproj` file

### Step 3: Configure Signing (if needed)

If you plan to run on your device:
1. Select the project in Xcode's navigator
2. Choose your target under "Targets"
3. In the "Signing & Capabilities" tab
4. Select your Apple Developer account or team

## Running the Application

### Development Mode

1. **In Xcode**: Press `Cmd+R` or click the "Run" button
2. **From Terminal**: 
   ```bash
   xcodebuild -project context.xcodeproj -scheme context build
   ```

The app will launch with:
- Split-pane interface
- Sample projects and tasks (for demonstration)
- Full task tree visualization

### Building for Distribution

```bash
# Build for release
xcodebuild -project context.xcodeproj -scheme context -configuration Release build

# Archive for distribution
xcodebuild -project context.xcodeproj -scheme context archive
```

## Project Structure

```
context/
├── context.xcodeproj/           # Xcode project file
├── context/                     # Main app source
│   ├── contextApp.swift        # App entry point (@main)
│   ├── ContentView.swift       # Main UI layout
│   ├── AppStateManager.swift   # Centralized state management
│   ├── Models.swift            # Data models (Project, Task, Message)
│   ├── Assets.xcassets/        # App icons and assets
│   └── Views/                  # SwiftUI view components
│       ├── ProjectsView.swift  # Task tree sidebar
│       ├── ChartView.swift     # Visual task representation
│       └── ChatView.swift      # Conversation interface
│
├── contextTests/               # Unit tests
├── contextUITests/             # UI automation tests
├── docs/                       # Documentation
└── README.md                   # Project overview
```

### Key Files Explained

- **`contextApp.swift`**: App entry point with `@main` attribute
- **`ContentView.swift`**: Main split-pane layout with panels
- **`AppStateManager.swift`**: ObservableObject managing all app state
- **`Models.swift`**: Core data structures for projects, tasks, and messages
- **`Views/`**: SwiftUI view components for different app sections

## Key Concepts

### 1. SwiftUI Architecture

Context uses SwiftUI's declarative UI framework:

- **Views**: Define what the UI looks like
- **State**: Data that can change over time
- **Bindings**: Connect views to state changes

### 2. Reactive State Management

```swift
// AppStateManager is an ObservableObject
@StateObject private var appState = AppStateManager()

// Views automatically update when @Published properties change
@Published var state: AppState
```

### 3. Project and Task Hierarchy

- **Projects**: Top-level containers for related tasks
- **Tasks**: Individual work items organized in a tree structure
- **Messages**: Conversation history for each task

### 4. Task Types and Modes

- **Node Types**: Original, Clone, Spawn (different creation methods)
- **Execution Modes**: Interactive (user-guided) vs Autonomous (AI-driven)
- **Status**: Pending, Active, Completed, Failed

## Development Workflow

### 1. Making UI Changes

Edit SwiftUI views in the `Views/` directory:
- Changes are reflected immediately with Xcode's live preview
- Use `Cmd+R` to rebuild and test
- SwiftUI's declarative syntax makes UI updates straightforward

### 2. Adding New Features

1. **Update Models**: Add new properties to data structures in `Models.swift`
2. **Update State Manager**: Add methods to `AppStateManager.swift`
3. **Update Views**: Modify or create SwiftUI views
4. **Test**: Use Xcode's testing tools

### 3. Working with State

All state changes should go through `AppStateManager`:
```swift
// Good: Use AppStateManager methods
appState.createTask(projectId: projectId, title: "New Task", ...)

// Avoid: Direct state manipulation
// appState.state.projects[projectId].tasks[taskId] = newTask
```

### 4. Adding New Views

1. Create a new Swift file in the `Views/` directory
2. Define a SwiftUI view conforming to the `View` protocol
3. Use `@EnvironmentObject` to access `AppStateManager`
4. Add the view to the appropriate parent view

## Troubleshooting

### Common Issues

#### "Cannot find module" errors
- Ensure you're opening `context.xcodeproj`, not individual files
- Clean build folder: `Product` → `Clean Build Folder` in Xcode

#### App won't launch
- Check macOS version compatibility (15.4+)
- Verify Xcode version (16.0+)
- Check console for error messages

#### State not updating
- Ensure you're using `@Published` properties
- Check that views use `@StateObject` or `@EnvironmentObject`
- Verify state changes happen on the main actor

#### Build errors
```bash
# Clean derived data
rm -rf ~/Library/Developer/Xcode/DerivedData

# Restart Xcode
```

### Debug Mode

Enable debugging features:
1. In Xcode: `Product` → `Scheme` → `Edit Scheme`
2. Select "Run" and go to "Arguments"
3. Add environment variables or launch arguments as needed

### Performance Issues

- Use Xcode's Instruments to profile performance
- Check for retain cycles with the Memory Graph Debugger
- Monitor state update frequency

## Next Steps

1. **Explore the UI**: Navigate between projects and tasks
2. **Study the Code**: Examine how SwiftUI views connect to state
3. **Read Architecture**: Check [Architecture Guide](./architecture.md)
4. **Contribute**: See [Contributing Guidelines](../CONTRIBUTING.md) (when available)
5. **Understand the Vision**: Read the [original concept](./concept.md)

## Getting Help

- **Xcode Issues**: Check Apple's developer documentation
- **SwiftUI Questions**: Apple's SwiftUI tutorials and documentation
- **Project Issues**: Open an issue on GitHub
- **General Questions**: Check existing documentation in `/docs`

## Development Tips

### Xcode Shortcuts
- `Cmd+R`: Run/build the app
- `Cmd+.`: Stop running app
- `Cmd+Shift+K`: Clean build folder
- `Cmd+Option+P`: Resume SwiftUI preview

### SwiftUI Preview
Use Xcode's preview feature for rapid iteration:
```swift
#Preview {
    ContentView()
        .environmentObject(AppStateManager())
}
```

### State Debugging
Add breakpoints in `AppStateManager` methods to track state changes:
```swift
func createTask(...) {
    print("Creating task: \(title)")  // Debug output
    // ... implementation
}
```

---

Welcome to Context development! 🚀

The native macOS app provides a solid foundation for implementing the recursive task decomposition vision. The current version focuses on the UI and state management, with AI integration planned for future releases. 