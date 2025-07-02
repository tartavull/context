import React, { useEffect, useState } from 'react'
import { Folder, FolderOpen, FileText, Plus, MoreHorizontal, Trash2, Edit3 } from 'lucide-react'
import { useTaskStore } from '../store/taskStore'

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

interface TaskTreeItemProps {
  task: Task
  level: number
  isSelected: boolean
  onSelect: (taskId: string) => void
  onDeleteTask: (taskId: string) => void
  children?: Task[]
}

function TaskTreeItem({ task, level, isSelected, onSelect, onDeleteTask, children = [] }: TaskTreeItemProps) {
  const [showActions, setShowActions] = useState(false)
  const [isEditing, setIsEditing] = useState(false)
  const [editTitle, setEditTitle] = useState(task.title)
  const [isExpanded, setIsExpanded] = useState(false)

  const hasChildren = children.length > 0
  const indent = level * 12

  const handleSaveEdit = async () => {
    if (editTitle.trim() && editTitle !== task.title) {
      await window.electron.tasks.update(task.id, { title: editTitle.trim() })
    }
    setIsEditing(false)
  }

  const handleKeyDown = (e: React.KeyboardEvent) => {
    if (e.key === 'Enter') {
      handleSaveEdit()
    } else if (e.key === 'Escape') {
      setEditTitle(task.title)
      setIsEditing(false)
    }
  }

  // Get project status color
  const getStatusColor = () => {
    if (task.status === 'completed') return '#34D399' // green
    if (task.status === 'active') return '#60A5FA' // blue
    if (task.status === 'failed') return '#F87171' // red
    return '#9CA3AF' // gray for pending
  }

  const formatDate = (timestamp: number) => {
    const date = new Date(timestamp)
    const now = new Date()
    const diffInHours = (now.getTime() - date.getTime()) / (1000 * 60 * 60)
    
    if (diffInHours < 24) {
      return date.toLocaleTimeString([], { hour: '2-digit', minute: '2-digit' })
    } else if (diffInHours < 24 * 7) {
      return date.toLocaleDateString([], { weekday: 'short' })
    } else {
      return date.toLocaleDateString([], { month: 'short', day: 'numeric' })
    }
  }

  return (
    <div>
      <div
        className={`flex items-center gap-2 px-3 py-2 cursor-pointer group transition-colors relative`}
        style={{
          paddingLeft: `${12 + indent}px`,
          backgroundColor: isSelected ? '#007AFF' : 'transparent'
        }}
        onMouseEnter={(e) => {
          if (!isSelected) {
            e.currentTarget.style.backgroundColor = '#3d3d3d'
          }
          setShowActions(true)
        }}
        onMouseLeave={(e) => {
          if (!isSelected) {
            e.currentTarget.style.backgroundColor = 'transparent'
          }
          setShowActions(false)
        }}
        onClick={() => onSelect(task.id)}
      >
        {/* Project Avatar */}
        <div 
          className="w-8 h-8 rounded-full flex items-center justify-center flex-shrink-0 text-white text-xs font-medium"
          style={{ backgroundColor: getStatusColor() }}
        >
          {task.title.charAt(0).toUpperCase()}
        </div>

        {/* Expand/Collapse Button */}
        {hasChildren && (
          <button
            onClick={(e) => {
              e.stopPropagation()
              setIsExpanded(!isExpanded)
            }}
            className="w-4 h-4 flex items-center justify-center text-gray-400 hover:text-white transition-colors"
          >
            {isExpanded ? (
              <FolderOpen className="w-3 h-3" />
            ) : (
              <Folder className="w-3 h-3" />
            )}
          </button>
        )}

        {/* Task Content */}
        <div className="flex-1 min-w-0">
          {isEditing ? (
            <input
              type="text"
              value={editTitle}
              onChange={(e) => setEditTitle(e.target.value)}
              onBlur={handleSaveEdit}
              onKeyDown={handleKeyDown}
              className="w-full bg-transparent border-none outline-none text-white text-sm font-medium"
              autoFocus
            />
          ) : (
            <div>
              <div className="flex items-center justify-between">
                <div className={`text-sm font-medium truncate ${isSelected ? 'text-white' : 'text-white'}`}>
                  {task.title}
                </div>
                <span className={`text-xs ml-2 flex-shrink-0 ${isSelected ? 'text-blue-100' : 'text-gray-400'}`}>
                  {formatDate(task.created_at)}
                </span>
              </div>
              {task.description && (
                <div className={`text-xs truncate ${isSelected ? 'text-blue-100' : 'text-gray-400'}`}>
                  {task.description}
                </div>
              )}
            </div>
          )}
        </div>

        {/* Status Indicator */}
        <div className="flex items-center gap-1">
          {task.status === 'completed' && (
            <div className="w-2 h-2 rounded-full bg-green-400"></div>
          )}
          {task.status === 'active' && (
            <div className="w-2 h-2 rounded-full bg-blue-400"></div>
          )}
          {task.status === 'failed' && (
            <div className="w-2 h-2 rounded-full bg-red-400"></div>
          )}
        </div>

        {/* Actions Menu */}
        {showActions && !isEditing && (
          <div className="flex items-center gap-1 opacity-0 group-hover:opacity-100 transition-opacity">
            <button
              onClick={(e) => {
                e.stopPropagation()
                setIsEditing(true)
              }}
              className="w-6 h-6 flex items-center justify-center text-gray-400 hover:text-white transition-colors"
              title="Edit"
            >
              <Edit3 className="w-3 h-3" />
            </button>
            <button
              onClick={(e) => {
                e.stopPropagation()
                onDeleteTask(task.id)
              }}
              className="w-6 h-6 flex items-center justify-center text-gray-400 hover:text-red-400 transition-colors"
              title="Delete"
            >
              <Trash2 className="w-3 h-3" />
            </button>
          </div>
        )}
      </div>

      {/* Children */}
      {hasChildren && isExpanded && (
        <div>
          {children.map((child) => (
            <TaskTreeItem
              key={child.id}
              task={child}
              level={level + 1}
              isSelected={isSelected}
              onSelect={onSelect}
              onDeleteTask={onDeleteTask}
              children={[]}
            />
          ))}
        </div>
      )}
    </div>
  )
}

