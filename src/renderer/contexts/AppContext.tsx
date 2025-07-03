import React, { createContext, useContext, useReducer, ReactNode } from 'react'
import { AppState, Project, Task, Message, sampleAppState, createProject, createTask } from '../types/app-state'

// Helper function to calculate tree layout positions for all tasks
const calculateTreeLayout = (
  tasks: Record<string, Task>,
  rootTaskIds: string[],
  columnWidth = 280,
  nodeHeight = 160,
  verticalSpacing = 20,
  startX = 50,
  startY = 50
): Record<string, { x: number; y: number }> => {
  const positions: Record<string, { x: number; y: number }> = {}
  
  // Build tree structure by levels
  const levels: string[][] = []
  const visited = new Set<string>()
  
  // BFS to organize nodes by level
  const queue: Array<{ taskId: string; level: number }> = []
  
  // Start with root tasks
  rootTaskIds.forEach(rootId => {
    queue.push({ taskId: rootId, level: 0 })
  })
  
  while (queue.length > 0) {
    const { taskId, level } = queue.shift()!
    
    if (visited.has(taskId)) continue
    visited.add(taskId)
    
    const task = tasks[taskId]
    if (!task) continue
    
    // Ensure we have enough levels
    while (levels.length <= level) {
      levels.push([])
    }
    
    levels[level].push(taskId)
    
    // Add children to queue
    task.childIds.forEach(childId => {
      if (!visited.has(childId)) {
        queue.push({ taskId: childId, level: level + 1 })
      }
    })
  }
  
  // Calculate positions for each level
  levels.forEach((levelTasks, levelIndex) => {
    const x = startX + (levelIndex * columnWidth)
    
    // Calculate total height needed for this level
    const totalNodesHeight = levelTasks.length * nodeHeight
    const totalSpacingHeight = (levelTasks.length - 1) * verticalSpacing
    const totalHeight = totalNodesHeight + totalSpacingHeight
    
    // Start Y position to center the level vertically
    let currentY = startY
    if (levelTasks.length > 1) {
      // If we have multiple nodes, distribute them evenly
      currentY = Math.max(startY, 200 - (totalHeight / 2))
    } else {
      // Single node, center it around y=200
      currentY = 200 - (nodeHeight / 2)
    }
    
    // Position each task in this level
    levelTasks.forEach((taskId, taskIndex) => {
      positions[taskId] = {
        x: x,
        y: currentY + (taskIndex * (nodeHeight + verticalSpacing))
      }
    })
  })
  
  return positions
}

// Helper function to get position for a specific task
const calculateTreePosition = (
  taskId: string,
  tasks: Record<string, Task>,
  rootTaskIds: string[]
): { x: number; y: number } => {
  const allPositions = calculateTreeLayout(tasks, rootTaskIds)
  return allPositions[taskId] || { x: 50, y: 200 }
}

// Helper function for manual positioning (used for clones and spawns)
const findNonOverlappingPosition = (
  preferredPosition: { x: number; y: number },
  existingPositions: { x: number; y: number }[],
  boxWidth = 220,
  boxHeight = 140,
  margin = 30
): { x: number; y: number } => {
  const isOverlapping = (pos1: { x: number; y: number }, pos2: { x: number; y: number }) => {
    return !(
      pos1.x + boxWidth + margin < pos2.x ||
      pos2.x + boxWidth + margin < pos1.x ||
      pos1.y + boxHeight + margin < pos2.y ||
      pos2.y + boxHeight + margin < pos1.y
    )
  }

  // If no existing positions, return preferred position
  if (existingPositions.length === 0) {
    return { ...preferredPosition }
  }

  let position = { ...preferredPosition }

  // First check if preferred position is already clear
  if (!existingPositions.some(existingPos => isOverlapping(position, existingPos))) {
    return position
  }

  // Try positions below and above the preferred position
  for (let offset = nodeSpacing; offset <= nodeSpacing * 5; offset += nodeSpacing) {
    // Try below
    position = { x: preferredPosition.x, y: preferredPosition.y + offset }
    if (!existingPositions.some(existingPos => isOverlapping(position, existingPos))) {
      return position
    }

    // Try above
    position = { x: preferredPosition.x, y: preferredPosition.y - offset }
    if (position.y >= 50 && !existingPositions.some(existingPos => isOverlapping(position, existingPos))) {
      return position
    }
  }

  // Fallback: place far below
  return {
    x: preferredPosition.x,
    y: preferredPosition.y + (existingPositions.length * nodeSpacing)
  }
}

