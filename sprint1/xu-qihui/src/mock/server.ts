import type { ApiResult, LoginRequest, PageResult, User } from '@/types/api'
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
  persistData,
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
  const handlers: Record<string, (query?: Record<string, string>, body?: any) => ApiResult<any>> = {
    'POST /api/v1/auth/login': (_query?: Record<string, string>, body?: LoginRequest) => {
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

    'POST /api/v1/auth/register': (_query?: Record<string, string>, body?: { username: string; password: string; realName: string; phone: string }) => {
      if (!body || !body.username || !body.password || !body.realName) {
        return fail('用户名、密码和姓名不能为空')
      }

      if (body.password.length < 6) {
        return fail('密码至少6位')
      }

      const exists = mockUsers.find((u) => u.username === body.username)
      if (exists) {
        return fail('用户名已存在')
      }

      const newUserId = Date.now()
      const newUser: any = {
        username: body.username,
        password: body.password,
        token: `mock-${body.username}-token`,
        userId: newUserId,
        role: 'WORKER',
        realName: body.realName,
        phone: body.phone,
        communityId: undefined,
      }

      mockUsers.push(newUser)

      const systemUser: User = {
        id: newUserId,
        username: body.username,
        realName: body.realName,
        phone: body.phone || '',
        role: 'WORKER',
        communityId: undefined,
        communityName: undefined,
        status: 'ACTIVE',
        createdAt: new Date().toISOString(),
      }

      mockSystemUsers.push(systemUser)
      persistData()
      return success(null)
    },

    'GET /api/v1/auth/profile': () => {
      const user = mockUsers[0]
      const { password, ...profile } = user
      return success(profile)
    },

    'GET /api/v1/stats/overview': () => {
      return success(mockStatsOverview)
    },

    'GET /api/v1/alerts': (query?: Record<string, string>) => {
      let filtered = [...mockAlerts]
      if (query?.status) {
        filtered = filtered.filter((a) => a.status === query.status)
      }
      if (query?.type) {
        filtered = filtered.filter((a) => a.type === query.type)
      }
      if (query?.communityId) {
        filtered = filtered.filter((a) => a.communityId === Number(query.communityId))
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

    'GET /api/v1/alerts/:id': (query?: Record<string, string>) => {
      const id = query ? Number(query.id) : NaN
      const alert = mockAlerts.find((a) => a.id === id)
      if (!alert) {
        return fail('告警不存在', 404)
      }
      return success(alert)
    },

    'POST /api/v1/dispatches': (_query?: Record<string, string>, body?: { alertId: number; handlerId: number }) => {
      if (!body || !body.alertId || !body.handlerId) {
        return fail('告警ID和处理人ID不能为空')
      }

      const alert = mockAlerts.find((a) => a.id === body.alertId)
      if (!alert) {
        return fail('告警不存在', 404)
      }

      if (alert.status !== 'PENDING') {
        return fail('该告警已被处理')
      }

      const handlerName = mockSystemUsers.find((u) => u.id === body.handlerId)?.realName || '未知'

      alert.status = 'PROCESSING'
      alert.statusName = '处理中'
      alert.handlerId = body.handlerId
      alert.handlerName = handlerName

      const dispatch: typeof mockDispatches[0] = {
        id: Date.now(),
        alertId: alert.id,
        handlerId: body.handlerId,
        handlerName,
        status: 'PROCESSING',
        description: null,
        result: null,
        createdAt: new Date().toISOString(),
        completedAt: null,
      }

      mockDispatches.push(dispatch)
      alert.dispatch = dispatch
      persistData()

      return success(dispatch)
    },

    'GET /api/v1/dispatches/alert/:alertId': (query?: Record<string, string>) => {
      const alertId = query ? Number(query.alertId) : NaN
      const dispatch = mockDispatches.find((d) => d.alertId === alertId)
      if (!dispatch) {
        return fail('派单记录不存在', 404)
      }
      return success(dispatch)
    },

    'PATCH /api/v1/dispatches/:id': (query?: Record<string, string>, body?: { result: string; description: string }) => {
      const id = query ? Number(query.id) : NaN
      const dispatch = mockDispatches.find((d) => d.id === id)
      if (!dispatch) {
        return fail('派单记录不存在', 404)
      }

      if (!body || !body.result || !body.description) {
        return fail('处理结果和描述不能为空')
      }

      const alert = mockAlerts.find((a) => a.id === dispatch.alertId)
      if (alert) {
        alert.status = body.result === 'NEED_HOSPITAL' ? 'NEED_HOSPITAL' : 'RESOLVED'
        alert.statusName = alert.status === 'NEED_HOSPITAL' ? '需送医' : '已解决'
        alert.resolvedAt = new Date().toISOString()
      }

      dispatch.status = 'COMPLETED'
      dispatch.description = body.description
      dispatch.result = body.result as any
      dispatch.completedAt = new Date().toISOString()
      persistData()

      return success(dispatch)
    },

    'POST /api/v1/alerts/:id/take': (query?: Record<string, string>) => {
      const id = query ? Number(query.id) : NaN
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
      persistData()

      return success(alert)
    },

    'POST /api/v1/alerts/:id/complete': (query?: Record<string, string>, body?: { description: string; result: string }) => {
      const id = query ? Number(query.id) : NaN
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
      persistData()

      return success(alert)
    },

    'POST /api/v1/alerts/:id/dispatch': (query?: Record<string, string>, body?: { handlerId: number }) => {
      const id = query ? Number(query.id) : NaN
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
      persistData()

      return success(dispatch)
    },

    'GET /api/v1/communities': () => {
      return success(mockCommunities)
    },

    'GET /api/v1/elderlies': (query?: Record<string, string>) => {
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

    'GET /api/v1/devices': (query?: Record<string, string>) => {
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

    'GET /api/v1/users': (query?: Record<string, string>) => {
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

    'POST /api/v1/users': (_query?: Record<string, string>, body?: { username: string; password: string; realName: string; phone: string; role: any; communityId?: number }) => {
      if (!body || !body.username || !body.password || !body.realName) {
        return fail('用户名、密码和姓名不能为空')
      }

      const exists = mockSystemUsers.find((u) => u.username === body.username)
      if (exists) {
        return fail('用户名已存在')
      }

      const newUser = {
        id: Date.now(),
        username: body.username,
        realName: body.realName,
        phone: body.phone || '',
        role: (body.role || 'WORKER') as any,
        communityId: body.role === 'ADMIN' || body.role === 'SUPER_ADMIN' ? undefined : body.communityId,
        communityName: body.communityId ? mockCommunities.find((c) => c.id === body.communityId)?.name : undefined,
        status: 'ACTIVE' as const,
        createdAt: new Date().toISOString(),
      }

      mockSystemUsers.push(newUser)
      persistData()
      return success(newUser)
    },

    'PUT /api/v1/users/:id': (query?: Record<string, string>, body?: { realName: string; phone: string; role: any; communityId?: number; password?: string }) => {
      const id = query ? Number(query.id) : NaN
      const user = mockSystemUsers.find((u) => u.id === id)
      if (!user) {
        return fail('用户不存在', 404)
      }

      if (body?.realName) user.realName = body.realName
      if (body?.phone !== undefined) user.phone = body.phone
      if (body?.role) {
        user.role = body.role as any
        user.communityId = body.role === 'ADMIN' || body.role === 'SUPER_ADMIN' ? undefined : body.communityId
        user.communityName = user.communityId ? mockCommunities.find((c) => c.id === user.communityId)?.name : undefined
      }
      if (body?.communityId !== undefined && user.role !== 'ADMIN' && user.role !== 'SUPER_ADMIN') {
        user.communityId = body.communityId
        user.communityName = mockCommunities.find((c) => c.id === body.communityId)?.name
      }
      persistData()

      return success(user)
    },

    'DELETE /api/v1/users/:id': (query?: Record<string, string>) => {
      const id = query ? Number(query.id) : NaN
      const index = mockSystemUsers.findIndex((u) => u.id === id)
      if (index === -1) {
        return fail('用户不存在', 404)
      }

      if (mockSystemUsers[index].role === 'SUPER_ADMIN') {
        return fail('超级管理员不能删除')
      }

      mockSystemUsers.splice(index, 1)
      persistData()
      return success(null)
    },

    'POST /api/v1/communities': (_query?: Record<string, string>, body?: { name: string; address: string; area: string }) => {
      if (!body || !body.name || !body.address) {
        return fail('社区名称和地址不能为空')
      }

      const newCommunity = {
        id: Date.now(),
        name: body.name,
        address: body.address,
        area: body.area || '',
        elderlyCount: 0,
        deviceCount: 0,
        createdAt: new Date().toISOString(),
      }

      mockCommunities.push(newCommunity)
      persistData()
      return success(newCommunity)
    },

    'PUT /api/v1/communities/:id': (query?: Record<string, string>, body?: { name: string; address: string; area: string }) => {
      const id = query ? Number(query.id) : NaN
      const community = mockCommunities.find((c) => c.id === id)
      if (!community) {
        return fail('社区不存在', 404)
      }

      if (body?.name) community.name = body.name
      if (body?.address) community.address = body.address
      if (body?.area !== undefined) community.area = body.area
      persistData()

      return success(community)
    },

    'DELETE /api/v1/communities/:id': (query?: Record<string, string>) => {
      const id = query ? Number(query.id) : NaN
      const index = mockCommunities.findIndex((c) => c.id === id)
      if (index === -1) {
        return fail('社区不存在', 404)
      }

      mockCommunities.splice(index, 1)
      persistData()
      return success(null)
    },

    'POST /api/v1/elderlies': (_query?: Record<string, string>, body?: { name: string; age: number; gender: any; phone: string; communityId: number; emergencyContact: string; healthNotes: string }) => {
      if (!body || !body.name || !body.communityId) {
        return fail('姓名和社区不能为空')
      }

      const newElderly = {
        id: Date.now(),
        name: body.name,
        age: body.age || 0,
        gender: (body.gender || 'MALE') as any,
        phone: body.phone || '',
        communityId: body.communityId,
        communityName: mockCommunities.find((c) => c.id === body.communityId)?.name,
        emergencyContact: body.emergencyContact || '',
        healthNotes: body.healthNotes || '',
        status: 'ACTIVE' as const,
        createdAt: new Date().toISOString(),
      }

      mockElderlies.push(newElderly)
      persistData()
      return success(newElderly)
    },

    'PUT /api/v1/elderlies/:id': (query?: Record<string, string>, body?: { name: string; age: number; gender: any; phone: string; communityId: number; emergencyContact: string; healthNotes: string }) => {
      const id = query ? Number(query.id) : NaN
      const elderly = mockElderlies.find((e) => e.id === id)
      if (!elderly) {
        return fail('老人不存在', 404)
      }

      if (body?.name) elderly.name = body.name
      if (body?.age !== undefined) elderly.age = body.age
      if (body?.gender) elderly.gender = body.gender as any
      if (body?.phone !== undefined) elderly.phone = body.phone
      if (body?.communityId !== undefined) {
        elderly.communityId = body.communityId
        elderly.communityName = mockCommunities.find((c) => c.id === body.communityId)?.name
      }
      if (body?.emergencyContact !== undefined) elderly.emergencyContact = body.emergencyContact
      if (body?.healthNotes !== undefined) elderly.healthNotes = body.healthNotes
      persistData()

      return success(elderly)
    },

    'DELETE /api/v1/elderlies/:id': (query?: Record<string, string>) => {
      const id = query ? Number(query.id) : NaN
      const index = mockElderlies.findIndex((e) => e.id === id)
      if (index === -1) {
        return fail('老人不存在', 404)
      }

      mockElderlies.splice(index, 1)
      persistData()
      return success(null)
    },

    'POST /api/v1/devices': (_query?: Record<string, string>, body?: { name: string; type: any; mac: string; communityId: number; elderlyId?: number }) => {
      if (!body || !body.name || !body.type || !body.mac || !body.communityId) {
        return fail('设备名称、类型、MAC地址和社区不能为空')
      }

      const newDevice = {
        id: Date.now(),
        name: body.name,
        type: body.type || 'WATCH',
        mac: body.mac,
        communityId: body.communityId,
        communityName: mockCommunities.find((c) => c.id === body.communityId)?.name || '',
        elderlyId: body.elderlyId,
        elderlyName: body.elderlyId ? mockElderlies.find((e) => e.id === body.elderlyId)?.name : undefined,
        status: 'ONLINE' as const,
        battery: 100,
        lastHeartbeat: new Date().toISOString(),
        createdAt: new Date().toISOString(),
      }

      mockDevices.push(newDevice)
      persistData()
      return success(newDevice)
    },

    'PUT /api/v1/devices/:id': (query?: Record<string, string>, body?: { name: string; type: any; communityId: number; elderlyId?: number }) => {
      const id = query ? Number(query.id) : NaN
      const device = mockDevices.find((d) => d.id === id)
      if (!device) {
        return fail('设备不存在', 404)
      }

      if (body?.name) device.name = body.name
      if (body?.type) device.type = body.type
      if (body?.communityId !== undefined) {
        device.communityId = body.communityId
        device.communityName = mockCommunities.find((c) => c.id === body.communityId)?.name || ''
      }
      if (body?.elderlyId !== undefined) {
        device.elderlyId = body.elderlyId
        device.elderlyName = body.elderlyId ? mockElderlies.find((e) => e.id === body.elderlyId)?.name : undefined
      }
      persistData()

      return success(device)
    },

    'DELETE /api/v1/devices/:id': (query?: Record<string, string>) => {
      const id = query ? Number(query.id) : NaN
      const index = mockDevices.findIndex((d) => d.id === id)
      if (index === -1) {
        return fail('设备不存在', 404)
      }

      mockDevices.splice(index, 1)
      persistData()
      return success(null)
    },
  }

  function parseQueryString(url: string): Record<string, string> {
    const query: Record<string, string> = {}
    const idx = url.indexOf('?')
    if (idx !== -1) {
      const queryString = url.slice(idx + 1)
      queryString.split('&').forEach((pair) => {
        const [key, value] = pair.split('=')
        if (key && value !== undefined) {
          query[key] = decodeURIComponent(value)
        }
      })
    }
    return query
  }

  return {
    request: async function <T>(method: string, url: string, data?: any): Promise<ApiResult<T>> {
      const path = url.split('?')[0]
      const query = parseQueryString(url)
      const key = `${method.toUpperCase()} ${path}`
      const handler = handlers[key]

      if (!handler) {
        const paramKey = Object.keys(handlers).find((k) => {
          const parts = k.split(' ')
          const pathParts = parts[1].split('/')
          const urlParts = path.split('/')

          if (pathParts.length !== urlParts.length) return false

          for (let i = 0; i < pathParts.length; i++) {
            if (pathParts[i].startsWith(':')) {
              continue
            } else if (pathParts[i] !== urlParts[i]) {
              return false
            }
          }

          return true
        })

        if (paramKey) {
          const params: Record<string, string> = {}
          const urlParts = path.split('/')
          const pathParts = paramKey.split(' ')[1].split('/')

          for (let i = 0; i < pathParts.length; i++) {
            if (pathParts[i].startsWith(':')) {
              params[pathParts[i].slice(1)] = urlParts[i]
            }
          }

          await new Promise((resolve) => setTimeout(resolve, 300))
          return handlers[paramKey]({ ...query, ...params }, data) as ApiResult<T>
        }

        return fail(`Not found: ${key}`, 404) as ApiResult<T>
      }

      await new Promise((resolve) => setTimeout(resolve, 300))
      return handler({ ...query }, data)
    },
  }
}