export function TaskTreeView() {
  const { tasks, selectedTaskId, selectTask, loadTasks, deleteTask, getTaskChildren } = useTaskStore()

  useEffect(() => {
    loadTasks()
  }, [loadTasks])

  const handleDeleteTask = async (taskId: string) => {
    if (confirm('Are you sure you want to delete this task?')) {
      await deleteTask(taskId)
    }
  }

  // Convert Map to array and filter root tasks
  const rootTasks = Array.from(tasks.values()).filter((task) => !task.parent_id)

  return (
    <div className="h-full overflow-y-auto" style={{ backgroundColor: '#2d2d2d' }}>
      {rootTasks.length === 0 ? (
        <div className="p-4 text-center">
          <div className="text-gray-400 text-sm mb-3">No projects yet</div>
          <button
            onClick={() => {
              window.electron.tasks.create({
                title: 'My First Project',
                description: 'Get started with your first project'
              })
            }}
            className="inline-flex items-center gap-2 px-3 py-2 bg-blue-500 hover:bg-blue-600 text-white text-xs rounded-lg transition-colors"
          >
            <Plus className="w-3 h-3" />
            Create Project
          </button>
        </div>
      ) : (
        <div className="py-1">
          {rootTasks.map((task) => (
            <TaskTreeItem
              key={task.id}
              task={task}
              level={0}
              isSelected={selectedTaskId === task.id}
              onSelect={selectTask}
              onDeleteTask={handleDeleteTask}
              children={getTaskChildren(task.id)}
            />
          ))}
        </div>
      )}
    </div>
  )
}
