import React, { useState, useEffect } from 'react'
import { Download, RefreshCw, AlertCircle, CheckCircle, X } from 'lucide-react'

interface UpdateInfo {
  version: string
  releaseDate: string
  releaseNotes: string
  downloadSize: number
}

interface UpdateProgress {
  percent: number
  bytesPerSecond: number
  total: number
  transferred: number
}

export function UpdateNotification() {
  const [updateAvailable, setUpdateAvailable] = useState<UpdateInfo | null>(null)
  const [isChecking, setIsChecking] = useState(false)
  const [isDownloading, setIsDownloading] = useState(false)
  const [downloadProgress, setDownloadProgress] = useState<UpdateProgress | null>(null)
  const [updateDownloaded, setUpdateDownloaded] = useState(false)
  const [showDialog, setShowDialog] = useState(false)
  const [showCheckButton, setShowCheckButton] = useState(true)

  useEffect(() => {
    // Set up event listeners
    const removeListeners: (() => void)[] = []

    removeListeners.push(
      window.electron.onUpdateChecking(() => {
        setIsChecking(true)
      })
    )

    removeListeners.push(
      window.electron.onUpdateAvailable((info: UpdateInfo) => {
        setIsChecking(false)
        setUpdateAvailable(info)
        setShowDialog(true)
      })
    )

    removeListeners.push(
      window.electron.onUpdateNotAvailable(() => {
        setIsChecking(false)
        // Show a brief success message
        const timer = setTimeout(() => {
          setShowCheckButton(true)
        }, 2000)
        return () => clearTimeout(timer)
      })
    )

    removeListeners.push(
      window.electron.onUpdateError((error: string) => {
        setIsChecking(false)
        setIsDownloading(false)
        console.error('Update error:', error)
      })
    )

    removeListeners.push(
      window.electron.onUpdateDownloadProgress((progress: UpdateProgress) => {
        setDownloadProgress(progress)
      })
    )

    removeListeners.push(
      window.electron.onUpdateDownloaded(() => {
        setIsDownloading(false)
        setUpdateDownloaded(true)
      })
    )

    return () => {
      removeListeners.forEach((remove) => remove())
    }
  }, [])

  const handleCheckForUpdates = async () => {
    try {
      setShowCheckButton(false)
      await window.electron.update.check()
    } catch (error) {
      console.error('Failed to check for updates:', error)
      setShowCheckButton(true)
    }
  }

  const handleDownloadUpdate = async () => {
    try {
      setIsDownloading(true)
      await window.electron.update.download()
    } catch (error) {
      setIsDownloading(false)
      console.error('Failed to download update:', error)
    }
  }

  const handleInstallUpdate = async () => {
    try {
      await window.electron.update.install()
    } catch (error) {
      console.error('Failed to install update:', error)
    }
  }

  const formatBytes = (bytes: number) => {
    if (bytes === 0) return '0 Bytes'
    const k = 1024
    const sizes = ['Bytes', 'KB', 'MB', 'GB']
    const i = Math.floor(Math.log(bytes) / Math.log(k))
    return parseFloat((bytes / Math.pow(k, i)).toFixed(2)) + ' ' + sizes[i]
  }

  const formatSpeed = (bytesPerSecond: number) => {
    return formatBytes(bytesPerSecond) + '/s'
  }

  return (
    <>
      {/* Manual check button */}
      {showCheckButton && (
        <button
          onClick={handleCheckForUpdates}
          disabled={isChecking}
          className="flex items-center gap-2 px-3 py-1.5 text-sm text-muted-foreground hover:text-foreground transition-colors disabled:opacity-50"
        >
          <RefreshCw className={`h-4 w-4 ${isChecking ? 'animate-spin' : ''}`} />
          {isChecking ? 'Checking...' : 'Check for Updates'}
        </button>
      )}

      {/* Update dialog */}
      {showDialog && (
        <div className="fixed inset-0 bg-black/50 flex items-center justify-center z-50">
          <div className="bg-card border border-border rounded-lg shadow-lg max-w-md w-full mx-4">
            <div className="p-6">
              <div className="flex items-center justify-between mb-4">
                <div className="flex items-center gap-2">
                  {updateDownloaded ? (
                    <CheckCircle className="h-5 w-5 text-green-500" />
                  ) : (
                    <AlertCircle className="h-5 w-5 text-blue-500" />
                  )}
                  <h2 className="text-lg font-semibold">
                    {updateDownloaded ? 'Update Ready' : 'Update Available'}
                  </h2>
                </div>
                <button
                  onClick={() => setShowDialog(false)}
                  className="text-muted-foreground hover:text-foreground"
                >
                  <X className="h-4 w-4" />
                </button>
              </div>

              <p className="text-sm text-muted-foreground mb-4">
                {updateDownloaded
                  ? 'The update has been downloaded and is ready to install.'
                  : `A new version (v${updateAvailable?.version}) is available.`}
              </p>

              {updateAvailable && !updateDownloaded && (
                <div className="space-y-4">
                  <div className="text-sm text-muted-foreground space-y-1">
                    <p>
                      <strong>Version:</strong> {updateAvailable.version}
                    </p>
                    <p>
                      <strong>Size:</strong> {formatBytes(updateAvailable.downloadSize)}
                    </p>
                    <p>
                      <strong>Release Date:</strong>{' '}
                      {new Date(updateAvailable.releaseDate).toLocaleDateString()}
                    </p>
                  </div>

                  {updateAvailable.releaseNotes && (
                    <div className="text-sm">
                      <p className="font-medium mb-2">Release Notes:</p>
                      <div className="bg-muted p-3 rounded-md max-h-32 overflow-y-auto">
                        <pre className="whitespace-pre-wrap text-xs">
                          {updateAvailable.releaseNotes}
                        </pre>
                      </div>
                    </div>
                  )}

                  {isDownloading && downloadProgress && (
                    <div className="space-y-2">
                      <div className="flex justify-between text-sm">
                        <span>Downloading...</span>
                        <span>{downloadProgress.percent}%</span>
                      </div>
                      <div className="w-full bg-muted rounded-full h-2">
                        <div
                          className="bg-primary h-2 rounded-full transition-all duration-300"
                          style={{ width: `${downloadProgress.percent}%` }}
                        />
                      </div>
                      <div className="flex justify-between text-xs text-muted-foreground">
                        <span>
                          {formatBytes(downloadProgress.transferred)} /{' '}
                          {formatBytes(downloadProgress.total)}
                        </span>
                        <span>{formatSpeed(downloadProgress.bytesPerSecond)}</span>
                      </div>
                    </div>
                  )}
                </div>
              )}

              <div className="flex gap-2 mt-6">
                {updateDownloaded ? (
                  <>
                    <button
                      onClick={() => setShowDialog(false)}
                      className="flex-1 px-4 py-2 text-sm border border-border rounded-md hover:bg-accent transition-colors"
                    >
                      Later
                    </button>
                    <button
                      onClick={handleInstallUpdate}
                      className="flex-1 px-4 py-2 text-sm bg-primary text-primary-foreground rounded-md hover:bg-primary/90 transition-colors"
                    >
                      Install & Restart
                    </button>
                  </>
                ) : (
                  <>
                    <button
                      onClick={() => setShowDialog(false)}
                      className="flex-1 px-4 py-2 text-sm border border-border rounded-md hover:bg-accent transition-colors"
                    >
                      Skip
                    </button>
                    <button
                      onClick={handleDownloadUpdate}
                      disabled={isDownloading}
                      className="flex-1 px-4 py-2 text-sm bg-primary text-primary-foreground rounded-md hover:bg-primary/90 disabled:opacity-50 disabled:cursor-not-allowed transition-colors flex items-center justify-center gap-2"
                    >
                      <Download className="h-4 w-4" />
                      {isDownloading ? 'Downloading...' : 'Download'}
                    </button>
                  </>
                )}
              </div>
            </div>
          </div>
        </div>
      )}
    </>
  )
}
