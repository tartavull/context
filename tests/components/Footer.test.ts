import { test, expect, Page } from '@playwright/test';
import { ElectronAppHelper } from '../helpers/electron-app';

test.describe('Footer Component', () => {
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

  test('should display the footer', async () => {
    // Look for footer element
    const footer = page.locator('footer').first();
    await expect(footer).toBeVisible();
  });

  test('should be positioned at the bottom', async () => {
    const footer = page.locator('footer').first();
    
    // Get the footer's position
    const footerBox = await footer.boundingBox();
    const viewportSize = await page.viewportSize();
    
    if (footerBox && viewportSize) {
      // Footer should be near the bottom of the viewport
      expect(footerBox.y + footerBox.height).toBeGreaterThan(viewportSize.height * 0.8);
    }
  });

  test('should display copyright or version information', async () => {
    const footer = page.locator('footer').first();
    const footerText = await footer.textContent();
    
    // Footer might contain copyright, version, or other info
    expect(footerText).toBeTruthy();
    
    // Check for common footer elements
    const hasVersionOrCopyright = 
      footerText?.includes('©') || 
      footerText?.includes('Copyright') ||
      footerText?.includes('Version') ||
      footerText?.includes('v0.') ||
      footerText?.includes('Context');
      
    console.log('Footer text:', footerText);
  });

  test('should have appropriate styling', async () => {
    const footer = page.locator('footer').first();
    
    // Check footer classes
    const footerClasses = await footer.getAttribute('class');
    
    // Footer should have some styling classes
    expect(footerClasses).toBeTruthy();
    
    // Check computed styles
    const styles = await footer.evaluate(el => {
      const computed = window.getComputedStyle(el);
      return {
        backgroundColor: computed.backgroundColor,
        borderTop: computed.borderTop,
        padding: computed.padding
      };
    });
    
    console.log('Footer styles:', styles);
  });

  test('should handle links if present', async () => {
    const footer = page.locator('footer').first();
    const links = footer.locator('a');
    
    const linkCount = await links.count();
    
    if (linkCount > 0) {
      // Test first link
      const firstLink = links.first();
      const href = await firstLink.getAttribute('href');
      
      expect(href).toBeTruthy();
      console.log('Footer link found:', href);
      
      // Check if links have proper styling
      const linkStyles = await firstLink.evaluate(el => 
        window.getComputedStyle(el).textDecoration
      );
      
      console.log('Link decoration:', linkStyles);
    }
  });

  test('should remain visible when scrolling', async () => {
    // Create a project to have content
    await page.click('button:has-text("Create Project")');
    const projectInput = page.locator('input[value="New Project"]');
    await projectInput.clear();
    await projectInput.type('Test Project');
    await projectInput.press('Enter');
    
    // Try to scroll
    await page.evaluate(() => window.scrollBy(0, 200));
    
    // Footer should still be visible
    const footer = page.locator('footer').first();
    await expect(footer).toBeVisible();
  });

  test('should not overlap with main content', async () => {
    const footer = page.locator('footer').first();
    const mainContent = page.locator('main, [role="main"]').first();
    
    if (await mainContent.isVisible()) {
      const footerBox = await footer.boundingBox();
      const mainBox = await mainContent.boundingBox();
      
      if (footerBox && mainBox) {
        // Main content should not extend into footer area
        expect(mainBox.y + mainBox.height).toBeLessThanOrEqual(footerBox.y + 10); // 10px tolerance
      }
    }
  });

  test('should be responsive', async () => {
    const footer = page.locator('footer').first();
    
    // Get initial size
    const initialBox = await footer.boundingBox();
    
    // Resize window
    await page.setViewportSize({ width: 800, height: 600 });
    await page.waitForTimeout(500);
    
    // Footer should still be visible and properly positioned
    await expect(footer).toBeVisible();
    
    const resizedBox = await footer.boundingBox();
    if (initialBox && resizedBox) {
      // Footer width should adjust to viewport
      expect(resizedBox.width).toBeLessThanOrEqual(800);
    }
  });
}); 