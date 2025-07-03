import React from 'react'
import { Eye, EyeOff } from 'lucide-react'

interface HeaderProps {
  showProjects: boolean
  showChart: boolean
  showChat: boolean
  onToggleProjects: () => void
  onToggleChart: () => void
  onToggleChat: () => void
}

export function Header({ 
  showProjects, 
  showChart, 
  showChat, 
  onToggleProjects, 
  onToggleChart, 
  onToggleChat 
}: HeaderProps) {
  return (
    <div 
      className="h-8 flex items-center justify-between px-4 border-b"
      style={{ 
        backgroundColor: '#1a1a1a',
        borderBottomColor: '#0a0a0a' // darker grey line
      }}
    >
      <div className="text-xs text-gray-400 font-mono">
        Context - Recursive Task Decomposition
      </div>
      
      <div className="flex items-center gap-3">
        <button
          onClick={onToggleProjects}
          className="flex items-center gap-1 text-xs text-gray-400 hover:text-white transition-colors"
          title={`${showProjects ? 'Hide' : 'Show'} Projects Panel`}
        >
          {showProjects ? <Eye className="w-3 h-3" /> : <EyeOff className="w-3 h-3" />}
          <span>Projects</span>
        </button>
        
        <button
          onClick={onToggleChart}
          className="flex items-center gap-1 text-xs text-gray-400 hover:text-white transition-colors"
          title={`${showChart ? 'Hide' : 'Show'} Chart Panel`}
        >
          {showChart ? <Eye className="w-3 h-3" /> : <EyeOff className="w-3 h-3" />}
          <span>Chart</span>
        </button>
        
        <button
          onClick={onToggleChat}
          className="flex items-center gap-1 text-xs text-gray-400 hover:text-white transition-colors"
          title={`${showChat ? 'Hide' : 'Show'} Chat Panel`}
        >
          {showChat ? <Eye className="w-3 h-3" /> : <EyeOff className="w-3 h-3" />}
          <span>Chat</span>
        </button>
      </div>
    </div>
  )
} 