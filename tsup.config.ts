import { defineConfig } from 'tsup'

export default defineConfig({
  entry: {
    index: 'src/main/index.ts',
    preload: 'src/main/preload.ts'
  },
  outDir: 'dist/main',
  target: 'node18',
  format: ['cjs'],
  splitting: false,
  sourcemap: true,
  clean: true,
  external: ['electron', 'better-sqlite3']
}) 