const nodeSpacing = 180

// Action types
type AppAction = 
  | { type: 'SET_SELECTED_PROJECT'; payload: string | null }
  | { type: 'SET_SELECTED_TASK'; payload: string | null }
  | { type: 'CREATE_PROJECT'; payload: { title: string; description: string } }
  | { type: 'UPDATE_PROJECT'; payload: { projectId: string; updates: Partial<Project> } }
  | { type: 'DELETE_PROJECT'; payload: string }
  | { type: 'CREATE_TASK'; payload: { projectId: string; title: string; description: string; nodeType: Task['nodeType']; parentId?: string; position: { x: number; y: number } } }
  | { type: 'UPDATE_TASK'; payload: { projectId: string; taskId: string; updates: Partial<Task> } }
  | { type: 'DELETE_TASK'; payload: { projectId: string; taskId: string } }
  | { type: 'ADD_MESSAGE'; payload: { projectId: string; taskId: string; message: Message } }
  | { type: 'UPDATE_UI'; payload: Partial<AppState['ui']> }
  | { type: 'CLONE_TASK'; payload: { projectId: string; taskId: string } }
  | { type: 'SPAWN_TASK'; payload: { projectId: string; parentTaskId: string; title: string; description: string } }
  | { type: 'RECALCULATE_LAYOUT'; payload: { projectId: string } }

