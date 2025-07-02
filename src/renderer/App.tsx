import React from 'react'
import { PanelGroup, Panel, PanelResizeHandle } from 'react-resizable-panels'
import { TaskTreeView } from './components/TaskTreeView'
import { EnhancedChatView } from './components/EnhancedChatView'
import { GeneralChatView } from './components/GeneralChatView'
import { UpdateNotification } from './components/UpdateNotification'
import { useTaskStore } from './store/taskStore'

function App() {
  const { selectedTaskId } = useTaskStore()

  return (
    <div className="h-screen w-screen" style={{ backgroundColor: '#1e1e1e' }}>
      <PanelGroup direction="horizontal" className="h-full">
        {/* Left Panel - macOS Messages conversations style */}
        <Panel defaultSize={30} minSize={20} maxSize={40}>
          <div className="h-full border-r" style={{ 
            backgroundColor: '#2d2d2d', 
            borderRightColor: '#3d3d3d' 
          }}>
            {/* Header */}
            <div className="h-12 px-4 flex items-center justify-between border-b" style={{ 
              backgroundColor: '#2d2d2d', 
              borderBottomColor: '#3d3d3d' 
            }}>
              <h2 className="font-medium text-white text-sm">Projects</h2>
              <div className="flex items-center gap-2">
                <UpdateNotification />
                <button className="w-6 h-6 rounded-full bg-blue-500 hover:bg-blue-600 flex items-center justify-center transition-colors">
                  <svg className="w-3 h-3 text-white" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                    <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M12 4v16m8-8H4" />
                  </svg>
                </button>
              </div>
            </div>
            
            {/* Projects List */}
            <div className="flex-1 overflow-y-auto">
              <TaskTreeView />
              
              {/* Add new project button */}
              <div className="p-3 border-t" style={{ borderTopColor: '#3d3d3d' }}>
                <button 
                  className="w-full p-3 text-left rounded-lg transition-colors group"
                  style={{ backgroundColor: 'transparent' }}
                  onMouseEnter={(e) => e.currentTarget.style.backgroundColor = '#3d3d3d'}
                  onMouseLeave={(e) => e.currentTarget.style.backgroundColor = 'transparent'}
                  onClick={() => {
                    window.electron.tasks.create({
                      title: 'New Project',
                      description: ''
                    })
                  }}
                >
                  <div className="flex items-center gap-3">
                    <div className="w-8 h-8 rounded-full flex items-center justify-center transition-colors" style={{ backgroundColor: '#3d3d3d' }}>
                      <svg className="w-4 h-4 text-gray-300 group-hover:text-white transition-colors" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                        <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M12 4v16m8-8H4" />
                      </svg>
                    </div>
                    <div>
                      <div className="font-medium text-white text-sm">New Project</div>
                      <div className="text-gray-400 text-xs">Start a new project</div>
                    </div>
                  </div>
                </button>
              </div>
            </div>
          </div>
        </Panel>

        {/* Resize Handle - subtle like macOS */}
        <PanelResizeHandle className="w-px hover:bg-blue-500 transition-colors" style={{ backgroundColor: '#3d3d3d' }} />

        {/* Right Panel - Chat */}
        <Panel defaultSize={70}>
          <div className="h-full">
            {selectedTaskId ? (
              <EnhancedChatView taskId={selectedTaskId} />
            ) : (
              <GeneralChatView />
            )}
          </div>
        </Panel>
      </PanelGroup>
    </div>
  )
}

export default App
