# Context Documentation

Welcome to the Context developer documentation. This directory contains guides and references for building and extending the Context native macOS application.

## Documentation Index

### Getting Started
- **[Quick Start Guide](./quick-start.md)** - Get up and running in 5 minutes
- **[Getting Started Guide](./getting-started.md)** - Comprehensive setup and overview
- **[Architecture Overview](./architecture.md)** - Technical design and implementation details

### Concept & Design
- **[Original Concept](./concept.md)** - The vision and research behind Context
- **[Task Decomposition](./concept.md#how-it-works)** - Core algorithm and approach

## Quick Links

### For New Developers
1. Start with the [Quick Start Guide](./quick-start.md)
2. Read through [Getting Started](./getting-started.md) for full details
3. Explore the codebase starting from `context/ContentView.swift`

### For Contributors
1. Understand the [Architecture](./architecture.md)
2. Study the SwiftUI views in `context/Views/`
3. See open issues on GitHub

### For Users
1. See the main [README](../README.md) for features
2. Check [releases](https://github.com/tartavull/context/releases) for downloads

## Key Concepts

### Recursive Task Decomposition
The core innovation - breaking complex tasks into focused subtasks to maintain optimal LLM performance.

### Execution Modes
- **Interactive**: User participates in the conversation
- **Autonomous**: Runs without intervention (planned)

### Context Isolation
Each task maintains its own conversation context to prevent degradation.

## Technology Stack

- **SwiftUI**: Native macOS user interface
- **Swift 6.0**: Modern Swift with concurrency features
- **MVVM Architecture**: Reactive state management with ObservableObject
- **Native macOS**: Optimized for macOS ecosystem integration

## Current Status

### ✅ Completed
- Native macOS app with SwiftUI interface
- Project and task management system
- Visual task tree representation
- Conversation data models and UI
- Reactive state management

### 🚧 In Development
- AI integration (LLM API calls)
- Task decomposition logic
- Streaming conversation responses

### 📋 Planned
- Autonomous task execution
- Multi-model LLM support
- Advanced prompt engineering
- Native macOS integrations (Spotlight, Shortcuts)

## Getting Help

- **Issues**: [GitHub Issues](https://github.com/tartavull/context/issues)
- **Discussions**: [GitHub Discussions](https://github.com/tartavull/context/discussions)
- **Swift/SwiftUI**: Apple's developer documentation

## Contributing

We welcome contributions! The project is currently focused on:
1. AI integration and LLM API implementation
2. Task decomposition algorithms
3. Enhanced user experience features
4. Performance optimizations
