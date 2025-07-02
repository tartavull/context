import React from 'react'
import { PanelGroup, Panel, PanelResizeHandle } from 'react-resizable-panels'
import { TaskTreeView } from './components/TaskTreeView'
import { ChatView } from './components/ChatView'
import { useTaskStore } from './store/taskStore'

function App() {
  const { selectedTaskId } = useTaskStore()

  return (
    <div className="h-screen w-screen bg-background">
      <PanelGroup direction="horizontal" className="h-full">
        {/* Task Tree Panel */}
        <Panel defaultSize={30} minSize={20} maxSize={40}>
          <div className="h-full border-r border-border">
            <div className="h-12 px-4 flex items-center border-b border-border">
              <h2 className="font-semibold text-lg">Tasks</h2>
            </div>
            <TaskTreeView />
          </div>
        </Panel>

        {/* Resize Handle */}
        <PanelResizeHandle className="w-1 bg-border hover:bg-primary/20 transition-colors" />

        {/* Chat/Canvas Panel */}
        <Panel defaultSize={70}>
          <div className="h-full">
            {selectedTaskId ? (
              <ChatView taskId={selectedTaskId} />
            ) : (
              <div className="h-full flex items-center justify-center text-muted-foreground">
                <div className="text-center">
                  <h3 className="text-2xl font-semibold mb-2">Welcome to Orchestrator</h3>
                  <p className="mb-4">Create a new task or select an existing one to get started</p>
                  <button 
                    className="px-4 py-2 bg-primary text-primary-foreground rounded-md hover:bg-primary/90 transition-colors"
                    onClick={() => {
                      // Create new task
                      window.electron.tasks.create({
                        title: 'New Task',
                        description: ''
                      })
                    }}
                  >
                    Create New Task
                  </button>
                </div>
              </div>
            )}
          </div>
        </Panel>
      </PanelGroup>
    </div>
  )
}

export default App 