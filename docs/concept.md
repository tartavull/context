# Context: Recursive Task Decomposition for Optimal LLM Performance

## The Problem: LLMs Get Lost in Long Conversations

Recent research from Microsoft reveals a critical limitation in Large Language Models:

- **39% Performance Drop**: All LLMs exhibit significantly worse performance in multi-turn conversations compared to single-turn interactions
- **Self-Poisoning Context**: Once an LLM makes an incorrect assumption, it rarely recovers, generating overly verbose responses that compound errors
- **Universal Problem**: This affects all models equally - GPT-4, Claude, Gemini, and open-source alternatives

> *"When LLMs take a wrong turn in a conversation, they get lost and do not recover."* - Microsoft Research, 2025

## The Solution: Keep Conversations Short and Focused

Context is a conversation router that recursively decomposes complex tasks into minimal sub-tasks, solving each in isolation with optimal performance. Instead of fighting the multi-turn degradation problem, we architect around it by keeping each LLM interaction within its optimal performance zone. Never lose context.

## How It Works

### The Simplest Version: A Chat That Creates Chats

1. You describe what you want: *"Build a todo app"*
2. Instead of one long conversation, the AI creates separate, focused chats:
   - Design the UI
   - Set up the database  
   - Implement the frontend
   - Write tests
3. Each chat maintains its own context, preventing pollution and confusion

### Visual Task Tree

<div class="mermaid">
graph LR
    A[Todo App Project] --> B[✓ Design Phase]
    A --> C[● Development - active]
    A --> D[Testing]
    
    B --> E[✓ User Stories]
    B --> F[✓ Mockups]
    
    C --> G[● Backend API]
    C --> H[Frontend]
    
    style B fill:#90ee90
    style E fill:#90ee90
    style F fill:#90ee90
    style C fill:#87ceeb
    style G fill:#87ceeb
    style A fill:#f0f0f0
    style D fill:#f0f0f0
    style H fill:#f0f0f0
</div>

Click any node to jump into that conversation. See what's done, what's active, and what's pending at a glance.

## Key Features

### 1. Smart Task Decomposition
The system automatically decides when to split vs. execute tasks:

<div class="mermaid">
graph LR
    A["Add authentication to my app"] --> B[Research auth providers<br/>autonomous]
    A --> C[Design auth flow<br/>interactive]
    A --> D[Implement login<br/>interactive]
    A --> E[Add session management<br/>autonomous]
    A --> F[Write auth tests<br/>autonomous]
    
    style B fill:#ffd700
    style C fill:#87ceeb
    style D fill:#87ceeb
    style E fill:#ffd700
    style F fill:#ffd700
    style A fill:#f0f0f0
</div>

### 2. Hybrid Execution Modes
- **Interactive Tasks**: You participate and guide the conversation (e.g., design decisions, complex logic)
- **Autonomous Tasks**: Run automatically without intervention (e.g., boilerplate generation, testing)
- **Hybrid Tasks**: Start automatically but can request your input when needed

### 3. Context Isolation
- Each task maintains minimal, focused context
- No information bleed between tasks
- Parent tasks can access child results
- Sibling tasks remain independent

### 4. Continuous Prompt Improvement
- Track success rates for each prompt template
- Identify "flaky" prompts with inconsistent results
- Built-in prompt workshop for iterative refinement
- Version control for prompt evolution

## User Interface

### Split-Screen Design

