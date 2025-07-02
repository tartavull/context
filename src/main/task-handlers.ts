import { IpcMain } from 'electron'
import { nanoid } from 'nanoid'
import { getDatabase } from './database'

export function setupTaskHandlers(ipcMain: IpcMain) {
  const db = getDatabase()
  
  // Create a new task
  ipcMain.handle('task:create', async (_, task) => {
    const id = nanoid()
    const stmt = db.prepare(`
      INSERT INTO tasks (id, parent_id, title, description, execution_mode)
      VALUES (@id, @parent_id, @title, @description, @execution_mode)
    `)
    
    try {
      stmt.run({
        id,
        parent_id: task.parentId || null,
        title: task.title,
        description: task.description || null,
        execution_mode: task.executionMode || 'interactive'
      })
      
      return { success: true, id }
    } catch (error: any) {
      return { success: false, error: error.message }
    }
  })
  
  // Update a task
  ipcMain.handle('task:update', async (_, taskId, updates) => {
    const allowedFields = ['title', 'description', 'status', 'execution_mode']
    const setClause = Object.keys(updates)
      .filter(key => allowedFields.includes(key))
      .map(key => `${key} = @${key}`)
      .join(', ')
    
    if (!setClause) {
      return { success: false, error: 'No valid fields to update' }
    }
    
    const stmt = db.prepare(`
      UPDATE tasks 
      SET ${setClause}, updated_at = strftime('%s', 'now')
      WHERE id = @id
    `)
    
    try {
      const info = stmt.run({ id: taskId, ...updates })
      
      // Update completed_at if status changed to completed
      if (updates.status === 'completed') {
        db.prepare(`
          UPDATE tasks 
          SET completed_at = strftime('%s', 'now')
          WHERE id = ?
        `).run(taskId)
      }
      
      return { success: true, changes: info.changes }
    } catch (error: any) {
      return { success: false, error: error.message }
    }
  })
  
  // Delete a task
  ipcMain.handle('task:delete', async (_, taskId) => {
    const stmt = db.prepare('DELETE FROM tasks WHERE id = ?')
    
    try {
      const info = stmt.run(taskId)
      return { success: true, changes: info.changes }
    } catch (error: any) {
      return { success: false, error: error.message }
    }
  })
  
  // Get a single task
  ipcMain.handle('task:get', async (_, taskId) => {
    const stmt = db.prepare('SELECT * FROM tasks WHERE id = ?')
    
    try {
      const task = stmt.get(taskId)
      return { success: true, task }
    } catch (error: any) {
      return { success: false, error: error.message }
    }
  })
  
  // Get all tasks
  ipcMain.handle('task:get-all', async () => {
    const stmt = db.prepare('SELECT * FROM tasks ORDER BY created_at DESC')
    
    try {
      const tasks = stmt.all()
      return { success: true, tasks }
    } catch (error: any) {
      return { success: false, error: error.message }
    }
  })
  
  // Get children of a task
  ipcMain.handle('task:get-children', async (_, parentId) => {
    const stmt = db.prepare('SELECT * FROM tasks WHERE parent_id = ? ORDER BY created_at')
    
    try {
      const tasks = stmt.all(parentId)
      return { success: true, tasks }
    } catch (error: any) {
      return { success: false, error: error.message }
    }
  })
  
  // Decompose a task into subtasks
  ipcMain.handle('task:decompose', async (event, taskId) => {
    // This will use the AI to decompose the task
    // For now, return a placeholder
    return { success: true, message: 'Task decomposition not yet implemented' }
  })
  
  // Execute a task
  ipcMain.handle('task:execute', async (event, taskId, mode) => {
    // This will execute the task using AI
    // For now, return a placeholder
    return { success: true, message: 'Task execution not yet implemented' }
  })
} 