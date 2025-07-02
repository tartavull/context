import React, { useState, useRef, useEffect, useCallback } from 'react'
import { Send, Loader2, Bot, User, StopCircle, RotateCcw, Copy, Check } from 'lucide-react'
import { useTaskStore } from '../store/taskStore'
import ReactMarkdown from 'react-markdown'
import { getSystemPrompt, parseSubtasks } from '../../shared/prompts'
import { cn } from '../lib/utils'
import { useElectronChat } from '../hooks/useElectronChat'

interface EnhancedChatViewProps {
  taskId: string
}

export function EnhancedChatView({ taskId }: EnhancedChatViewProps) {
  const task = useTaskStore((state) => state.tasks.get(taskId))
  const createTask = useTaskStore((state) => state.createTask)
  const messagesEndRef = useRef<HTMLDivElement>(null)
  const [copiedMessageId, setCopiedMessageId] = useState<string | null>(null)

  // Use our custom Electron chat hook
  const {
    messages,
    input,
    handleInputChange,
    handleSubmit,
    isLoading,
    stop,
    reload,
    setMessages,
    append,
  } = useElectronChat({
    initialMessages: [],
    onFinish: async (message) => {
      // Save message to our database
      await window.electron.messages.create({
        task_id: taskId,
        role: 'assistant',
        content: message.content,
      })

      // Check for task decomposition
      await checkForTaskDecomposition(message.content)
    },
    onError: (error) => {
      console.error('Chat error:', error)
    },
  })

  const scrollToBottom = useCallback(() => {
    messagesEndRef.current?.scrollIntoView({ behavior: 'smooth' })
  }, [])

  useEffect(() => {
    scrollToBottom()
  }, [messages, scrollToBottom])

  // Load messages from database on mount
  useEffect(() => {
    loadMessages()
  }, [taskId])

  const loadMessages = async () => {
    const result = await window.electron.messages.getByTask(taskId)
    if (result.success && result.messages) {
      const formattedMessages = result.messages.map((msg: any) => ({
        id: msg.id,
        role: msg.role,
        content: msg.content,
        createdAt: new Date(msg.created_at),
      }))
      setMessages(formattedMessages)
    }
  }

  const checkForTaskDecomposition = async (content: string) => {
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
          console.log('Created autonomous task:', newTaskId)
        }
      } catch (error) {
        console.error('Failed to create subtask:', error)
      }
    }
  }

  const handleFormSubmit = async (e: React.FormEvent) => {
    e.preventDefault()
    if (!input.trim() || isLoading || !task) return

    // Save user message to database
    await window.electron.messages.create({
      task_id: taskId,
      role: 'user',
      content: input.trim(),
    })

    // Add system context to the submission
    const systemMessage = {
      role: 'system' as const,
      content: getSystemPrompt(task),
    }

    // Use the built-in handleSubmit with custom options
    handleSubmit(e, {
      body: {
        systemMessage,
        taskContext: {
          id: taskId,
          title: task.title,
          description: task.description,
          execution_mode: task.execution_mode,
        },
      },
    })
  }

  const copyToClipboard = async (content: string, messageId: string) => {
    try {
      await navigator.clipboard.writeText(content)
      setCopiedMessageId(messageId)
      setTimeout(() => setCopiedMessageId(null), 2000)
    } catch (error) {
      console.error('Failed to copy:', error)
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
      <div className="h-14 px-4 flex items-center justify-between border-b border-border bg-card/50 backdrop-blur-sm">
        <div className="flex items-center gap-3">
          <div className="w-8 h-8 rounded-full bg-primary/10 flex items-center justify-center">
            <Bot className="w-5 h-5 text-primary" />
          </div>
          <div>
            <h2 className="font-semibold text-lg">{task.title}</h2>
            <span className="text-xs text-muted-foreground">{task.execution_mode} mode</span>
          </div>
        </div>

        <div className="flex items-center gap-2">
          {isLoading && (
            <button
              onClick={stop}
              className="p-2 hover:bg-accent rounded-md transition-colors"
              title="Stop generation"
            >
              <StopCircle className="w-4 h-4" />
            </button>
          )}
          {!isLoading && messages.length > 0 && (
            <button
              onClick={reload}
              className="p-2 hover:bg-accent rounded-md transition-colors"
              title="Regenerate last response"
            >
              <RotateCcw className="w-4 h-4" />
            </button>
          )}
        </div>
      </div>

      {/* Messages */}
      <div className="flex-1 overflow-y-auto">
        <div className="max-w-4xl mx-auto p-4 space-y-6">
          {messages.length === 0 && (
            <div className="text-center py-12">
              <div className="w-16 h-16 rounded-full bg-primary/10 flex items-center justify-center mx-auto mb-4">
                <Bot className="w-8 h-8 text-primary" />
              </div>
              <h3 className="text-xl font-semibold mb-2">Start a conversation</h3>
              <p className="text-muted-foreground mb-6">
                Ask questions, request help, or discuss your task
              </p>
              {task.description && (
                <div className="p-4 bg-accent/20 rounded-lg text-left max-w-2xl mx-auto">
                  <p className="text-sm font-medium mb-2">Task Description:</p>
                  <p className="text-sm text-muted-foreground">{task.description}</p>
                </div>
              )}
            </div>
          )}

          {messages.map((message, index) => (
            <div
              key={message.id}
              className={cn(
                'flex gap-4 group',
                message.role === 'user' ? 'justify-end' : 'justify-start'
              )}
            >
              {message.role === 'assistant' && (
                <div className="w-8 h-8 rounded-full bg-primary/10 flex items-center justify-center flex-shrink-0 mt-1">
                  <Bot className="w-5 h-5 text-primary" />
                </div>
              )}

              <div
                className={cn(
                  'max-w-[80%] rounded-xl px-4 py-3 relative',
                  message.role === 'user'
                    ? 'bg-primary text-primary-foreground ml-12'
                    : 'bg-card border border-border mr-12'
                )}
              >
                {message.role === 'assistant' ? (
                  <ReactMarkdown
                    className="prose prose-sm dark:prose-invert max-w-none prose-p:leading-relaxed prose-pre:p-0"
                    components={{
                      pre: ({ children }) => (
                        <pre className="overflow-x-auto bg-muted p-4 rounded-lg">{children}</pre>
                      ),
                      code: ({ children, className }) => (
                        <code
                          className={cn(
                            'relative rounded bg-muted px-[0.3rem] py-[0.2rem] font-mono text-sm',
                            className
                          )}
                        >
                          {children}
                        </code>
                      ),
                    }}
                  >
                    {message.content}
                  </ReactMarkdown>
                ) : (
                  <p className="text-sm whitespace-pre-wrap leading-relaxed">{message.content}</p>
                )}

                {/* Copy button */}
                <button
                  onClick={() => copyToClipboard(message.content, message.id)}
                  className="absolute top-2 right-2 opacity-0 group-hover:opacity-100 transition-opacity p-1 hover:bg-accent rounded"
                  title="Copy message"
                >
                  {copiedMessageId === message.id ? (
                    <Check className="w-3 h-3 text-green-500" />
                  ) : (
                    <Copy className="w-3 h-3" />
                  )}
                </button>
              </div>

              {message.role === 'user' && (
                <div className="w-8 h-8 rounded-full bg-secondary flex items-center justify-center flex-shrink-0 mt-1">
                  <User className="w-5 h-5" />
                </div>
              )}
            </div>
          ))}

          {isLoading && (
            <div className="flex gap-4">
              <div className="w-8 h-8 rounded-full bg-primary/10 flex items-center justify-center flex-shrink-0">
                <Bot className="w-5 h-5 text-primary" />
              </div>
              <div className="bg-card border border-border rounded-xl px-4 py-3 mr-12">
                <div className="flex items-center gap-2">
                  <Loader2 className="w-4 h-4 animate-spin" />
                  <span className="text-sm text-muted-foreground">Thinking...</span>
                </div>
              </div>
            </div>
          )}
        </div>

        <div ref={messagesEndRef} />
      </div>

      {/* Input */}
      <div className="p-4 border-t border-border bg-card/50 backdrop-blur-sm">
        <form onSubmit={handleFormSubmit} className="max-w-4xl mx-auto">
          <div className="relative flex items-end gap-3">
            <div className="flex-1 relative">
              <textarea
                value={input}
                onChange={handleInputChange}
                placeholder={
                  task.execution_mode === 'autonomous'
                    ? 'This task runs autonomously...'
                    : 'Type your message... (Shift+Enter for new line)'
                }
                className="w-full px-4 py-3 pr-12 bg-background border border-input rounded-xl focus:outline-none focus:ring-2 focus:ring-ring resize-none min-h-[52px] max-h-32"
                disabled={isLoading || task.execution_mode === 'autonomous'}
                rows={1}
                onKeyDown={(e) => {
                  if (e.key === 'Enter' && !e.shiftKey) {
                    e.preventDefault()
                    handleFormSubmit(e as any)
                  }
                }}
                style={{
                  height: 'auto',
                  minHeight: '52px',
                }}
                onInput={(e) => {
                  const target = e.target as HTMLTextAreaElement
                  target.style.height = 'auto'
                  target.style.height = Math.min(target.scrollHeight, 128) + 'px'
                }}
              />
            </div>

            <button
              type="submit"
              disabled={!input.trim() || isLoading || task.execution_mode === 'autonomous'}
              className="px-4 py-3 bg-primary text-primary-foreground rounded-xl hover:bg-primary/90 disabled:opacity-50 disabled:cursor-not-allowed transition-all duration-200 flex items-center justify-center min-w-[52px]"
            >
              {isLoading ? (
                <Loader2 className="w-4 h-4 animate-spin" />
              ) : (
                <Send className="w-4 h-4" />
              )}
            </button>
          </div>

          <div className="flex items-center justify-between mt-2 px-1">
            <span className="text-xs text-muted-foreground">
              {task.execution_mode === 'interactive'
                ? 'Press Enter to send, Shift+Enter for new line'
                : 'Autonomous mode active'}
            </span>
            {messages.length > 0 && (
              <span className="text-xs text-muted-foreground">
                {messages.length} message{messages.length !== 1 ? 's' : ''}
              </span>
            )}
          </div>
        </form>
      </div>
    </div>
  )
}