// Reducer function
function appReducer(state: AppState, action: AppAction): AppState {
  switch (action.type) {
    case 'SET_SELECTED_PROJECT':
      return {
        ...state,
        selectedProjectId: action.payload,
        selectedTaskId: null, // Reset selected task when changing projects
      }

    case 'SET_SELECTED_TASK':
      return {
        ...state,
        selectedTaskId: action.payload,
      }

    case 'CREATE_PROJECT': {
      const newProject = createProject(action.payload.title, action.payload.description)
      return {
        ...state,
        projects: {
          ...state.projects,
          [newProject.id]: newProject,
        },
        selectedProjectId: newProject.id,
      }
    }

    case 'UPDATE_PROJECT': {
      const { projectId, updates } = action.payload
      const project = state.projects[projectId]
      if (!project) return state

      return {
        ...state,
        projects: {
          ...state.projects,
          [projectId]: {
            ...project,
            ...updates,
            updatedAt: Date.now(),
          },
        },
      }
    }

    case 'DELETE_PROJECT': {
      const { [action.payload]: deleted, ...remainingProjects } = state.projects
      return {
        ...state,
        projects: remainingProjects,
        selectedProjectId: state.selectedProjectId === action.payload ? null : state.selectedProjectId,
        selectedTaskId: null,
      }
    }

    case 'CREATE_TASK': {
      const { projectId, title, description, nodeType, parentId, position } = action.payload
      const project = state.projects[projectId]
      if (!project) return state

      const newTask = createTask(title, description, nodeType, parentId, { x: 0, y: 0 })
      
      // Update parent task's childIds if this is a child task
      const updatedTasks = { ...project.tasks }
      if (parentId && updatedTasks[parentId]) {
        updatedTasks[parentId] = {
          ...updatedTasks[parentId],
          childIds: [...updatedTasks[parentId].childIds, newTask.id],
          updatedAt: Date.now(),
        }
      }

      updatedTasks[newTask.id] = newTask
      const newRootTaskIds = parentId ? project.rootTaskIds : [...project.rootTaskIds, newTask.id]

      // Recalculate all positions
      const newPositions = calculateTreeLayout(updatedTasks, newRootTaskIds)
      Object.keys(newPositions).forEach(taskId => {
        if (updatedTasks[taskId]) {
          updatedTasks[taskId] = {
            ...updatedTasks[taskId],
            position: newPositions[taskId],
            updatedAt: Date.now(),
          }
        }
      })

      return {
        ...state,
        projects: {
          ...state.projects,
          [projectId]: {
            ...project,
            tasks: updatedTasks,
            rootTaskIds: newRootTaskIds,
            updatedAt: Date.now(),
          },
        },
        selectedTaskId: newTask.id,
      }
    }

    case 'UPDATE_TASK': {
      const { projectId, taskId, updates } = action.payload
      const project = state.projects[projectId]
      if (!project || !project.tasks[taskId]) return state

      return {
        ...state,
        projects: {
          ...state.projects,
          [projectId]: {
            ...project,
            tasks: {
              ...project.tasks,
              [taskId]: {
                ...project.tasks[taskId],
                ...updates,
                updatedAt: Date.now(),
              },
            },
            updatedAt: Date.now(),
          },
        },
      }
    }

    case 'DELETE_TASK': {
      const { projectId, taskId } = action.payload
      const project = state.projects[projectId]
      if (!project || !project.tasks[taskId]) return state

      const task = project.tasks[taskId]
      const { [taskId]: deleted, ...remainingTasks } = project.tasks

      // Remove from parent's childIds
      if (task.parentId && remainingTasks[task.parentId]) {
        remainingTasks[task.parentId] = {
          ...remainingTasks[task.parentId],
          childIds: remainingTasks[task.parentId].childIds.filter(id => id !== taskId),
          updatedAt: Date.now(),
        }
      }

      return {
        ...state,
        projects: {
          ...state.projects,
          [projectId]: {
            ...project,
            tasks: remainingTasks,
            rootTaskIds: project.rootTaskIds.filter(id => id !== taskId),
            updatedAt: Date.now(),
          },
        },
        selectedTaskId: state.selectedTaskId === taskId ? null : state.selectedTaskId,
      }
    }

    case 'ADD_MESSAGE': {
      const { projectId, taskId, message } = action.payload
      const project = state.projects[projectId]
      if (!project || !project.tasks[taskId]) return state

      const task = project.tasks[taskId]
      return {
        ...state,
        projects: {
          ...state.projects,
          [projectId]: {
            ...project,
            tasks: {
              ...project.tasks,
              [taskId]: {
                ...task,
                conversation: {
                  ...task.conversation,
                  messages: [...task.conversation.messages, message],
                  lastActivity: Date.now(),
                },
                updatedAt: Date.now(),
              },
            },
            updatedAt: Date.now(),
          },
        },
      }
    }

    case 'CLONE_TASK': {
      const { projectId, taskId } = action.payload
      const project = state.projects[projectId]
      if (!project || !project.tasks[taskId]) return state

      const originalTask = project.tasks[taskId]
      const clonedTask = createTask(
        `${originalTask.title} (Clone)`,
        originalTask.description,
        'clone',
        originalTask.parentId,
        { x: 0, y: 0 }
      )

      // Update parent task's childIds if this is a child task
      const updatedTasks = { ...project.tasks }
      if (originalTask.parentId && updatedTasks[originalTask.parentId]) {
        updatedTasks[originalTask.parentId] = {
          ...updatedTasks[originalTask.parentId],
          childIds: [...updatedTasks[originalTask.parentId].childIds, clonedTask.id],
          updatedAt: Date.now(),
        }
      }

      updatedTasks[clonedTask.id] = clonedTask
      const newRootTaskIds = originalTask.parentId ? project.rootTaskIds : [...project.rootTaskIds, clonedTask.id]

      // Recalculate all positions
      const newPositions = calculateTreeLayout(updatedTasks, newRootTaskIds)
      Object.keys(newPositions).forEach(taskId => {
        if (updatedTasks[taskId]) {
          updatedTasks[taskId] = {
            ...updatedTasks[taskId],
            position: newPositions[taskId],
            updatedAt: Date.now(),
          }
        }
      })

      return {
        ...state,
        projects: {
          ...state.projects,
          [projectId]: {
            ...project,
            tasks: updatedTasks,
            rootTaskIds: newRootTaskIds,
            updatedAt: Date.now(),
          },
        },
        selectedTaskId: clonedTask.id,
      }
    }

    case 'SPAWN_TASK': {
      const { projectId, parentTaskId, title, description } = action.payload
      const project = state.projects[projectId]
      if (!project || !project.tasks[parentTaskId]) return state

      const parentTask = project.tasks[parentTaskId]
      const spawnedTask = createTask(title, description, 'spawn', parentTaskId, { x: 0, y: 0 })

      const updatedTasks = { ...project.tasks }
      updatedTasks[parentTaskId] = {
        ...parentTask,
        childIds: [...parentTask.childIds, spawnedTask.id],
        updatedAt: Date.now(),
      }
      updatedTasks[spawnedTask.id] = spawnedTask

      // Recalculate all positions
      const newPositions = calculateTreeLayout(updatedTasks, project.rootTaskIds)
      Object.keys(newPositions).forEach(taskId => {
        if (updatedTasks[taskId]) {
          updatedTasks[taskId] = {
            ...updatedTasks[taskId],
            position: newPositions[taskId],
            updatedAt: Date.now(),
          }
        }
      })

      return {
        ...state,
        projects: {
          ...state.projects,
          [projectId]: {
            ...project,
            tasks: updatedTasks,
            updatedAt: Date.now(),
          },
        },
        selectedTaskId: spawnedTask.id,
      }
    }

    case 'UPDATE_UI':
      return {
        ...state,
        ui: {
          ...state.ui,
          ...action.payload,
        },
      }

    case 'RECALCULATE_LAYOUT': {
      const { projectId } = action.payload
      const project = state.projects[projectId]
      if (!project) return state

      // Recalculate all positions using tree layout
      const newPositions = calculateTreeLayout(project.tasks, project.rootTaskIds)
      
      const updatedTasks = { ...project.tasks }
      Object.keys(newPositions).forEach(taskId => {
        if (updatedTasks[taskId]) {
          updatedTasks[taskId] = {
            ...updatedTasks[taskId],
            position: newPositions[taskId],
            updatedAt: Date.now(),
          }
        }
      })

      return {
        ...state,
        projects: {
          ...state.projects,
          [projectId]: {
            ...project,
            tasks: updatedTasks,
            updatedAt: Date.now(),
          },
        },
      }
    }

    default:
      return state
  }
}

