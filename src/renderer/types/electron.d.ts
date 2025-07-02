export interface ElectronAPI {
  ai: {
    streamChat: (messages: any[], options?: any) => Promise<{ streamId: string; success: boolean }>
    generateText: (prompt: string, options?: any) => Promise<{ success: boolean; text?: string; error?: string }>
    stopStream: (streamId: string) => void
    onStreamData: (callback: (data: any) => void) => () => void
  }
  tasks: {
    create: (task: any) => Promise<{ success: boolean; id?: string; error?: string }>
    update: (taskId: string, updates: any) => Promise<{ success: boolean; error?: string }>
    delete: (taskId: string) => Promise<{ success: boolean; error?: string }>
    get: (taskId: string) => Promise<{ success: boolean; task?: any; error?: string }>
    getAll: () => Promise<{ success: boolean; tasks?: any[]; error?: string }>
    getChildren: (parentId: string) => Promise<{ success: boolean; tasks?: any[]; error?: string }>
    decompose: (taskId: string) => Promise<any>
    execute: (taskId: string, mode: 'interactive' | 'autonomous') => Promise<any>
  }
  prompts: {
    getLibrary: () => Promise<any>
    savePrompt: (prompt: any) => Promise<any>
    getMetrics: (promptId: string) => Promise<any>
    testPrompt: (promptId: string, testData: any) => Promise<any>
  }
  settings: {
    get: (key: string) => Promise<any>
    set: (key: string, value: any) => Promise<void>
  }
  onMenuAction: (callback: (action: string) => void) => () => void
  platform: NodeJS.Platform
}

declare global {
  interface Window {
    electron: ElectronAPI
  }
} 