import React, { useState } from 'react'
import { PanelGroup, Panel, PanelResizeHandle } from 'react-resizable-panels'
import { Projects } from './components/Projects'
import { Chart } from './components/Chart'
import { Chat } from './components/Chat'
import { Plus } from 'lucide-react'
import { Footer } from './components/Footer'
import { Header } from './components/Header'

function App() {
  const [selectedProjectId, setSelectedProjectId] = useState<string | null>(null)
  const [showProjects, setShowProjects] = useState(true)
  const [showChart, setShowChart] = useState(true)
  const [showChat, setShowChat] = useState(true)

  // Calculate panel sizes based on visibility
  const getVisiblePanelCount = () => {
    return [showProjects, showChart, showChat].filter(Boolean).length
  }

  const getDefaultSize = () => {
    const visibleCount = getVisiblePanelCount()
    return visibleCount > 0 ? 100 / visibleCount : 33.33
  }

  return (
    <div className="h-screen w-screen flex flex-col" style={{ backgroundColor: '#1e1e1e' }}>
      {/* Header spanning across all panels */}
      <Header 
        showProjects={showProjects}
        showChart={showChart}
        showChat={showChat}
        onToggleProjects={() => setShowProjects(!showProjects)}
        onToggleChart={() => setShowChart(!showChart)}
        onToggleChat={() => setShowChat(!showChat)}
      />
      
      {/* Main content area */}
      <div className="flex-1">
        <PanelGroup direction="horizontal" className="h-full">
          {/* Left Panel - Projects */}
          {showProjects && (
            <>
              <Panel defaultSize={getDefaultSize()} minSize={20} maxSize={60}>
                <div
                  className="h-full border-r"
                  style={{
                    backgroundColor: '#2d2d2d',
                    borderRightColor: '#3d3d3d',
                  }}
                >
                  {/* Header */}
                  <div
                    className="h-12 px-4 flex items-center justify-between border-b"
                    style={{
                      backgroundColor: '#2d2d2d',
                      borderBottomColor: '#3d3d3d',
                    }}
                  >
                    <h2 className="font-medium text-white text-sm">Projects</h2>
                    <div className="flex items-center gap-2">
                      <button 
                        className="w-6 h-6 rounded-full bg-blue-500 hover:bg-blue-600 flex items-center justify-center transition-colors"
                        onClick={() => {
                          console.log('Create new project clicked')
                          setSelectedProjectId('project-1') // Auto-select first project for demo
                        }}
                        title="Create New Project"
                      >
                        <Plus className="w-3 h-3 text-white" />
                      </button>
                    </div>
                  </div>

                  {/* Projects List */}
                  <div className="flex-1 overflow-y-auto">
                    <Projects 
                      selectedProjectId={selectedProjectId}
                      onSelectProject={setSelectedProjectId}
                    />
                  </div>
                </div>
              </Panel>

              {/* Resize Handle */}
              {(showChart || showChat) && (
                <PanelResizeHandle
                  className="w-px hover:bg-blue-500 transition-colors"
                  style={{ backgroundColor: '#3d3d3d' }}
                />
              )}
            </>
          )}

          {/* Middle Panel - Chart */}
          {showChart && (
            <>
              <Panel defaultSize={getDefaultSize()} minSize={30} maxSize={60}>
                <div className="h-full border-r" style={{ borderRightColor: '#3d3d3d' }}>
                  <Chart selectedProjectId={selectedProjectId} />
                </div>
              </Panel>

              {/* Resize Handle */}
              {showChat && (
                <PanelResizeHandle
                  className="w-px hover:bg-blue-500 transition-colors"
                  style={{ backgroundColor: '#3d3d3d' }}
                />
              )}
            </>
          )}

          {/* Right Panel - Chat */}
          {showChat && (
            <Panel defaultSize={getDefaultSize()} minSize={25}>
              <div className="h-full">
                <Chat selectedProjectId={selectedProjectId} />
              </div>
            </Panel>
          )}
        </PanelGroup>
      </div>
      
      {/* Footer spanning across all panels */}
      <Footer />
    </div>
  )
}

export default App
