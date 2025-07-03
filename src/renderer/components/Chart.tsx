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

// Mock data for UI display
const mockTasks = [
  {
    id: 'task-1',
    title: 'Build a Todo App',
    description: 'Create a modern todo application',
    status: 'active',
    execution_mode: 'interactive',
    nodeType: 'original',
  },
  {
    id: 'task-2',
    title: 'Design UI Components',
    description: 'Create reusable components',
    status: 'completed',
    execution_mode: 'interactive',
    nodeType: 'spawn',
    parent_id: 'task-1',
  },
  {
    id: 'task-3',
    title: 'Implement State Management',
    description: 'Set up state management',
    status: 'active',
    execution_mode: 'interactive',
    nodeType: 'clone',
    parent_id: 'task-1',
  },
]

// Custom node component
const TaskNode = ({ data, selected }: { data: any; selected: boolean }) => {
  const handleDelete = (e: React.MouseEvent) => {
    e.stopPropagation()
    console.log('Delete task:', data.title)
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
      className={`px-4 py-3 shadow-lg rounded-lg border-2 min-w-[200px] ${
        selected ? 'border-[#a0a0a0]' : 'border-[#4d4d4d]'
      }`}
      style={{ 
        backgroundColor: '#2d2d2d',
        borderColor: selected ? '#a0a0a0' : getNodeColor() 
      }}
    >
      <Handle 
        type="target" 
        position={Position.Top}
        style={{ backgroundColor: '#a0a0a0', border: '2px solid #2d2d2d' }}
      />
      
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
      
      <div className="text-sm font-medium text-[#ffffff] mb-1 truncate">
        {data.title}
      </div>
      
      {data.description && (
        <div className="text-xs text-[#a0a0a0] truncate">
          {data.description}
        </div>
      )}
      
      <div className="flex items-center justify-between mt-2">
        <span className="text-xs text-[#707070] capitalize">
          {data.nodeType || 'task'}
        </span>
        <span className="text-xs text-[#707070] capitalize">
          {data.execution_mode}
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
  const [selectedId, setSelectedId] = useState<string | null>(null)
  const [nodes, setNodes, onNodesChange] = useNodesState([])
  const [edges, setEdges, onEdgesChange] = useEdgesState([])

  // Convert mock tasks to nodes and edges
  const { flowNodes, flowEdges } = useMemo(() => {
    const flowNodes: Node[] = []
    const flowEdges: Edge[] = []

    // Create nodes
    mockTasks.forEach((task, index) => {
      flowNodes.push({
        id: task.id,
        type: 'taskNode',
        position: { 
          x: (index % 4) * 250 + 50, 
          y: Math.floor(index / 4) * 150 + 50 
        },
        data: {
          taskId: task.id,
          title: task.title,
          description: task.description,
          status: task.status,
          execution_mode: task.execution_mode,
          nodeType: task.nodeType,
        },
        selected: task.id === selectedId,
      })
    })

    // Create edges for parent-child relationships
    mockTasks.forEach((task) => {
      if (task.parent_id) {
        flowEdges.push({
          id: `${task.parent_id}-${task.id}`,
          source: task.parent_id,
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
  }, [selectedId])

  // Initialize nodes and edges
  React.useEffect(() => {
    setNodes(flowNodes)
    setEdges(flowEdges)
  }, [flowNodes, flowEdges, setNodes, setEdges])

  const onNodeClick = useCallback(
    (event: React.MouseEvent, node: Node) => {
      setSelectedId(node.id)
      console.log('Selected task:', node.id)
    },
    []
  )

  const onPaneClick = useCallback(() => {
    setSelectedId(null)
    console.log('Deselected task')
  }, [])

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
        fitView
        attributionPosition="bottom-left"
        style={{ backgroundColor: '#2d2d2d' }}
      >
        <Background color="#4d4d4d" />
      </ReactFlow>
    </div>
  )
} 