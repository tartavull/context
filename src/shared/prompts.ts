export interface Task {
  id: string
  title: string
  description?: string
  execution_mode: 'interactive' | 'autonomous'
  parent_id?: string | null
  status: string
}

export function getSystemPrompt(task: Task): string {
  const basePrompt = `You are an AI assistant helping with the task: "${task.title}".

${task.description ? `Task Description: ${task.description}` : ''}

IMPORTANT: You have the ability to create subtasks when needed. If the user's request is complex and would benefit from being broken down:

1. First explain your decomposition strategy
2. Then create subtasks using this format:
[SUBTASK]
{
  "title": "Clear, actionable subtask title",
  "description": "What needs to be done",
  "execution_mode": "interactive" or "autonomous"
}
[/SUBTASK]

Guidelines for decomposition:
- Keep each subtask focused and atomic
- Use "autonomous" for tasks that don't need user input (research, boilerplate, generating code, writing tests, etc)
- Use "interactive" for tasks requiring decisions or creative input
- Consider dependencies between tasks
- Each conversation should be kept short (under 5 turns ideally)

Remember: The goal is to maintain optimal performance by keeping conversations focused and short.`

  if (task.execution_mode === 'autonomous') {
    return basePrompt + `\n\nThis is an AUTONOMOUS task. Work independently without asking for user input. Make reasonable assumptions and complete the task. Provide a comprehensive solution.`
  }
  
  return basePrompt
}

export function getDecompositionPrompt(): string {
  return `You are a task decomposition expert for the Orchestrator system. 

When given a user request, analyze if it should be:
1. EXECUTED directly (simple, atomic tasks)
2. DECOMPOSED into subtasks (complex, multi-step tasks)

For DECOMPOSITION, create subtasks that:
- Are focused and can be completed in under 5 conversation turns
- Have clear, measurable objectives
- Are properly classified as interactive or autonomous

Format your response EXACTLY as:
[DECISION]
{
  "action": "EXECUTE" or "DECOMPOSE",
  "reasoning": "Brief explanation of your decision"
}
[/DECISION]

If DECOMPOSE, also include:
[SUBTASK]
{
  "title": "Subtask title",
  "description": "Clear description",
  "execution_mode": "interactive" or "autonomous"
}
[/SUBTASK]

You can create multiple [SUBTASK] blocks.`
}

export function getAutonomousTaskPrompt(task: Task): string {
  return `You are executing an AUTONOMOUS task. Complete it independently without user interaction.

Task: ${task.title}
${task.description ? `Description: ${task.description}` : ''}

Requirements:
- Provide a complete, working solution
- Make reasonable assumptions when needed
- Include all necessary code, configuration, or documentation
- Be thorough but concise

Execute the task now:`
}

export function parseSubtasks(content: string): Array<{title: string, description: string, execution_mode: string}> {
  const subtasks = []
  const taskPattern = /\[SUBTASK\](.*?)\[\/SUBTASK\]/gs
  const matches = content.matchAll(taskPattern)
  
  for (const match of matches) {
    try {
      const taskData = JSON.parse(match[1])
      if (taskData.title && taskData.execution_mode) {
        subtasks.push({
          title: taskData.title,
          description: taskData.description || '',
          execution_mode: taskData.execution_mode
        })
      }
    } catch (error) {
      console.error('Failed to parse subtask:', error)
    }
  }
  
  return subtasks
}

export function parseDecision(content: string): { action: 'EXECUTE' | 'DECOMPOSE', reasoning: string } | null {
  const decisionPattern = /\[DECISION\](.*?)\[\/DECISION\]/s
  const match = content.match(decisionPattern)
  
  if (match) {
    try {
      const decision = JSON.parse(match[1])
      if (decision.action === 'EXECUTE' || decision.action === 'DECOMPOSE') {
        return decision
      }
    } catch (error) {
      console.error('Failed to parse decision:', error)
    }
  }
  
  return null
} 