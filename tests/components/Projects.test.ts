import { test, expect, Page } from '@playwright/test';
import { ElectronAppHelper } from '../helpers/electron-app';

test.describe('Projects Component', () => {
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

  test('should display empty state when no projects exist', async () => {
    // Look for the empty state message
    const emptyMessage = page.locator('text=No projects yet');
    await expect(emptyMessage).toBeVisible();
    
    // Verify the Create Project button is visible
    const createButton = page.locator('button:has-text("Create Project")');
    await expect(createButton).toBeVisible();
  });

  test('should create a new project', async () => {
    // Click the Create Project button
    await page.click('button:has-text("Create Project")');
    
    // The new project should appear with "New Project" title in edit mode
    const projectInput = page.locator('input[value="New Project"]');
    await expect(projectInput).toBeVisible();
    
    // Type a new name
    await projectInput.clear();
    await projectInput.type('My Test Project');
    await projectInput.press('Enter');
    
    // Verify the project was created with the new name
    const projectItem = page.locator('text=My Test Project');
    await expect(projectItem).toBeVisible();
  });

  test('should rename an existing project', async () => {
    // First create a project
    await page.click('button:has-text("Create Project")');
    const projectInput = page.locator('input[value="New Project"]');
    await projectInput.clear();
    await projectInput.type('Original Project Name');
    await projectInput.press('Enter');
    
    // Hover over the project to show actions
    const projectItem = page.locator('div:has-text("Original Project Name")').first();
    await projectItem.hover();
    
    // Click the edit button
    const editButton = page.locator('button[title="Edit"]');
    await editButton.click();
    
    // Rename the project
    const editInput = page.locator('input[value="Original Project Name"]');
    await editInput.clear();
    await editInput.type('Renamed Project');
    await editInput.press('Enter');
    
    // Verify the project was renamed
    await expect(page.locator('text=Renamed Project')).toBeVisible();
    await expect(page.locator('text=Original Project Name')).not.toBeVisible();
  });

  test('should delete a project', async () => {
    // First create a project
    await page.click('button:has-text("Create Project")');
    const projectInput = page.locator('input[value="New Project"]');
    await projectInput.clear();
    await projectInput.type('Project to Delete');
    await projectInput.press('Enter');
    
    // Hover over the project to show actions
    const projectItem = page.locator('div:has-text("Project to Delete")').first();
    await projectItem.hover();
    
    // Click the delete button
    const deleteButton = page.locator('button[title="Delete"]');
    await deleteButton.click();
    
    // Handle the confirmation dialog
    page.on('dialog', dialog => dialog.accept());
    
    // Wait for the project to be removed
    await expect(page.locator('text=Project to Delete')).not.toBeVisible();
    
    // Verify we're back to empty state
    await expect(page.locator('text=No projects yet')).toBeVisible();
  });

  test('should select a project when clicked', async () => {
    // Create two projects
    await page.click('button:has-text("Create Project")');
    let projectInput = page.locator('input[value="New Project"]');
    await projectInput.clear();
    await projectInput.type('First Project');
    await projectInput.press('Enter');
    
    // Wait a bit before creating second project
    await page.waitForTimeout(500);
    
    await page.click('button:has-text("Create Project")');
    projectInput = page.locator('input[value="New Project"]');
    await projectInput.clear();
    await projectInput.type('Second Project');
    await projectInput.press('Enter');
    
    // Click on the first project
    const firstProject = page.locator('div:has-text("First Project")').first();
    await firstProject.click();
    
    // Verify it has the selected style (bg-blue-600)
    const selectedProject = page.locator('.bg-blue-600');
    await expect(selectedProject).toContainText('First Project');
  });

  test('should handle escape key to cancel rename', async () => {
    // Create a project
    await page.click('button:has-text("Create Project")');
    const projectInput = page.locator('input[value="New Project"]');
    await projectInput.clear();
    await projectInput.type('Original Name');
    await projectInput.press('Enter');
    
    // Start editing
    const projectItem = page.locator('div:has-text("Original Name")').first();
    await projectItem.hover();
    await page.click('button[title="Edit"]');
    
    // Type new name but press Escape
    const editInput = page.locator('input[value="Original Name"]');
    await editInput.clear();
    await editInput.type('Cancelled Name');
    await editInput.press('Escape');
    
    // Verify the original name is preserved
    await expect(page.locator('text=Original Name')).toBeVisible();
    await expect(page.locator('text=Cancelled Name')).not.toBeVisible();
  });

  test('should display project metadata correctly', async () => {
    // Create a project with description
    await page.click('button:has-text("Create Project")');
    const projectInput = page.locator('input[value="New Project"]');
    await projectInput.clear();
    await projectInput.type('Project with Metadata');
    await projectInput.press('Enter');
    
    // Verify the project shows creation time
    const projectItem = page.locator('div:has-text("Project with Metadata")').first();
    const timeText = projectItem.locator('.text-gray-400.text-xs');
    await expect(timeText).toBeVisible();
    
    // Time should be in format like "2:30 PM" for recent items
    await expect(timeText).toContainText(/\d{1,2}:\d{2}/);
  });
}); 