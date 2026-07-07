import axios, { type AxiosRequestConfig } from 'axios'
import { ElMessage } from 'element-plus'

import { mockRequest } from '@/mock/server'
import type { ApiResult } from '@/types/api'

const useMock = import.meta.env.VITE_USE_MOCK !== 'false'

const http = axios.create({
  baseURL: import.meta.env.VITE_API_BASE_URL || '/api/v1',
  timeout: 10000,
})

http.interceptors.request.use((config) => {
  const token = localStorage.getItem('aiguard-token')
  if (token) {
    config.headers.Authorization = `Bearer ${token}`
  }
  return config
})

function handleBusinessError(result: ApiResult<unknown>) {
  if (result.code === 0) return
  if (result.code === 401) {
    localStorage.removeItem('aiguard-token')
    localStorage.removeItem('aiguard-auth')
    if (window.location.pathname !== '/login') {
      ElMessage.error(result.message || '登录已过期')
      window.location.href = '/login'
    }
    return
  }
  ElMessage.error(result.message || '请求失败')
}

async function send<T>(config: AxiosRequestConfig): Promise<T> {
  if (useMock) {
    const result = await mockRequest<T>({
      method: (config.method?.toUpperCase() || 'GET') as 'GET' | 'POST' | 'PATCH' | 'PUT' | 'DELETE',
      url: config.url || '',
      params: config.params as Record<string, unknown>,
      data: config.data,
    })

    if (result.code !== 0) {
      handleBusinessError(result)
      return Promise.reject(result)
    }

    return result.data as T
  }

  const response = await http.request<ApiResult<T>>(config)
  const result = response.data
  if (result.code !== 0) {
    handleBusinessError(result)
    return Promise.reject(result)
  }
  return result.data
}

const request = {
  get<T>(url: string, params?: Record<string, unknown>) {
    return send<T>({ method: 'GET', url, params })
  },
  post<T>(url: string, data?: unknown) {
    return send<T>({ method: 'POST', url, data })
  },
  patch<T>(url: string, data?: unknown) {
    return send<T>({ method: 'PATCH', url, data })
  },
}

export default request
