import React, { useEffect, useState } from 'react'
import { Folder, FolderOpen, FileText, Plus, MoreHorizontal, Trash2, Edit3 } from 'lucide-react'
import { useApp } from '../contexts/AppContext'
import { Project } from '../types/app-state'

interface ProjectItemProps {
  project: Project
  isSelected: boolean
  onSelect: (projectId: string) => void
  onDelete: (projectId: string) => void
  isCollapsed: boolean
}

function ProjectItem({ project, isSelected, onSelect, onDelete, isCollapsed }: ProjectItemProps) {
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
      className={`flex items-center px-4 py-3 cursor-pointer group transition-colors relative ${
        isSelected ? 'bg-blue-600' : 'hover:bg-[#2a2a2a]'
      }`}
      onMouseEnter={() => setShowActions(true)}
      onMouseLeave={() => setShowActions(false)}
      onClick={() => onSelect(project.id)}
      title={isCollapsed ? `${project.title} - ${project.description}` : undefined}
    >
      {/* Project Avatar - always in same position */}
      <div
        className="w-8 h-8 rounded-full flex items-center justify-center flex-shrink-0 text-white text-xs font-medium"
        style={{ backgroundColor: getStatusColor() }}
      >
        {project.title.charAt(0).toUpperCase()}
      </div>

      {/* Project Content - only visible when not collapsed */}
      {!isCollapsed && (
        <div className="flex-1 min-w-0 ml-3">
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
                  {formatDate(project.createdAt)}
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
      )}



      {/* Actions Menu - only visible when not collapsed */}
      {!isCollapsed && showActions && !isEditing && (
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
  isCollapsed?: boolean
}

export function Projects({ selectedProjectId, onSelectProject, isCollapsed = false }: ProjectsProps) {
  const { state, deleteProject, createProject } = useApp()
  const projects = Object.values(state.projects)

  const handleDeleteProject = (projectId: string) => {
    if (confirm('Are you sure you want to delete this project?')) {
      deleteProject(projectId)
    }
  }

  const handleCreateProject = () => {
    const title = prompt('Enter project title:')
    const description = prompt('Enter project description:')
    if (title && description) {
      createProject(title, description)
    }
  }

  return (
    <div className="h-full overflow-y-auto bg-[#2d2d2d] transition-all duration-300">
      {projects.length === 0 ? (
        <div className={`transition-all duration-300 ${isCollapsed ? 'px-4 py-3' : 'p-4 text-center'}`}>
          {!isCollapsed && <div className="text-gray-400 text-sm mb-3">No projects yet</div>}
          <button
            onClick={handleCreateProject}
            className={`inline-flex items-center gap-2 bg-blue-500 hover:bg-blue-600 text-white transition-all duration-300 ${
              isCollapsed 
                ? 'w-8 h-8 rounded-full justify-center flex-shrink-0' 
                : 'px-3 py-2 text-xs rounded-lg'
            }`}
            title={isCollapsed ? 'Create Project' : undefined}
          >
            <Plus className="w-3 h-3" />
            {!isCollapsed && <span className="transition-opacity duration-300">Create Project</span>}
          </button>
        </div>
      ) : (
        <div className={`transition-all duration-300 ${isCollapsed ? 'py-1' : 'py-1'}`}>
          {projects.map((project) => (
            <ProjectItem
              key={project.id}
              project={project}
              isSelected={selectedProjectId === project.id}
              onSelect={onSelectProject}
              onDelete={handleDeleteProject}
              isCollapsed={isCollapsed}
            />
          ))}
        </div>
      )}
    </div>
  )
} 