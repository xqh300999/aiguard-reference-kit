# Vue 3 + Vite + TypeScript

Vue 3 组合式 API + Vite + TypeScript 是 AIguard Web 管理后台的技术选型。

## 快速参考

### 项目创建

```bash
# 方式一：create-vue（官方推荐）
npm create vue@latest aiguard-admin
# 交互选项：
# ✔ Add TypeScript? Yes
# ✔ Add JSX Support? No
# ✔ Add Vue Router for Single Page Application? Yes
# ✔ Add Pinia for state management? Yes
# ✔ Add Vitest for Unit Testing? No
# ✔ Add an End-to-End Testing Solution? No
# ✔ Add ESLint for code quality? Yes

cd aiguard-admin
npm install
npm run dev
```

```bash
# 方式二：手动 Vite 创建
npm create vite@latest aiguard-admin -- --template vue-ts
cd aiguard-admin
npm install
npm install vue-router@4 pinia axios element-plus
```

### 项目结构

```
aiguard-admin/
├── src/
│   ├── api/              # API 请求封装
│   ├── assets/           # 静态资源
│   ├── components/       # 公共组件
│   ├── composables/      # 组合式函数
│   ├── layouts/          # 布局组件
│   ├── router/           # 路由配置
│   ├── stores/           # Pinia 状态管理
│   ├── types/            # TypeScript 类型定义
│   ├── utils/            # 工具函数
│   ├── views/            # 页面组件
│   ├── App.vue
│   └── main.ts
├── public/
├── index.html
├── vite.config.ts
├── tsconfig.json
└── package.json
```

### 组合式 API 核心

**ref 和 reactive：**
```typescript
import { ref, reactive, computed, onMounted, watch } from 'vue'

// ref 用于基本类型
const count = ref(0)
const message = ref('Hello')
// 访问/修改需要 .value
count.value++

// reactive 用于对象
const state = reactive({
  name: 'AIguard',
  online: true,
  devices: [] as Device[]
})

// computed 计算属性
const deviceCount = computed(() => state.devices.length)
const onlineCount = computed(() => state.devices.filter(d => d.online).length)

// watch 侦听器
watch(count, (newVal, oldVal) => {
  console.log(`count changed: ${oldVal} -> ${newVal}`)
})

// 生命周期
onMounted(() => {
  loadDevices()
})
```

**组件定义（`<script setup>`）：**
```vue
<script setup lang="ts">
import { ref, onMounted } from 'vue'
import { deviceApi } from '@/api/device'
import type { Device } from '@/types/device'

const devices = ref<Device[]>([])
const loading = ref(false)

async function loadDevices() {
  loading.value = true
  try {
    devices.value = await deviceApi.list()
  } finally {
    loading.value = false
  }
}

onMounted(loadDevices)
</script>

<template>
  <div class="device-list">
    <el-button @click="loadDevices" :loading="loading">刷新</el-button>
    <el-table :data="devices" v-loading="loading">
      <el-table-column prop="name" label="设备名称" />
      <el-table-column prop="status" label="状态" />
      <el-table-column prop="lastOnline" label="最后在线" />
    </el-table>
  </div>
</template>
```

### 类型定义示例

```typescript
// src/types/device.ts
export interface Device {
  id: number
  deviceId: string
  name: string
  type: DeviceType
  status: DeviceStatus
  online: boolean
  lastOnline?: string
  createdAt: string
  updatedAt: string
}

export enum DeviceType {
  VOICE_ASSISTANT = 'VOICE_ASSISTANT',
  SENSOR = 'SENSOR',
  CAMERA = 'CAMERA',
  GATEWAY = 'GATEWAY'
}

export enum DeviceStatus {
  ONLINE = 'ONLINE',
  OFFLINE = 'OFFLINE',
  ERROR = 'ERROR'
}

export interface SensorData {
  id: number
  deviceId: string
  metric: string
  value: number
  unit?: string
  recordedAt: string
}

// API 响应类型
export interface ApiResponse<T> {
  code: number
  message: string
  data: T
}

export interface PageQuery {
  page: number
  pageSize: number
}

export interface PageResult<T> {
  items: T[]
  total: number
  page: number
  pageSize: number
}
```

