import { IpcMain, IpcMainInvokeEvent } from 'electron'
import { getDatabase } from './database'
import { nanoid } from 'nanoid'

export interface Message {
  id: string
  task_id: string
  role: 'user' | 'assistant' | 'system'
  content: string
  metadata?: any
  created_at: number
}

export function setupMessageHandlers(ipcMain: IpcMain) {
  // Get messages for a task
  ipcMain.handle('messages:get-by-task', async (_event: IpcMainInvokeEvent, taskId: string) => {
    try {
      const db = getDatabase()
      const messages = db.prepare(`
        SELECT * FROM messages 
        WHERE task_id = ? 
        ORDER BY created_at ASC
      `).all(taskId) as Message[]
      
      return { success: true, messages }
    } catch (error: any) {
      return { success: false, error: error.message }
    }
  })
  
  // Save a message
  ipcMain.handle('messages:create', async (_event: IpcMainInvokeEvent, message: Partial<Message>) => {
    try {
      const db = getDatabase()
      const id = nanoid()
      const now = Date.now()
      
      db.prepare(`
        INSERT INTO messages (id, task_id, role, content, metadata, created_at)
        VALUES (?, ?, ?, ?, ?, ?)
      `).run(
        id,
        message.task_id,
        message.role,
        message.content,
        JSON.stringify(message.metadata || {}),
        now
      )
      
      return { success: true, id }
    } catch (error: any) {
      return { success: false, error: error.message }
    }
  })
  
  // Get messages with parent context
  ipcMain.handle('messages:get-with-context', async (_event: IpcMainInvokeEvent, taskId: string) => {
    try {
      const db = getDatabase()
      // Get task to check for parent
      const task = db.prepare('SELECT * FROM tasks WHERE id = ?').get(taskId) as any
      if (!task) {
        return { success: false, error: 'Task not found' }
      }
      
      const messages: Message[] = []
      
      // If task has parent, get parent's messages first (for context)
      if (task.parent_id) {
        const parentMessages = db.prepare(`
          SELECT * FROM messages 
          WHERE task_id = ? 
          ORDER BY created_at ASC
        `).all(task.parent_id) as Message[]
        
        messages.push(...parentMessages)
      }
      
      // Get this task's messages
      const taskMessages = db.prepare(`
        SELECT * FROM messages 
        WHERE task_id = ? 
        ORDER BY created_at ASC
      `).all(taskId) as Message[]
      
      messages.push(...taskMessages)
      
      return { success: true, messages, hasParentContext: !!task.parent_id }
    } catch (error: any) {
      return { success: false, error: error.message }
    }
  })
  
  // Delete all messages for a task
  ipcMain.handle('messages:delete-by-task', async (_event: IpcMainInvokeEvent, taskId: string) => {
    try {
      const db = getDatabase()
      db.prepare('DELETE FROM messages WHERE task_id = ?').run(taskId)
      return { success: true }
    } catch (error: any) {
      return { success: false, error: error.message }
    }
  })
} 