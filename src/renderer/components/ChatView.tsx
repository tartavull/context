import React, { useState, useRef, useEffect, useCallback } from 'react'
import { Send, Loader2, Bot, User } from 'lucide-react'
import { useTaskStore } from '../store/taskStore'
import ReactMarkdown from 'react-markdown'
import { getSystemPrompt, parseSubtasks } from '../../shared/prompts'
import { nanoid } from 'nanoid'

interface ChatViewProps {
  taskId: string
}

interface Message {
  id: string
  role: 'user' | 'assistant' | 'system'
  content: string
  timestamp: number
}

export function ChatView({ taskId }: ChatViewProps) {
  const task = useTaskStore((state) => state.tasks.get(taskId))
  const createTask = useTaskStore((state) => state.createTask)
  const [messages, setMessages] = useState<Message[]>([])
  const [input, setInput] = useState('')
  const [isLoading, setIsLoading] = useState(false)
  const [streamingContent, setStreamingContent] = useState('')
  const messagesEndRef = useRef<HTMLDivElement>(null)
  const streamUnsubscribeRef = useRef<(() => void) | null>(null)

  const scrollToBottom = () => {
    messagesEndRef.current?.scrollIntoView({ behavior: 'smooth' })
  }

  useEffect(() => {
    scrollToBottom()
  }, [messages, streamingContent])

  // Load messages from database
  useEffect(() => {
    loadMessages()

    return () => {
      // Cleanup stream subscription on unmount
      if (streamUnsubscribeRef.current) {
        streamUnsubscribeRef.current()
      }
    }
  }, [taskId])

  const loadMessages = async () => {
    const result = await window.electron.messages.getByTask(taskId)
    if (result.success && result.messages) {
      setMessages(
        result.messages.map((msg: any) => ({
          id: msg.id,
          role: msg.role,
          content: msg.content,
          timestamp: msg.created_at,
        }))
      )
    }
  }

  const checkForTaskDecomposition = async (content: string) => {
    // Parse for subtasks in the response
    const subtasks = parseSubtasks(content)

    for (const subtask of subtasks) {
      try {
        const newTaskId = await createTask({
          parent_id: taskId,
          title: subtask.title,
          description: subtask.description,
          execution_mode: subtask.execution_mode as 'interactive' | 'autonomous',
          status: 'pending',
        })

        if (newTaskId && subtask.execution_mode === 'autonomous') {
          // TODO: Queue autonomous task for execution
          console.log('Created autonomous task:', newTaskId)
        }
      } catch (error) {
        console.error('Failed to create subtask:', error)
      }
    }
  }

  const handleSubmit = async (e: React.FormEvent) => {
    e.preventDefault()
    if (!input.trim() || isLoading || !task) return

    const userMessage: Message = {
      id: nanoid(),
      role: 'user',
      content: input.trim(),
      timestamp: Date.now(),
    }

    setMessages((prev) => [...prev, userMessage])
    setInput('')
    setIsLoading(true)
    setStreamingContent('')

    // Save user message to database
    await window.electron.messages.create({
      task_id: taskId,
      role: 'user',
      content: userMessage.content,
    })

    try {
      // Build context with system prompt
      const contextMessages = [
        {
          role: 'system',
          content: getSystemPrompt(task),
        },
        ...messages.map((m) => ({
          role: m.role,
          content: m.content,
        })),
        {
          role: 'user',
          content: userMessage.content,
        },
      ]

      // Start streaming
      const result = await window.electron.ai.streamChat(contextMessages, {
        provider: 'openai',
        temperature: 0.7,
        model: 'gpt-4-turbo-preview',
      })

      if (result.success && result.streamId) {
        // Subscribe to stream events
        streamUnsubscribeRef.current = window.electron.ai.onStreamData((data: any) => {
          if (data.streamId !== result.streamId) return

          if (data.type === 'text') {
            setStreamingContent((prev) => prev + data.data)
          } else if (data.type === 'complete') {
            // Save complete message
            const assistantMessage: Message = {
              id: nanoid(),
              role: 'assistant',
              content: streamingContent,
              timestamp: Date.now(),
            }

            setMessages((prev) => [...prev, assistantMessage])
            setStreamingContent('')
            setIsLoading(false)

            // Save to database
            window.electron.messages
              .create({
                task_id: taskId,
                role: 'assistant',
                content: streamingContent,
              })
              .then(() => {
                // Check for task decomposition after saving
                checkForTaskDecomposition(streamingContent)
              })

            // Cleanup subscription
            if (streamUnsubscribeRef.current) {
              streamUnsubscribeRef.current()
              streamUnsubscribeRef.current = null
            }
          } else if (data.type === 'error') {
            console.error('Stream error:', data.error)
            setIsLoading(false)
            setStreamingContent('')

            // Cleanup subscription
            if (streamUnsubscribeRef.current) {
              streamUnsubscribeRef.current()
              streamUnsubscribeRef.current = null
            }
          }
        })
      }
    } catch (error) {
      console.error('Chat error:', error)
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
    <div className="h-full flex flex-col bg-background">
      {/* Header */}
      <div className="h-14 px-4 flex items-center border-b border-border bg-card">
        <h2 className="font-semibold text-lg">{task.title}</h2>
        <span className="ml-2 text-sm text-muted-foreground">({task.execution_mode})</span>
      </div>

      {/* Messages */}
      <div className="flex-1 overflow-y-auto p-4">
        {messages.length === 0 && !streamingContent && (
          <div className="text-center text-muted-foreground py-8">
            <p>No messages yet. Start a conversation!</p>
            {task.description && (
              <div className="mt-4 p-4 bg-accent/10 rounded-lg text-left max-w-2xl mx-auto">
                <p className="text-sm font-medium mb-1">Task Description:</p>
                <p className="text-sm">{task.description}</p>
              </div>
            )}
          </div>
        )}

        <div className="space-y-4 max-w-4xl mx-auto">
          {messages.map((message) => (
            <div
              key={message.id}
              className={`flex gap-3 ${message.role === 'user' ? 'justify-end' : 'justify-start'}`}
            >
              {message.role === 'assistant' && (
                <div className="w-8 h-8 rounded-full bg-primary/10 flex items-center justify-center flex-shrink-0">
                  <Bot className="w-5 h-5 text-primary" />
                </div>
              )}

              <div
                className={`
                  max-w-[70%] rounded-lg px-4 py-2
                  ${
                    message.role === 'user'
                      ? 'bg-primary text-primary-foreground'
                      : 'bg-card border border-border'
                  }
                `}
              >
                {message.role === 'assistant' ? (
                  <ReactMarkdown className="prose prose-sm dark:prose-invert max-w-none">
                    {message.content}
                  </ReactMarkdown>
                ) : (
                  <p className="text-sm whitespace-pre-wrap">{message.content}</p>
                )}
              </div>

              {message.role === 'user' && (
                <div className="w-8 h-8 rounded-full bg-secondary flex items-center justify-center flex-shrink-0">
                  <User className="w-5 h-5" />
                </div>
              )}
            </div>
          ))}

          {streamingContent && (
            <div className="flex gap-3 justify-start">
              <div className="w-8 h-8 rounded-full bg-primary/10 flex items-center justify-center flex-shrink-0">
                <Bot className="w-5 h-5 text-primary" />
              </div>

              <div className="max-w-[70%] rounded-lg px-4 py-2 bg-card border border-border">
                <ReactMarkdown className="prose prose-sm dark:prose-invert max-w-none">
                  {streamingContent}
                </ReactMarkdown>
              </div>
            </div>
          )}

          {isLoading && !streamingContent && (
            <div className="flex gap-3 justify-start">
              <div className="w-8 h-8 rounded-full bg-primary/10 flex items-center justify-center">
                <Bot className="w-5 h-5 text-primary" />
              </div>
              <div className="bg-card border border-border rounded-lg px-4 py-2">
                <Loader2 className="w-4 h-4 animate-spin" />
              </div>
            </div>
          )}
        </div>

        <div ref={messagesEndRef} />
      </div>

      {/* Input */}
      <form onSubmit={handleSubmit} className="p-4 border-t border-border bg-card">
        <div className="flex gap-2 max-w-4xl mx-auto">
          <input
            type="text"
            value={input}
            onChange={(e) => setInput(e.target.value)}
            placeholder={
              task.execution_mode === 'autonomous'
                ? 'This task runs autonomously...'
                : 'Type your message...'
            }
            className="flex-1 px-3 py-2 bg-background border border-input rounded-md focus:outline-none focus:ring-2 focus:ring-ring"
            disabled={isLoading || task.execution_mode === 'autonomous'}
          />
          <button
            type="submit"
            disabled={!input.trim() || isLoading || task.execution_mode === 'autonomous'}
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
