# Getting Started with Context

This guide will walk you through setting up and running the Context application, a recursive task decomposition system for optimal LLM performance.

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

1. **Nix Package Manager** (Recommended)
   - Install from [nixos.org](https://nixos.org/download.html)
   - Provides reproducible development environment
   
2. **direnv** (Recommended)
   - Install: `nix-env -iA nixpkgs.direnv`
   - Hook to shell: [direnv.net/docs/hook.html](https://direnv.net/docs/hook.html)

### Alternative Setup (without Nix)

If you prefer not to use Nix, install these manually:
- Node.js 20.x or later
- pnpm 8.x or later
- Python 3.x (for node-gyp)
- Build tools (gcc, make)

## Installation

### Step 1: Clone the Repository

```bash
git clone https://github.com/your-org/context.git
cd context
```

### Step 2: Setup Development Environment

#### With Nix + direnv (Recommended):

```bash
# Allow direnv to load the Nix environment
direnv allow

# This automatically loads all required dependencies
```

#### Without Nix:

```bash
# Install pnpm if not already installed
npm install -g pnpm
```

### Step 3: Install Node Dependencies

```bash
pnpm install
```

### Step 4: Configure API Keys

Create a `.env.local` file in the root directory:

```bash
# Copy the template
cp .env.local.example .env.local

# Edit with your API keys
OPENAI_API_KEY=sk-...
ANTHROPIC_API_KEY=sk-ant-...
```

## Running the Application

### Development Mode

```bash
# Start the development server with hot reload
pnpm dev
```

This command:
- Starts the Electron main process
- Launches the Vite dev server for the renderer
- Enables hot module replacement
- Opens developer tools

### Production Build

```bash
# Build the application
pnpm build

# Run the built application
pnpm start
```

### Package for Distribution

```bash
# Create distributable packages
pnpm package
```

Packages will be created in the `release/` directory.

## Project Structure

```
context/
├── src/                      # Source code
│   ├── main/                # Electron main process
│   │   ├── index.ts        # Entry point, window management
│   │   ├── preload.ts      # Secure bridge between main/renderer
│   │   ├── database.ts     # SQLite database setup
│   │   ├── ai-handlers.ts  # AI SDK integration (Vercel AI)
│   │   └── task-handlers.ts # Task CRUD operations
│   │
│   ├── renderer/            # React application (runs in browser context)
│   │   ├── main.tsx        # React entry point
│   │   ├── App.tsx         # Main app component
│   │   ├── components/     # React components
│   │   │   ├── TaskTreeView.tsx  # Hierarchical task display
│   │   │   └── ChatView.tsx      # AI chat interface
│   │   ├── store/          # State management
│   │   │   └── taskStore.ts      # Zustand store for tasks
│   │   ├── styles/         # CSS and styling
│   │   └── types/          # TypeScript definitions
│   │
│   └── shared/             # Shared code between main/renderer
│
├── assets/                 # Application assets (icons, etc.)
├── doc/                    # Project documentation
├── docs/                   # Developer guides
│
├── flake.nix              # Nix environment definition
├── package.json           # Node.js dependencies
├── tsconfig.json          # TypeScript configuration
├── vite.config.ts         # Vite bundler config
├── tailwind.config.js     # Tailwind CSS config
└── .env.local             # Local environment variables (not in git)
```

### Key Files Explained

- **`src/main/index.ts`**: Creates the Electron window, handles app lifecycle
- **`src/main/preload.ts`**: Exposes safe APIs to the renderer process
- **`src/renderer/App.tsx`**: Main UI with split-pane layout
- **`flake.nix`**: Defines the complete development environment

## Key Concepts

### 1. Process Separation

Electron uses two types of processes:

- **Main Process**: Node.js environment with full system access
  - Manages windows
  - Handles file system
  - Runs AI SDK operations
  - Protects API keys

- **Renderer Process**: Chromium browser environment
  - Runs the React UI
  - Communicates via IPC
  - No direct system access

### 2. Secure Communication

```typescript
// In preload.ts - Safe API exposure
contextBridge.exposeInMainWorld('electron', {
  ai: {
    streamChat: (messages) => ipcRenderer.invoke('ai:stream-chat', messages),
    // ... other methods
  }
})

// In renderer - Using the API
const result = await window.electron.ai.streamChat(messages)
```

### 3. Task Hierarchy

Tasks are organized in a tree structure:
- Each task can have multiple subtasks
- Tasks can be executed interactively or autonomously
- Context is isolated per task to prevent degradation

### 4. State Management

- **Zustand** for client-side state
- **SQLite** for persistent storage
- **React Query** for server state (future)

## Development Workflow

### 1. Making UI Changes

Edit files in `src/renderer/`:
- Components will hot reload automatically
- Tailwind classes are available globally
- Use the custom scrollbar utility classes

### 2. Adding New IPC Handlers

1. Define the handler in `src/main/`:
```typescript
// In appropriate handler file
ipcMain.handle('my:action', async (event, arg) => {
  // Implementation
})
```

2. Expose in `src/main/preload.ts`:
```typescript
myFeature: {
  doAction: (arg) => ipcRenderer.invoke('my:action', arg)
}
```

3. Add types in `src/renderer/types/electron.d.ts`

### 3. Working with the Database

The SQLite database is initialized in `src/main/database.ts`:
- Tables are created on first run
- Database is stored in user's app data directory
- Use prepared statements for queries

### 4. Styling Guidelines

- Use Tailwind utility classes
- Custom colors defined in `tailwind.config.js`
- Support both light and dark modes
- Keep components responsive

## Troubleshooting

### Common Issues

#### "Cannot find module" errors
```bash
# Ensure all dependencies are installed
pnpm install

# If using Nix, reload the environment
direnv reload
```

#### Electron not starting
```bash
# Check if port 5173 is in use (Vite dev server)
lsof -i :5173

# Kill the process if needed
kill -9 <PID>
```

#### API errors
- Verify `.env.local` has valid API keys
- Check console for detailed error messages
- Ensure you have credits/access for the AI providers

#### Build errors with native modules
```bash
# Rebuild native modules for Electron
pnpm rebuild
```

### Debug Mode

Set environment variables for debugging:
```bash
# Enable Electron logging
ELECTRON_ENABLE_LOGGING=1 pnpm dev

# Enable Node debugging
NODE_OPTIONS='--inspect' pnpm dev
```

### Logs Location

- **Development**: Check the terminal and DevTools console
- **Production**: 
  - macOS: `~/Library/Logs/context/`
  - Linux: `~/.config/context/logs/`
  - Windows: `%USERPROFILE%\AppData\Roaming\context\logs\`

## Next Steps

1. Read the [Architecture Guide](./architecture.md) for deeper understanding
2. Check [Contributing Guidelines](../CONTRIBUTING.md) to submit changes
3. Explore the [original concept](./concept.md) for feature ideas

## Getting Help

- Check existing issues on GitHub
- Read the error messages carefully - they often contain the solution
- The Nix flake includes all necessary system dependencies
- Join our Discord community (link in main README)

---

Happy coding! 🚀 