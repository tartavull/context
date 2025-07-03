import { contextBridge } from 'electron'

// Define the simplified API exposed to the renderer process
const electronAPI = {
  // Platform info
  platform: process.platform,

  // App info (static for UI-only version)
  getVersion: () => Promise.resolve('0.1.2-ui'),
}

// Expose the API to the renderer process
contextBridge.exposeInMainWorld('electron', electronAPI)

// Type definitions for TypeScript
export type ElectronAPI = typeof electronAPI
