# Context App - Playwright E2E Tests

This directory contains end-to-end tests for the Context Electron application using Playwright.

## Test Structure

```
tests/
├── components/          # Component-specific test files
│   ├── Projects.test.ts # Tests for project management (add, remove, rename)
│   ├── Chat.test.ts     # Tests for chat functionality
│   ├── ChatInput.test.ts # Tests for chat input interactions
│   ├── Header.test.ts   # Tests for header component
│   ├── Footer.test.ts   # Tests for footer component
│   └── Chart.test.ts    # Tests for chart/visualization component
├── helpers/
│   └── electron-app.ts  # Helper class for launching Electron app
└── screenshots/         # Screenshots captured during tests (auto-created)
```

## Running Tests

### Prerequisites

Make sure you have built the application first:

```bash
pnpm build
```

### Run All Tests

```bash
pnpm test
```

### Run Tests in UI Mode (Interactive)

```bash
pnpm test:ui
```

This opens Playwright's UI mode where you can:
- See tests run in real-time
- Debug tests step by step
- Explore selectors

### Debug Tests

```bash
pnpm test:debug
```

This runs tests in debug mode with the Playwright Inspector.

### Run Specific Test File

```bash
pnpm test tests/components/Projects.test.ts
```

### Run Tests with Specific Pattern

```bash
pnpm test -g "should create a new project"
```

### View Test Report

After running tests:

```bash
pnpm test:report
```

## Test Coverage

### Projects Component
- ✅ Empty state display
- ✅ Creating new projects
- ✅ Renaming projects
- ✅ Deleting projects
- ✅ Project selection
- ✅ Keyboard shortcuts (Enter/Escape)
- ✅ Project metadata display

### Chat Component
- ✅ Chat interface display
- ✅ Welcome message
- ✅ Sending messages
- ✅ Markdown formatting
- ✅ Code blocks
- ✅ Auto-scrolling
- ✅ Long message handling

### ChatInput Component
- ✅ Text input
- ✅ Message submission
- ✅ Keyboard shortcuts
- ✅ Multi-line support
- ✅ Paste operations
- ✅ Emoji support
- ✅ Focus management

### Header Component
- ✅ Title display
- ✅ Styling consistency
- ✅ Project name display
- ✅ macOS window controls
- ✅ Sticky positioning

### Footer Component
- ✅ Footer display
- ✅ Positioning
- ✅ Content display
- ✅ Responsive behavior

### Chart Component
- ✅ Chart rendering
- ✅ Empty states
- ✅ Interactivity
- ✅ Zoom/pan support
- ✅ Responsive sizing
- ✅ Dark mode support

## Writing New Tests

### Test Template

```typescript
import { test, expect, Page } from '@playwright/test';
import { ElectronAppHelper } from '../helpers/electron-app';

test.describe('Component Name', () => {
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

  test('should do something', async () => {
    // Your test code here
    await expect(page.locator('selector')).toBeVisible();
  });
});
```

### Best Practices

1. **Use descriptive test names**: Start with "should" to describe expected behavior
2. **Keep tests isolated**: Each test should be independent
3. **Use proper selectors**: Prefer semantic selectors (roles, text) over classes
4. **Wait for elements**: Use Playwright's auto-waiting, avoid fixed timeouts
5. **Clean up**: Always close the Electron app in afterEach

### Common Selectors

```typescript
// By text
page.locator('text=Create Project')
page.locator('button:has-text("Submit")')

// By role
page.locator('[role="button"]')
page.locator('[role="main"]')

// By test ID (if added to components)
page.locator('[data-testid="project-list"]')

// Combined
page.locator('header').locator('h1')
```

## Debugging Tips

1. **Take screenshots**: 
   ```typescript
   await page.screenshot({ path: 'debug.png' });
   ```

2. **Pause execution**:
   ```typescript
   await page.pause();
   ```

3. **Log element info**:
   ```typescript
   const text = await element.textContent();
   console.log('Element text:', text);
   ```

4. **Check visibility**:
   ```typescript
   const isVisible = await element.isVisible();
   ```

## CI/CD Integration

To run tests in CI:

```yaml
- name: Install dependencies
  run: pnpm install
  
- name: Build app
  run: pnpm build
  
- name: Run tests
  run: pnpm test
  
- name: Upload test results
  if: always()
  uses: actions/upload-artifact@v3
  with:
    name: playwright-report
    path: playwright-report/
```

## Troubleshooting

### Tests fail to launch Electron
- Ensure the app is built: `pnpm build`
- Check the Electron path in `electron-app.ts`

### Tests are flaky
- Add more specific waits: `await page.waitForSelector()`
- Increase timeout in playwright.config.ts
- Check for race conditions in the app

### Can't find elements
- Use Playwright Inspector: `pnpm test:debug`
- Try different selectors
- Check if element is in shadow DOM or iframe 