import { defineConfig, loadEnv } from 'vite'
import vue from '@vitejs/plugin-vue'
import { resolve } from 'path'

export default defineConfig(({ mode }) => {
  const env = loadEnv(mode, process.cwd(), '')

  return {
    plugins: [vue()],
    resolve: {
      alias: {
        '@': resolve(__dirname, './src')
      }
    },
    server: {
      // 本地网关（开发态）：浏览器只认同源的 /api、/ws，
      // 由这里统一路由到后端。前端代码里不要写死任何后端地址。
      proxy: {
        '/api': {
          target: env.VITE_API_TARGET || 'http://10.98.27.33:8080',
          changeOrigin: true
        },
        '/ws': {
          target: env.VITE_API_TARGET || 'http://10.98.27.33:8080',
          changeOrigin: true,
          ws: true
        }
      }
    },
    preview: {
      // 本地网关（生产态预览）：用 `npm run build && npm run preview` 启动，
      // 同样只暴露单一源，/api、/ws 路由到后端，等价于远程通过网关访问。
      proxy: {
        '/api': {
          target: env.VITE_API_TARGET || 'http://10.98.27.33:8080',
          changeOrigin: true
        },
        '/ws': {
          target: env.VITE_API_TARGET || 'http://10.98.27.33:8080',
          changeOrigin: true,
          ws: true
        }
      }
    },
    build: {
      emptyOutDir: true
    }
  }
})