<div class="mermaid">
flowchart LR
    subgraph "Context UI"
        subgraph "Task Tree View"
            A[Project Root] --> B[✓ Setup]
            A --> C[● Frontend]
            A --> D[Deploy]
            C --> E[● Login]
            C --> F[Dashboard]
        end
        
        subgraph "Active Chat / Canvas Editor"
            G[Current: Frontend<br/><br/>AI: Let's implement<br/>the login component.<br/><br/>You: ...]
        end
    end
    
    C -.->|Active Task| G
    
    style B fill:#90ee90
    style C fill:#87ceeb
    style E fill:#87ceeb
    style A fill:#f0f0f0
    style D fill:#f0f0f0
    style F fill:#f0f0f0
</div>

### Key Interactions
- Click a task node to switch conversations
- Real-time status updates (pending, active, completed, failed)
- Drag and drop to reorganize tasks
- Jump into any conversation exactly where your expertise is needed

## Technical Architecture

### System Overview

<div class="mermaid">
flowchart LR
    subgraph UI["User Interface"]
        A[Task Tree View]
        B[Chat/Canvas Editor]
    end
    
    subgraph OL["Orchestration Layer"]
        C[Task Decomposer]
        D[Execution Manager<br/>Mode Selection]
        E[Context Isolation]
    end
    
    subgraph PF["Prompt Factory Layer"]
        F[Prompt Library & Versioning]
        G[Performance Tracking & Analytics]
        H[A/B Testing Infrastructure]
    end
    
    subgraph LLM["LLM Interface Layer"]
        I[Short, Focused Conversations]
    end
    
    UI --> OL
    OL --> PF
    PF --> LLM
    
    style UI fill:#e6f3ff
    style OL fill:#fff0e6
    style PF fill:#f0e6ff
    style LLM fill:#e6ffe6
</div>

### Technology Stack

- **Frontend**: Electron + React for rich visual interface and cross-platform support
- **AI Integration**: Vercel AI SDK for streaming responses and tool-calling
- **State Management**: Centralized task tree state with Zustand
- **Storage**: SQLite for task history and prompt versioning
- **Styling**: Tailwind CSS for modern, responsive design
- **Development**: TypeScript for type safety and better developer experience

## Implementation Roadmap

### Phase 1: MVP
- Basic chat that can spawn chats
- Simple parent-child relationships
- Manual task creation
- Core decomposition prompts

### Phase 2: Visual & Interactive
- Tree visualization component
- Real-time status tracking
- Interactive vs autonomous execution modes
- Basic prompt performance tracking

### Phase 3: Intelligence Layer
- Smart decomposition with dependency detection
- Parallel task execution
- Automated prompt optimization
- Pattern recognition for common workflows

### Phase 4: Scale & Polish
- Multi-model support
- Team collaboration features
- Advanced analytics dashboard
- Plugin system for extensibility

## Example: Feature Development Workflow

<div class="mermaid">
graph LR
    A["Add a shopping cart to my e-commerce site"] --> B[Shopping Cart Feature]
    
    B --> C[Research best practices<br/>Auto]
    B --> D[Design cart UI<br/>Interactive]
    B --> E[Set up database schema<br/>Auto]
    B --> F[Implement cart logic<br/>Interactive]
    B --> G[Create API endpoints<br/>Auto]
    B --> H[Frontend integration<br/>Interactive]
    B --> I[Write tests<br/>Auto]
    
    style C fill:#ffd700
    style D fill:#87ceeb
    style E fill:#ffd700
    style F fill:#87ceeb
    style G fill:#ffd700
    style H fill:#87ceeb
    style I fill:#ffd700
    style A fill:#f0f0f0
    style B fill:#f0f0f0
</div>

While you design the UI, the system:
- Researches best practices in the background
- Generates the database schema
- Creates boilerplate API endpoints

By the time you finish the design, much of the groundwork is complete.

## Prompt Engineering: The Secret Sauce

### Decomposition Prompt Template
```
You are a task decomposition expert. Given a user request:

1. If simple and atomic → Execute directly
2. If complex → Decompose into subtasks

For each subtask, specify:
- Clear, measurable objective
- Execution mode (interactive/autonomous)
- Dependencies on other tasks
- Expected outputs

Request: [user input]
```

### Continuous Improvement Process
1. Log all prompt executions with outcomes
2. Calculate success rates and identify patterns
3. A/B test variations on low-performing prompts
4. Build a library of proven patterns
5. Share successful prompts across the community

## Key Benefits

- **Optimal Performance**: Maintains conversations within the reliable single-turn performance zone
- **Parallel Progress**: Multiple tasks advance simultaneously
- **Transparency**: Full visibility into task decomposition and execution
- **User Control**: Jump in exactly where your expertise is needed
- **Continuous Learning**: System improves through usage patterns

## Success Metrics

- Task completion rate > 90%
- Average conversation length < 5 turns per task
- Context degradation incidents < 5%
- Time to complete complex tasks reduced by 50%
- Prompt improvement suggestions adoption rate > 70%

## Related Projects and Research

Several projects and research papers explore similar approaches to recursive task decomposition and multi-agent collaboration:

### Academic Research

1. **TDAG (Task Decomposition and Agent Generation)** - A framework that dynamically decomposes complex tasks into subtasks and assigns each to a specifically generated subagent. Shows 40% performance improvement over single-turn conversations.

2. **CoThinker** - Based on Cognitive Load Theory, distributes intrinsic cognitive load through agent specialization and manages transactional load via structured communication.

3. **Task Memory Engine (TME)** - Implements spatial memory frameworks with graph-based structures instead of linear context. Eliminates 100% of hallucinations in certain tasks.

4. **TalkHier (Talk Structurally, Act Hierarchically)** - Introduces structured communication protocols for context-rich exchanges and hierarchical refinement systems.

5. **Agentic Neural Networks (ANN)** - Conceptualizes multi-agent collaboration as a layered neural network architecture with forward/backward phase optimization.

### Open Source Projects

1. **Task Tree Agent** - LLM-powered autonomous agent with hierarchical task management by SuperpoweredAI. Uses dynamic tree structures for organizing tasks.

2. **AutoGPT & BabyAGI** - Early pioneering projects in autonomous agents that break down tasks and maintain task lists, though less focused on hierarchical decomposition.

3. **CrewAI** - Framework for orchestrating role-playing autonomous AI agents working together on complex tasks.

4. **LangChain Agents** - Provides tools for building agents with memory, planning, and tool integration capabilities.

### Key Differentiators of Context

While these projects share similar insights about task decomposition, Context distinguishes itself through:

- **Explicit focus on context degradation** - Built specifically to address the 39% performance drop in multi-turn conversations
- **Interactive/Autonomous hybrid execution** - Allows selective user intervention at the task level
- **Continuous prompt improvement system** - Built-in mechanisms for identifying and improving flaky prompts
- **Visual task tree interface** - Real-time visualization and navigation of the decomposition hierarchy

The convergence of multiple independent projects on similar architectures validates the core insight: keeping LLM conversations short and focused through recursive decomposition is a fundamental pattern for building reliable AI systems.

## Conclusion

Context transforms how we work with AI by embracing a fundamental truth: focused conversations work better than long, meandering ones. By building a system where chats can create and manage other chats, we unlock a new paradigm for AI-assisted work - one that's more efficient, more reliable, and more transparent.

The future of LLM applications lies not in trying to fix the multi-turn problem at the model level, but in building intelligent orchestration layers that work with the natural strengths of these systems.

## Get Involved

We're building Context in the open. Check out the [GitHub repository](https://github.com/tartavull/orchestrator) to follow our progress, contribute ideas, or build upon this concept.

---

## References

- ["LLMs Get Lost in Multi-Turn Conversation"](https://arxiv.org/abs/2401.16929) - Microsoft Research, 2025

## License

This project is licensed under the MIT License - see the [LICENSE](https://github.com/tartavull/orchestrator/blob/main/LICENSE) file for details. 