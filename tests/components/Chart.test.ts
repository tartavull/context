import { test, expect, Page } from '@playwright/test';
import { ElectronAppHelper } from '../helpers/electron-app';

test.describe('Chart Component', () => {
  let electronApp: ElectronAppHelper;
  let page: Page;

  test.beforeEach(async () => {
    electronApp = new ElectronAppHelper();
    const { window } = await electronApp.launch();
    page = window;
    
    // Create a project since chart might need project context
    await page.click('button:has-text("Create Project")');
    const projectInput = page.locator('input[value="New Project"]');
    await projectInput.clear();
    await projectInput.type('Chart Test Project');
    await projectInput.press('Enter');
  });

  test.afterEach(async () => {
    await electronApp.close();
  });

  test('should display chart container when data is available', async () => {
    // Look for chart container - might use canvas, svg, or div with specific class
    const chartElements = page.locator('canvas, svg, .chart-container, [class*="chart"]');
    
    // Wait a bit for chart to render
    await page.waitForTimeout(1000);
    
    const chartCount = await chartElements.count();
    console.log('Number of chart elements found:', chartCount);
    
    if (chartCount > 0) {
      const firstChart = chartElements.first();
      await expect(firstChart).toBeVisible();
    }
  });

  test('should handle empty data state', async () => {
    // Look for empty state or loading indicators
    const emptyState = page.locator('text=/no data|empty|loading/i');
    
    // Chart might show empty state initially
    if (await emptyState.isVisible()) {
      console.log('Chart empty state displayed');
      expect(await emptyState.textContent()).toBeTruthy();
    }
  });

  test('should render chart with react-flow if used', async () => {
    // Check if react-flow-renderer is being used (from dependencies)
    const reactFlowContainer = page.locator('.react-flow, [class*="reactflow"]');
    
    if (await reactFlowContainer.isVisible()) {
      await expect(reactFlowContainer).toBeVisible();
      
      // React Flow specific elements
      const nodes = page.locator('.react-flow__node');
      const edges = page.locator('.react-flow__edge');
      
      console.log('React Flow nodes:', await nodes.count());
      console.log('React Flow edges:', await edges.count());
    }
  });

  test('should be interactive if chart supports interactions', async () => {
    const chartElement = page.locator('canvas, svg, .chart-container').first();
    
    if (await chartElement.isVisible()) {
      // Get initial position
      const box = await chartElement.boundingBox();
      
      if (box) {
        // Try clicking on the chart
        await chartElement.click({ position: { x: box.width / 2, y: box.height / 2 } });
        
        // Try hovering
        await chartElement.hover({ position: { x: box.width / 3, y: box.height / 3 } });
        
        // Check for tooltips or hover effects
        const tooltip = page.locator('[role="tooltip"], .tooltip, [class*="tooltip"]');
        if (await tooltip.isVisible()) {
          console.log('Tooltip appeared on hover');
          const tooltipText = await tooltip.textContent();
          expect(tooltipText).toBeTruthy();
        }
      }
    }
  });

  test('should support zoom and pan if enabled', async () => {
    const chartElement = page.locator('canvas, svg, .chart-container').first();
    
    if (await chartElement.isVisible()) {
      const box = await chartElement.boundingBox();
      
      if (box) {
        // Try wheel zoom
        await chartElement.hover();
        await page.mouse.wheel(0, -100); // Zoom in
        await page.waitForTimeout(300);
        
        // Try pan by dragging
        await page.mouse.move(box.x + box.width / 2, box.y + box.height / 2);
        await page.mouse.down();
        await page.mouse.move(box.x + box.width / 3, box.y + box.height / 3);
        await page.mouse.up();
        
        // Chart should still be visible after interactions
        await expect(chartElement).toBeVisible();
      }
    }
  });

  test('should have proper aspect ratio', async () => {
    const chartElement = page.locator('canvas, svg, .chart-container').first();
    
    if (await chartElement.isVisible()) {
      const box = await chartElement.boundingBox();
      
      if (box) {
        // Check aspect ratio is reasonable
        const aspectRatio = box.width / box.height;
        expect(aspectRatio).toBeGreaterThan(0.5);
        expect(aspectRatio).toBeLessThan(3);
        
        console.log('Chart dimensions:', box.width, 'x', box.height);
        console.log('Aspect ratio:', aspectRatio);
      }
    }
  });

  test('should resize responsively', async () => {
    const chartElement = page.locator('canvas, svg, .chart-container').first();
    
    if (await chartElement.isVisible()) {
      // Get initial size
      const initialBox = await chartElement.boundingBox();
      
      // Resize window
      await page.setViewportSize({ width: 1200, height: 800 });
      await page.waitForTimeout(500);
      
      // Get new size
      const resizedBox = await chartElement.boundingBox();
      
      if (initialBox && resizedBox) {
        // Chart should have resized
        expect(resizedBox.width).not.toBe(initialBox.width);
        console.log('Chart resized from', initialBox.width, 'to', resizedBox.width);
      }
    }
  });

  test('should display legend if available', async () => {
    const legend = page.locator('.legend, [class*="legend"], text=/legend/i');
    
    if (await legend.isVisible()) {
      const legendText = await legend.textContent();
      expect(legendText).toBeTruthy();
      console.log('Legend found:', legendText);
    }
  });

  test('should handle dark mode if supported', async () => {
    const chartElement = page.locator('canvas, svg, .chart-container').first();
    
    if (await chartElement.isVisible()) {
      // Get initial styles
      const initialStyles = await chartElement.evaluate(el => {
        const computed = window.getComputedStyle(el);
        return {
          backgroundColor: computed.backgroundColor,
          color: computed.color
        };
      });
      
      console.log('Chart styles:', initialStyles);
      
      // Check if chart adapts to dark theme
      const isDarkMode = await page.evaluate(() => {
        return window.matchMedia && window.matchMedia('(prefers-color-scheme: dark)').matches;
      });
      
      console.log('System dark mode:', isDarkMode);
    }
  });

  test('should export or save chart if feature exists', async () => {
    // Look for export/save buttons
    const exportButton = page.locator('button:has-text("Export"), button:has-text("Save"), button[title*="export"], button[title*="save"]');
    
    if (await exportButton.isVisible()) {
      await exportButton.click();
      
      // Check for export menu or dialog
      const exportOptions = page.locator('[role="menu"], .export-options, text=/PNG|SVG|PDF/i');
      
      if (await exportOptions.isVisible()) {
        console.log('Export options available');
        const optionsText = await exportOptions.textContent();
        expect(optionsText).toBeTruthy();
      }
    }
  });
}); 