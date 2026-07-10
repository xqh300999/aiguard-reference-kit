import axios, { type AxiosRequestConfig, type InternalAxiosRequestConfig } from 'axios'
import { useAuthStore } from '@/stores/auth'
import router from '@/router'
import { ElMessage } from 'element-plus'
import { createMockServer } from '@/mock/server'

const USE_MOCK = import.meta.env.VITE_USE_MOCK === 'true'
const API_BASE_URL = import.meta.env.VITE_API_BASE_URL || '/api/v1'
const WEB_API_BASE_URL = import.meta.env.VITE_WEB_API_BASE_URL || '/api/web/v1'

const mockServer = createMockServer()

const instance = axios.create({
  baseURL: API_BASE_URL,
  timeout: 10000,
})

const webInstance = axios.create({
  baseURL: WEB_API_BASE_URL,
  timeout: 10000,
})

const attachToken = (config: InternalAxiosRequestConfig) => {
  const authStore = useAuthStore()
  if (authStore.token) {
    config.headers.Authorization = `Bearer ${authStore.token}`
  }
  return config
}

const unwrapResponse = (response: any) => {
  const res = response.data
  if (res.code !== 0) {
    ElMessage.error(res.message || '请求失败')
    return Promise.reject(new Error(res.message))
  }
  return res.data
}

const handleResponseError = (error: any) => {
  if (error.response?.status === 401) {
    const authStore = useAuthStore()
    authStore.logout()
    router.push('/login')
    ElMessage.error('登录已过期，请重新登录')
  }
  return Promise.reject(error)
}

instance.interceptors.request.use(
  (config) => attachToken(config),
  (error) => Promise.reject(error)
)

webInstance.interceptors.request.use(
  (config) => attachToken(config),
  (error) => Promise.reject(error)
)

instance.interceptors.response.use(
  (response) => {
    return unwrapResponse(response)
  }
)

instance.interceptors.response.use(undefined, handleResponseError)

webInstance.interceptors.response.use(
  (response) => {
    return unwrapResponse(response)
  }
)

webInstance.interceptors.response.use(undefined, handleResponseError)

function isWebRequest(url: string) {
  return url.startsWith('/web/')
}

function stripWebPrefix(url: string) {
  return url.replace(/^\/web\//, '')
}

async function request<T>(method: string, url: string, data?: unknown): Promise<T> {
  if (USE_MOCK) {
    const normalizedUrl = isWebRequest(url) ? `/${stripWebPrefix(url)}` : url
    const fullUrl = normalizedUrl.startsWith('/api/v1') ? normalizedUrl : `/api/v1${normalizedUrl}`
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

  if (isWebRequest(url)) {
    return webInstance({ method, url: stripWebPrefix(url), data }) as Promise<T>
  }

  return instance({ method, url, data }) as Promise<T>
}

async function download(url: string, params?: Record<string, unknown>): Promise<Blob> {
  const query = new URLSearchParams()
  Object.entries(params ?? {}).forEach(([key, value]) => {
    if (value !== undefined && value !== null && value !== '') {
      query.set(key, String(value))
    }
  })

  if (USE_MOCK) {
    const fullUrl = `/api/v1${url}${query.toString() ? `?${query.toString()}` : ''}`
    const result = await mockServer.request<{ content: string; mimeType: string }>('GET', fullUrl)
    if (result.code !== 0) {
      ElMessage.error(result.message)
      return Promise.reject(new Error(result.message))
    }
    return new Blob([result.data.content], { type: result.data.mimeType })
  }

  const authStore = useAuthStore()
  const response = await axios.request<Blob>({
    baseURL: API_BASE_URL,
    url,
    method: 'GET',
    params,
    responseType: 'blob',
    headers: authStore.token ? { Authorization: `Bearer ${authStore.token}` } : undefined,
  })
  return response.data
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
    if (isWebRequest(url)) {
      return webInstance.get(stripWebPrefix(url), config)
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
    if (isWebRequest(url)) {
      return webInstance.delete(stripWebPrefix(url))
    }
    return instance.delete(url)
  },

  patch<T = unknown>(url: string, data?: unknown): Promise<T> {
    return request('PATCH', url, data)
  },

  download,
}

export default http
