import { create } from 'zustand'
import { toast } from 'react-hot-toast'

interface Task {
  id: string
  parent_id: string | null
  title: string
  description: string
  status: 'pending' | 'active' | 'completed' | 'failed'
  execution_mode: 'interactive' | 'autonomous'
  created_at: number
  updated_at: number
  completed_at: number | null
  metadata: any
}

interface TaskStore {
  tasks: Map<string, Task>
  selectedTaskId: string | null
  isLoading: boolean
  
  // Actions
  loadTasks: () => Promise<void>
  createTask: (task: Partial<Task>) => Promise<string | null>
  updateTask: (taskId: string, updates: Partial<Task>) => Promise<void>
  deleteTask: (taskId: string) => Promise<void>
  selectTask: (taskId: string | null) => void
  getTaskChildren: (taskId: string) => Task[]
  getTaskPath: (taskId: string) => Task[]
}

export const useTaskStore = create<TaskStore>((set, get) => ({
  tasks: new Map(),
  selectedTaskId: null,
  isLoading: false,
  
  loadTasks: async () => {
    set({ isLoading: true })
    try {
      const result = await window.electron.tasks.getAll()
      if (result.success && result.tasks) {
        const tasksMap = new Map(result.tasks.map(task => [task.id, task]))
        set({ tasks: tasksMap })
      } else {
        toast.error(result.error || 'Failed to load tasks')
      }
    } catch (error) {
      toast.error('Failed to load tasks')
      console.error(error)
    } finally {
      set({ isLoading: false })
    }
  },
  
  createTask: async (taskData) => {
    try {
      const result = await window.electron.tasks.create(taskData)
      if (result.success && result.id) {
        // Reload tasks to get the new task
        await get().loadTasks()
        toast.success('Task created')
        return result.id
      } else {
        toast.error(result.error || 'Failed to create task')
        return null
      }
    } catch (error) {
      toast.error('Failed to create task')
      console.error(error)
      return null
    }
  },
  
  updateTask: async (taskId, updates) => {
    try {
      const result = await window.electron.tasks.update(taskId, updates)
      if (result.success) {
        // Update local state
        const tasks = new Map(get().tasks)
        const task = tasks.get(taskId)
        if (task) {
          tasks.set(taskId, { ...task, ...updates })
          set({ tasks })
        }
        toast.success('Task updated')
      } else {
        toast.error(result.error || 'Failed to update task')
      }
    } catch (error) {
      toast.error('Failed to update task')
      console.error(error)
    }
  },
  
  deleteTask: async (taskId) => {
    try {
      const result = await window.electron.tasks.delete(taskId)
      if (result.success) {
        // Remove from local state
        const tasks = new Map(get().tasks)
        tasks.delete(taskId)
        set({ tasks })
        
        // If this was the selected task, clear selection
        if (get().selectedTaskId === taskId) {
          set({ selectedTaskId: null })
        }
        
        toast.success('Task deleted')
      } else {
        toast.error(result.error || 'Failed to delete task')
      }
    } catch (error) {
      toast.error('Failed to delete task')
      console.error(error)
    }
  },
  
  selectTask: (taskId) => {
    set({ selectedTaskId: taskId })
  },
  
  getTaskChildren: (taskId) => {
    const tasks = Array.from(get().tasks.values())
    return tasks.filter(task => task.parent_id === taskId)
  },
  
  getTaskPath: (taskId) => {
    const path: Task[] = []
    let currentTask = get().tasks.get(taskId)
    
    while (currentTask) {
      path.unshift(currentTask)
      if (currentTask.parent_id) {
        currentTask = get().tasks.get(currentTask.parent_id)
      } else {
        break
      }
    }
    
    return path
  }
})) 