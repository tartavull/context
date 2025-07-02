# Context

> **Stop losing 39% of your AI's capability in long conversations.** 

Context is a desktop app that revolutionizes how you work with AI by keeping conversations short, focused, and optimally effective. Never lose context.

<div align="center">
  
[![Download Latest Release](https://img.shields.io/github/v/release/tartavull/orchestrator?color=brightgreen&label=Download&style=for-the-badge)](https://github.com/tartavull/orchestrator/releases/latest)
[![Windows](https://img.shields.io/badge/Windows-0078D6?style=flat-square&logo=windows&logoColor=white)](https://github.com/tartavull/orchestrator/releases/latest)
[![macOS](https://img.shields.io/badge/macOS-000000?style=flat-square&logo=apple&logoColor=white)](https://github.com/tartavull/orchestrator/releases/latest)
[![Linux](https://img.shields.io/badge/Linux-FCC624?style=flat-square&logo=linux&logoColor=black)](https://github.com/tartavull/orchestrator/releases/latest)

</div>

## The Problem

Microsoft Research shows that **ALL** major LLMs (GPT-4, Claude, Gemini) lose 39% of their performance in multi-turn conversations. Once they make a wrong assumption, they rarely recover.

## The Solution

Context automatically breaks complex tasks into focused sub-conversations, maintaining peak AI performance throughout your project.

```
Your request: "Build a todo app"
                    ↓
           Context creates:
    ┌────────────┬────────────┬──────────┐
    │ Design UI  │ Setup DB   │ Frontend │ → Each in its own 
    │ (focused)  │ (focused)  │ (focused)│   optimized conversation
    └────────────┴────────────┴──────────┘
```

## Key Benefits

- ✅ **39% Better AI Performance** - Keep conversations in the optimal single-turn zone
- ✅ **Parallel Progress** - Multiple tasks advance simultaneously  
- ✅ **Visual Task Management** - See your entire project at a glance
- ✅ **No Context Pollution** - Each task has its own clean context

## Quick Start

```bash
# Clone the repository
git clone https://github.com/tartavull/orchestrator.git
cd orchestrator

# Set up environment (with Nix)
direnv allow

# Install and run
pnpm install
pnpm dev
```

## Documentation

📚 **[Read the full documentation →](https://tartavull.github.io/orchestrator/)**

- [Quick Start Guide](https://tartavull.github.io/orchestrator/quick-start) - Get running in 5 minutes
- [Getting Started](https://tartavull.github.io/orchestrator/getting-started) - Complete setup guide
- [Architecture](https://tartavull.github.io/orchestrator/architecture) - Technical deep dive
- [Original Concept](https://tartavull.github.io/orchestrator/concept) - The research and vision

## Who It's For

- **Developers** building complex applications with AI assistance
- **Researchers** who need reliable, consistent AI performance
- **Teams** working on multi-faceted projects
- **Anyone** frustrated by AI getting confused in long conversations

We welcome contributions! See our [documentation](https://tartavull.github.io/orchestrator/) for development setup.

## License

MIT License - see [LICENSE](LICENSE) file for details.

---

*Based on research: ["LLMs Get Lost in the Middle of Long Contexts"](https://arxiv.org/abs/2401.16929) - Microsoft Research, 2024* 