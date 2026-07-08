import axios, { type AxiosRequestConfig } from 'axios'
import { useAuthStore } from '@/stores/auth'
import router from '@/router'
import { ElMessage } from 'element-plus'
import { createMockServer } from '@/mock/server'

const USE_MOCK = import.meta.env.VITE_USE_MOCK === 'true'

const mockServer = createMockServer()

const instance = axios.create({
  baseURL: '/api/v1',
  timeout: 10000,
})

instance.interceptors.request.use(
  (config) => {
    const authStore = useAuthStore()
    if (authStore.token) {
      config.headers.Authorization = `Bearer ${authStore.token}`
    }
    return config
  },
  (error) => Promise.reject(error)
)

instance.interceptors.response.use(
  (response) => {
    const res = response.data
    if (res.code !== 0) {
      ElMessage.error(res.message || '请求失败')
      return Promise.reject(new Error(res.message))
    }
    return res.data
  },
  (error) => {
    if (error.response?.status === 401) {
      const authStore = useAuthStore()
      authStore.logout()
      router.push('/login')
      ElMessage.error('登录已过期，请重新登录')
    }
    return Promise.reject(error)
  }
)

async function request<T>(method: string, url: string, data?: unknown): Promise<T> {
  if (USE_MOCK) {
    const fullUrl = url.startsWith('/api/v1') ? url : `/api/v1${url}`
    const result = await mockServer.request<T>(method, fullUrl, data)
    if (result.code !== 0) {
      if (result.code === 401) {
        const authStore = useAuthStore()
        authStore.logout()
        router.push('/login')
      }
      ElMessage.error(result.message)
      return Promise.reject(new Error(result.message))
    }
    return result.data
  }

  return instance({ method, url, data }) as Promise<T>
}

export const http = {
  get<T = unknown>(url: string, config?: AxiosRequestConfig): Promise<T> {
    if (USE_MOCK) {
      const params = new URLSearchParams()
      Object.entries((config?.params ?? {}) as Record<string, unknown>).forEach(([key, value]) => {
        if (value !== undefined && value !== null && value !== '') {
          params.set(key, String(value))
        }
      })
      const query = params.toString()
      return request('GET', query ? `${url}?${query}` : url)
    }
    return instance.get(url, config)
  },

  post<T = unknown>(url: string, data?: unknown): Promise<T> {
    return request('POST', url, data)
  },

  put<T = unknown>(url: string, data?: unknown): Promise<T> {
    return request('PUT', url, data)
  },

  delete<T = unknown>(url: string): Promise<T> {
    if (USE_MOCK) {
      return request('DELETE', url)
    }
    return instance.delete(url)
  },

  patch<T = unknown>(url: string, data?: unknown): Promise<T> {
    return request('PATCH', url, data)
  },
}

export default http
