// import Database from 'better-sqlite3'
import { app } from 'electron'
import path from 'path'
import fs from 'fs'

let db: any // Database.Database

export async function initializeDatabase() {
  console.log('Initializing mock database (better-sqlite3 disabled for now)')
  
  // Mock database for development
  db = {
    prepare: (sql: string) => ({
      run: (...args: any[]) => ({ changes: 1, lastInsertRowid: Date.now() }),
      get: (...args: any[]) => null,
      all: (...args: any[]) => []
    }),
    exec: (sql: string) => {},
    pragma: (pragma: string) => {}
  }
  
  console.log('Mock database initialized successfully')
  
  /* TODO: Re-enable when better-sqlite3 is fixed
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
    
    -- Messages table
    CREATE TABLE IF NOT EXISTS messages (
      id TEXT PRIMARY KEY,
      task_id TEXT NOT NULL,
      role TEXT NOT NULL,
      content TEXT NOT NULL,
      metadata TEXT DEFAULT '{}',
      created_at INTEGER NOT NULL,
      FOREIGN KEY (task_id) REFERENCES tasks (id) ON DELETE CASCADE
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
    CREATE INDEX IF NOT EXISTS idx_messages_task_id ON messages(task_id);
    CREATE INDEX IF NOT EXISTS idx_conversations_task_id ON conversations(task_id);
    CREATE INDEX IF NOT EXISTS idx_prompt_metrics_prompt_id ON prompt_metrics(prompt_id);
    CREATE INDEX IF NOT EXISTS idx_prompt_metrics_success ON prompt_metrics(success);
  `)
  
  // Insert default prompts
  insertDefaultPrompts()
  */
}

function insertDefaultPrompts() {
  // Mock implementation - do nothing for now
  console.log('Mock: Default prompts would be inserted here')
}

export function getDatabase() {
  if (!db) {
    throw new Error('Database not initialized')
  }
  return db
}

// Export db for easier access
export { db } 