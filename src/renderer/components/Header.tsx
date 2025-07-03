import React from 'react'

interface HeaderProps {
  showProjects: boolean
  showChart: boolean
  showChat: boolean
  onToggleProjects: () => void
  onToggleChart: () => void
  onToggleChat: () => void
}

// Custom panel icons
const LeftPanelIcon = ({ isActive }: { isActive: boolean }) => (
  <svg width="16" height="12" viewBox="0 0 16 12" className="w-4 h-3">
    <rect x="0" y="0" width="16" height="12" fill="none" stroke="currentColor" strokeWidth="1"/>
    <rect x="0" y="0" width="8" height="12" fill={isActive ? "currentColor" : "none"}/>
  </svg>
)

const MiddlePanelIcon = ({ isActive }: { isActive: boolean }) => (
  <svg width="16" height="12" viewBox="0 0 16 12" className="w-4 h-3">
    <rect x="0" y="0" width="16" height="12" fill="none" stroke="currentColor" strokeWidth="1"/>
    <rect x="5" y="0" width="6" height="12" fill={isActive ? "currentColor" : "none"}/>
  </svg>
)

const RightPanelIcon = ({ isActive }: { isActive: boolean }) => (
  <svg width="16" height="12" viewBox="0 0 16 12" className="w-4 h-3">
    <rect x="0" y="0" width="16" height="12" fill="none" stroke="currentColor" strokeWidth="1"/>
    <rect x="8" y="0" width="8" height="12" fill={isActive ? "currentColor" : "none"}/>
  </svg>
)

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
      className="h-8 flex items-center justify-end px-4 border-b"
      style={{ 
        backgroundColor: '#1a1a1a',
        borderBottomColor: '#0a0a0a' // darker grey line
      }}
    >
      <div className="flex items-center gap-2">
        <button
          onClick={onToggleProjects}
          className={`flex items-center justify-center w-6 h-5 rounded transition-colors ${
            showProjects 
              ? 'text-gray-400 hover:text-gray-300' 
              : 'text-gray-500 hover:text-gray-400'
          }`}
          title={`${showProjects ? 'Hide' : 'Show'} Projects Panel`}
        >
          <LeftPanelIcon isActive={showProjects} />
        </button>
        
        <button
          onClick={onToggleChart}
          className={`flex items-center justify-center w-6 h-5 rounded transition-colors ${
            showChart 
              ? 'text-gray-400 hover:text-gray-300' 
              : 'text-gray-500 hover:text-gray-400'
          }`}
          title={`${showChart ? 'Hide' : 'Show'} Chart Panel`}
        >
          <MiddlePanelIcon isActive={showChart} />
        </button>
        
        <button
          onClick={onToggleChat}
          className={`flex items-center justify-center w-6 h-5 rounded transition-colors ${
            showChat 
              ? 'text-gray-400 hover:text-gray-300' 
              : 'text-gray-500 hover:text-gray-400'
          }`}
          title={`${showChat ? 'Hide' : 'Show'} Chat Panel`}
        >
          <RightPanelIcon isActive={showChat} />
        </button>
      </div>
    </div>
  )
} 