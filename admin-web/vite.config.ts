import { defineConfig } from 'vite'
import react from '@vitejs/plugin-react'
import tailwindcss from '@tailwindcss/vite'

export default defineConfig({
  plugins: [react(), tailwindcss()],
  server: {
    proxy: {
      '/api': 'http://localhost:8080',
      '/auth': 'http://localhost:8080',
      '/subscriptions': 'http://localhost:8080',
      '/backups': 'http://localhost:8080',
      '/healthz': 'http://localhost:8080',
    },
  },
})
