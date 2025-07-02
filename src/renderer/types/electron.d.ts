export interface ElectronAPI {
  ai: {
    streamChat: (
      messages: unknown[],
      options?: unknown
    ) => Promise<{ success: boolean; streamId?: string; error?: string }>
    generateText: (
      prompt: string,
      options?: unknown
    ) => Promise<{ success: boolean; text?: string; error?: string }>
    stopStream: (streamId: string) => void
    onStreamData: (callback: (data: unknown) => void) => () => void
  }
  tasks: {
    create: (task: unknown) => Promise<{ success: boolean; id?: string; error?: string }>
    update: (taskId: string, updates: unknown) => Promise<{ success: boolean; error?: string }>
    delete: (taskId: string) => Promise<{ success: boolean; error?: string }>
    get: (taskId: string) => Promise<{ success: boolean; task?: unknown; error?: string }>
    getAll: () => Promise<{ success: boolean; tasks?: unknown[]; error?: string }>
    getChildren: (
      parentId: string
    ) => Promise<{ success: boolean; tasks?: unknown[]; error?: string }>
    decompose: (
      taskId: string
    ) => Promise<{ success: boolean; subtasks?: unknown[]; error?: string }>
    execute: (
      taskId: string,
      mode: 'interactive' | 'autonomous'
    ) => Promise<{ success: boolean; error?: string }>
  }
  messages: {
    getByTask: (
      taskId: string
    ) => Promise<{ success: boolean; messages?: unknown[]; error?: string }>
    getWithContext: (taskId: string) => Promise<{
      success: boolean
      messages?: unknown[]
      hasParentContext?: boolean
      error?: string
    }>
    create: (message: unknown) => Promise<{ success: boolean; id?: string; error?: string }>
    deleteByTask: (taskId: string) => Promise<{ success: boolean; error?: string }>
  }
  prompts: {
    getLibrary: () => Promise<{ success: boolean; prompts?: unknown[]; error?: string }>
    savePrompt: (prompt: unknown) => Promise<{ success: boolean; id?: string; error?: string }>
    getMetrics: (
      promptId: string
    ) => Promise<{ success: boolean; metrics?: unknown[]; error?: string }>
    testPrompt: (
      promptId: string,
      testData: unknown
    ) => Promise<{ success: boolean; result?: unknown; error?: string }>
  }
  settings: {
    get: (key: string) => Promise<unknown>
    set: (key: string, value: unknown) => Promise<void>
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
  onUpdateAvailable: (callback: (info: unknown) => void) => () => void
  onUpdateNotAvailable: (callback: () => void) => () => void
  onUpdateError: (callback: (error: string) => void) => () => void
  onUpdateDownloadProgress: (callback: (progress: unknown) => void) => () => void
  onUpdateDownloaded: (callback: (info: unknown) => void) => () => void
}

declare global {
  interface Window {
    electron: ElectronAPI
  }
} 