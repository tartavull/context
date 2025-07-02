import express from 'express'
import cors from 'cors'
import { openai } from '@ai-sdk/openai'
import { anthropic } from '@ai-sdk/anthropic'
import { streamText } from 'ai'

let server: any = null

export function startChatServer(port: number = 3001) {
  const app = express()

  app.use(cors())
  app.use(express.json())

  // Chat endpoint that mimics Vercel AI SDK expected format
  app.post('/api/chat', async (req, res) => {
    try {
      const { messages, systemMessage, taskContext } = req.body

      // Build context with system prompt if provided
      const contextMessages = [...(systemMessage ? [systemMessage] : []), ...messages]

      // Get model based on preferences (defaulting to OpenAI)
      const model = openai('gpt-4-turbo-preview')

      const result = await streamText({
        model,
        messages: contextMessages,
        temperature: 0.7,
      })

      // Return the streaming response in the format expected by useChat
      return result.toDataStreamResponse()(req, res)
    } catch (error) {
      console.error('Chat API error:', error)
      res.status(500).json({ error: 'Internal server error' })
    }
  })

  server = app.listen(port, 'localhost', () => {
    console.log(`Chat server running on http://localhost:${port}`)
  })

  return server
}

export function stopChatServer() {
  if (server) {
    server.close()
    server = null
  }
}
