import { autoUpdater } from 'electron-updater'
import { BrowserWindow } from 'electron'
import { EventEmitter } from 'events'
import Store from 'electron-store'

export interface UpdateInfo {
  version: string
  releaseDate: string
  releaseNotes: string
  downloadSize: number
}

export interface UpdateProgress {
  percent: number
  bytesPerSecond: number
  total: number
  transferred: number
}

class UpdateManager extends EventEmitter {
  private store: Store
  private mainWindow: BrowserWindow | null = null
  private updateCheckInProgress = false
  private downloadInProgress = false

  constructor() {
    super()
    this.store = new Store()
    this.setupAutoUpdater()
  }

  setMainWindow(window: BrowserWindow) {
    this.mainWindow = window
  }

  private setupAutoUpdater() {
    // Configure auto-updater
    autoUpdater.autoDownload = false // We'll handle download manually for better UX
    autoUpdater.autoInstallOnAppQuit = true

    // Set GitHub as the update server
    autoUpdater.setFeedURL({
      provider: 'github',
      owner: 'tartavull',
      repo: 'orchestrator',
      private: false,
    })

    // Auto-updater event handlers
    autoUpdater.on('checking-for-update', () => {
      this.updateCheckInProgress = true
      this.emit('checking-for-update')
      this.sendToRenderer('update:checking')
    })

    autoUpdater.on('update-available', (info) => {
      this.updateCheckInProgress = false
      const updateInfo: UpdateInfo = {
        version: info.version,
        releaseDate: info.releaseDate,
        releaseNotes: typeof info.releaseNotes === 'string' ? info.releaseNotes : '',
        downloadSize: info.files?.[0]?.size || 0,
      }
      this.emit('update-available', updateInfo)
      this.sendToRenderer('update:available', updateInfo)
    })

    autoUpdater.on('update-not-available', () => {
      this.updateCheckInProgress = false
      this.emit('update-not-available')
      this.sendToRenderer('update:not-available')
    })

    autoUpdater.on('error', (error) => {
      this.updateCheckInProgress = false
      this.downloadInProgress = false
      this.emit('error', error)
      this.sendToRenderer('update:error', error.message)
    })

    autoUpdater.on('download-progress', (progress) => {
      const progressInfo: UpdateProgress = {
        percent: Math.round(progress.percent),
        bytesPerSecond: progress.bytesPerSecond,
        total: progress.total,
        transferred: progress.transferred,
      }
      this.emit('download-progress', progressInfo)
      this.sendToRenderer('update:download-progress', progressInfo)
    })

    autoUpdater.on('update-downloaded', (info) => {
      this.downloadInProgress = false
      this.emit('update-downloaded', info)
      this.sendToRenderer('update:downloaded', info)
    })
  }

  private sendToRenderer(channel: string, ...args: unknown[]) {
    if (this.mainWindow && !this.mainWindow.isDestroyed()) {
      this.mainWindow.webContents.send(channel, ...args)
    }
  }

  // Public methods
  async checkForUpdates(silent = false): Promise<void> {
    if (this.updateCheckInProgress) return

    try {
      if (!silent) {
        this.sendToRenderer('update:checking')
      }
      await autoUpdater.checkForUpdates()
    } catch (error) {
      if (!silent) {
        this.emit('error', error)
      }
    }
  }

  async downloadUpdate(): Promise<void> {
    if (this.downloadInProgress) return

    try {
      this.downloadInProgress = true
      await autoUpdater.downloadUpdate()
    } catch (error) {
      this.downloadInProgress = false
      throw error
    }
  }

  quitAndInstall(): void {
    autoUpdater.quitAndInstall()
  }

  // Settings
  getAutoUpdateEnabled(): boolean {
    return this.store.get('autoUpdate.enabled', true) as boolean
  }

  setAutoUpdateEnabled(enabled: boolean): void {
    this.store.set('autoUpdate.enabled', enabled)
  }

  getCheckInterval(): number {
    // Return interval in hours
    return this.store.get('autoUpdate.checkInterval', 24) as number
  }

  setCheckInterval(hours: number): void {
    this.store.set('autoUpdate.checkInterval', hours)
  }

  // Automatic periodic checking
  startPeriodicChecks(): void {
    if (!this.getAutoUpdateEnabled()) return

    const intervalHours = this.getCheckInterval()
    const intervalMs = intervalHours * 60 * 60 * 1000

    // Check immediately on startup (after 30 seconds delay)
    setTimeout(() => {
      this.checkForUpdates(true)
    }, 30000)

    // Set up periodic checks
    setInterval(() => {
      if (this.getAutoUpdateEnabled()) {
        this.checkForUpdates(true)
      }
    }, intervalMs)
  }
}

export const updateManager = new UpdateManager()
