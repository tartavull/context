import React, { useState, useRef, useEffect } from 'react'
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
  const [projectsCollapsed, setProjectsCollapsed] = useState(false)
  const [projectsPanelSize, setProjectsPanelSize] = useState(30)
  
  const COLLAPSE_THRESHOLD = 12 // Threshold below which panel snaps to collapsed state
  const COLLAPSED_SIZE = 4.5 // Size when collapsed - just enough for the circular icons
  const panelRef = useRef<any>(null)
  
  // Effect to handle smooth transitions when toggling collapsed state
  useEffect(() => {
    if (panelRef.current) {
      if (projectsCollapsed) {
        panelRef.current.resize(COLLAPSED_SIZE)
      }
    }
  }, [projectsCollapsed, COLLAPSED_SIZE])

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
            <Panel 
              ref={panelRef}
              defaultSize={projectsCollapsed ? COLLAPSED_SIZE : projectsPanelSize} 
              minSize={COLLAPSED_SIZE} 
              maxSize={50} 
              id="projects-panel"
              onResize={(size) => {
                if (size <= COLLAPSE_THRESHOLD) {
                  if (!projectsCollapsed) {
                    setProjectsCollapsed(true)
                    // Force snap to collapsed size - this breaks the drag
                    setTimeout(() => {
                      if (panelRef.current) {
                        panelRef.current.resize(COLLAPSED_SIZE)
                      }
                    }, 0)
                  }
                } else {
                  if (projectsCollapsed) {
                    setProjectsCollapsed(false)
                  }
                  if (!projectsCollapsed || size > COLLAPSE_THRESHOLD) {
                    setProjectsPanelSize(size)
                  }
                }
              }}
            >
              <div
                className="h-full border-r transition-all duration-300"
                style={{
                  backgroundColor: '#2d2d2d',
                  borderRightColor: '#3d3d3d',
                }}
              >
                {/* Header */}
                <div
                  className={`h-12 flex items-center border-b px-4 ${
                    projectsCollapsed ? 'justify-start' : 'justify-between'
                  }`}
                  style={{
                    backgroundColor: '#2d2d2d',
                    borderBottomColor: '#3d3d3d',
                  }}
                >
                  {!projectsCollapsed && <h2 className="font-medium text-white text-sm">Projects</h2>}
                  <div className="flex items-center">
                    <button 
                      className={`rounded-full bg-blue-500 hover:bg-blue-600 flex items-center justify-center transition-colors ${
                        projectsCollapsed ? 'w-8 h-8' : 'w-6 h-6'
                      }`}
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
                    isCollapsed={projectsCollapsed}
                  />
                </div>
              </div>
            </Panel>
          )}

          {/* Resize Handle between Projects and Chart */}
          {showProjects && (showChart || showChat) && (
            <PanelResizeHandle className="w-1 bg-gray-600 hover:bg-gray-500 transition-colors cursor-col-resize" />
          )}

          {/* Middle Panel - Chart */}
          {showChart && (
            <Panel defaultSize={45} minSize={30} id="chart-panel">
              <div className="h-full border-r" style={{ borderRightColor: '#3d3d3d' }}>
                <Chart selectedProjectId={selectedProjectId} />
              </div>
            </Panel>
          )}

          {/* Resize Handle between Chart and Chat */}
          {showChart && showChat && (
            <PanelResizeHandle className="w-1 bg-gray-600 hover:bg-gray-500 transition-colors cursor-col-resize" />
          )}

          {/* Right Panel - Chat */}
          {showChat && (
            <Panel defaultSize={25} minSize={20} id="chat-panel">
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