// Context
interface AppContextType {
  state: AppState
  dispatch: React.Dispatch<AppAction>
  // Helper functions
  selectProject: (projectId: string | null) => void
  selectTask: (taskId: string | null) => void
  createProject: (title: string, description: string) => void
  updateProject: (projectId: string, updates: Partial<Project>) => void
  deleteProject: (projectId: string) => void
  createTask: (projectId: string, title: string, description: string, nodeType: Task['nodeType'], parentId?: string, position?: { x: number; y: number }) => void
  updateTask: (projectId: string, taskId: string, updates: Partial<Task>) => void
  deleteTask: (projectId: string, taskId: string) => void
  addMessage: (projectId: string, taskId: string, message: Message) => void
  cloneTask: (projectId: string, taskId: string) => void
  spawnTask: (projectId: string, parentTaskId: string, title: string, description: string) => void
  updateUI: (updates: Partial<AppState['ui']>) => void
  recalculateLayout: (projectId: string) => void
  // Getters
  getSelectedProject: () => Project | null
  getSelectedTask: () => Task | null
  getProjectTasks: (projectId: string) => Task[]
}

const AppContext = createContext<AppContextType | undefined>(undefined)

// Provider component
interface AppProviderProps {
  children: ReactNode
}

export function AppProvider({ children }: AppProviderProps) {
  const [state, dispatch] = useReducer(appReducer, sampleAppState)

  // Helper functions
  const selectProject = (projectId: string | null) => {
    dispatch({ type: 'SET_SELECTED_PROJECT', payload: projectId })
  }

  const selectTask = (taskId: string | null) => {
    dispatch({ type: 'SET_SELECTED_TASK', payload: taskId })
  }

  const createProjectAction = (title: string, description: string) => {
    dispatch({ type: 'CREATE_PROJECT', payload: { title, description } })
  }

  const updateProject = (projectId: string, updates: Partial<Project>) => {
    dispatch({ type: 'UPDATE_PROJECT', payload: { projectId, updates } })
  }

  const deleteProject = (projectId: string) => {
    dispatch({ type: 'DELETE_PROJECT', payload: projectId })
  }

  const createTaskAction = (projectId: string, title: string, description: string, nodeType: Task['nodeType'], parentId?: string, position = { x: 100, y: 100 }) => {
    dispatch({ type: 'CREATE_TASK', payload: { projectId, title, description, nodeType, parentId, position } })
  }

  const updateTask = (projectId: string, taskId: string, updates: Partial<Task>) => {
    dispatch({ type: 'UPDATE_TASK', payload: { projectId, taskId, updates } })
  }

  const deleteTask = (projectId: string, taskId: string) => {
    dispatch({ type: 'DELETE_TASK', payload: { projectId, taskId } })
  }

  const addMessage = (projectId: string, taskId: string, message: Message) => {
    dispatch({ type: 'ADD_MESSAGE', payload: { projectId, taskId, message } })
  }

  const cloneTask = (projectId: string, taskId: string) => {
    dispatch({ type: 'CLONE_TASK', payload: { projectId, taskId } })
  }

  const spawnTask = (projectId: string, parentTaskId: string, title: string, description: string) => {
    dispatch({ type: 'SPAWN_TASK', payload: { projectId, parentTaskId, title, description } })
  }

  const updateUI = (updates: Partial<AppState['ui']>) => {
    dispatch({ type: 'UPDATE_UI', payload: updates })
  }

  const recalculateLayout = (projectId: string) => {
    dispatch({ type: 'RECALCULATE_LAYOUT', payload: { projectId } })
  }

  // Getters
  const getSelectedProject = (): Project | null => {
    return state.selectedProjectId ? state.projects[state.selectedProjectId] || null : null
  }

  const getSelectedTask = (): Task | null => {
    const project = getSelectedProject()
    return project && state.selectedTaskId ? project.tasks[state.selectedTaskId] || null : null
  }

  const getProjectTasks = (projectId: string): Task[] => {
    const project = state.projects[projectId]
    return project ? Object.values(project.tasks) : []
  }

  const contextValue: AppContextType = {
    state,
    dispatch,
    selectProject,
    selectTask,
    createProject: createProjectAction,
    updateProject,
    deleteProject,
    createTask: createTaskAction,
    updateTask,
    deleteTask,
    addMessage,
    cloneTask,
    spawnTask,
    updateUI,
    recalculateLayout,
    getSelectedProject,
    getSelectedTask,
    getProjectTasks,
  }

  return (
    <AppContext.Provider value={contextValue}>
      {children}
    </AppContext.Provider>
  )
}

// Hook to use the context
export function useApp() {
  const context = useContext(AppContext)
  if (context === undefined) {
    throw new Error('useApp must be used within an AppProvider')
  }
  return context
} 