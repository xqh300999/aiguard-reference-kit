import type {
  AlertListQuery,
  AlertStatus,
  ApiResult,
  CreateDispatchPayload,
  DispatchRecord,
  LoginRequest,
  PageResult,
  UpdateDispatchPayload,
} from '@/types/api'
import { alertStatusText, dispatchResultText } from '@/utils/labels'

import { mockAlerts, mockDispatches, mockElderlyMap, mockUsers, toAlertRecord } from './data'

interface MockRequestConfig {
  method: 'GET' | 'POST' | 'PATCH' | 'PUT' | 'DELETE'
  url: string
  params?: Record<string, unknown>
  data?: unknown
}

function now() {
  return new Date().toISOString()
}

function ok<T>(data: T, message = 'success'): ApiResult<T> {
  return {
    code: 0,
    message,
    data,
    ts: now(),
  }
}

function fail(code: number, message: string): ApiResult<null> {
  return {
    code,
    message,
    data: null,
    ts: now(),
  }
}

function normalizeUrl(url: string) {
  const path = url.split('?')[0] ?? url
  return path.replace(/^\/api\/v1/, '').replace(/\/$/, '') || '/'
}

function getToken(config: MockRequestConfig) {
  if (config.url === '/auth/login') return null
  return localStorage.getItem('aiguard-token')
}

function paginate<T>(records: T[], page = 1, size = 20): PageResult<T> {
  const start = (page - 1) * size
  return {
    records: records.slice(start, start + size),
    total: records.length,
    page,
    size,
  }
}

function listAlerts(query: AlertListQuery) {
  const page = Number(query.page ?? 1)
  const size = Number(query.size ?? 20)

  let records = [...mockAlerts]
  if (query.communityId) {
    records = records.filter((alert) => alert.communityId === Number(query.communityId))
  }
  if (query.status) {
    records = records.filter((alert) => alert.status === query.status)
  }
  if (query.type) {
    records = records.filter((alert) => alert.type === query.type)
  }

  records.sort((a, b) => new Date(b.happenedAt).getTime() - new Date(a.happenedAt).getTime())
  return ok(paginate(records.map(toAlertRecord), page, size))
}

function login(data: unknown) {
  const payload = data as LoginRequest
  const user = mockUsers.find(
    (item) => item.username === payload.username && item.password === payload.password,
  )

  if (!user) return fail(401, '用户名或密码错误')

  return ok({
    token: user.token,
    userId: user.userId,
    role: user.role,
    realName: user.realName,
    communityId: user.communityId,
  })
}

function createDispatch(data: unknown) {
  const payload = data as CreateDispatchPayload
  const alert = mockAlerts.find((item) => item.id === Number(payload.alertId))
  const user = mockUsers.find((item) => item.userId === Number(payload.handlerId))

  if (!alert) return fail(404, '告警不存在')
  if (!user) return fail(404, '处理人不存在')
  if (alert.status !== 'PENDING') return fail(400, '该告警已被接单')

  const dispatch: DispatchRecord = {
    id: Math.max(...mockDispatches.map((item) => item.id)) + 1,
    alertId: alert.id,
    handlerId: user.userId,
    handlerName: user.realName,
    status: 'PROCESSING',
    description: null,
    result: null,
    createdAt: now(),
    completedAt: null,
  }

  mockDispatches.unshift(dispatch)
  alert.status = 'PROCESSING'
  alert.statusName = alertStatusText.PROCESSING
  alert.handlerId = user.userId
  alert.handlerName = user.realName
  alert.dispatch = dispatch

  return ok(dispatch)
}

function updateDispatch(id: number, data: unknown) {
  const payload = data as UpdateDispatchPayload
  const dispatch = mockDispatches.find((item) => item.id === id)
  if (!dispatch) return fail(404, '派单不存在')

  const alert = mockAlerts.find((item) => item.id === dispatch.alertId)
  if (!alert) return fail(404, '告警不存在')

  dispatch.status = 'COMPLETED'
  dispatch.description = payload.description
  dispatch.result = payload.result
  dispatch.completedAt = now()

  alert.details = payload.description
  alert.cause = dispatchResultText[payload.result]

  if (payload.result === 'RESOLVED' || payload.result === 'NEED_HOSPITAL') {
    alert.status = payload.result as AlertStatus
    alert.statusName = alertStatusText[payload.result as AlertStatus]
    alert.resolvedAt = dispatch.completedAt
  } else {
    alert.status = 'PROCESSING'
    alert.statusName = alertStatusText.PROCESSING
  }

  alert.dispatch = dispatch
  return ok(dispatch)
}

export async function mockRequest<T>(config: MockRequestConfig): Promise<ApiResult<T> | ApiResult<null>> {
  await new Promise((resolve) => window.setTimeout(resolve, 240))

  const path = normalizeUrl(config.url)
  const token = getToken(config)
  if (path !== '/auth/login' && !token) return fail(401, 'Token 已过期，请重新登录')

  if (config.method === 'POST' && path === '/auth/login') {
    return login(config.data) as ApiResult<T>
  }

  if (config.method === 'GET' && path === '/alerts') {
    return listAlerts((config.params ?? {}) as AlertListQuery) as ApiResult<T>
  }

  const alertDetailMatch = path.match(/^\/alerts\/(\d+)$/)
  if (config.method === 'GET' && alertDetailMatch) {
    const alert = mockAlerts.find((item) => item.id === Number(alertDetailMatch[1]))
    return alert ? (ok(alert) as ApiResult<T>) : fail(404, '告警不存在')
  }

  const elderlyDetailMatch = path.match(/^\/elderly\/(\d+)$/)
  if (config.method === 'GET' && elderlyDetailMatch) {
    const elderly = mockElderlyMap[Number(elderlyDetailMatch[1])]
    return elderly ? (ok(elderly) as ApiResult<T>) : fail(404, '老人不存在')
  }

  if (config.method === 'POST' && path === '/dispatches') {
    return createDispatch(config.data) as ApiResult<T>
  }

  const dispatchByAlertMatch = path.match(/^\/dispatches\/alert\/(\d+)$/)
  if (config.method === 'GET' && dispatchByAlertMatch) {
    const dispatch = mockDispatches.find(
      (item) => item.alertId === Number(dispatchByAlertMatch[1]),
    )
    return dispatch ? (ok(dispatch) as ApiResult<T>) : fail(404, '派单不存在')
  }

  const dispatchMatch = path.match(/^\/dispatches\/(\d+)$/)
  if (config.method === 'PATCH' && dispatchMatch) {
    return updateDispatch(Number(dispatchMatch[1]), config.data) as ApiResult<T>
  }

  return fail(404, 'Mock 接口未定义')
}
