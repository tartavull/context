export interface ElectronAPI {
  ai: {
    streamChat: (messages: any[], options?: any) => Promise<{ success: boolean; streamId?: string; error?: string }>
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
    decompose: (taskId: string) => Promise<{ success: boolean; subtasks?: any[]; error?: string }>
    execute: (taskId: string, mode: 'interactive' | 'autonomous') => Promise<{ success: boolean; error?: string }>
  }
  messages: {
    getByTask: (taskId: string) => Promise<{ success: boolean; messages?: any[]; error?: string }>
    getWithContext: (taskId: string) => Promise<{ success: boolean; messages?: any[]; hasParentContext?: boolean; error?: string }>
    create: (message: any) => Promise<{ success: boolean; id?: string; error?: string }>
    deleteByTask: (taskId: string) => Promise<{ success: boolean; error?: string }>
  }
  prompts: {
    getLibrary: () => Promise<{ success: boolean; prompts?: any[]; error?: string }>
    savePrompt: (prompt: any) => Promise<{ success: boolean; id?: string; error?: string }>
    getMetrics: (promptId: string) => Promise<{ success: boolean; metrics?: any[]; error?: string }>
    testPrompt: (promptId: string, testData: any) => Promise<{ success: boolean; result?: any; error?: string }>
  }
  settings: {
    get: (key: string) => Promise<any>
    set: (key: string, value: any) => Promise<void>
  }
  onMenuAction: (callback: (action: string) => void) => () => void
  platform: string
  getVersion: () => Promise<string>
  
  // Update management
  update: {
    check: () => Promise<void>
    download: () => Promise<void>
    install: () => Promise<void>
    getAutoEnabled: () => Promise<boolean>
    setAutoEnabled: (enabled: boolean) => Promise<void>
    getCheckInterval: () => Promise<number>
    setCheckInterval: (hours: number) => Promise<void>
  }

  // Update event listeners
  onUpdateChecking: (callback: () => void) => () => void
  onUpdateAvailable: (callback: (info: any) => void) => () => void
  onUpdateNotAvailable: (callback: () => void) => () => void
  onUpdateError: (callback: (error: string) => void) => () => void
  onUpdateDownloadProgress: (callback: (progress: any) => void) => () => void
  onUpdateDownloaded: (callback: (info: any) => void) => () => void
}

declare global {
  interface Window {
    electron: ElectronAPI
  }
} 