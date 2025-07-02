import React, { useState, useEffect } from 'react'
import { Settings } from 'lucide-react'

export function UpdateSettings() {
  const [autoUpdateEnabled, setAutoUpdateEnabled] = useState(true)
  const [checkInterval, setCheckInterval] = useState(24)
  const [isLoading, setIsLoading] = useState(true)

  useEffect(() => {
    // Load current settings
    const loadSettings = async () => {
      try {
        const enabled = await window.electron.update.getAutoEnabled()
        const interval = await window.electron.update.getCheckInterval()
        setAutoUpdateEnabled(enabled)
        setCheckInterval(interval)
      } catch (error) {
        console.error('Failed to load update settings:', error)
      } finally {
        setIsLoading(false)
      }
    }
    loadSettings()
  }, [])

  const handleAutoUpdateToggle = async (enabled: boolean) => {
    try {
      await window.electron.update.setAutoEnabled(enabled)
      setAutoUpdateEnabled(enabled)
    } catch (error) {
      console.error('Failed to update auto-update setting:', error)
    }
  }

  const handleIntervalChange = async (hours: number) => {
    try {
      await window.electron.update.setCheckInterval(hours)
      setCheckInterval(hours)
    } catch (error) {
      console.error('Failed to update check interval:', error)
    }
  }

  if (isLoading) {
    return (
      <div className="bg-card border border-border rounded-lg p-6">
        <div className="animate-pulse">
          <div className="h-4 bg-muted rounded w-1/3 mb-2"></div>
          <div className="h-3 bg-muted rounded w-2/3"></div>
        </div>
      </div>
    )
  }

  return (
    <div className="bg-card border border-border rounded-lg">
      <div className="p-6">
        <div className="flex items-center gap-2 mb-2">
          <Settings className="h-5 w-5" />
          <h3 className="text-lg font-semibold">Auto-Update Settings</h3>
        </div>
        <p className="text-sm text-muted-foreground mb-6">
          Configure how Orchestrator checks for and installs updates
        </p>

        <div className="space-y-6">
          <div className="flex items-center justify-between">
            <div className="space-y-0.5">
              <label htmlFor="auto-update" className="text-sm font-medium">
                Enable automatic updates
              </label>
              <p className="text-sm text-muted-foreground">
                Automatically check for and notify about new versions
              </p>
            </div>
            <button
              id="auto-update"
              onClick={() => handleAutoUpdateToggle(!autoUpdateEnabled)}
              className={`
                relative inline-flex h-6 w-11 items-center rounded-full transition-colors
                ${autoUpdateEnabled ? 'bg-primary' : 'bg-muted'}
              `}
            >
              <span
                className={`
                  inline-block h-4 w-4 transform rounded-full bg-white transition-transform
                  ${autoUpdateEnabled ? 'translate-x-6' : 'translate-x-1'}
                `}
              />
            </button>
          </div>

          {autoUpdateEnabled && (
            <div className="space-y-2">
              <label htmlFor="check-interval" className="text-sm font-medium">
                Check interval
              </label>
              <select
                id="check-interval"
                value={checkInterval}
                onChange={(e) => handleIntervalChange(parseInt(e.target.value))}
                className="w-full px-3 py-2 bg-background border border-input rounded-md focus:outline-none focus:ring-2 focus:ring-ring text-sm"
              >
                <option value={1}>Every hour</option>
                <option value={6}>Every 6 hours</option>
                <option value={12}>Every 12 hours</option>
                <option value={24}>Daily</option>
                <option value={168}>Weekly</option>
              </select>
            </div>
          )}
        </div>
      </div>
    </div>
  )
} 