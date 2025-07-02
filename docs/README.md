# Orchestrator Documentation

Welcome to the Orchestrator developer documentation. This directory contains guides and references for building and extending the Orchestrator application.

## Documentation Index

### Getting Started
- **[Quick Start Guide](./quick-start.md)** - Get up and running in 5 minutes
- **[Getting Started Guide](./getting-started.md)** - Comprehensive setup and overview
- **[Setup Guide](./setup.md)** - Implementation details and testing guide
- **[Architecture Overview](./architecture.md)** - Technical design and implementation details

### Concept & Design
- **[Original Concept](./concept.md)** - The vision and research behind Orchestrator
- **[Task Decomposition](./concept.md#how-it-works)** - Core algorithm and approach

## Quick Links

### For New Developers
1. Start with the [Quick Start Guide](./quick-start.md)
2. Read through [Getting Started](./getting-started.md) for full details
3. Explore the codebase starting from `src/renderer/App.tsx`

### For Contributors
1. Understand the [Architecture](./architecture.md)
2. Check our coding standards (coming soon)
3. See open issues on GitHub

### For Users
1. See the main [README](../README.md) for features
2. Check [releases](https://github.com/your-org/orchestrator/releases) for downloads

## Key Concepts

### Recursive Task Decomposition
The core innovation - breaking complex tasks into focused subtasks to maintain optimal LLM performance.

### Execution Modes
- **Interactive**: User participates in the conversation
- **Autonomous**: Runs without intervention

### Context Isolation
Each task maintains its own conversation context to prevent degradation.

## Technology Stack

- **Electron**: Desktop application framework
- **React**: User interface
- **TypeScript**: Type safety
- **Vercel AI SDK**: LLM integration
- **SQLite**: Local data storage
- **Nix**: Reproducible development environment

## Getting Help

- **Issues**: [GitHub Issues](https://github.com/your-org/orchestrator/issues)
- **Discussions**: [GitHub Discussions](https://github.com/your-org/orchestrator/discussions)
- **Email**: support@orchestrator.dev

## Contributing

We welcome contributions! Please see our [Contributing Guide](../CONTRIBUTING.md) (coming soon).

---

*This documentation is a work in progress. Please help us improve it by submitting issues or pull requests.* 