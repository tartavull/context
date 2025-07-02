import Database from 'better-sqlite3'
import { app } from 'electron'
import path from 'path'
import fs from 'fs'

let db: Database.Database

export async function initializeDatabase() {
  const userDataPath = app.getPath('userData')
  const dbPath = path.join(userDataPath, 'orchestrator.db')
  
  // Ensure directory exists
  fs.mkdirSync(userDataPath, { recursive: true })
  
  db = new Database(dbPath)
  db.pragma('journal_mode = WAL')
  
  // Create tables
  db.exec(`
    -- Tasks table
    CREATE TABLE IF NOT EXISTS tasks (
      id TEXT PRIMARY KEY,
      parent_id TEXT,
      title TEXT NOT NULL,
      description TEXT,
      status TEXT DEFAULT 'pending',
      execution_mode TEXT DEFAULT 'interactive',
      created_at INTEGER DEFAULT (strftime('%s', 'now')),
      updated_at INTEGER DEFAULT (strftime('%s', 'now')),
      completed_at INTEGER,
      metadata TEXT,
      FOREIGN KEY (parent_id) REFERENCES tasks(id) ON DELETE CASCADE
    );
    
    -- Conversations table
    CREATE TABLE IF NOT EXISTS conversations (
      id TEXT PRIMARY KEY,
      task_id TEXT NOT NULL,
      messages TEXT NOT NULL,
      created_at INTEGER DEFAULT (strftime('%s', 'now')),
      updated_at INTEGER DEFAULT (strftime('%s', 'now')),
      FOREIGN KEY (task_id) REFERENCES tasks(id) ON DELETE CASCADE
    );
    
    -- Prompts table
    CREATE TABLE IF NOT EXISTS prompts (
      id TEXT PRIMARY KEY,
      name TEXT NOT NULL,
      description TEXT,
      template TEXT NOT NULL,
      category TEXT,
      version INTEGER DEFAULT 1,
      parent_version_id TEXT,
      created_at INTEGER DEFAULT (strftime('%s', 'now')),
      updated_at INTEGER DEFAULT (strftime('%s', 'now')),
      metadata TEXT
    );
    
    -- Prompt metrics table
    CREATE TABLE IF NOT EXISTS prompt_metrics (
      id TEXT PRIMARY KEY,
      prompt_id TEXT NOT NULL,
      execution_time INTEGER,
      success BOOLEAN,
      error_message TEXT,
      input_data TEXT,
      output_data TEXT,
      created_at INTEGER DEFAULT (strftime('%s', 'now')),
      FOREIGN KEY (prompt_id) REFERENCES prompts(id)
    );
    
    -- Create indexes
    CREATE INDEX IF NOT EXISTS idx_tasks_parent_id ON tasks(parent_id);
    CREATE INDEX IF NOT EXISTS idx_tasks_status ON tasks(status);
    CREATE INDEX IF NOT EXISTS idx_conversations_task_id ON conversations(task_id);
    CREATE INDEX IF NOT EXISTS idx_prompt_metrics_prompt_id ON prompt_metrics(prompt_id);
    CREATE INDEX IF NOT EXISTS idx_prompt_metrics_success ON prompt_metrics(success);
  `)
  
  // Insert default prompts
  insertDefaultPrompts()
}

function insertDefaultPrompts() {
  const defaultPrompts = [
    {
      id: 'decompose-task',
      name: 'Task Decomposition',
      description: 'Breaks down complex tasks into subtasks',
      category: 'core',
      template: `You are a task decomposition expert. Given a user request:

1. If simple and atomic → Return "EXECUTE" 
2. If complex → Decompose into subtasks

For each subtask, specify:
- Clear, measurable objective
- Execution mode (interactive/autonomous)
- Dependencies on other tasks
- Expected outputs

Request: {input}

Response format:
{
  "action": "DECOMPOSE" | "EXECUTE",
  "subtasks": [
    {
      "title": "...",
      "description": "...",
      "executionMode": "interactive" | "autonomous",
      "dependencies": []
    }
  ]
}`
    },
    {
      id: 'execute-task',
      name: 'Task Execution',
      description: 'Executes a specific task',
      category: 'core',
      template: `You are executing the following task:

Title: {title}
Description: {description}
Context: {context}

Please complete this task. Be specific and actionable in your response.`
    }
  ]
  
  const insert = db.prepare(`
    INSERT OR IGNORE INTO prompts (id, name, description, template, category)
    VALUES (@id, @name, @description, @template, @category)
  `)
  
  defaultPrompts.forEach(prompt => insert.run(prompt))
}

export function getDatabase() {
  if (!db) {
    throw new Error('Database not initialized')
  }
  return db
} 