### API 请求封装（Axios）

```typescript
// src/utils/request.ts
import axios from 'axios'
import type { AxiosInstance, AxiosRequestConfig } from 'axios'
import { ElMessage } from 'element-plus'
import router from '@/router'

const request: AxiosInstance = axios.create({
  baseURL: import.meta.env.VITE_API_BASE_URL || '/api',
  timeout: 10000
})

// 请求拦截器
request.interceptors.request.use((config) => {
  const token = localStorage.getItem('token')
  if (token) {
    config.headers.Authorization = `Bearer ${token}`
  }
  return config
})

// 响应拦截器
request.interceptors.response.use(
  (response) => {
    const { code, message, data } = response.data
    if (code === 0) {
      return data
    }
    ElMessage.error(message || '请求失败')
    return Promise.reject(new Error(message))
  },
  (error) => {
    if (error.response?.status === 401) {
      localStorage.removeItem('token')
      router.push('/login')
    }
    ElMessage.error(error.message || '网络错误')
    return Promise.reject(error)
  }
)

export default request
```

```typescript
// src/api/device.ts
import request from '@/utils/request'
import type { Device, PageQuery, PageResult } from '@/types/device'

export const deviceApi = {
  list(params?: PageQuery): Promise<Device[]> {
    return request.get('/devices', { params })
  },
  get(id: number): Promise<Device> {
    return request.get(`/devices/${id}`)
  },
  create(data: Partial<Device>): Promise<Device> {
    return request.post('/devices', data)
  },
  update(id: number, data: Partial<Device>): Promise<Device> {
    return request.put(`/devices/${id}`, data)
  },
  delete(id: number): Promise<void> {
    return request.delete(`/devices/${id}`)
  }
}
```

### Pinia 状态管理

```typescript
// src/stores/device.ts
import { defineStore } from 'pinia'
import { ref, computed } from 'vue'
import { deviceApi } from '@/api/device'
import type { Device } from '@/types/device'

export const useDeviceStore = defineStore('device', () => {
  const devices = ref<Device[]>([])
  const loading = ref(false)
  const currentDevice = ref<Device | null>(null)

  const onlineCount = computed(() => devices.value.filter(d => d.online).length)
  const offlineCount = computed(() => devices.value.length - onlineCount.value)

  async function fetchDevices() {
    loading.value = true
    try {
      devices.value = await deviceApi.list()
    } finally {
      loading.value = false
    }
  }

  function updateDeviceStatus(deviceId: string, online: boolean) {
    const device = devices.value.find(d => d.deviceId === deviceId)
    if (device) {
      device.online = online
      device.lastOnline = online ? undefined : new Date().toISOString()
    }
  }

  return {
    devices,
    loading,
    currentDevice,
    onlineCount,
    offlineCount,
    fetchDevices,
    updateDeviceStatus
  }
})
```

### 路由配置

```typescript
// src/router/index.ts
import { createRouter, createWebHistory } from 'vue-router'
import type { RouteRecordRaw } from 'vue-router'

const routes: RouteRecordRaw[] = [
  {
    path: '/login',
    component: () => import('@/views/Login.vue'),
    meta: { public: true }
  },
  {
    path: '/',
    component: () => import('@/layouts/MainLayout.vue'),
    redirect: '/dashboard',
    children: [
      {
        path: 'dashboard',
        name: 'Dashboard',
        component: () => import('@/views/Dashboard.vue')
      },
      {
        path: 'devices',
        name: 'Devices',
        component: () => import('@/views/Devices.vue')
      },
      {
        path: 'automation',
        name: 'Automation',
        component: () => import('@/views/Automation.vue')
      },
      {
        path: 'settings',
        name: 'Settings',
        component: () => import('@/views/Settings.vue')
      }
    ]
  }
]

const router = createRouter({
  history: createWebHistory(import.meta.env.BASE_URL),
  routes
})

// 路由守卫
router.beforeEach((to, from, next) => {
  const token = localStorage.getItem('token')
  if (!to.meta.public && !token) {
    next('/login')
  } else {
    next()
  }
})

export default router
```

### 组合式函数（Composable）

