# Quick Start Guide

Get Context running in under 5 minutes.

## Prerequisites

- Git
- Nix package manager ([install](https://nixos.org/download.html))
- direnv ([install](https://direnv.net/docs/installation.html))

## Setup

```bash
# 1. Clone and enter directory
git clone https://github.com/your-org/context.git
cd context

# 2. Allow direnv (loads all dependencies via Nix)
direnv allow

# 3. Install Node packages
pnpm install

# 4. Add your API keys
echo "OPENAI_API_KEY=your-key-here" >> .env.local
echo "ANTHROPIC_API_KEY=your-key-here" >> .env.local

# 5. Start the app
pnpm dev
```

## What You'll See

1. **Electron window** opens with split-pane interface
2. **Left pane**: Task tree (create/organize tasks)
3. **Right pane**: Chat interface for selected task

## First Steps

1. Click **"Create New Task"** or **"New Task"** button
2. Select the task in the tree
3. Start chatting to execute or decompose the task
4. Watch as complex tasks are broken down automatically

## Key Commands

| Command | Description |
|---------|-------------|
| `pnpm dev` | Start development server |
| `pnpm build` | Build for production |
| `pnpm package` | Create distributable |
| `Cmd/Ctrl + ,` | Open preferences |
| `Cmd/Ctrl + N` | New task |

## Troubleshooting

**"command not found: direnv"**
```bash
# Install direnv first
nix-env -iA nixpkgs.direnv
# Then hook it to your shell (see direnv docs)
```

**"Cannot find module"**
```bash
# Reload environment and reinstall
direnv reload
pnpm install
```

**Port already in use**
```bash
# Kill process on port 5173
lsof -ti:5173 | xargs kill -9
```

## Next Steps

- Read the full [Getting Started Guide](./getting-started.md)
- Explore the [Architecture](./architecture.md)
- Check out the [original concept](./concept.md)

---

Need help? Open an issue on GitHub! 