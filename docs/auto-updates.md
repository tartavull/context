# Auto-Update System

Context includes a comprehensive auto-update system that automatically checks for new releases and allows users to update the application seamlessly.

## Overview

The auto-update system is built using `electron-updater` and integrates with GitHub Releases. It provides:

- **Automatic Update Checking**: Periodically checks for new versions
- **User-Controlled Downloads**: Users can choose when to download updates
- **Background Installation**: Updates are downloaded and installed with minimal user interruption
- **Cross-Platform Support**: Works on macOS, Windows, and Linux
- **Configurable Settings**: Users can enable/disable auto-updates and set check intervals

## Architecture

### Components

1. **Update Manager** (`src/main/update-manager.ts`)
   - Handles all update-related functionality
   - Manages update checking, downloading, and installation
   - Stores user preferences for auto-updates

2. **UI Components**
   - **UpdateNotification** (`src/renderer/components/UpdateNotification.tsx`): Shows update dialogs and progress
   - **UpdateSettings** (`src/renderer/components/UpdateSettings.tsx`): Allows users to configure auto-update preferences

3. **IPC Communication**
   - Secure communication between main and renderer processes
   - Event-driven updates for real-time progress reporting

## How It Works

### 1. Update Detection
- The app checks for updates on startup (after 30-second delay)
- Periodic checks based on user-configured interval (default: 24 hours)
- Manual checks via the UI
- Uses GitHub Releases API to detect new versions

### 2. User Notification
- When an update is available, a dialog appears with:
  - Version information
  - Release notes
  - Download size
  - Option to download or skip

### 3. Download Process
- Updates are downloaded in the background
- Progress is shown with download speed and percentage
- Users can continue using the app during download

### 4. Installation
- Once downloaded, users are prompted to install and restart
- Installation happens automatically on app quit
- On restart, the new version is active

## Configuration

### GitHub Releases Setup

The system is configured to use GitHub releases from `tartavull/context`. The configuration in `package.json`:

```json
{
  "build": {
    "publish": [
      {
        "provider": "github",
        "owner": "tartavull",
        "repo": "context"
      }
    ]
  }
}
```

### User Settings

Users can configure:
- **Auto-update enabled/disabled**: Toggle automatic update checking
- **Check interval**: How often to check for updates (1 hour to 1 week)

Settings are persisted using `electron-store`.

## Release Process

### Creating a Release

1. **Update Version**: Bump version in `package.json`
2. **Create Git Tag**: 
   ```bash
   git tag v0.2.0
   git push origin v0.2.0
   ```
3. **GitHub Actions**: Automatically builds and publishes release
4. **Auto-Update**: Users will be notified of the new version

### GitHub Actions Workflow

The existing `.github/workflows/release.yml` handles:
- Cross-platform builds (Windows, macOS, Linux)
- Code signing (macOS)
- Asset uploading to GitHub Releases
- Release notes generation

## Development

### Testing Auto-Updates

1. **Local Testing**: 
   ```bash
   # Build and package
   pnpm build
   pnpm package
   ```

2. **Mock Updates**: Create a test release on GitHub to test the update flow

3. **Development Mode**: Auto-updates are disabled in development mode

### Adding Update UI to Your App

The `UpdateNotification` component is already integrated into the main app header. To add update settings to a preferences panel:

```tsx
import { UpdateSettings } from './components/UpdateSettings'

function PreferencesPanel() {
  return (
    <div>
      <UpdateSettings />
    </div>
  )
}
```

## Security

### Code Signing

- **macOS**: Uses hardened runtime and entitlements for security
- **Windows**: NSIS installer with proper signatures
- **Linux**: AppImage format for universal compatibility

### Update Verification

- Updates are verified against GitHub's SSL certificates
- Checksums are validated automatically by `electron-updater`
- Only official releases from the configured repository are accepted

## Troubleshooting

### Common Issues

1. **Updates Not Detected**
   - Check internet connection
   - Verify GitHub repository is accessible
   - Check console for error messages

2. **Download Failures**
   - Usually network-related
   - Updates will retry on next check
   - Users can manually trigger checks

3. **Installation Issues**
   - Ensure app has write permissions
   - On macOS, may need to approve security prompts
   - Check system requirements for new version

### Debugging

Enable debug logging:
```bash
# Set environment variable
DEBUG=electron-updater
```

### Manual Updates

If auto-updates fail, users can always:
1. Download the latest release from GitHub
2. Install manually
3. The app will resume normal auto-update functionality

## Best Practices

### For Releases

1. **Semantic Versioning**: Use proper version numbering (v1.2.3)
2. **Release Notes**: Include clear, user-friendly release notes
3. **Testing**: Test releases on all platforms before publishing
4. **Gradual Rollout**: Consider feature flags for major changes

### For Users

1. **Keep Auto-Updates Enabled**: Ensures security and feature updates
2. **Regular Restarts**: Install updates promptly for best experience
3. **Backup Settings**: User settings are preserved across updates

## API Reference

### Update Manager Methods

```typescript
// Check for updates
await updateManager.checkForUpdates(silent?: boolean)

// Download update
await updateManager.downloadUpdate()

// Install and restart
updateManager.quitAndInstall()

// Settings
updateManager.getAutoUpdateEnabled(): boolean
updateManager.setAutoUpdateEnabled(enabled: boolean)
updateManager.getCheckInterval(): number
updateManager.setCheckInterval(hours: number)
```

### Events

```typescript
// Listen for update events
updateManager.on('checking-for-update', () => {})
updateManager.on('update-available', (info) => {})
updateManager.on('update-not-available', () => {})
updateManager.on('download-progress', (progress) => {})
updateManager.on('update-downloaded', (info) => {})
updateManager.on('error', (error) => {})
``` 