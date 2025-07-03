import React, { useRef, useEffect } from 'react'
import { PanelGroup, Panel, PanelResizeHandle } from 'react-resizable-panels'
import { Projects } from './components/Projects'
import { Chart } from './components/Chart'
import { Chat } from './components/Chat'
import { Plus } from 'lucide-react'
import { Footer } from './components/Footer'
import { Header } from './components/Header'
import { AppProvider, useApp } from './contexts/AppContext'

function AppContent() {
  const { state, selectProject, updateUI, createProject } = useApp()
  const { selectedProjectId, ui } = state
  const { showProjects, showChart, showChat, projectsCollapsed, projectsPanelSize } = ui
  
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
        onToggleProjects={() => updateUI({ showProjects: !showProjects })}
        onToggleChart={() => updateUI({ showChart: !showChart })}
        onToggleChat={() => updateUI({ showChat: !showChat })}
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
                    updateUI({ projectsCollapsed: true })
                    // Force snap to collapsed size - this breaks the drag
                    setTimeout(() => {
                      if (panelRef.current) {
                        panelRef.current.resize(COLLAPSED_SIZE)
                      }
                    }, 0)
                  }
                } else {
                  if (projectsCollapsed) {
                    updateUI({ projectsCollapsed: false })
                  }
                  if (!projectsCollapsed || size > COLLAPSE_THRESHOLD) {
                    updateUI({ projectsPanelSize: size })
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
                        console.log('Create new project clicked from header')
                        createProject('New Project', 'Project description')
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
                    onSelectProject={selectProject}
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

function App() {
  return (
    <AppProvider>
      <AppContent />
    </AppProvider>
  )
}

export default App
