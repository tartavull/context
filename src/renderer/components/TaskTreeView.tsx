import React, { useEffect } from 'react'
import { ChevronRight, ChevronDown, Plus, MoreHorizontal } from 'lucide-react'
import { useTaskStore } from '../store/taskStore'

export function TaskTreeView() {
  const { tasks, selectedTaskId, selectTask, loadTasks, createTask } = useTaskStore()
  
  useEffect(() => {
    loadTasks()
  }, [])
  
  const rootTasks = Array.from(tasks.values()).filter(task => !task.parent_id)
  
  const handleCreateRootTask = async () => {
    const taskId = await createTask({
      title: 'New Task',
      description: ''
    })
    if (taskId) {
      selectTask(taskId)
    }
  }
  
  return (
    <div className="h-full overflow-y-auto custom-scrollbar p-4">
      <div className="space-y-1">
        {rootTasks.map(task => (
          <TaskNode key={task.id} task={task} level={0} />
        ))}
      </div>
      
      <button
        onClick={handleCreateRootTask}
        className="mt-4 w-full p-2 text-sm text-muted-foreground hover:text-foreground hover:bg-accent rounded-md flex items-center gap-2 transition-colors"
      >
        <Plus className="w-4 h-4" />
        New Task
      </button>
    </div>
  )
}

interface TaskNodeProps {
  task: any
  level: number
}

function TaskNode({ task, level }: TaskNodeProps) {
  const { tasks, selectedTaskId, selectTask, getTaskChildren } = useTaskStore()
  const [isExpanded, setIsExpanded] = React.useState(true)
  
  const children = getTaskChildren(task.id)
  const hasChildren = children.length > 0
  
  const statusIcon = {
    pending: '○',
    active: '●',
    completed: '✓',
    failed: '✗'
  }[task.status]
  
  const statusColor = {
    pending: 'text-muted-foreground',
    active: 'text-blue-500',
    completed: 'text-green-500',
    failed: 'text-red-500'
  }[task.status]
  
  return (
    <div>
      <div
        className={`
          flex items-center gap-1 px-2 py-1 rounded-md cursor-pointer
          ${selectedTaskId === task.id ? 'bg-accent' : 'hover:bg-accent/50'}
          transition-colors
        `}
        style={{ paddingLeft: `${level * 16 + 8}px` }}
        onClick={() => selectTask(task.id)}
      >
        {hasChildren && (
          <button
            onClick={(e) => {
              e.stopPropagation()
              setIsExpanded(!isExpanded)
            }}
            className="p-0.5 hover:bg-background/50 rounded"
          >
            {isExpanded ? (
              <ChevronDown className="w-3 h-3" />
            ) : (
              <ChevronRight className="w-3 h-3" />
            )}
          </button>
        )}
        
        {!hasChildren && <div className="w-4" />}
        
        <span className={`${statusColor} mr-2`}>{statusIcon}</span>
        
        <span className="flex-1 text-sm truncate">{task.title}</span>
        
        <button
          onClick={(e) => {
            e.stopPropagation()
            // TODO: Add context menu for task actions
          }}
          className="opacity-0 group-hover:opacity-100 p-0.5 hover:bg-background/50 rounded"
        >
          <MoreHorizontal className="w-3 h-3" />
        </button>
      </div>
      
      {hasChildren && isExpanded && (
        <div>
          {children.map(child => (
            <TaskNode key={child.id} task={child} level={level + 1} />
          ))}
        </div>
      )}
    </div>
  )
} 