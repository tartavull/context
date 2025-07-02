# Orchestrator Chat System Setup Guide

## What We've Implemented

We've successfully implemented the core chat system for Orchestrator with the following features:

### 1. **Streaming Chat Interface**
- Real-time streaming responses from AI models
- Beautiful chat UI with user/assistant avatars
- Markdown rendering for AI responses
- Loading states and error handling

### 2. **Message Persistence**
- All messages are saved to SQLite database
- Messages are loaded when switching between tasks
- Parent task context is available for subtasks

### 3. **Task Decomposition**
- AI can automatically create subtasks when needed
- Subtasks are parsed from special `[SUBTASK]` blocks in AI responses
- Each subtask can be either "interactive" or "autonomous"

### 4. **Autonomous Task Execution**
- Autonomous tasks run automatically without user input
- Task executor queues and processes tasks sequentially
- Results are saved as messages in the task's chat

### 5. **System Prompts**
- Specialized prompts for different task types
- Decomposition guidelines built into the system
- Focus on keeping conversations short (< 5 turns)

## Environment Setup

Create a `.env` file in the root directory with your API keys:

```env
# AI Provider Settings
AI_PROVIDER=openai # or anthropic
OPENAI_API_KEY=your-openai-api-key-here
ANTHROPIC_API_KEY=your-anthropic-api-key-here

# Optional: Model overrides
# OPENAI_MODEL=gpt-4-turbo-preview
# ANTHROPIC_MODEL=claude-3-opus-20240229
```

## How to Test the Chat System

### 1. Start the Development Server
```bash
pnpm dev
```

### 2. Create a Root Task
Click "New Task" or use Cmd+N to create a new task. Try something complex like:
- "Build a todo app with React"
- "Create a REST API for a blog"
- "Write a Python script to analyze CSV files"

### 3. Watch Task Decomposition
The AI will analyze your request and may create subtasks like:
- Design the UI (interactive)
- Set up the database schema (autonomous)
- Implement the frontend (interactive)
- Write tests (autonomous)

### 4. Navigate Between Tasks
- Click on any task in the tree view to switch conversations
- Each task maintains its own isolated context
- Autonomous tasks will show their execution results

### 5. Monitor Task Status
- **Pending**: Task not started
- **Active**: Currently being worked on
- **Completed**: Successfully finished
- **Failed**: Encountered an error

## Architecture Overview

```
User Input → ChatView Component
    ↓
AI Stream Handler → Message Persistence
    ↓
Task Decomposition Parser
    ↓
Creates Subtasks → Task Executor (for autonomous)
    ↓
Updates Task Tree View
```

## Key Files Created/Modified

1. **`src/main/message-handlers.ts`** - Database operations for messages
2. **`src/renderer/components/ChatView.tsx`** - Enhanced chat UI with streaming
3. **`src/shared/prompts.ts`** - System prompts and parsing utilities
4. **`src/main/task-executor.ts`** - Autonomous task execution engine
5. **`src/main/database.ts`** - Added messages table schema
6. **`src/main/preload.ts`** - Exposed message APIs to renderer

## Next Steps

1. **Test Different Scenarios**
   - Try various complex tasks to see decomposition
   - Test autonomous task execution
   - Verify message persistence

2. **Monitor Performance**
   - Check that conversations stay focused
   - Ensure autonomous tasks complete properly
   - Verify no context pollution between tasks

3. **Customize Prompts**
   - Adjust decomposition thresholds
   - Fine-tune autonomous task prompts
   - Add domain-specific guidelines

## Troubleshooting

### If AI responses aren't working:
1. Check your API keys in `.env`
2. Verify you have internet connection
3. Check the console for error messages

### If tasks aren't decomposing:
1. Try more complex requests
2. Check the system prompt is being applied
3. Look for `[SUBTASK]` blocks in AI responses

### If autonomous tasks aren't running:
1. Verify the task executor is initialized
2. Check task status is "pending"
3. Look at console logs for execution errors

## Example Task Decomposition

When you ask: "Build a todo app", the AI might respond:

```
I'll help you build a todo app. Let me break this down into manageable subtasks:

[SUBTASK]
{
  "title": "Design todo app UI mockup",
  "description": "Create a visual design for the todo app interface",
  "execution_mode": "interactive"
}
[/SUBTASK]

[SUBTASK]
{
  "title": "Set up project structure",
  "description": "Initialize React project with necessary dependencies",
  "execution_mode": "autonomous"
}
[/SUBTASK]

[SUBTASK]
{
  "title": "Implement todo CRUD operations",
  "description": "Create functions to add, edit, delete, and mark todos complete",
  "execution_mode": "interactive"
}
[/SUBTASK]
```

These subtasks will automatically appear in your task tree! 