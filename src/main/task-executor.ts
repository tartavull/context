import { generateText } from 'ai'
import { openai } from '@ai-sdk/openai'
import { anthropic } from '@ai-sdk/anthropic'
import { getDatabase } from './database'
import { getAutonomousTaskPrompt } from '../shared/prompts'
import { nanoid } from 'nanoid'

interface Task {
  id: string
  title: string
  description?: string
  status: string
  execution_mode: 'interactive' | 'autonomous'
}

export class TaskExecutor {
  private runningTasks = new Set<string>()
  private taskQueue: string[] = []
  private isProcessing = false
  
  async queueTask(taskId: string) {
    if (!this.taskQueue.includes(taskId) && !this.runningTasks.has(taskId)) {
      this.taskQueue.push(taskId)
      this.processQueue()
    }
  }
  
  private async processQueue() {
    if (this.isProcessing || this.taskQueue.length === 0) return
    
    this.isProcessing = true
    
    while (this.taskQueue.length > 0) {
      const taskId = this.taskQueue.shift()!
      await this.executeTask(taskId)
    }
    
    this.isProcessing = false
  }
  
  private async executeTask(taskId: string) {
    if (this.runningTasks.has(taskId)) return
    
    this.runningTasks.add(taskId)
    const db = getDatabase()
    
    try {
      // Get task details
      const task = db.prepare('SELECT * FROM tasks WHERE id = ?').get(taskId) as Task
      if (!task || task.execution_mode !== 'autonomous') {
        console.log('Task not found or not autonomous:', taskId)
        return
      }
      
      // Update task status to active
      db.prepare('UPDATE tasks SET status = ?, updated_at = ? WHERE id = ?')
        .run('active', Date.now(), taskId)
      
      // Get existing messages for context
      const existingMessages = db.prepare(`
        SELECT * FROM messages 
        WHERE task_id = ? 
        ORDER BY created_at ASC
      `).all(taskId) as any[]
      
      // Build prompt
      const systemPrompt = getAutonomousTaskPrompt(task)
      
      const messages = [
        { role: 'system', content: systemPrompt },
        ...existingMessages.map(msg => ({
          role: msg.role,
          content: msg.content
        }))
      ]
      
      // If no existing messages, add a starter message
      if (existingMessages.length === 0) {
        messages.push({
          role: 'user',
          content: 'Please complete this task autonomously.'
        })
      }
      
      // Execute with AI
      const provider = process.env.AI_PROVIDER || 'openai'
      const model = provider === 'anthropic' 
        ? anthropic('claude-3-opus-20240229')
        : openai('gpt-4-turbo-preview')
      
      console.log(`Executing autonomous task: ${task.title}`)
      
      const result = await generateText({
        model,
        messages,
        temperature: 0.7,
        maxTokens: 4000,
      })
      
      // Save the result as a message
      const messageId = nanoid()
      db.prepare(`
        INSERT INTO messages (id, task_id, role, content, metadata, created_at)
        VALUES (?, ?, ?, ?, ?, ?)
      `).run(
        messageId,
        taskId,
        'assistant',
        result.text,
        JSON.stringify({ autonomous: true }),
        Date.now()
      )
      
      // Update task status to completed
      db.prepare('UPDATE tasks SET status = ?, completed_at = ?, updated_at = ? WHERE id = ?')
        .run('completed', Date.now(), Date.now(), taskId)
      
      console.log(`Completed autonomous task: ${task.title}`)
      
    } catch (error) {
      console.error(`Error executing task ${taskId}:`, error)
      
      // Update task status to failed
      db.prepare('UPDATE tasks SET status = ?, updated_at = ? WHERE id = ?')
        .run('failed', Date.now(), taskId)
      
      // Save error message
      const errorId = nanoid()
      db.prepare(`
        INSERT INTO messages (id, task_id, role, content, metadata, created_at)
        VALUES (?, ?, ?, ?, ?, ?)
      `).run(
        errorId,
        taskId,
        'system',
        `Task execution failed: ${error instanceof Error ? error.message : 'Unknown error'}`,
        JSON.stringify({ error: true }),
        Date.now()
      )
    } finally {
      this.runningTasks.delete(taskId)
    }
  }
  
  // Get all pending autonomous tasks and queue them
  async queuePendingTasks() {
    const db = getDatabase()
    const pendingTasks = db.prepare(`
      SELECT id FROM tasks 
      WHERE status = 'pending' 
      AND execution_mode = 'autonomous'
    `).all() as { id: string }[]
    
    for (const task of pendingTasks) {
      await this.queueTask(task.id)
    }
  }
}

// Create singleton instance
export const taskExecutor = new TaskExecutor() 