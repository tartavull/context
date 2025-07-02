import React, { useState, useRef, useEffect } from 'react'
import { Send, Loader2 } from 'lucide-react'
import { useTaskStore } from '../store/taskStore'
import ReactMarkdown from 'react-markdown'

interface ChatViewProps {
  taskId: string
}

interface Message {
  id: string
  role: 'user' | 'assistant'
  content: string
  timestamp: number
}

export function ChatView({ taskId }: ChatViewProps) {
  const task = useTaskStore(state => state.tasks.get(taskId))
  const [messages, setMessages] = useState<Message[]>([])
  const [input, setInput] = useState('')
  const [isLoading, setIsLoading] = useState(false)
  const messagesEndRef = useRef<HTMLDivElement>(null)
  
  const scrollToBottom = () => {
    messagesEndRef.current?.scrollIntoView({ behavior: 'smooth' })
  }
  
  useEffect(() => {
    scrollToBottom()
  }, [messages])
  
  useEffect(() => {
    // Load messages for this task
    // TODO: Implement message loading from database
    setMessages([])
  }, [taskId])
  
  const handleSubmit = async (e: React.FormEvent) => {
    e.preventDefault()
    if (!input.trim() || isLoading) return
    
    const userMessage: Message = {
      id: Date.now().toString(),
      role: 'user',
      content: input.trim(),
      timestamp: Date.now()
    }
    
    setMessages(prev => [...prev, userMessage])
    setInput('')
    setIsLoading(true)
    
    try {
      // TODO: Implement actual AI chat
      const result = await window.electron.ai.generateText(input, {
        provider: 'openai'
      })
      
      if (result.success && result.text) {
        const assistantMessage: Message = {
          id: (Date.now() + 1).toString(),
          role: 'assistant',
          content: result.text,
          timestamp: Date.now()
        }
        setMessages(prev => [...prev, assistantMessage])
      }
    } catch (error) {
      console.error('Chat error:', error)
    } finally {
      setIsLoading(false)
    }
  }
  
  if (!task) {
    return (
      <div className="h-full flex items-center justify-center text-muted-foreground">
        Task not found
      </div>
    )
  }
  
  return (
    <div className="h-full flex flex-col">
      {/* Header */}
      <div className="h-12 px-4 flex items-center border-b border-border">
        <h2 className="font-semibold text-lg">{task.title}</h2>
        <span className="ml-2 text-sm text-muted-foreground">
          ({task.execution_mode})
        </span>
      </div>
      
      {/* Messages */}
      <div className="flex-1 overflow-y-auto custom-scrollbar p-4">
        {messages.length === 0 && (
          <div className="text-center text-muted-foreground py-8">
            <p>No messages yet. Start a conversation!</p>
            {task.description && (
              <div className="mt-4 p-4 bg-accent/20 rounded-md text-left">
                <p className="text-sm font-medium mb-1">Task Description:</p>
                <p className="text-sm">{task.description}</p>
              </div>
            )}
          </div>
        )}
        
        <div className="space-y-4">
          {messages.map(message => (
            <div
              key={message.id}
              className={`flex ${message.role === 'user' ? 'justify-end' : 'justify-start'}`}
            >
              <div
                className={`
                  max-w-[70%] rounded-lg px-4 py-2
                  ${message.role === 'user' 
                    ? 'bg-primary text-primary-foreground' 
                    : 'bg-accent'
                  }
                `}
              >
                {message.role === 'assistant' ? (
                  <ReactMarkdown className="prose prose-sm dark:prose-invert">
                    {message.content}
                  </ReactMarkdown>
                ) : (
                  <p className="text-sm whitespace-pre-wrap">{message.content}</p>
                )}
              </div>
            </div>
          ))}
          
          {isLoading && (
            <div className="flex justify-start">
              <div className="bg-accent rounded-lg px-4 py-2">
                <Loader2 className="w-4 h-4 animate-spin" />
              </div>
            </div>
          )}
        </div>
        
        <div ref={messagesEndRef} />
      </div>
      
      {/* Input */}
      <form onSubmit={handleSubmit} className="p-4 border-t border-border">
        <div className="flex gap-2">
          <input
            type="text"
            value={input}
            onChange={(e) => setInput(e.target.value)}
            placeholder="Type your message..."
            className="flex-1 px-3 py-2 bg-background border border-input rounded-md focus:outline-none focus:ring-2 focus:ring-ring"
            disabled={isLoading}
          />
          <button
            type="submit"
            disabled={!input.trim() || isLoading}
            className="px-4 py-2 bg-primary text-primary-foreground rounded-md hover:bg-primary/90 disabled:opacity-50 disabled:cursor-not-allowed transition-colors"
          >
            {isLoading ? (
              <Loader2 className="w-4 h-4 animate-spin" />
            ) : (
              <Send className="w-4 h-4" />
            )}
          </button>
        </div>
      </form>
    </div>
  )
} 