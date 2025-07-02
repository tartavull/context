import { defineConfig } from 'tsup'

export default defineConfig({
  entry: ['src/main/index.ts'],
  target: 'node18',
  format: ['cjs'],
  splitting: false,
  sourcemap: true,
  clean: true,
  external: ['electron', 'better-sqlite3']
}) 