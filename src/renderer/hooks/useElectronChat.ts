import { useState, useRef, useCallback } from 'react'
import { nanoid } from 'nanoid'

interface Message {
  id: string
  role: 'user' | 'assistant' | 'system'
  content: string
  createdAt?: Date
}

interface UseElectronChatOptions {
  initialMessages?: Message[]
  onFinish?: (message: Message) => void | Promise<void>
  onError?: (error: Error) => void
}

interface UseElectronChatReturn {
  messages: Message[]
  input: string
  handleInputChange: (e: React.ChangeEvent<HTMLInputElement | HTMLTextAreaElement>) => void
  handleSubmit: (e: React.FormEvent, options?: { body?: any }) => Promise<void>
  isLoading: boolean
  stop: () => void
  reload: () => Promise<void>
  setMessages: (messages: Message[]) => void
  append: (message: Message) => Promise<void>
}

export function useElectronChat(options: UseElectronChatOptions = {}): UseElectronChatReturn {
  const { initialMessages = [], onFinish, onError } = options

  const [messages, setMessages] = useState<Message[]>(initialMessages)
  const [input, setInput] = useState('')
  const [isLoading, setIsLoading] = useState(false)
  const [streamingContent, setStreamingContent] = useState('')
  const streamUnsubscribeRef = useRef<(() => void) | null>(null)
  const lastUserMessageRef = useRef<Message | null>(null)

  const handleInputChange = useCallback(
    (e: React.ChangeEvent<HTMLInputElement | HTMLTextAreaElement>) => {
      setInput(e.target.value)
    },
    []
  )

  const stop = useCallback(() => {
    if (streamUnsubscribeRef.current) {
      streamUnsubscribeRef.current()
      streamUnsubscribeRef.current = null
    }
    setIsLoading(false)
    setStreamingContent('')
  }, [])

  const sendMessage = useCallback(
    async (userMessage: Message, systemMessage?: Message) => {
      setIsLoading(true)
      setStreamingContent('')

      try {
        // Build context with system prompt if provided
        const contextMessages = [
          ...(systemMessage ? [systemMessage] : []),
          ...messages.map((m) => ({
            role: m.role,
            content: m.content,
          })),
          {
            role: userMessage.role,
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
          let accumulatedContent = ''

          // Subscribe to stream events
          streamUnsubscribeRef.current = window.electron.ai.onStreamData((data: any) => {
            if (data.streamId !== result.streamId) return

            if (data.type === 'text') {
              accumulatedContent += data.data
              setStreamingContent(accumulatedContent)
            } else if (data.type === 'complete') {
              // Create assistant message
              const assistantMessage: Message = {
                id: nanoid(),
                role: 'assistant',
                content: accumulatedContent,
                createdAt: new Date(),
              }

              setMessages((prev) => [...prev, assistantMessage])
              setStreamingContent('')
              setIsLoading(false)

              // Call onFinish callback
              if (onFinish) {
                onFinish(assistantMessage)
              }

              // Cleanup subscription
              if (streamUnsubscribeRef.current) {
                streamUnsubscribeRef.current()
                streamUnsubscribeRef.current = null
              }
            } else if (data.type === 'error') {
              console.error('Stream error:', data.error)
              setIsLoading(false)
              setStreamingContent('')

              if (onError) {
                onError(new Error(data.error))
              }

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
        setStreamingContent('')

        if (onError) {
          onError(error as Error)
        }
      }
    },
    [messages, onFinish, onError]
  )

  const handleSubmit = useCallback(
    async (e: React.FormEvent, submitOptions?: { body?: any }) => {
      e.preventDefault()
      if (!input.trim() || isLoading) return

      const userMessage: Message = {
        id: nanoid(),
        role: 'user',
        content: input.trim(),
        createdAt: new Date(),
      }

      lastUserMessageRef.current = userMessage
      setMessages((prev) => [...prev, userMessage])
      setInput('')

      // Extract system message from options if provided
      const systemMessage = submitOptions?.body?.systemMessage

      await sendMessage(userMessage, systemMessage)
    },
    [input, isLoading, sendMessage]
  )

  const append = useCallback(
    async (message: Message) => {
      setMessages((prev) => [...prev, message])

      if (message.role === 'user') {
        lastUserMessageRef.current = message
        await sendMessage(message)
      }
    },
    [sendMessage]
  )

  const reload = useCallback(async () => {
    if (!lastUserMessageRef.current || isLoading) return

    // Remove the last assistant message if it exists
    setMessages((prev) => {
      const lastMessage = prev[prev.length - 1]
      if (lastMessage && lastMessage.role === 'assistant') {
        return prev.slice(0, -1)
      }
      return prev
    })

    // Resend the last user message
    await sendMessage(lastUserMessageRef.current)
  }, [isLoading, sendMessage])

  // Include streaming content in messages for display
  const displayMessages = streamingContent
    ? [
        ...messages,
        {
          id: 'streaming',
          role: 'assistant' as const,
          content: streamingContent,
          createdAt: new Date(),
        },
      ]
    : messages

  return {
    messages: displayMessages,
    input,
    handleInputChange,
    handleSubmit,
    isLoading,
    stop,
    reload,
    setMessages,
    append,
  }
}