```typescript
// src/composables/useWebSocket.ts
import { ref, onUnmounted } from 'vue'
import { useDeviceStore } from '@/stores/device'

export function useDeviceWebSocket() {
  const ws = ref<WebSocket | null>(null)
  const connected = ref(false)
  const lastMessage = ref<any>(null)
  const deviceStore = useDeviceStore()

  function connect() {
    const token = localStorage.getItem('token')
    const wsBase = import.meta.env.VITE_WS_URL || `ws://${location.host}`
    ws.value = new WebSocket(`${wsBase}/ws/device-status?token=${token}`)

    ws.value.onopen = () => {
      connected.value = true
    }

    ws.value.onmessage = (event) => {
      const msg = JSON.parse(event.data)
      lastMessage.value = msg

      switch (msg.type) {
        case 'device_status':
          deviceStore.updateDeviceStatus(msg.data.deviceId, msg.data.online)
          break
        case 'sensor_data':
          break
      }
    }

    ws.value.onclose = () => {
      connected.value = false
      setTimeout(connect, 3000)
    }
  }

  function disconnect() {
    ws.value?.close()
  }

  connect()
  onUnmounted(disconnect)

  return { connected, lastMessage, disconnect }
}
```

### vite.config.ts 配置

```typescript
import { defineConfig } from 'vite'
import vue from '@vitejs/plugin-vue'
import { fileURLToPath, URL } from 'node:url'

export default defineConfig({
  plugins: [vue()],
  resolve: {
    alias: {
      '@': fileURLToPath(new URL('./src', import.meta.url))
    }
  },
  server: {
    port: 5173,
    proxy: {
      '/api': {
        target: 'http://localhost:8080',
        changeOrigin: true
      },
      '/ws': {
        target: 'ws://localhost:8080',
        ws: true
      }
    }
  },
  build: {
    outDir: 'dist',
    sourcemap: false,
    chunkSizeWarningLimit: 1000
  }
})
```

## 常见坑点

1. **ref 访问忘记 `.value`**
   - 组合式 API 中 `ref` 在 `<script>` 中必须用 `.value` 访问，`<template>` 中自动解包
   - TypeScript 通常能检测到此类错误，启用严格模式有帮助

2. **reactive 解构丢失响应性**
   - 直接解构 `reactive` 对象会丢失响应性
   - 解决方案：使用 `toRefs()` 解构，或直接用 `ref`
   ```typescript
   const state = reactive({ count: 0 })
   // 错误：const { count } = state
   // 正确：const { count } = toRefs(state)
   ```

3. **Vite 路径别名配置**
   - `@` 别名需要在 `vite.config.ts` 和 `tsconfig.json` 同时配置
   - tsconfig.json 中需配置 `compilerOptions.paths`

4. **环境变量问题**
   - 必须使用 `VITE_` 前缀的变量才能暴露到客户端
   - 通过 `import.meta.env.VITE_XXX` 访问
   - `.env.development` 和 `.env.production` 分别在开发和构建时加载

5. **组件命名规范**
   - 组件文件名使用 PascalCase：`DeviceList.vue`
   - 避免使用单个单词（与 HTML 元素冲突），如 `Button.vue` → `AppButton.vue`

6. **Pinia 持久化问题**
   - Pinia 状态刷新页面后丢失，需使用 `pinia-plugin-persistedstate` 插件
   - 用户登录状态、主题设置等需持久化

7. **WebSocket 组件生命周期**
   - WebSocket 连接应在组件 `onMounted` 建立，`onUnmounted` 关闭
   - 全局连接建议在 Pinia store 或单独的 composable 中管理

8. **Element Plus 按需引入**
   - 全量引入包体积较大，推荐使用 `unplugin-vue-components` 和 `unplugin-auto-import` 自动按需引入

## 官方链接

详见 [official-links.md](official-links.md)。

- Vue 3 官方文档：https://cn.vuejs.org/
- Vite 官方文档：https://cn.vitejs.dev/
- TypeScript 官方文档：https://www.typescriptlang.org/zh/
- Vue Router 4：https://router.vuejs.org/zh/
- Pinia：https://pinia.vuejs.org/zh/
- Element Plus：https://element-plus.org/zh-CN/
