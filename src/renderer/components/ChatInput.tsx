import React, { useState } from 'react'
import { Loader2, ChevronDown, ImageIcon, ArrowUp } from 'lucide-react'

interface ChatInputProps {
  input: string
  setInput: (value: string) => void
  isLoading: boolean
  onSubmit: (e: React.FormEvent) => void
}

const models = [
  { id: 'claude-4-sonnet', name: 'claude-4-sonnet', tier: 'MAX' },
  { id: 'claude-3-sonnet', name: 'claude-3-sonnet', tier: 'PRO' },
  { id: 'claude-3-haiku', name: 'claude-3-haiku', tier: 'FAST' },
  { id: 'gpt-4', name: 'gpt-4', tier: 'MAX' },
  { id: 'gpt-3.5-turbo', name: 'gpt-3.5-turbo', tier: 'FAST' },
]

export function ChatInput({ input, setInput, isLoading, onSubmit }: ChatInputProps) {
  const [selectedModel, setSelectedModel] = useState(models[0])
  const [showModelDropdown, setShowModelDropdown] = useState(false)

  return (
    <div className="border-t border-[#2a2a2a] bg-[#1a1a1a] px-4 py-4">
      <form onSubmit={onSubmit} className="max-w-3xl mx-auto">
        <div className="relative">
          {/* Combined text input and controls */}
          <div className="bg-[#2a2a2a] border border-[#3a3a3a] rounded-2xl overflow-hidden">
            {/* Text input area */}
            <div className="relative min-h-[48px]">
              <textarea
                value={input}
                onChange={(e) => setInput(e.target.value)}
                placeholder="Type your message here..."
                className="w-full h-full px-4 py-3 bg-transparent text-sm text-[#e1e1e1] placeholder-[#888] focus:outline-none resize-none min-h-[48px] max-h-32"
                disabled={isLoading}
                rows={1}
                onKeyDown={(e) => {
                  if (e.key === 'Enter' && !e.shiftKey) {
                    e.preventDefault()
                    onSubmit(e as any)
                  }
                }}
                style={{
                  height: 'auto',
                  minHeight: '48px',
                }}
                onInput={(e) => {
                  const target = e.target as HTMLTextAreaElement
                  target.style.height = 'auto'
                  target.style.height = Math.min(target.scrollHeight, 128) + 'px'
                }}
              />
            </div>

            {/* Bottom row with model selector and icons */}
            <div className="flex items-center justify-between px-4 py-2">
              {/* Model selector on the left */}
              <div className="relative">
                <button
                  type="button"
                  onClick={() => setShowModelDropdown(!showModelDropdown)}
                  className="flex items-center gap-1 hover:bg-[#3a3a3a] transition-colors rounded px-2 py-1"
                >
                  <span className="text-xs text-[#e1e1e1]">
                    {selectedModel.name} <span className="text-[#888] text-xs">{selectedModel.tier}</span>
                  </span>
                  <ChevronDown className="w-2 h-2 text-[#888]" />
                </button>

                {/* Model Dropdown */}
                {showModelDropdown && (
                  <div className="absolute top-full left-0 mt-2 w-64 bg-[#2a2a2a] border border-[#3a3a3a] rounded-lg shadow-lg z-50">
                    {models.map((model) => (
                      <button
                        key={model.id}
                        type="button"
                        onClick={() => {
                          setSelectedModel(model)
                          setShowModelDropdown(false)
                        }}
                        className={`w-full text-left px-4 py-3 text-xs hover:bg-[#3a3a3a] transition-colors first:rounded-t-lg last:rounded-b-lg ${
                          selectedModel.id === model.id ? 'bg-[#3a3a3a]' : ''
                        }`}
                      >
                        <div className="flex items-center justify-between">
                          <span className="text-[#e1e1e1]">{model.name}</span>
                          <span className="text-[#888] text-xs">{model.tier}</span>
                        </div>
                      </button>
                    ))}
                  </div>
                )}
              </div>

              {/* Icons on the right */}
              <div className="flex items-center gap-2">
                <button
                  type="button"
                  className="w-6 h-6 bg-transparent hover:bg-[#3a3a3a] rounded flex items-center justify-center transition-colors"
                >
                  <ImageIcon className="w-3 h-3 text-[#888]" />
                </button>
                <button
                  type="submit"
                  disabled={!input.trim() || isLoading}
                  className="w-6 h-6 bg-transparent hover:bg-[#3a3a3a] disabled:opacity-50 disabled:cursor-not-allowed rounded flex items-center justify-center transition-colors"
                >
                  {isLoading ? (
                    <Loader2 className="w-3 h-3 text-[#888] animate-spin" />
                  ) : (
                    <ArrowUp className="w-3 h-3 text-[#888]" />
                  )}
                </button>
              </div>
            </div>
          </div>

          {/* Click outside to close dropdown */}
          {showModelDropdown && (
            <div
              className="fixed inset-0 z-40"
              onClick={() => setShowModelDropdown(false)}
            />
          )}
        </div>
      </form>
    </div>
  )
} 