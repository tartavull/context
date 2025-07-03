export interface ElectronAPI {
  // Platform info
  platform: string

  // App info
  getVersion: () => Promise<string>
}

declare global {
  interface Window {
    electron: ElectronAPI
  }
}
