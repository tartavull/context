# Orchestrator Architecture

This document describes the technical architecture of the Orchestrator application, including design decisions, component interactions, and implementation details.

## Overview

Orchestrator is built as an Electron desktop application that implements recursive task decomposition to optimize LLM interactions. The architecture is designed to:

1. **Prevent context degradation** by keeping conversations short and focused
2. **Enable parallel task execution** through isolated task contexts
3. **Provide visual task management** with a hierarchical tree interface
4. **Secure API credentials** by handling AI operations in the main process

## High-Level Architecture

```
┌─────────────────────────────────────────────────────────┐
│                    User Interface                        │
│  ┌──────────────────┐    ┌──────────────────────────┐  │
│  │ Task Tree View   │    │   Chat/Canvas View       │  │
│  │ (Hierarchical)   │    │   (Active Task)          │  │
│  └──────────────────┘    └──────────────────────────┘  │
└─────────────────────────────────────────────────────────┘
                            │ IPC
┌─────────────────────────────────────────────────────────┐
│                    Main Process                          │
│  ┌────────────────┐  ┌─────────────┐  ┌─────────────┐  │
│  │ Window Manager │  │ AI Handlers │  │Task Manager │  │
│  └────────────────┘  └─────────────┘  └─────────────┘  │
│           │                  │                │          │
│  ┌────────────────────────────────────────────────────┐ │
│  │              SQLite Database                        │ │
│  │  Tasks | Conversations | Prompts | Metrics         │ │
│  └────────────────────────────────────────────────────┘ │
└─────────────────────────────────────────────────────────┘
```

## Core Components

### 1. Electron Main Process (`src/main/`)

The main process manages the application lifecycle and handles sensitive operations:

#### Window Management (`index.ts`)
- Creates and manages BrowserWindow instances
- Handles application menu and shortcuts
- Manages deep linking (`orchestrator://` protocol)
- Configures security policies

#### AI Handlers (`ai-handlers.ts`)
- Integrates with Vercel AI SDK
- Manages streaming responses
- Handles multiple AI providers (OpenAI, Anthropic)
- Protects API keys from renderer exposure

```typescript
// Example: Streaming AI response
ipcMain.handle('ai:stream-chat', async (event, messages, options) => {
  const result = await streamText({
    model: openai('gpt-4-turbo-preview'),
    messages,
    abortSignal: abortController.signal
  })
  
  // Stream chunks back to renderer
  for await (const chunk of result.textStream) {
    event.sender.send('ai:stream-data', { streamId, data: chunk })
  }
})
```

#### Task Handlers (`task-handlers.ts`)
- CRUD operations for tasks
- Manages task hierarchy
- Handles task decomposition logic
- Coordinates execution modes

#### Database Layer (`database.ts`)
- SQLite for persistent storage
- Schema management and migrations
- Prepared statements for performance
- Transaction support

### 2. Renderer Process (`src/renderer/`)

The renderer runs the React application in a sandboxed browser environment:

#### Component Architecture
```
App.tsx (Root)
├── TaskTreeView.tsx
│   └── TaskNode.tsx (Recursive)
└── ChatView.tsx
    ├── MessageList.tsx
    └── InputArea.tsx
```

#### State Management (`store/taskStore.ts`)
Uses Zustand for client-side state:
- Task hierarchy cache
- Selected task tracking
- Optimistic updates
- Derived state (children, path)

#### IPC Communication
Secure communication through preload script:
```typescript
// Type-safe IPC calls
const result = await window.electron.tasks.create({
  title: 'New Task',
  executionMode: 'interactive'
})
```

### 3. Preload Script (`src/main/preload.ts`)

Acts as a secure bridge between main and renderer:
- Exposes limited, safe APIs
- Validates IPC messages
- Provides type definitions
- Prevents direct Node.js access

## Data Model

### Task Structure
```typescript
interface Task {
  id: string                    // Unique identifier
  parent_id: string | null      // Hierarchical relationship
  title: string                 // Display name
  description: string           // Detailed description
  status: TaskStatus            // pending|active|completed|failed
  execution_mode: ExecutionMode // interactive|autonomous
  created_at: number            // Unix timestamp
  updated_at: number            // Unix timestamp
  completed_at: number | null   // Completion timestamp
  metadata: any                 // Flexible data storage
}
```

