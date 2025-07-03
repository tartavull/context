import { _electron as electron, ElectronApplication, Page } from '@playwright/test';
import path from 'path';

export class ElectronAppHelper {
  app: ElectronApplication | null = null;
  window: Page | null = null;

  async launch() {
    // Launch Electron app - point to the main.js file
    const appPath = path.join(__dirname, '../../');
    
    this.app = await electron.launch({
      args: [appPath],
      env: {
        ...process.env,
        NODE_ENV: 'test',
      },
    });

    // Wait for the first window to open
    this.window = await this.app.firstWindow();
    
    // Wait for the app to be ready
    await this.window.waitForLoadState('domcontentloaded');
    
    return { app: this.app, window: this.window };
  }

  async close() {
    if (this.app) {
      await this.app.close();
      this.app = null;
      this.window = null;
    }
  }

  async takeScreenshot(name: string) {
    if (this.window) {
      await this.window.screenshot({ 
        path: `tests/screenshots/${name}.png`,
        fullPage: true 
      });
    }
  }
} 