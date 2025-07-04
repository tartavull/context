# Quick Start Guide

Get Context running in under 5 minutes.

## Prerequisites

- **macOS 15.4+** (native macOS app)
- **Xcode 16.0+** (includes Swift 6.0)
- **Git** (for cloning)

## Setup

```bash
# 1. Clone the repository
git clone https://github.com/tartavull/context.git
cd context

# 2. Open in Xcode
open context.xcodeproj

# 3. Build and run (Cmd+R in Xcode)
# Or from terminal:
xcodebuild -project context.xcodeproj -scheme context build
```

## What You'll See

1. **Native macOS window** with split-pane interface
2. **Left pane**: Projects and task tree navigation
3. **Center pane**: Visual task chart representation
4. **Right pane**: Chat interface for selected task (overlay)

## First Steps

1. **Explore Sample Data**: The app launches with sample projects and tasks
2. **Navigate Projects**: Click projects in the left sidebar
3. **Select Tasks**: Click on task nodes to view their conversations
4. **Create New**: Use the "+" button to add projects or tasks
5. **View Conversations**: Each task has its own chat history

## Key Features (Current)

- **Project Management**: Create and organize multiple projects
- **Task Hierarchy**: Tree-structured task organization
- **Visual Layout**: Interactive task chart with automatic positioning
- **Conversation History**: Each task maintains its own message thread
- **Native Performance**: Optimized SwiftUI interface

## Key Commands

| Command | Description |
|---------|-------------|
| `Cmd+R` (Xcode) | Build and run |
| `Cmd+.` (Xcode) | Stop running app |
| Sidebar toggle | Show/hide projects panel |
| Task selection | Switch between task conversations |

## Troubleshooting

**"Cannot open project"**
- Ensure you have Xcode 16.0+ installed
- Verify macOS 15.4+ compatibility

**Build errors**
```bash
# Clean build folder in Xcode
Product → Clean Build Folder

# Or from terminal
rm -rf ~/Library/Developer/Xcode/DerivedData
```

**App crashes on launch**
- Check Xcode console for error messages
- Verify all Swift files compile without errors

## Next Steps

- **Understand the Code**: Explore `AppStateManager.swift` for state management
- **Read Architecture**: Check the [Architecture Guide](./architecture.md)
- **Study the Vision**: Review the [original concept](./concept.md)
- **Plan Contributions**: AI integration is the next major milestone

## Current Status

✅ **Completed**: Native macOS app with SwiftUI interface  
✅ **Completed**: Project and task management  
✅ **Completed**: Visual task tree representation  
✅ **Completed**: Conversation data models  

🚧 **In Progress**: AI integration and task decomposition  
🚧 **Planned**: Autonomous task execution  
🚧 **Planned**: Multi-model LLM support  

---

**Note**: This is a native Swift app, not an Electron application. The current version focuses on the UI foundation and state management, with AI features planned for future releases.

Need help? Check the [Getting Started Guide](./getting-started.md) for detailed setup instructions! 