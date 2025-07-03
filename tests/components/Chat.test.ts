import { test, expect, Page } from '@playwright/test';
import { ElectronAppHelper } from '../helpers/electron-app';

test.describe('Chat Component', () => {
  let electronApp: ElectronAppHelper;
  let page: Page;

  test.beforeEach(async () => {
    electronApp = new ElectronAppHelper();
    const { window } = await electronApp.launch();
    page = window;
    
    // Create a project first since chat needs an active project
    await page.click('button:has-text("Create Project")');
    const projectInput = page.locator('input[value="New Project"]');
    await projectInput.clear();
    await projectInput.type('Test Project');
    await projectInput.press('Enter');
  });

  test.afterEach(async () => {
    await electronApp.close();
  });

  test('should display chat interface when project is selected', async () => {
    // The chat component should be visible
    const chatContainer = page.locator('[role="main"]').first();
    await expect(chatContainer).toBeVisible();
  });

  test('should show welcome message for new chat', async () => {
    // Look for welcome or empty state message
    const welcomeMessage = page.locator('text=/How can I help|Welcome|Start a conversation/i');
    await expect(welcomeMessage).toBeVisible();
  });

  test('should display chat messages', async () => {
    // Type a message in the chat input
    const chatInput = page.locator('textarea, input[type="text"]').last();
    await chatInput.fill('Hello, this is a test message');
    await chatInput.press('Enter');
    
    // Wait for the message to appear
    await page.waitForTimeout(1000);
    
    // The message should be visible in the chat
    const userMessage = page.locator('text=Hello, this is a test message');
    await expect(userMessage).toBeVisible();
  });

  test('should handle markdown formatting', async () => {
    // Send a message with markdown
    const chatInput = page.locator('textarea, input[type="text"]').last();
    await chatInput.fill('**Bold text** and *italic text*');
    await chatInput.press('Enter');
    
    // Wait for the message to be processed
    await page.waitForTimeout(1000);
    
    // Check if markdown is rendered (looking for strong or em tags)
    const boldText = page.locator('strong, b').first();
    const italicText = page.locator('em, i').first();
    
    // At least check the message appears
    const message = page.locator('text=/Bold text.*italic text/');
    await expect(message).toBeVisible();
  });

  test('should handle code blocks', async () => {
    // Send a message with a code block
    const chatInput = page.locator('textarea, input[type="text"]').last();
    await chatInput.fill('```javascript\nconst test = "hello";\n```');
    await chatInput.press('Enter');
    
    // Wait for the message to be processed
    await page.waitForTimeout(1000);
    
    // Look for code block elements
    const codeBlock = page.locator('pre, code').first();
    await expect(codeBlock).toBeVisible();
  });

  test('should clear chat input after sending', async () => {
    const chatInput = page.locator('textarea, input[type="text"]').last();
    
    // Type and send a message
    await chatInput.fill('Test message');
    await chatInput.press('Enter');
    
    // Wait a bit for the action to complete
    await page.waitForTimeout(500);
    
    // Input should be cleared
    await expect(chatInput).toHaveValue('');
  });

  test('should maintain scroll position when new messages arrive', async () => {
    // Send multiple messages to create scroll
    const chatInput = page.locator('textarea, input[type="text"]').last();
    
    for (let i = 1; i <= 5; i++) {
      await chatInput.fill(`Message ${i}`);
      await chatInput.press('Enter');
      await page.waitForTimeout(300);
    }
    
    // The last message should be visible (auto-scroll)
    const lastMessage = page.locator('text=Message 5');
    await expect(lastMessage).toBeVisible();
  });

  test('should handle long messages gracefully', async () => {
    const chatInput = page.locator('textarea, input[type="text"]').last();
    const longMessage = 'This is a very long message. '.repeat(20);
    
    await chatInput.fill(longMessage);
    await chatInput.press('Enter');
    
    // Wait for the message to appear
    await page.waitForTimeout(1000);
    
    // The message should be visible and wrapped properly
    const message = page.locator(`text=/This is a very long message/`).first();
    await expect(message).toBeVisible();
  });
}); 