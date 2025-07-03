import { app, BrowserWindow, shell } from 'electron'
import path from 'path'

// For CommonJS compatibility (tsup will provide these)
declare const __dirname: string

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

  // Load the app
  console.log('NODE_ENV:', process.env.NODE_ENV)
  console.log('__dirname:', __dirname)
  if (process.env.NODE_ENV === 'development' || !app.isPackaged) {
    console.log('Loading development URL: http://localhost:5173')
    mainWindow.loadURL('http://localhost:5173')
    mainWindow.webContents.openDevTools()
  } else {
    console.log('Loading production file:', path.join(__dirname, '../renderer/index.html'))
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

// App event handlers
app.whenReady().then(async () => {
  try {
    console.log('Creating main window...')
    createWindow()
    console.log('Main window created')

    app.on('activate', () => {
      if (BrowserWindow.getAllWindows().length === 0) {
        createWindow()
      }
    })
  } catch (error: any) {
    console.error('Failed to initialize app:', error)
  }
})

app.on('window-all-closed', () => {
  if (process.platform !== 'darwin') {
    app.quit()
  }
})

// Handle app version
app.whenReady().then(() => {
  console.log(`Context UI v${app.getVersion()}`)
})
