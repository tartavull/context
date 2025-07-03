import React, { useState } from 'react'
import { Loader2, Bot, User } from 'lucide-react'
import { nanoid } from 'nanoid'
import { ChatInput } from './ChatInput'

interface Message {
  id: string
  role: 'user' | 'assistant'
  content: string
  timestamp: number
}

interface ChatProps {
  selectedProjectId: string | null
}

const models = [
  { id: 'claude-4-sonnet', name: 'claude-4-sonnet', tier: 'MAX' },
  { id: 'claude-3-sonnet', name: 'claude-3-sonnet', tier: 'PRO' },
  { id: 'claude-3-haiku', name: 'claude-3-haiku', tier: 'FAST' },
  { id: 'gpt-4', name: 'gpt-4', tier: 'MAX' },
  { id: 'gpt-3.5-turbo', name: 'gpt-3.5-turbo', tier: 'FAST' },
]

const agents = [
  { id: 'agent-1', name: 'Agent #1' },
  { id: 'agent-2', name: 'Agent #2' },
  { id: 'agent-3', name: 'Agent #3' },
  { id: 'agent-4', name: 'Agent #4' },
]

export function Chat({ selectedProjectId }: ChatProps) {
  const [messages, setMessages] = useState<Message[]>([])
  const [input, setInput] = useState('')
  const [isLoading, setIsLoading] = useState(false)
  const [selectedModel, setSelectedModel] = useState(models[0])
  const [selectedAgent, setSelectedAgent] = useState(agents[0])
  const [showModelDropdown, setShowModelDropdown] = useState(false)
  const [showAgentDropdown, setShowAgentDropdown] = useState(false)

  const handleCommand = async (command: string, args: string[]) => {
    console.log('Executing command:', command, 'with args:', args)
    
    // Simulate command execution
    await new Promise(resolve => setTimeout(resolve, 500))
    
    let responseMessage = ''
    
    switch (command) {
      case '/clone':
        responseMessage = '✅ Task cloned successfully! A new clone has been created.'
        break
      case '/spawn':
        responseMessage = `✅ New task spawned successfully!`
        break
      case '/exit':
        responseMessage = '✅ Task folded back to parent successfully.'
        break
      default:
        responseMessage = `❌ Unknown command: ${command}. Available commands: /clone, /spawn, /exit`
    }

    const assistantMessage: Message = {
      id: nanoid(),
      role: 'assistant',
      content: responseMessage,
      timestamp: Date.now(),
    }

    setMessages(prev => [...prev, assistantMessage])
  }

  const handleSubmit = async (e: React.FormEvent) => {
    e.preventDefault()
    if (!input.trim() || isLoading) return

    const inputText = input.trim()
    console.log('Chat input:', inputText)

    // Add user message
    const userMessage: Message = {
      id: nanoid(),
      role: 'user',
      content: inputText,
      timestamp: Date.now(),
    }

    setMessages(prev => [...prev, userMessage])
    setInput('')

    // Check if it's a command
    if (inputText.startsWith('/')) {
      const parts = inputText.split(' ')
      const command = parts[0]
      const args = parts.slice(1)
      
      await handleCommand(command, args)
      return
    }

    // Simulate AI response for regular messages
    setIsLoading(true)
    await new Promise(resolve => setTimeout(resolve, 1000))

    const assistantMessage: Message = {
      id: nanoid(),
      role: 'assistant',
      content: `I received your message: "${inputText}". This is a mock response using ${selectedModel.name}. In a real implementation, this would connect to an AI service.`,
      timestamp: Date.now(),
    }

    setMessages(prev => [...prev, assistantMessage])
    setIsLoading(false)
  }

  if (!selectedProjectId) {
    return (
      <div className="h-full flex items-center justify-center bg-[#1a1a1a]">
        <div className="text-center">
          <Bot className="w-12 h-12 text-gray-400 mx-auto mb-4" />
          <h3 className="text-lg font-medium text-[#e1e1e1] mb-2">No Project Selected</h3>
          <p className="text-[#888] text-sm">Select a project from the left panel to start chatting</p>
        </div>
      </div>
    )
  }

  return (
    <div className="h-full flex flex-col bg-[#1a1a1a]">
      {/* Messages */}
      <div className="flex-1 overflow-y-auto">
        <div className="max-w-3xl mx-auto px-4 py-6">
          {messages.length === 0 && (
            <div className="text-center py-12">
              <div className="w-12 h-12 rounded-full bg-blue-600 flex items-center justify-center mx-auto mb-4">
                <Bot className="w-6 h-6 text-white" />
              </div>
              <h3 className="text-xl font-medium text-[#e1e1e1] mb-2">Start a conversation</h3>
              <p className="text-[#888] text-sm mb-8 max-w-md mx-auto">
                Ask questions, request help, or use commands to manage your project
              </p>
              <div className="p-4 bg-[#2a2a2a] border border-[#3a3a3a] rounded-lg text-left max-w-2xl mx-auto">
                <p className="text-sm font-medium mb-2 text-[#e1e1e1]">Available Commands:</p>
                <div className="text-sm text-[#888] space-y-1">
                  <div><code className="text-blue-400">/clone</code> - Clone the current task</div>
                  <div><code className="text-blue-400">/spawn</code> - Create a new child task</div>
                  <div><code className="text-blue-400">/exit</code> - Fold task back to parent</div>
                </div>
              </div>
            </div>
          )}

          <div className="space-y-6">
            {messages.map((message) => (
              <div
                key={message.id}
                className={`flex gap-3 ${
                  message.role === 'user' ? 'justify-end' : 'justify-start'
                }`}
              >
                {message.role === 'assistant' && (
                  <div className="w-7 h-7 rounded-full bg-blue-600 flex items-center justify-center flex-shrink-0 mt-1">
                    <Bot className="w-4 h-4 text-white" />
                  </div>
                )}

                <div
                  className={`max-w-[75%] relative ${
                    message.role === 'user'
                      ? 'bg-blue-600 text-white rounded-2xl rounded-br-md px-4 py-3'
                      : 'bg-[#2a2a2a] text-[#e1e1e1] rounded-2xl rounded-bl-md px-4 py-3 border border-[#3a3a3a]'
                  }`}
                >
                  <p className="text-sm leading-relaxed">{message.content}</p>
                </div>

                {message.role === 'user' && (
                  <div className="w-7 h-7 rounded-full bg-[#888] flex items-center justify-center flex-shrink-0 mt-1">
                    <User className="w-4 h-4 text-white" />
                  </div>
                )}
              </div>
            ))}
          </div>

          {isLoading && (
            <div className="flex gap-3 justify-start mt-6">
              <div className="w-7 h-7 rounded-full bg-blue-600 flex items-center justify-center flex-shrink-0">
                <Bot className="w-4 h-4 text-white" />
              </div>
              <div className="bg-[#2a2a2a] border border-[#3a3a3a] rounded-2xl rounded-bl-md px-4 py-3">
                <div className="flex items-center gap-2">
                  <Loader2 className="w-4 h-4 animate-spin text-[#888]" />
                  <span className="text-sm text-[#888]">Thinking...</span>
                </div>
              </div>
            </div>
          )}
        </div>
      </div>

      {/* Use the new ChatInput component */}
      <ChatInput
        input={input}
        setInput={setInput}
        isLoading={isLoading}
        onSubmit={handleSubmit}
      />
    </div>
  )
} 