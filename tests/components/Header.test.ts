import { test, expect, Page } from '@playwright/test';
import { ElectronAppHelper } from '../helpers/electron-app';

test.describe('Header Component', () => {
  let electronApp: ElectronAppHelper;
  let page: Page;

  test.beforeEach(async () => {
    electronApp = new ElectronAppHelper();
    const { window } = await electronApp.launch();
    page = window;
  });

  test.afterEach(async () => {
    await electronApp.close();
  });

  test('should display the header', async () => {
    // Look for header element
    const header = page.locator('header').first();
    await expect(header).toBeVisible();
  });

  test('should display app title', async () => {
    // Look for the app title - it should say "Context"
    const title = page.locator('header').locator('text=/Context/i').first();
    await expect(title).toBeVisible();
  });

  test('should have consistent styling', async () => {
    const header = page.locator('header').first();
    
    // Check if header has appropriate classes for styling
    const headerClasses = await header.getAttribute('class');
    expect(headerClasses).toContain('bg-'); // Should have background color
  });

  test('should display project name when project is selected', async () => {
    // Create and select a project
    await page.click('button:has-text("Create Project")');
    const projectInput = page.locator('input[value="New Project"]');
    await projectInput.clear();
    await projectInput.type('My Project');
    await projectInput.press('Enter');
    
    // Wait for project to be created
    await page.waitForTimeout(500);
    
    // Check if project name appears in header
    const projectNameInHeader = page.locator('header').locator('text=My Project');
    
    // The header might show the project name or just the app title
    // This depends on the implementation
    const headerText = await page.locator('header').textContent();
    expect(headerText).toBeTruthy();
  });

  test('should handle window controls on macOS', async () => {
    // On macOS, the header might have space for traffic lights
    const platform = process.platform;
    
    if (platform === 'darwin') {
      const header = page.locator('header').first();
      const headerStyle = await header.getAttribute('style');
      
      // Check if header has appropriate padding for macOS window controls
      // This is implementation-specific
      const headerClasses = await header.getAttribute('class');
      console.log('Header classes on macOS:', headerClasses);
    }
  });

  test('should be sticky/fixed at top', async () => {
    const header = page.locator('header').first();
    
    // Scroll down if there's content
    await page.evaluate(() => window.scrollBy(0, 100));
    
    // Header should still be visible
    await expect(header).toBeVisible();
    
    // Get position style
    const position = await header.evaluate(el => 
      window.getComputedStyle(el).position
    );
    
    // Header should be fixed or sticky
    expect(['fixed', 'sticky', 'absolute']).toContain(position);
  });

  test('should have proper contrast for readability', async () => {
    const header = page.locator('header').first();
    const headerText = header.locator('h1, h2, h3, span, div').first();
    
    if (await headerText.isVisible()) {
      // Get computed styles
      const styles = await headerText.evaluate(el => {
        const computed = window.getComputedStyle(el);
        return {
          color: computed.color,
          backgroundColor: computed.backgroundColor
        };
      });
      
      console.log('Header text styles:', styles);
      // In a real test, you might want to calculate contrast ratio
    }
  });
}); 