# Orchestrator Electron App

This is the Electron implementation of the Orchestrator - a recursive task decomposition system for optimal LLM performance.

## Setup

### Prerequisites

1. Install Nix package manager if you haven't already
2. Install direnv and hook it to your shell

### Development Setup

1. Navigate to the project directory:
   ```bash
   cd orchestrator
   ```

2. Allow direnv to load the environment:
   ```bash
   direnv allow
   ```

3. Install dependencies:
   ```bash
   pnpm install
   ```

4. Set up your API keys in `.env.local`:
   ```bash
   # Add your API keys
   OPENAI_API_KEY=your-openai-key-here
   ANTHROPIC_API_KEY=your-anthropic-key-here
   ```

5. Start the development server:
   ```bash
   pnpm dev
   ```

## Project Structure

```
orchestrator/
├── src/
│   ├── main/           # Electron main process
│   │   ├── index.ts    # Main entry point
│   │   ├── preload.ts  # Preload script
│   │   ├── database.ts # SQLite database
│   │   ├── ai-handlers.ts      # AI SDK integration
│   │   └── task-handlers.ts    # Task management
│   ├── renderer/       # React renderer process
│   │   ├── App.tsx     # Main app component
│   │   ├── components/ # React components
│   │   ├── store/      # Zustand stores
│   │   └── styles/     # CSS and styling
│   └── shared/         # Shared types/utilities
├── doc/               # Documentation
│   └── README.md      # Original project concept
├── flake.nix          # Nix flake configuration
├── package.json       # NPM dependencies
└── README.md          # This file
```

## Available Scripts

- `pnpm dev` - Start development server
- `pnpm build` - Build for production
- `pnpm start` - Run built application
- `pnpm package` - Package application for distribution
- `pnpm lint` - Run ESLint
- `pnpm format` - Format code with Prettier

## Features

- **Task Tree View**: Visual representation of task hierarchy
- **Chat Interface**: AI-powered chat for each task
- **Task Decomposition**: Automatically break down complex tasks
- **Execution Modes**: Interactive or autonomous task execution
- **Prompt Library**: Manage and version prompts
- **Performance Tracking**: Monitor prompt effectiveness
- **SQLite Database**: Local storage for tasks and conversations

## Technologies

- **Electron**: Desktop application framework
- **React**: UI framework
- **TypeScript**: Type safety
- **Vercel AI SDK**: AI integration
- **SQLite**: Local database
- **Tailwind CSS**: Styling
- **Zustand**: State management
- **Nix**: Reproducible development environment

## Development Notes

- The app uses Electron's context isolation for security
- All AI operations happen in the main process to protect API keys
- The SQLite database is stored in the user's app data directory
- Hot reload is enabled for the renderer process in development

## Building for Production

To build the application for distribution:

```bash
pnpm build
pnpm package
```

The packaged application will be available in the `release` directory.

## License

See the main project README for license information. 