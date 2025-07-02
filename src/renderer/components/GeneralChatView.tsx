import React, { useState, useRef, useEffect, useCallback } from 'react'
import { Send, Loader2, Bot, User, StopCircle, RotateCcw, Copy, Check } from 'lucide-react'
import ReactMarkdown from 'react-markdown'
import { cn } from '../lib/utils'
import { useElectronChat } from '../hooks/useElectronChat'

export function GeneralChatView() {
  const messagesEndRef = useRef<HTMLDivElement>(null)
  const [copiedMessageId, setCopiedMessageId] = useState<string | null>(null)

  // Use our custom Electron chat hook for general conversations
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
      // For general chat, we could save to a general conversation log if needed
      console.log('General chat message completed:', message.content)
    },
    onError: (error) => {
      console.error('General chat error:', error)
    },
  })

  const scrollToBottom = useCallback(() => {
    messagesEndRef.current?.scrollIntoView({ behavior: 'smooth' })
  }, [])

  useEffect(() => {
    scrollToBottom()
  }, [messages, scrollToBottom])

  const handleFormSubmit = async (e: React.FormEvent) => {
    e.preventDefault()
    if (!input.trim() || isLoading) return

    // Add system context for general chat
    const systemMessage = {
      role: 'system' as const,
      content:
        'You are a helpful AI assistant in the Orchestrator app. You can help with general questions, task planning, productivity advice, and anything else the user needs. Be friendly, helpful, and concise.',
    }

    // Use the built-in handleSubmit with system context
    handleSubmit(e, {
      body: {
        systemMessage,
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

  return (
    <div className="h-full flex flex-col" style={{ backgroundColor: '#1e1e1e' }}>
      {/* Header - macOS Messages style */}
      <div
        className="h-12 px-4 flex items-center justify-center border-b"
        style={{
          backgroundColor: '#2d2d2d',
          borderBottomColor: '#3d3d3d',
        }}
      >
        <div className="flex items-center gap-2">
          <div className="w-6 h-6 rounded-full bg-blue-500 flex items-center justify-center">
            <Bot className="w-4 h-4 text-white" />
          </div>
          <div className="text-center">
            <h2 className="font-medium text-white text-sm">Orchestrator AI</h2>
          </div>
        </div>
      </div>

      {/* Messages - macOS Messages dark style */}
      <div className="flex-1 overflow-y-auto" style={{ backgroundColor: '#1e1e1e' }}>
        <div className="max-w-2xl mx-auto px-4 py-4">
          {messages.length === 0 && (
            <div className="text-center py-8">
              <div className="w-12 h-12 rounded-full bg-blue-500 flex items-center justify-center mx-auto mb-3">
                <Bot className="w-6 h-6 text-white" />
              </div>
              <h3 className="text-lg font-medium text-white mb-2">Welcome to Orchestrator</h3>
              <p className="text-gray-400 text-sm mb-6">
                I'm your AI assistant. Ask me anything or let me help you plan your tasks!
              </p>
              <div className="space-y-2 max-w-sm mx-auto">
                <button
                  onClick={() =>
                    append({
                      id: 'suggestion-1',
                      role: 'user',
                      content: 'Help me break down a complex project into manageable tasks',
                      createdAt: new Date(),
                    })
                  }
                  className="w-full p-3 rounded-lg text-left transition-colors text-sm"
                  style={{ backgroundColor: '#2d2d2d' }}
                  onMouseEnter={(e) => (e.currentTarget.style.backgroundColor = '#3d3d3d')}
                  onMouseLeave={(e) => (e.currentTarget.style.backgroundColor = '#2d2d2d')}
                >
                  <div className="font-medium text-white">📋 Task Planning</div>
                  <div className="text-gray-400 text-xs">Break down complex projects</div>
                </button>
                <button
                  onClick={() =>
                    append({
                      id: 'suggestion-2',
                      role: 'user',
                      content: 'What are some productivity tips for managing multiple projects?',
                      createdAt: new Date(),
                    })
                  }
                  className="w-full p-3 rounded-lg text-left transition-colors text-sm"
                  style={{ backgroundColor: '#2d2d2d' }}
                  onMouseEnter={(e) => (e.currentTarget.style.backgroundColor = '#3d3d3d')}
                  onMouseLeave={(e) => (e.currentTarget.style.backgroundColor = '#2d2d2d')}
                >
                  <div className="font-medium text-white">⚡ Productivity Tips</div>
                  <div className="text-gray-400 text-xs">Get advice on staying organized</div>
                </button>
              </div>
            </div>
          )}

          <div className="space-y-2">
            {messages.map((message, index) => (
              <div
                key={message.id}
                className={cn(
                  'flex gap-2 group',
                  message.role === 'user' ? 'justify-end' : 'justify-start'
                )}
              >
                {message.role === 'assistant' && (
                  <div
                    className="w-6 h-6 rounded-full flex items-center justify-center flex-shrink-0 mt-1"
                    style={{ backgroundColor: '#3d3d3d' }}
                  >
                    <Bot className="w-3 h-3 text-gray-300" />
                  </div>
                )}

                <div
                  className={cn(
                    'max-w-[70%] px-3 py-2 text-sm relative group',
                    message.role === 'user'
                      ? 'rounded-2xl rounded-br-md'
                      : 'rounded-2xl rounded-bl-md'
                  )}
                  style={{
                    backgroundColor: message.role === 'user' ? '#007AFF' : '#2d2d2d',
                    color: message.role === 'user' ? 'white' : '#ffffff',
                  }}
                >
                  {message.role === 'assistant' ? (
                    <ReactMarkdown
                      className="prose prose-sm max-w-none [&_p]:leading-relaxed [&_p]:my-1 [&_p]:text-white [&_code]:px-1 [&_code]:py-0.5 [&_code]:rounded [&_code]:text-xs [&_pre]:p-2 [&_pre]:rounded-lg [&_pre]:text-xs [&_pre]:overflow-x-auto"
                      components={{
                        p: ({ children }) => (
                          <div className="leading-relaxed text-white">{children}</div>
                        ),
                        code: ({ children, className }) => (
                          <code
                            className="px-1 py-0.5 rounded text-xs font-mono text-white"
                            style={{ backgroundColor: '#3d3d3d' }}
                          >
                            {children}
                          </code>
                        ),
                        pre: ({ children }) => (
                          <pre
                            className="p-2 rounded-lg text-xs overflow-x-auto font-mono text-white"
                            style={{ backgroundColor: '#3d3d3d' }}
                          >
                            {children}
                          </pre>
                        ),
                      }}
                    >
                      {message.content}
                    </ReactMarkdown>
                  ) : (
                    <div className="leading-relaxed text-white">{message.content}</div>
                  )}

                  {/* Copy button - only show on hover */}
                  <button
                    onClick={() => copyToClipboard(message.content, message.id)}
                    className="absolute -top-8 right-0 opacity-0 group-hover:opacity-100 transition-opacity p-1 rounded text-xs"
                    style={{ backgroundColor: '#000000', color: 'white' }}
                    title="Copy message"
                  >
                    {copiedMessageId === message.id ? (
                      <Check className="w-3 h-3" />
                    ) : (
                      <Copy className="w-3 h-3" />
                    )}
                  </button>
                </div>

                {message.role === 'user' && (
                  <div className="w-6 h-6 rounded-full bg-blue-500 flex items-center justify-center flex-shrink-0 mt-1">
                    <User className="w-3 h-3 text-white" />
                  </div>
                )}
              </div>
            ))}
          </div>

          {isLoading && (
            <div className="flex gap-2 justify-start mt-2">
              <div
                className="w-6 h-6 rounded-full flex items-center justify-center flex-shrink-0"
                style={{ backgroundColor: '#3d3d3d' }}
              >
                <Bot className="w-3 h-3 text-gray-300" />
              </div>
              <div
                className="rounded-2xl rounded-bl-md px-3 py-2"
                style={{ backgroundColor: '#2d2d2d' }}
              >
                <div className="flex items-center gap-1">
                  <div className="flex space-x-1">
                    <div
                      className="w-1 h-1 bg-gray-400 rounded-full animate-bounce"
                      style={{ animationDelay: '0ms' }}
                    ></div>
                    <div
                      className="w-1 h-1 bg-gray-400 rounded-full animate-bounce"
                      style={{ animationDelay: '150ms' }}
                    ></div>
                    <div
                      className="w-1 h-1 bg-gray-400 rounded-full animate-bounce"
                      style={{ animationDelay: '300ms' }}
                    ></div>
                  </div>
                </div>
              </div>
            </div>
          )}
        </div>

        <div ref={messagesEndRef} />
      </div>

      {/* Input - macOS Messages dark style */}
      <div
        className="p-3 border-t"
        style={{
          backgroundColor: '#2d2d2d',
          borderTopColor: '#3d3d3d',
        }}
      >
        <form onSubmit={handleFormSubmit} className="max-w-2xl mx-auto">
          <div className="flex items-end gap-2">
            <div className="flex-1 relative">
              <textarea
                value={input}
                onChange={handleInputChange}
                placeholder="Message Orchestrator AI..."
                className="w-full px-3 py-2 border rounded-2xl focus:outline-none focus:ring-2 focus:ring-blue-500 focus:border-transparent resize-none text-sm min-h-[36px] max-h-24 text-white placeholder-gray-400"
                disabled={isLoading}
                rows={1}
                onKeyDown={(e) => {
                  if (e.key === 'Enter' && !e.shiftKey) {
                    e.preventDefault()
                    handleFormSubmit(e as any)
                  }
                }}
                style={{
                  height: 'auto',
                  minHeight: '36px',
                  backgroundColor: '#1e1e1e',
                  borderColor: '#3d3d3d',
                  color: 'white',
                }}
                onInput={(e) => {
                  const target = e.target as HTMLTextAreaElement
                  target.style.height = 'auto'
                  target.style.height = Math.min(target.scrollHeight, 96) + 'px'
                }}
              />
            </div>

            <button
              type="submit"
              disabled={!input.trim() || isLoading}
              className="w-8 h-8 bg-blue-500 hover:bg-blue-600 disabled:opacity-50 disabled:cursor-not-allowed rounded-full flex items-center justify-center transition-colors"
            >
              {isLoading ? (
                <Loader2 className="w-4 h-4 text-white animate-spin" />
              ) : (
                <Send className="w-4 h-4 text-white ml-0.5" />
              )}
            </button>
          </div>
        </form>
      </div>
    </div>
  )
}
