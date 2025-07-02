import { IpcMain } from 'electron'
import { openai } from '@ai-sdk/openai'
import { anthropic } from '@ai-sdk/anthropic'
import { streamText, generateText } from 'ai'
import { nanoid } from 'nanoid'

// Store active streams
const activeStreams = new Map<string, AbortController>()

export function setupAIHandlers(ipcMain: IpcMain) {
  // Handle streaming chat
  ipcMain.handle('ai:stream-chat', async (event, messages, options = {}) => {
    const streamId = nanoid()
    const abortController = new AbortController()
    activeStreams.set(streamId, abortController)
    
    try {
      // Get API keys from environment
      const provider = options.provider || 'openai'
      const model = provider === 'anthropic' 
        ? anthropic('claude-3-opus-20240229')
        : openai('gpt-4-turbo-preview')
      
      const result = await streamText({
        model,
        messages,
        abortSignal: abortController.signal,
        ...options
      })
      
      // Stream data back to renderer
      for await (const textPart of result.textStream) {
        event.sender.send('ai:stream-data', {
          streamId,
          type: 'text',
          data: textPart
        })
      }
      
      // Send completion signal
      event.sender.send('ai:stream-data', {
        streamId,
        type: 'complete'
      })
      
      return { streamId, success: true }
    } catch (error: any) {
      event.sender.send('ai:stream-data', {
        streamId,
        type: 'error',
        error: error.message
      })
      return { streamId, success: false, error: error.message }
    } finally {
      activeStreams.delete(streamId)
    }
  })
  
  // Handle text generation
  ipcMain.handle('ai:generate-text', async (_, prompt, options = {}) => {
    try {
      const provider = options.provider || 'openai'
      const model = provider === 'anthropic' 
        ? anthropic('claude-3-opus-20240229')
        : openai('gpt-4-turbo-preview')
      
      const result = await generateText({
        model,
        prompt,
        ...options
      })
      
      return { success: true, text: result.text }
    } catch (error: any) {
      return { success: false, error: error.message }
    }
  })
  
  // Handle stream cancellation
  ipcMain.on('ai:stop-stream', (_, streamId) => {
    const controller = activeStreams.get(streamId)
    if (controller) {
      controller.abort()
      activeStreams.delete(streamId)
    }
  })
} 