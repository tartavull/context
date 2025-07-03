import React, { useEffect, useState } from 'react'
import { Folder, FolderOpen, FileText, Plus, MoreHorizontal, Trash2, Edit3 } from 'lucide-react'

// Mock data for now
const mockProjects = [
  {
    id: 'project-1',
    title: 'Build Todo App',
    description: 'Create a modern todo application with React',
    status: 'active',
    created_at: Date.now() - 86400000,
  },
  {
    id: 'project-2', 
    title: 'Design System',
    description: 'Build a comprehensive design system',
    status: 'pending',
    created_at: Date.now() - 172800000,
  },
  {
    id: 'project-3',
    title: 'API Integration',
    description: 'Integrate with external APIs',
    status: 'completed',
    created_at: Date.now() - 259200000,
  }
]

interface ProjectItemProps {
  project: any
  isSelected: boolean
  onSelect: (projectId: string) => void
  onDelete: (projectId: string) => void
}

function ProjectItem({ project, isSelected, onSelect, onDelete }: ProjectItemProps) {
  const [showActions, setShowActions] = useState(false)
  const [isEditing, setIsEditing] = useState(false)
  const [editTitle, setEditTitle] = useState(project.title)

  const handleSaveEdit = () => {
    if (editTitle.trim() && editTitle !== project.title) {
      console.log('Update project title:', editTitle)
    }
    setIsEditing(false)
  }

  const handleKeyDown = (e: React.KeyboardEvent) => {
    if (e.key === 'Enter') {
      handleSaveEdit()
    } else if (e.key === 'Escape') {
      setEditTitle(project.title)
      setIsEditing(false)
    }
  }

  const getStatusColor = () => {
    switch (project.status) {
      case 'completed':
        return '#10B981'
      case 'active':
        return '#3B82F6'
      case 'failed':
        return '#EF4444'
      default:
        return '#6B7280'
    }
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
    <div
      className={`flex items-center gap-3 px-4 py-3 cursor-pointer group transition-colors relative ${
        isSelected ? 'bg-blue-600' : 'hover:bg-[#2a2a2a]'
      }`}
      onMouseEnter={() => setShowActions(true)}
      onMouseLeave={() => setShowActions(false)}
      onClick={() => onSelect(project.id)}
    >
      {/* Project Avatar */}
      <div
        className="w-8 h-8 rounded-full flex items-center justify-center flex-shrink-0 text-white text-xs font-medium"
        style={{ backgroundColor: getStatusColor() }}
      >
        {project.title.charAt(0).toUpperCase()}
      </div>

      {/* Project Content */}
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
              <div className="text-sm font-medium truncate text-white">
                {project.title}
              </div>
              <span className="text-xs ml-2 flex-shrink-0 text-gray-400">
                {formatDate(project.created_at)}
              </span>
            </div>
            {project.description && (
              <div className="text-xs truncate text-gray-400">
                {project.description}
              </div>
            )}
          </div>
        )}
      </div>

      {/* Status Indicator */}
      <div className="flex items-center gap-1">
        <div className="w-2 h-2 rounded-full" style={{ backgroundColor: getStatusColor() }}></div>
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
              onDelete(project.id)
            }}
            className="w-6 h-6 flex items-center justify-center text-gray-400 hover:text-red-400 transition-colors"
            title="Delete"
          >
            <Trash2 className="w-3 h-3" />
          </button>
        </div>
      )}
    </div>
  )
}

interface ProjectsProps {
  selectedProjectId: string | null
  onSelectProject: (projectId: string | null) => void
}

export function Projects({ selectedProjectId, onSelectProject }: ProjectsProps) {
  const handleDeleteProject = (projectId: string) => {
    if (confirm('Are you sure you want to delete this project?')) {
      console.log('Delete project:', projectId)
      if (selectedProjectId === projectId) {
        onSelectProject(null)
      }
    }
  }

  const handleCreateProject = () => {
    console.log('Create new project')
    // For now, just select the first project
    onSelectProject('project-1')
  }

  return (
    <div className="h-full overflow-y-auto bg-[#2d2d2d]">
      {mockProjects.length === 0 ? (
        <div className="p-4 text-center">
          <div className="text-gray-400 text-sm mb-3">No projects yet</div>
          <button
            onClick={handleCreateProject}
            className="inline-flex items-center gap-2 px-3 py-2 bg-blue-500 hover:bg-blue-600 text-white text-xs rounded-lg transition-colors"
          >
            <Plus className="w-3 h-3" />
            Create Project
          </button>
        </div>
      ) : (
        <div className="py-1">
          {mockProjects.map((project) => (
            <ProjectItem
              key={project.id}
              project={project}
              isSelected={selectedProjectId === project.id}
              onSelect={onSelectProject}
              onDelete={handleDeleteProject}
            />
          ))}
        </div>
      )}
    </div>
  )
} 