import React, { useCallback, useMemo, useState } from 'react'
import ReactFlow, {
  Node,
  Edge,
  useNodesState,
  useEdgesState,
  Background,
  ConnectionMode,
  NodeTypes,
  Handle,
  Position,
} from 'react-flow-renderer'
import { Trash2 } from 'lucide-react'
import { useApp } from '../contexts/AppContext'
import { Task } from '../types/app-state'

// Custom node component
const TaskNode = ({ data, selected }: { data: any; selected: boolean }) => {
  const handleDelete = (e: React.MouseEvent) => {
    e.stopPropagation()
    if (data.onDelete) {
      data.onDelete()
    }
  }

  const getNodeColor = () => {
    switch (data.nodeType) {
      case 'clone':
        return '#a0a0a0' // light gray
      case 'spawn':
        return '#707070' // medium gray
      case 'original':
        return '#606060' // accent gray
      default:
        return '#4d4d4d' // border gray
    }
  }

  const getStatusColor = () => {
    switch (data.status) {
      case 'completed':
        return '#a0a0a0' // light gray
      case 'active':
        return '#ffffff' // white
      case 'failed':
        return '#707070' // medium gray
      default:
        return '#4d4d4d' // border gray
    }
  }

  return (
    <div
      className={`px-4 py-3 shadow-lg rounded-lg border-2 flex flex-col ${
        selected ? 'border-[#a0a0a0]' : 'border-[#4d4d4d]'
      }`}
      style={{ 
        backgroundColor: '#2d2d2d',
        borderColor: selected ? '#a0a0a0' : getNodeColor(),
        width: '220px',
        height: '140px'
      }}
    >
      <Handle 
        type="target" 
        position={Position.Top}
        style={{ backgroundColor: '#a0a0a0', border: '2px solid #2d2d2d' }}
      />
      
      {/* Header row */}
      <div className="flex items-center justify-between mb-2">
        <div
          className="w-3 h-3 rounded-full flex-shrink-0"
          style={{ backgroundColor: getNodeColor() }}
        />
        <div className="flex items-center gap-1">
          <div
            className="w-2 h-2 rounded-full"
            style={{ backgroundColor: getStatusColor() }}
          />
          <button
            onClick={handleDelete}
            className="w-4 h-4 flex items-center justify-center text-[#707070] hover:text-red-400 transition-colors"
            title="Delete node"
          >
            <Trash2 className="w-3 h-3" />
          </button>
        </div>
      </div>
      
      {/* Content area - flexible height */}
      <div className="flex-1 flex flex-col justify-center min-h-0">
        <div className="text-sm font-medium text-[#ffffff] mb-1 line-clamp-2 leading-tight">
          {data.title}
        </div>
        
        {data.description && (
          <div className="text-xs text-[#a0a0a0] line-clamp-2 leading-tight">
            {data.description}
          </div>
        )}
      </div>
      
      {/* Footer row */}
      <div className="flex items-center justify-between mt-2 pt-1 border-t border-[#4d4d4d]">
        <span className="text-xs text-[#707070] capitalize truncate">
          {data.nodeType || 'task'}
        </span>
        <span className="text-xs text-[#707070] capitalize truncate">
          {data.executionMode}
        </span>
      </div>

      <Handle 
        type="source" 
        position={Position.Bottom}
        style={{ backgroundColor: '#a0a0a0', border: '2px solid #2d2d2d' }}
      />
    </div>
  )
}

interface ChartProps {
  selectedProjectId?: string | null
}

// Define nodeTypes outside component to prevent re-creation
const nodeTypes: NodeTypes = {
  taskNode: TaskNode,
}

export function Chart({ selectedProjectId }: ChartProps) {
  const { state, selectTask, deleteTask, updateTask } = useApp()
  const [selectedId, setSelectedId] = useState<string | null>(null)
  const [nodes, setNodes, onNodesChange] = useNodesState([])
  const [edges, setEdges, onEdgesChange] = useEdgesState([])

  // Get tasks for the selected project
  const tasks = useMemo(() => {
    if (!selectedProjectId || !state.projects[selectedProjectId]) {
      return []
    }
    return Object.values(state.projects[selectedProjectId].tasks)
  }, [selectedProjectId, state.projects])

  // Convert tasks to nodes and edges
  const { flowNodes, flowEdges } = useMemo(() => {
    const flowNodes: Node[] = []
    const flowEdges: Edge[] = []

    // Create nodes
    tasks.forEach((task: Task) => {
      flowNodes.push({
        id: task.id,
        type: 'taskNode',
        position: task.position,
        draggable: false, // Disable dragging
        data: {
          taskId: task.id,
          title: task.title,
          description: task.description,
          status: task.status,
          executionMode: task.executionMode,
          nodeType: task.nodeType,
          onDelete: () => {
            if (selectedProjectId) {
              deleteTask(selectedProjectId, task.id)
            }
          },
        },
        selected: task.id === selectedId,
      })
    })

    // Create edges for parent-child relationships
    tasks.forEach((task: Task) => {
      if (task.parentId) {
        flowEdges.push({
          id: `${task.parentId}-${task.id}`,
          source: task.parentId,
          target: task.id,
          type: 'smoothstep',
          animated: task.status === 'active',
          style: {
            strokeWidth: 2,
            stroke: task.status === 'active' ? '#a0a0a0' : '#707070',
          },
        })
      }
    })

    return { flowNodes, flowEdges }
  }, [selectedId, tasks, selectedProjectId, deleteTask])

  // Initialize nodes and edges
  React.useEffect(() => {
    setNodes(flowNodes)
    setEdges(flowEdges)
  }, [flowNodes, flowEdges, setNodes, setEdges])



  const onNodeClick = useCallback(
    (event: React.MouseEvent, node: Node) => {
      setSelectedId(node.id)
      selectTask(node.id)
    },
    [selectTask]
  )

  const onPaneClick = useCallback(() => {
    setSelectedId(null)
    selectTask(null)
  }, [selectTask])

  if (!selectedProjectId) {
    return (
      <div className="h-full w-full flex items-center justify-center" style={{ backgroundColor: '#1e1e1e' }}>
        <div className="text-center">
          <div className="text-lg font-medium text-[#e1e1e1] mb-2">No Project Selected</div>
          <p className="text-[#888] text-sm">Select a project from the left panel to view its task tree</p>
        </div>
      </div>
    )
  }

  return (
    <div className="h-full w-full" style={{ backgroundColor: '#1e1e1e' }}>
      <ReactFlow
        nodes={nodes}
        edges={edges}
        onNodesChange={onNodesChange}
        onEdgesChange={onEdgesChange}
        onNodeClick={onNodeClick}
        onPaneClick={onPaneClick}
        nodeTypes={nodeTypes}
        connectionMode={ConnectionMode.Loose}
        nodesDraggable={false}
        nodesConnectable={false}
        fitView
        style={{ backgroundColor: '#2d2d2d' }}
      >
        <Background color="#4d4d4d" />
      </ReactFlow>
    </div>
  )
} 