import { defineConfig, loadEnv } from 'vite'
import vue from '@vitejs/plugin-vue'
import path from 'path'

export default defineConfig(({ mode }) => {
  const env = loadEnv(mode, process.cwd(), '')
  const apiProxyTarget = env.VITE_API_PROXY_TARGET || env.VITE_API_TARGET || 'http://localhost:8080'

  const proxy = {
    '/api': {
      target: apiProxyTarget,
      changeOrigin: true
    },
    '/ws': {
      target: apiProxyTarget,
      changeOrigin: true,
      ws: true
    }
  }

  return {
    plugins: [vue()],
    server: {
      proxy
    },
    preview: {
      proxy
    },
    build: {
      emptyOutDir: true
    },
    resolve: {
      alias: {
        '@': path.resolve(__dirname, './src')
      }
    }
  }
})
