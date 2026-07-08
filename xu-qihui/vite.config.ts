import { defineConfig } from 'vite'
import vue from '@vitejs/plugin-vue'
import path from 'path'

// 同学后端地址（同一路由下，IP 可能会变，改这里即可）
const BACKEND_TARGET = 'http://10.98.27.33:8080'

export default defineConfig({
  plugins: [vue()],
  resolve: {
    alias: {
      '@': path.resolve(__dirname, './src')
    }
  },
  server: {
    proxy: {
      // 前端请求 /api/xxx 会被转发到同学的后端，从而绕过浏览器跨域限制
      '/api': {
        target: BACKEND_TARGET,
        changeOrigin: true
        // 如果同学后端接口本身没有 /api 前缀（例如直接是 /auth/login），
        // 取消下面这行的注释，把 /api 前缀去掉再转发：
        // rewrite: (path) => path.replace(/^\/api/, '')
      }
    }
  }
})