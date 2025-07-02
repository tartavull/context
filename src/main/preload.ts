import { contextBridge, ipcRenderer, IpcRendererEvent } from 'electron'

// Define the API exposed to the renderer process
const electronAPI = {
  // AI SDK handlers
  ai: {
    streamChat: (messages: any[], options?: any) => 
      ipcRenderer.invoke('ai:stream-chat', messages, options),
    generateText: (prompt: string, options?: any) => 
      ipcRenderer.invoke('ai:generate-text', prompt, options),
    stopStream: (streamId: string) => 
      ipcRenderer.send('ai:stop-stream', streamId),
    onStreamData: (callback: (data: any) => void) => {
      const subscription = (_: IpcRendererEvent, data: any) => callback(data)
      ipcRenderer.on('ai:stream-data', subscription)
      return () => ipcRenderer.removeListener('ai:stream-data', subscription)
    }
  },

  // Task management
  tasks: {
    create: (task: any) => ipcRenderer.invoke('task:create', task),
    update: (taskId: string, updates: any) => 
      ipcRenderer.invoke('task:update', taskId, updates),
    delete: (taskId: string) => ipcRenderer.invoke('task:delete', taskId),
    get: (taskId: string) => ipcRenderer.invoke('task:get', taskId),
    getAll: () => ipcRenderer.invoke('task:get-all'),
    getChildren: (parentId: string) => 
      ipcRenderer.invoke('task:get-children', parentId),
    decompose: (taskId: string) => 
      ipcRenderer.invoke('task:decompose', taskId),
    execute: (taskId: string, mode: 'interactive' | 'autonomous') => 
      ipcRenderer.invoke('task:execute', taskId, mode)
  },

  // Prompt management
  prompts: {
    getLibrary: () => ipcRenderer.invoke('prompts:get-library'),
    savePrompt: (prompt: any) => ipcRenderer.invoke('prompts:save', prompt),
    getMetrics: (promptId: string) => 
      ipcRenderer.invoke('prompts:get-metrics', promptId),
    testPrompt: (promptId: string, testData: any) => 
      ipcRenderer.invoke('prompts:test', promptId, testData)
  },

  // Settings
  settings: {
    get: (key: string) => ipcRenderer.invoke('settings:get', key),
    set: (key: string, value: any) => 
      ipcRenderer.invoke('settings:set', key, value)
  },

  // App menu events
  onMenuAction: (callback: (action: string) => void) => {
    const events = ['menu:new-task', 'menu:open-task', 'menu:preferences']
    const subscriptions = events.map(event => {
      const handler = () => callback(event.replace('menu:', ''))
      ipcRenderer.on(event, handler)
      return () => ipcRenderer.removeListener(event, handler)
    })
    return () => subscriptions.forEach(unsub => unsub())
  },

  // Platform info
  platform: process.platform
}

// Expose the API to the renderer process
contextBridge.exposeInMainWorld('electron', electronAPI)

// Type definitions for TypeScript
export type ElectronAPI = typeof electronAPI 