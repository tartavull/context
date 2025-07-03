export interface Message {
  id: string
  role: 'user' | 'assistant'
  content: string
  timestamp: number
}

export interface Conversation {
  id: string
  messages: Message[]
  lastActivity: number
}

export interface Task {
  id: string
  title: string
  description: string
  status: 'pending' | 'active' | 'completed' | 'failed'
  nodeType: 'original' | 'clone' | 'spawn'
  executionMode: 'interactive' | 'autonomous'
  parentId?: string
  childIds: string[]
  position: { x: number; y: number }
  conversation: Conversation
  createdAt: number
  updatedAt: number
}

export interface Project {
  id: string
  title: string
  description: string
  status: 'active' | 'pending' | 'completed' | 'failed'
  tasks: Record<string, Task>
  rootTaskIds: string[]
  createdAt: number
  updatedAt: number
}

export interface AppState {
  projects: Record<string, Project>
  selectedProjectId: string | null
  selectedTaskId: string | null
  ui: {
    showProjects: boolean
    showChart: boolean
    showChat: boolean
    projectsCollapsed: boolean
    projectsPanelSize: number
  }
}

// Helper functions
export const createTask = (
  title: string,
  description: string,
  nodeType: Task['nodeType'] = 'original',
  parentId?: string,
  position: { x: number; y: number } = { x: 0, y: 0 }
): Task => ({
  id: `task-${Date.now()}-${Math.random().toString(36).substr(2, 9)}`,
  title,
  description,
  status: 'pending',
  nodeType,
  executionMode: 'interactive',
  parentId,
  childIds: [],
  position,
  conversation: {
    id: `conv-${Date.now()}-${Math.random().toString(36).substr(2, 9)}`,
    messages: [],
    lastActivity: Date.now(),
  },
  createdAt: Date.now(),
  updatedAt: Date.now(),
})

export const createProject = (title: string, description: string): Project => {
  const rootTask = createTask(title, description, 'original', undefined, { x: 50, y: 200 })
  
  return {
    id: `project-${Date.now()}-${Math.random().toString(36).substr(2, 9)}`,
    title,
    description,
    status: 'active',
    tasks: {
      [rootTask.id]: rootTask,
    },
    rootTaskIds: [rootTask.id],
    createdAt: Date.now(),
    updatedAt: Date.now(),
  }
}

// Sample data
export const sampleAppState: AppState = {
  projects: {
    'project-1': {
      id: 'project-1',
      title: 'Build Todo App',
      description: 'Create a modern todo application with React',
      status: 'active',
      tasks: {
        'task-1': {
          id: 'task-1',
          title: 'Build Todo App',
          description: 'Create a modern todo application with React',
          status: 'active',
          nodeType: 'original',
          executionMode: 'interactive',
          childIds: ['task-2', 'task-3'],
          position: { x: 50, y: 200 },
          conversation: {
            id: 'conv-1',
            messages: [
              {
                id: 'msg-1',
                role: 'user',
                content: 'Let\'s build a todo app with React',
                timestamp: Date.now() - 3600000,
              },
              {
                id: 'msg-2',
                role: 'assistant',
                content: 'Great! I\'ll help you build a modern todo app. Let\'s start by planning the components and state management.',
                timestamp: Date.now() - 3500000,
              },
            ],
            lastActivity: Date.now() - 3500000,
          },
          createdAt: Date.now() - 86400000,
          updatedAt: Date.now() - 3500000,
        },
        'task-2': {
          id: 'task-2',
          title: 'Design UI Components',
          description: 'Create reusable UI components for the todo app',
          status: 'completed',
          nodeType: 'spawn',
          executionMode: 'interactive',
          parentId: 'task-1',
          childIds: [],
          position: { x: 350, y: 110 },
          conversation: {
            id: 'conv-2',
            messages: [
              {
                id: 'msg-3',
                role: 'user',
                content: 'Can you help me design the UI components?',
                timestamp: Date.now() - 3000000,
              },
              {
                id: 'msg-4',
                role: 'assistant',
                content: 'Absolutely! Let\'s create a TodoItem component, TodoList, and AddTodo form. I\'ll use modern React patterns.',
                timestamp: Date.now() - 2900000,
              },
            ],
            lastActivity: Date.now() - 2900000,
          },
          createdAt: Date.now() - 72000000,
          updatedAt: Date.now() - 2900000,
        },
        'task-3': {
          id: 'task-3',
          title: 'Implement State Management',
          description: 'Set up state management with Context API',
          status: 'active',
          nodeType: 'clone',
          executionMode: 'interactive',
          parentId: 'task-1',
          childIds: [],
          position: { x: 350, y: 290 },
          conversation: {
            id: 'conv-3',
            messages: [
              {
                id: 'msg-5',
                role: 'user',
                content: 'How should we handle state management?',
                timestamp: Date.now() - 1800000,
              },
              {
                id: 'msg-6',
                role: 'assistant',
                content: 'For this todo app, I recommend using React\'s Context API with useReducer for state management. It\'s perfect for this scale.',
                timestamp: Date.now() - 1700000,
              },
            ],
            lastActivity: Date.now() - 1700000,
          },
          createdAt: Date.now() - 48000000,
          updatedAt: Date.now() - 1700000,
        },
      },
      rootTaskIds: ['task-1'],
      createdAt: Date.now() - 86400000,
      updatedAt: Date.now() - 1700000,
    },
    'project-2': {
      id: 'project-2',
      title: 'Design System',
      description: 'Build a comprehensive design system',
      status: 'pending',
      tasks: {
        'task-4': {
          id: 'task-4',
          title: 'Design System',
          description: 'Build a comprehensive design system with tokens and components',
          status: 'pending',
          nodeType: 'original',
          executionMode: 'interactive',
          childIds: [],
          position: { x: 50, y: 200 },
          conversation: {
            id: 'conv-4',
            messages: [],
            lastActivity: Date.now() - 172800000,
          },
          createdAt: Date.now() - 172800000,
          updatedAt: Date.now() - 172800000,
        },
      },
      rootTaskIds: ['task-4'],
      createdAt: Date.now() - 172800000,
      updatedAt: Date.now() - 172800000,
    },
    'project-3': {
      id: 'project-3',
      title: 'API Integration',
      description: 'Integrate with external APIs',
      status: 'completed',
      tasks: {
        'task-5': {
          id: 'task-5',
          title: 'API Integration',
          description: 'Set up REST API integration with proper error handling',
          status: 'completed',
          nodeType: 'original',
          executionMode: 'interactive',
          childIds: [],
          position: { x: 50, y: 200 },
          conversation: {
            id: 'conv-5',
            messages: [
              {
                id: 'msg-7',
                role: 'user',
                content: 'I need to integrate with a REST API',
                timestamp: Date.now() - 259200000,
              },
              {
                id: 'msg-8',
                role: 'assistant',
                content: 'I\'ll help you set up proper API integration with fetch, error handling, and loading states.',
                timestamp: Date.now() - 259100000,
              },
            ],
            lastActivity: Date.now() - 259100000,
          },
          createdAt: Date.now() - 259200000,
          updatedAt: Date.now() - 259100000,
        },
      },
      rootTaskIds: ['task-5'],
      createdAt: Date.now() - 259200000,
      updatedAt: Date.now() - 259100000,
    },
  },
  selectedProjectId: null,
  selectedTaskId: null,
  ui: {
    showProjects: true,
    showChart: true,
    showChat: true,
    projectsCollapsed: false,
    projectsPanelSize: 30,
  },
} 