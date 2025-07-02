import { app, BrowserWindow, ipcMain, shell, Menu } from 'electron'
import path from 'path'
import { initializeDatabase } from './database'
import { setupAIHandlers } from './ai-handlers'
import { setupTaskHandlers } from './task-handlers'
import { setupMessageHandlers } from './message-handlers'
// import { updateManager } from './update-manager' // TODO: Implement update manager
import Store from 'electron-store'

// For CommonJS compatibility (tsup will provide these)
declare const __dirname: string

// Initialize electron store for persistent settings
const store = new Store()

let mainWindow: BrowserWindow | null = null

function createWindow() {
  mainWindow = new BrowserWindow({
    width: 1400,
    height: 900,
    minWidth: 1000,
    minHeight: 600,
    webPreferences: {
      nodeIntegration: false,
      contextIsolation: true,
      preload: path.join(__dirname, 'preload.js'),
    },
    titleBarStyle: process.platform === 'darwin' ? 'hiddenInset' : 'default',
    frame: process.platform !== 'darwin',
    icon: path.join(__dirname, '../assets/icon.png'),
  })

  // Set the main window for update manager
  updateManager.setMainWindow(mainWindow)

  // Load the app
  if (process.env.NODE_ENV === 'development') {
    mainWindow.loadURL('http://localhost:5173')
    mainWindow.webContents.openDevTools()
  } else {
    mainWindow.loadFile(path.join(__dirname, '../renderer/index.html'))
  }

  // Open external links in browser
  mainWindow.webContents.setWindowOpenHandler(({ url }) => {
    shell.openExternal(url)
    return { action: 'deny' }
  })

  mainWindow.on('closed', () => {
    mainWindow = null
  })
}

// App menu
function createMenu() {
  const template: any[] = [
    {
      label: 'File',
      submenu: [
        {
          label: 'New Task',
          accelerator: 'CmdOrCtrl+N',
          click: () => {
            mainWindow?.webContents.send('menu:new-task')
          },
        },
        {
          label: 'Open Task',
          accelerator: 'CmdOrCtrl+O',
          click: () => {
            mainWindow?.webContents.send('menu:open-task')
          },
        },
        { type: 'separator' },
        {
          label: 'Preferences',
          accelerator: 'CmdOrCtrl+,',
          click: () => {
            mainWindow?.webContents.send('menu:preferences')
          },
        },
        { type: 'separator' },
        { role: 'quit' },
      ],
    },
    {
      label: 'Edit',
      submenu: [
        { role: 'undo' },
        { role: 'redo' },
        { type: 'separator' },
        { role: 'cut' },
        { role: 'copy' },
        { role: 'paste' },
      ],
    },
    {
      label: 'View',
      submenu: [
        { role: 'reload' },
        { role: 'forceReload' },
        { role: 'toggleDevTools' },
        { type: 'separator' },
        { role: 'resetZoom' },
        { role: 'zoomIn' },
        { role: 'zoomOut' },
        { type: 'separator' },
        { role: 'togglefullscreen' },
      ],
    },
  ]

  if (process.platform === 'darwin') {
    template.unshift({
      label: app.getName(),
      submenu: [
        { role: 'about' },
        { type: 'separator' },
        { role: 'services', submenu: [] },
        { type: 'separator' },
        { role: 'hide' },
        { role: 'hideOthers' },
        { role: 'unhide' },
        { type: 'separator' },
        { role: 'quit' },
      ],
    })
  }

  const menu = Menu.buildFromTemplate(template)
  Menu.setApplicationMenu(menu)
}

// Setup update handlers
function setupUpdateHandlers() {
  // Check for updates
  ipcMain.handle('update:check', async () => {
    await updateManager.checkForUpdates()
  })

  // Download update
  ipcMain.handle('update:download', async () => {
    await updateManager.downloadUpdate()
  })

  // Install update
  ipcMain.handle('update:install', () => {
    updateManager.quitAndInstall()
  })

  // Get auto-update settings
  ipcMain.handle('update:get-auto-enabled', () => {
    return updateManager.getAutoUpdateEnabled()
  })

  // Set auto-update enabled
  ipcMain.handle('update:set-auto-enabled', (_, enabled: boolean) => {
    updateManager.setAutoUpdateEnabled(enabled)
  })

  // Get check interval
  ipcMain.handle('update:get-check-interval', () => {
    return updateManager.getCheckInterval()
  })

  // Set check interval
  ipcMain.handle('update:set-check-interval', (_, hours: number) => {
    updateManager.setCheckInterval(hours)
  })
}

// App event handlers
app.whenReady().then(async () => {
  try {
    // Initialize database
    await initializeDatabase()
    console.log('Database initialized successfully')

    // Setup IPC handlers
    setupTaskHandlers(ipcMain)
    setupAIHandlers(ipcMain)
    setupMessageHandlers(ipcMain)
    setupUpdateHandlers()
    console.log('IPC handlers set up')

    // Import and queue any pending autonomous tasks
    const { taskExecutor } = await import('./task-executor')
    await taskExecutor.queuePendingTasks()
    console.log('Task executor initialized')

    // Create app menu
    createMenu()

    // Create window
    createWindow()
    console.log('Main window created')

    // Start periodic update checks
    updateManager.startPeriodicChecks()

    app.on('activate', () => {
      if (BrowserWindow.getAllWindows().length === 0) {
        createWindow()
      }
    })
  } catch (error: any) {
    console.error('Failed to initialize app:', error)

    // Create a simple error window
    const errorWindow = new BrowserWindow({
      width: 600,
      height: 400,
      webPreferences: {
        nodeIntegration: false,
        contextIsolation: true,
      },
    })

    errorWindow.loadURL(`data:text/html,
      <html>
        <body style="font-family: Arial; padding: 20px;">
          <h1>Orchestrator - Initialization Error</h1>
          <p>Failed to initialize the application. Please check the console for details.</p>
          <pre style="background: #f0f0f0; padding: 10px; border-radius: 4px;">${error?.message || error}</pre>
          <p>Try restarting the application or check if you have the necessary permissions.</p>
        </body>
      </html>
    `)
  }
})

app.on('window-all-closed', () => {
  if (process.platform !== 'darwin') {
    app.quit()
  }
})

// Handle app settings
ipcMain.handle('settings:get', (_, key: string) => {
  return store.get(key)
})

ipcMain.handle('settings:set', (_, key: string, value: any) => {
  store.set(key, value)
})

// Handle deep links (orchestrator://)
app.setAsDefaultProtocolClient('orchestrator')

// Security: Prevent new window creation
app.on('web-contents-created', (_, contents) => {
  contents.setWindowOpenHandler(({ url }) => {
    shell.openExternal(url)
    return { action: 'deny' }
  })
})