### Database Schema
```sql
-- Core task hierarchy
CREATE TABLE tasks (
  id TEXT PRIMARY KEY,
  parent_id TEXT REFERENCES tasks(id),
  title TEXT NOT NULL,
  status TEXT DEFAULT 'pending',
  execution_mode TEXT DEFAULT 'interactive',
  -- ... timestamps and metadata
);

-- Conversation history per task
CREATE TABLE conversations (
  id TEXT PRIMARY KEY,
  task_id TEXT REFERENCES tasks(id),
  messages TEXT NOT NULL, -- JSON array
  -- ... timestamps
);

-- Prompt templates with versioning
CREATE TABLE prompts (
  id TEXT PRIMARY KEY,
  name TEXT NOT NULL,
  template TEXT NOT NULL,
  version INTEGER DEFAULT 1,
  parent_version_id TEXT,
  -- ... metadata
);
```

## Key Design Patterns

### 1. Task Decomposition Strategy

The system uses a recursive decomposition approach:

```
Initial Request → Decomposer → Decision
                                  ↓
                    ┌─────────────┴─────────────┐
                    │                           │
                 EXECUTE                    DECOMPOSE
                (Simple)                    (Complex)
                    │                           │
                 Do Task                 Create Subtasks
                                               ↓
                                     Recurse for each
```

### 2. Context Isolation

Each task maintains its own conversation context:
- Prevents context pollution between tasks
- Allows parallel execution
- Enables focused, short conversations
- Maintains optimal LLM performance

### 3. Execution Modes

**Interactive Mode**:
- User participates in the conversation
- Suitable for design decisions, reviews
- Allows mid-execution corrections

**Autonomous Mode**:
- Runs without user intervention
- Best for well-defined, repetitive tasks
- Can escalate to interactive if needed

### 4. Streaming Architecture

Supports real-time AI responses:
1. Main process initiates stream
2. Chunks sent via IPC events
3. Renderer updates UI incrementally
4. Abort capability for user control

## Security Considerations

### API Key Protection
- Keys stored in `.env.local` (gitignored)
- Never exposed to renderer process
- All AI calls proxied through main process

### Process Isolation
- Context isolation enabled
- Node integration disabled
- Preload script validates all IPC
- Content Security Policy enforced

### Data Privacy
- Local SQLite database
- No cloud storage by default
- User controls all data

## Performance Optimizations

### 1. Lazy Loading
- Tasks loaded on demand
- Virtual scrolling for large trees
- Component code splitting

### 2. Database Optimization
- Indexed foreign keys
- Prepared statements
- Write-ahead logging (WAL mode)
- Batch operations where possible

### 3. Render Optimization
- React.memo for expensive components
- Virtualized lists
- Debounced updates
- Optimistic UI updates

## Extension Points

### 1. AI Provider Plugins
```typescript
interface AIProvider {
  name: string
  generateText(prompt: string, options: any): Promise<string>
  streamText(messages: any[], options: any): AsyncIterable<string>
}
```

### 2. Task Executors
Custom executors for specific task types:
- Code generation executor
- Research executor
- Review executor

### 3. Export/Import Formats
- JSON for task trees
- Markdown for conversations
- CSV for metrics

## Future Enhancements

### Planned Features
1. **Multi-model orchestration**: Route tasks to optimal models
2. **Collaborative features**: Real-time multi-user support
3. **Plugin system**: Custom task types and executors
4. **Cloud sync**: Optional encrypted backup
5. **Mobile companion**: View and manage tasks on mobile

### Technical Improvements
1. **WebRTC for streaming**: Better real-time performance
2. **Vector database**: Semantic search over task history
3. **GraphQL API**: More flexible data fetching
4. **Web Workers**: Offload heavy computations

## Development Guidelines

### Code Organization
- Feature-based structure in renderer
- Domain-based structure in main
- Shared types in dedicated directory

### Testing Strategy
- Unit tests for business logic
- Integration tests for IPC
- E2E tests for critical paths

### Performance Monitoring
- Track conversation lengths
- Monitor task completion rates
- Measure prompt effectiveness
- Analyze usage patterns

---

This architecture is designed to scale with the complexity of tasks while maintaining the core principle: keeping LLM conversations short and focused for optimal performance. 