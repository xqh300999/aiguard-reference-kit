import type { ApiResult, LoginRequest, PageResult } from '@/types/api'
import {
  mockAlerts,
  mockCommunities,
  mockDevices,
  mockDispatches,
  mockElderlies,
  mockStatsOverview,
  mockSystemUsers,
  mockUsers,
  toAlertRecord,
} from './data'

function success<T>(data: T): ApiResult<T> {
  return {
    code: 0,
    message: 'success',
    data,
    ts: new Date().toISOString(),
  }
}

function fail(message: string, code = 400): ApiResult<null> {
  return {
    code,
    message,
    data: null,
    ts: new Date().toISOString(),
  }
}

export interface MockServer {
  request: <T>(method: string, url: string, data?: any) => Promise<ApiResult<T>>
}

export function createMockServer(): MockServer {
  const handlers: Record<string, (body?: any, params?: Record<string, string>) => ApiResult<any>> = {
    'POST /api/v1/auth/login': (body?: LoginRequest) => {
      if (!body || !body.username || !body.password) {
        return fail('用户名或密码不能为空')
      }

      const user = mockUsers.find((u) => u.username === body.username && u.password === body.password)
      if (!user) {
        return fail('用户名或密码错误', 401)
      }

      const { password, ...session } = user
      return success(session)
    },

    'GET /api/v1/auth/profile': () => {
      return success(mockUsers[0])
    },

    'GET /api/v1/stats/overview': () => {
      return success(mockStatsOverview)
    },

    'GET /api/v1/alerts': (query?: { status?: string; page?: number; size?: number }) => {
      let filtered = [...mockAlerts]
      if (query?.status) {
        filtered = filtered.filter((a) => a.status === query.status)
      }

      const page = query?.page ? Number(query.page) : 1
      const size = query?.size ? Number(query.size) : 10
      const start = (page - 1) * size
      const end = start + size

      const records = filtered.slice(start, end).map(toAlertRecord)
      return success<PageResult<typeof records[0]>>({
        records,
        total: filtered.length,
        page,
        size,
      })
    },

    'GET /api/v1/alerts/:id': (params?: { id?: string }) => {
      const id = params ? Number(params.id) : NaN
      const alert = mockAlerts.find((a) => a.id === id)
      if (!alert) {
        return fail('告警不存在', 404)
      }
      return success(alert)
    },

    'POST /api/v1/alerts/:id/take': (params?: { id?: string }) => {
      const id = params ? Number(params.id) : NaN
      const alert = mockAlerts.find((a) => a.id === id)
      if (!alert) {
        return fail('告警不存在', 404)
      }

      if (alert.status !== 'PENDING') {
        return fail('该告警已被处理')
      }

      alert.status = 'PROCESSING'
      alert.statusName = '处理中'
      alert.handlerId = 2
      alert.handlerName = '李凯辉'

      const dispatch: typeof mockDispatches[0] = {
        id: Date.now(),
        alertId: alert.id,
        handlerId: 2,
        handlerName: '李凯辉',
        status: 'PROCESSING',
        description: null,
        result: null,
        createdAt: new Date().toISOString(),
        completedAt: null,
      }

      mockDispatches.push(dispatch)
      alert.dispatch = dispatch

      return success(alert)
    },

    'POST /api/v1/alerts/:id/complete': (body?: { description: string; result: string }, params?: { id?: string }) => {
      const id = params ? Number(params.id) : NaN
      const alert = mockAlerts.find((a) => a.id === id)
      if (!alert) {
        return fail('告警不存在', 404)
      }

      if (alert.status !== 'PROCESSING') {
        return fail('告警状态错误')
      }

      if (!body || !body.description || !body.result) {
        return fail('处理内容和结果不能为空')
      }

      alert.status = body.result === 'NEED_HOSPITAL' ? 'NEED_HOSPITAL' : 'RESOLVED'
      alert.statusName = alert.status === 'NEED_HOSPITAL' ? '需送医' : '已解决'
      alert.resolvedAt = new Date().toISOString()

      if (alert.dispatch) {
        alert.dispatch.status = 'COMPLETED'
        alert.dispatch.description = body.description
        alert.dispatch.result = body.result as any
        alert.dispatch.completedAt = new Date().toISOString()
      }

      return success(alert)
    },

    'POST /api/v1/alerts/:id/dispatch': (body?: { handlerId: number }, params?: { id?: string }) => {
      const id = params ? Number(params.id) : NaN
      const alert = mockAlerts.find((a) => a.id === id)
      if (!alert) {
        return fail('告警不存在', 404)
      }

      if (!body || !body.handlerId) {
        return fail('处理人ID不能为空')
      }

      alert.status = 'PROCESSING'
      alert.statusName = '处理中'
      alert.handlerId = body.handlerId
      alert.handlerName = mockSystemUsers.find((u) => u.id === body.handlerId)?.realName || '未知'

      const dispatch: typeof mockDispatches[0] = {
        id: Date.now(),
        alertId: alert.id,
        handlerId: body.handlerId,
        handlerName: alert.handlerName,
        status: 'PROCESSING',
        description: null,
        result: null,
        createdAt: new Date().toISOString(),
        completedAt: null,
      }

      mockDispatches.push(dispatch)
      alert.dispatch = dispatch

      return success(dispatch)
    },

    'GET /api/v1/communities': () => {
      return success(mockCommunities)
    },

    'GET /api/v1/elderlies': (query?: { communityId?: number; page?: number; size?: number }) => {
      let filtered = [...mockElderlies]
      if (query?.communityId) {
        filtered = filtered.filter((e) => e.communityId === Number(query.communityId))
      }

      const page = query?.page ? Number(query.page) : 1
      const size = query?.size ? Number(query.size) : 10
      const start = (page - 1) * size
      const end = start + size

      return success<PageResult<typeof mockElderlies[0]>>({
        records: filtered.slice(start, end),
        total: filtered.length,
        page,
        size,
      })
    },

    'GET /api/v1/devices': (query?: { communityId?: number; status?: string; page?: number; size?: number }) => {
      let filtered = [...mockDevices]
      if (query?.communityId) {
        filtered = filtered.filter((d) => d.communityId === Number(query.communityId))
      }
      if (query?.status) {
        filtered = filtered.filter((d) => d.status === query.status)
      }

      const page = query?.page ? Number(query.page) : 1
      const size = query?.size ? Number(query.size) : 10
      const start = (page - 1) * size
      const end = start + size

      return success<PageResult<typeof mockDevices[0]>>({
        records: filtered.slice(start, end),
        total: filtered.length,
        page,
        size,
      })
    },

    'GET /api/v1/users': (query?: { role?: string; page?: number; size?: number }) => {
      let filtered = [...mockSystemUsers]
      if (query?.role) {
        filtered = filtered.filter((u) => u.role === query.role)
      }

      const page = query?.page ? Number(query.page) : 1
      const size = query?.size ? Number(query.size) : 10
      const start = (page - 1) * size
      const end = start + size

      return success<PageResult<typeof mockSystemUsers[0]>>({
        records: filtered.slice(start, end),
        total: filtered.length,
        page,
        size,
      })
    },
  }

  return {
    request: async function <T>(method: string, url: string, data?: any): Promise<ApiResult<T>> {
      const key = `${method.toUpperCase()} ${url.split('?')[0]}`
      const handler = handlers[key]

      if (!handler) {
        const paramKey = Object.keys(handlers).find((k) => {
          const parts = k.split(' ')
          const pathParts = parts[1].split('/')
          const urlParts = url.split('?')[0].split('/')

          if (pathParts.length !== urlParts.length) return false

          const params: Record<string, string> = {}
          for (let i = 0; i < pathParts.length; i++) {
            if (pathParts[i].startsWith(':')) {
              params[pathParts[i].slice(1)] = urlParts[i]
            } else if (pathParts[i] !== urlParts[i]) {
              return false
            }
          }

          return true
        })

        if (paramKey) {
          const params: Record<string, string> = {}
          const urlParts = url.split('?')[0].split('/')
          const pathParts = paramKey.split(' ')[1].split('/')

          for (let i = 0; i < pathParts.length; i++) {
            if (pathParts[i].startsWith(':')) {
              params[pathParts[i].slice(1)] = urlParts[i]
            }
          }

          await new Promise((resolve) => setTimeout(resolve, 300))
          return handlers[paramKey](data, params) as ApiResult<T>
        }

        return fail(`Not found: ${key}`, 404) as ApiResult<T>
      }

      await new Promise((resolve) => setTimeout(resolve, 300))
      return handler(data)
    },
  }
}