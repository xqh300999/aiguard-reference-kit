import type {
  AlertStatus,
  ApiResult,
  AlertStatsTrendPoint,
  CareStats,
  Community,
  CreateDispatchPayload,
  Device,
  DispatchRecord,
  Elderly,
  LoginRequest,
  PageResult,
  StatsPeriod,
  StatsExportPayload,
  UpdateDispatchPayload,
  User,
} from '@/types/api'
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

type Query = Record<string, string>
type Params = Record<string, string>

interface HandlerContext {
  body?: any
  params: Params
  query: Query
}

interface HandlerEntry {
  method: string
  pattern: string
  handler: (context: HandlerContext) => ApiResult<any>
}

export interface MockServer {
  request: <T>(method: string, url: string, data?: any) => Promise<ApiResult<T>>
}

const statusText: Record<AlertStatus, string> = {
  PENDING: '待处理',
  PROCESSING: '处理中',
  RESOLVED: '已解决',
  NEED_HOSPITAL: '需送医',
}

const dispatchResultText = {
  RESOLVED: '已解决',
  NEED_HOSPITAL: '需送医',
  NEED_FOLLOW_UP: '需跟进',
}

function now() {
  return new Date().toISOString()
}

function success<T>(data: T): ApiResult<T> {
  return {
    code: 0,
    message: 'success',
    data,
    ts: now(),
  }
}

function fail(message: string, code = 400): ApiResult<null> {
  return {
    code,
    message,
    data: null,
    ts: now(),
  }
}

function nextId(items: Array<{ id: number }>) {
  return items.length ? Math.max(...items.map((item) => item.id)) + 1 : 1
}

function parseUrl(url: string) {
  const [path, queryString = ''] = url.split('?')
  const query: Query = {}
  new URLSearchParams(queryString).forEach((value, key) => {
    query[key] = value
  })
  return { path: path.replace(/\/$/, '') || '/', query }
}

function matchPath(pattern: string, path: string): Params | null {
  const patternParts = pattern.split('/').filter(Boolean)
  const pathParts = path.split('/').filter(Boolean)
  if (patternParts.length !== pathParts.length) return null

  const params: Params = {}
  for (let index = 0; index < patternParts.length; index += 1) {
    const expected = patternParts[index]
    const actual = pathParts[index]
    if (expected.startsWith(':')) {
      params[expected.slice(1)] = actual
    } else if (expected !== actual) {
      return null
    }
  }
  return params
}

function paginate<T>(records: T[], query: Query): PageResult<T> {
  const page = Number(query.page || 1)
  const size = Number(query.size || 10)
  const start = (page - 1) * size
  return {
    records: records.slice(start, start + size),
    total: records.length,
    page,
    size,
  }
}

function withCommunityName<T extends { communityId?: number; communityName?: string }>(item: T): T {
  if (!item.communityId) return item
  return {
    ...item,
    communityName: mockCommunities.find((community) => community.id === item.communityId)?.name,
  }
}

function refreshCommunityCounts() {
  mockCommunities.forEach((community) => {
    community.elderlyCount = mockElderlies.filter((elderly) => elderly.communityId === community.id).length
    community.deviceCount = mockDevices.filter((device) => device.communityId === community.id).length
  })
}

function getPeriodLabels(period: StatsPeriod) {
  if (period === 'daily') return ['周一', '周二', '周三', '周四', '周五', '周六', '周日']
  if (period === 'monthly') return ['1月', '2月', '3月', '4月', '5月', '6月']
  return ['第1周', '第2周', '第3周', '第4周']
}

function getAlertStatsTrend(communityId: number, period: StatsPeriod): AlertStatsTrendPoint[] {
  const baseAlerts = mockAlerts.filter((alert) => alert.communityId === communityId)
  return getPeriodLabels(period).map((label, index) => {
    const sos = baseAlerts.filter((alert) => alert.type === 'SOS').length + ((index + 1) % 3)
    const fall = baseAlerts.filter((alert) => alert.type === 'FALL').length + (index % 2)
    const device = baseAlerts.filter((alert) => alert.type === 'DEVICE_OFFLINE' || alert.type === 'LOW_BATTERY').length + (index % 3)
    return {
      label,
      sos,
      fall,
      device,
      total: sos + fall + device,
    }
  })
}

function getCareStats(period: StatsPeriod): CareStats {
  const records = getPeriodLabels(period).map((label, index) => {
    const phone = 8 + index * 2
    const visit = 3 + index
    const medicine = 5 + (index % 3)
    const other = 1 + (index % 2)
    return {
      label,
      phone,
      visit,
      medicine,
      other,
      total: phone + visit + medicine + other,
    }
  })
  const completedLogs = records.reduce((sum, item) => sum + item.total, 0)
  const totalPlans = Math.max(completedLogs + 12, 1)
  return {
    totalPlans,
    completedLogs,
    completionRate: Math.round((completedLogs / totalPlans) * 100),
    records,
  }
}

function buildStatsExport(communityId?: number): StatsExportPayload {
  const communityName = communityId
    ? mockCommunities.find((community) => community.id === communityId)?.name || `社区${communityId}`
    : '全部社区'
  const alertRows = getAlertStatsTrend(communityId || 1, 'weekly')
    .map((item) => `<tr><td>${item.label}</td><td>${item.total}</td><td>${item.sos}</td><td>${item.fall}</td><td>${item.device}</td></tr>`)
    .join('')
  const careRows = getCareStats('weekly').records
    .map((item) => `<tr><td>${item.label}</td><td>${item.total}</td><td>${item.phone}</td><td>${item.visit}</td><td>${item.medicine}</td><td>${item.other}</td></tr>`)
    .join('')
  const elderlyRows = mockElderlies
    .filter((elderly) => !communityId || elderly.communityId === communityId)
    .map((elderly) => `<tr><td>${elderly.id}</td><td>${elderly.name}</td><td>${elderly.age}</td><td>${elderly.communityName || communityName}</td><td>${elderly.status}</td></tr>`)
    .join('')

  return {
    filename: `AiGuard-${communityName}-统计报表.xls`,
    mimeType: 'application/vnd.ms-excel;charset=utf-8',
    content: `
      <html>
        <head><meta charset="utf-8" /></head>
        <body>
          <h2>老人列表</h2>
          <table border="1"><tr><th>ID</th><th>姓名</th><th>年龄</th><th>社区</th><th>状态</th></tr>${elderlyRows}</table>
          <h2>告警统计</h2>
          <table border="1"><tr><th>周期</th><th>总数</th><th>SOS</th><th>跌倒</th><th>设备</th></tr>${alertRows}</table>
          <h2>关怀统计</h2>
          <table border="1"><tr><th>周期</th><th>总数</th><th>电话</th><th>走访</th><th>用药提醒</th><th>其他</th></tr>${careRows}</table>
        </body>
      </html>
    `,
  }
}

function listAlerts(query: Query) {
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
  return success(paginate(records.map(toAlertRecord), query))
}

function getHandlerName(handlerId: number) {
  return (
    mockSystemUsers.find((user) => user.id === handlerId)?.realName ||
    mockUsers.find((user) => user.userId === handlerId)?.realName ||
    '社区工作人员'
  )
}

function createDispatch(body?: CreateDispatchPayload) {
  if (!body?.alertId) return fail('告警ID不能为空')
  const alert = mockAlerts.find((item) => item.id === Number(body.alertId))
  if (!alert) return fail('告警不存在', 404)
  if (alert.status !== 'PENDING') return fail('该告警已被接单')

  const handlerId = Number(body.handlerId || 2)
  const dispatch: DispatchRecord = {
    id: nextId(mockDispatches),
    alertId: alert.id,
    handlerId,
    handlerName: getHandlerName(handlerId),
    status: 'PROCESSING',
    description: null,
    result: null,
    createdAt: now(),
    completedAt: null,
  }

  mockDispatches.unshift(dispatch)
  alert.status = 'PROCESSING'
  alert.statusName = statusText.PROCESSING
  alert.handlerId = handlerId
  alert.handlerName = dispatch.handlerName
  alert.dispatch = dispatch

  return success(dispatch)
}

function updateDispatch(id: number, body?: UpdateDispatchPayload) {
  const dispatch = mockDispatches.find((item) => item.id === id)
  if (!dispatch) return fail('派单不存在', 404)
  if (!body?.description || !body.result) return fail('处理结果和描述不能为空')

  const alert = mockAlerts.find((item) => item.id === dispatch.alertId)
  if (!alert) return fail('告警不存在', 404)

  dispatch.status = 'COMPLETED'
  dispatch.description = body.description
  dispatch.result = body.result
  dispatch.completedAt = now()

  alert.details = body.description
  alert.cause = dispatchResultText[body.result]
  alert.dispatch = dispatch

  if (body.result === 'NEED_FOLLOW_UP') {
    alert.status = 'PROCESSING'
    alert.statusName = statusText.PROCESSING
    alert.resolvedAt = null
  } else {
    alert.status = body.result
    alert.statusName = statusText[body.result]
    alert.resolvedAt = dispatch.completedAt
  }

  return success(dispatch)
}

function listElderly(query: Query) {
  let records = [...mockElderlies]
  if (query.name) {
    records = records.filter((elderly) => elderly.name.includes(query.name))
  }
  if (query.communityId) {
    records = records.filter((elderly) => elderly.communityId === Number(query.communityId))
  }
  if (query.status) {
    records = records.filter((elderly) => elderly.status === query.status)
  }

  const hydrated = records.map((elderly) => ({
    ...withCommunityName(elderly),
    device: mockDevices.find((device) => device.elderlyId === elderly.id),
    deviceId: mockDevices.find((device) => device.elderlyId === elderly.id)?.id,
  }))
  return success(paginate(hydrated, query))
}

function listDevices(query: Query) {
  let records = [...mockDevices]
  if (query.communityId) {
    records = records.filter((device) => device.communityId === Number(query.communityId))
  }
  if (query.elderlyId) {
    records = records.filter((device) => device.elderlyId === Number(query.elderlyId))
  }
  if (query.status) {
    records = records.filter((device) => device.status === query.status)
  }

  const hydrated = records.map((device) => ({
    ...withCommunityName(device),
    elderlyName: device.elderlyId
      ? mockElderlies.find((elderly) => elderly.id === device.elderlyId)?.name
      : undefined,
  }))
  return success(paginate(hydrated, query))
}

function listUsers(query: Query) {
  let records = [...mockSystemUsers]
  if (query.role) {
    records = records.filter((user) => user.role === query.role)
  }
  if (query.communityId) {
    records = records.filter((user) => user.communityId === Number(query.communityId))
  }
  return success(paginate(records.map(withCommunityName), query))
}

function bindDevice(deviceId: number, body?: { elderlyId: number | null }) {
  const device = mockDevices.find((item) => item.id === deviceId)
  if (!device) return fail('设备不存在', 404)

  if (!body?.elderlyId) {
    delete device.elderlyId
    delete device.elderlyName
    return success(device)
  }

  const elderly = mockElderlies.find((item) => item.id === Number(body.elderlyId))
  if (!elderly) return fail('老人不存在', 404)
  if (elderly.communityId !== device.communityId) return fail('只能绑定本社区老人')

  const boundDevice = mockDevices.find((item) => item.elderlyId === elderly.id && item.id !== device.id)
  if (boundDevice) return fail('该老人已绑定其他设备')

  device.elderlyId = elderly.id
  device.elderlyName = elderly.name
  return success(device)
}

function buildHandlers(): HandlerEntry[] {
  return [
    {
      method: 'POST',
      pattern: '/api/v1/auth/login',
      handler: ({ body }) => {
        const payload = body as LoginRequest | undefined
        if (!payload?.username || !payload.password) return fail('用户名或密码不能为空')

        const user = mockUsers.find(
          (item) => item.username === payload.username && item.password === payload.password,
        )
        if (!user) return fail('用户名或密码错误', 401)

        const { password, ...session } = user
        return success(session)
      },
    },
    {
      method: 'POST',
      pattern: '/api/v1/auth/register',
      handler: ({ body }) => {
        if (!body?.username || !body.password || !body.realName) {
          return fail('用户名、密码和姓名不能为空')
        }
        if (mockUsers.some((user) => user.username === body.username)) {
          return fail('用户名已存在')
        }
        const role = body.role === 'FAMILY' ? 'FAMILY' : 'WORKER'
        const community = mockCommunities.find((item) => item.id === Number(body.communityId))
        if (!community) return fail('社区不存在')
        const user: User = {
          id: nextId(mockSystemUsers),
          username: body.username,
          realName: body.realName,
          phone: body.phone || '',
          role,
          communityId: community.id,
          communityName: community.name,
          status: 'ACTIVE',
          createdAt: now(),
        }
        mockSystemUsers.push(user)
        mockUsers.push({
          username: user.username,
          password: body.password,
          token: `mock-user-${user.id}-token`,
          userId: user.id,
          role: user.role,
          realName: user.realName,
          communityId: user.communityId,
        })
        return success(true)
      },
    },
    {
      method: 'GET',
      pattern: '/api/v1/auth/profile',
      handler: () => success(mockUsers[0]),
    },
    {
      method: 'GET',
      pattern: '/api/v1/stats/overview',
      handler: () => {
        refreshCommunityCounts()
        return success({
          ...mockStatsOverview,
          totalElderly: mockElderlies.length,
          onlineDevices: mockDevices.filter((device) => device.status === 'ONLINE').length,
          pendingAlerts: mockAlerts.filter((alert) => alert.status === 'PENDING').length,
        })
      },
    },
    {
      method: 'GET',
      pattern: '/api/v1/stats/alerts/:communityId',
      handler: ({ params, query }) => {
        const period = (query.period || 'weekly') as StatsPeriod
        return success(getAlertStatsTrend(Number(params.communityId), period))
      },
    },
    {
      method: 'GET',
      pattern: '/api/v1/stats/care/:communityId',
      handler: ({ query }) => {
        const period = (query.period || 'weekly') as StatsPeriod
        return success(getCareStats(period))
      },
    },
    {
      method: 'GET',
      pattern: '/api/v1/stats/export',
      handler: ({ query }) => success(buildStatsExport(query.communityId ? Number(query.communityId) : undefined)),
    },
    {
      method: 'GET',
      pattern: '/api/v1/alerts',
      handler: ({ query }) => listAlerts(query),
    },
    {
      method: 'GET',
      pattern: '/api/v1/alerts/:id',
      handler: ({ params }) => {
        const alert = mockAlerts.find((item) => item.id === Number(params.id))
        return alert ? success(alert) : fail('告警不存在', 404)
      },
    },
    {
      method: 'PATCH',
      pattern: '/api/v1/alerts/:id',
      handler: ({ body, params }) => {
        const alert = mockAlerts.find((item) => item.id === Number(params.id))
        if (!alert) return fail('告警不存在', 404)
        const status = body?.status as AlertStatus | undefined
        if (!status || !statusText[status]) return fail('状态不合法')
        alert.status = status
        alert.statusName = statusText[status]
        alert.resolvedAt = status === 'RESOLVED' || status === 'NEED_HOSPITAL' ? now() : null
        return success(alert)
      },
    },
    {
      method: 'POST',
      pattern: '/api/v1/dispatches',
      handler: ({ body }) => createDispatch(body),
    },
    {
      method: 'GET',
      pattern: '/api/v1/dispatches/alert/:alertId',
      handler: ({ params }) => {
        const dispatch = mockDispatches.find((item) => item.alertId === Number(params.alertId))
        return dispatch ? success(dispatch) : fail('派单不存在', 404)
      },
    },
    {
      method: 'PATCH',
      pattern: '/api/v1/dispatches/:id',
      handler: ({ body, params }) => updateDispatch(Number(params.id), body),
    },
    {
      method: 'GET',
      pattern: '/api/v1/communities',
      handler: () => {
        refreshCommunityCounts()
        return success(mockCommunities)
      },
    },
    {
      method: 'POST',
      pattern: '/api/v1/communities',
      handler: ({ body }) => {
        if (!body?.name || !body.address || !body.area) return fail('社区名称、地址、区域不能为空')
        const community: Community = {
          id: nextId(mockCommunities),
          name: body.name,
          address: body.address,
          area: body.area,
          elderlyCount: 0,
          deviceCount: 0,
          createdAt: now(),
        }
        mockCommunities.push(community)
        return success(community)
      },
    },
    {
      method: 'PUT',
      pattern: '/api/v1/communities/:id',
      handler: ({ body, params }) => {
        const community = mockCommunities.find((item) => item.id === Number(params.id))
        if (!community) return fail('社区不存在', 404)
        community.name = body?.name ?? community.name
        community.address = body?.address ?? community.address
        community.area = body?.area ?? community.area
        mockElderlies.forEach((elderly) => {
          if (elderly.communityId === community.id) elderly.communityName = community.name
        })
        mockDevices.forEach((device) => {
          if (device.communityId === community.id) device.communityName = community.name
        })
        mockSystemUsers.forEach((user) => {
          if (user.communityId === community.id) user.communityName = community.name
        })
        return success(community)
      },
    },
    {
      method: 'DELETE',
      pattern: '/api/v1/communities/:id',
      handler: ({ params }) => {
        const id = Number(params.id)
        if (mockElderlies.some((elderly) => elderly.communityId === id)) {
          return fail('该社区下有老人，不能删除')
        }
        if (mockSystemUsers.some((user) => user.communityId === id)) {
          return fail('该社区下有用户，不能删除')
        }
        const index = mockCommunities.findIndex((item) => item.id === id)
        if (index < 0) return fail('社区不存在', 404)
        mockCommunities.splice(index, 1)
        return success(true)
      },
    },
    {
      method: 'GET',
      pattern: '/api/v1/elderly',
      handler: ({ query }) => listElderly(query),
    },
    {
      method: 'GET',
      pattern: '/api/v1/elderly/:id',
      handler: ({ params }) => {
        const elderly = mockElderlies.find((item) => item.id === Number(params.id))
        return elderly ? success(withCommunityName(elderly)) : fail('老人不存在', 404)
      },
    },
    {
      method: 'POST',
      pattern: '/api/v1/elderly',
      handler: ({ body }) => {
        const community = mockCommunities.find((item) => item.id === Number(body?.communityId))
        if (!community) return fail('社区不存在')
        const elderly: Elderly = {
          id: nextId(mockElderlies),
          name: body.name,
          age: Number(body.age),
          gender: body.gender,
          phone: body.phone || '',
          communityId: community.id,
          communityName: community.name,
          emergencyContact: body.emergencyContact || '',
          healthNotes: body.healthNotes || '',
          status: 'ACTIVE',
          createdAt: now(),
        }
        mockElderlies.push(elderly)
        refreshCommunityCounts()
        return success(elderly)
      },
    },
    {
      method: 'PUT',
      pattern: '/api/v1/elderly/:id',
      handler: ({ body, params }) => {
        const elderly = mockElderlies.find((item) => item.id === Number(params.id))
        if (!elderly) return fail('老人不存在', 404)
        if (body?.communityId) {
          const community = mockCommunities.find((item) => item.id === Number(body.communityId))
          if (!community) return fail('社区不存在')
          elderly.communityId = community.id
          elderly.communityName = community.name
        }
        Object.assign(elderly, {
          name: body?.name ?? elderly.name,
          age: body?.age ?? elderly.age,
          gender: body?.gender ?? elderly.gender,
          phone: body?.phone ?? elderly.phone,
          emergencyContact: body?.emergencyContact ?? elderly.emergencyContact,
          healthNotes: body?.healthNotes ?? elderly.healthNotes,
          status: body?.status ?? elderly.status,
        })
        refreshCommunityCounts()
        return success(elderly)
      },
    },
    {
      method: 'DELETE',
      pattern: '/api/v1/elderly/:id',
      handler: ({ params }) => {
        const id = Number(params.id)
        const index = mockElderlies.findIndex((item) => item.id === id)
        if (index < 0) return fail('老人不存在', 404)
        mockDevices.forEach((device) => {
          if (device.elderlyId === id) {
            delete device.elderlyId
            delete device.elderlyName
          }
        })
        mockElderlies.splice(index, 1)
        refreshCommunityCounts()
        return success(true)
      },
    },
    {
      method: 'GET',
      pattern: '/api/v1/devices',
      handler: ({ query }) => listDevices(query),
    },
    {
      method: 'POST',
      pattern: '/api/v1/devices',
      handler: ({ body }) => {
        const community = mockCommunities.find((item) => item.id === Number(body?.communityId))
        if (!community) return fail('社区不存在')
        if (!body?.name || !body.type || !body.mac) return fail('设备名称、类型和 MAC 不能为空')
        const device: Device = {
          id: nextId(mockDevices),
          name: body.name,
          type: body.type,
          mac: body.mac,
          communityId: community.id,
          communityName: community.name,
          status: 'OFFLINE',
          battery: body.battery,
          lastHeartbeat: now(),
          createdAt: now(),
        }
        mockDevices.push(device)
        refreshCommunityCounts()
        return success(device)
      },
    },
    {
      method: 'PUT',
      pattern: '/api/v1/devices/:id',
      handler: ({ body, params }) => {
        const device = mockDevices.find((item) => item.id === Number(params.id))
        if (!device) return fail('设备不存在', 404)
        if (body?.communityId) {
          const community = mockCommunities.find((item) => item.id === Number(body.communityId))
          if (!community) return fail('社区不存在')
          device.communityId = community.id
          device.communityName = community.name
        }
        Object.assign(device, {
          name: body?.name ?? device.name,
          type: body?.type ?? device.type,
          mac: body?.mac ?? device.mac,
        })
        refreshCommunityCounts()
        return success(device)
      },
    },
    {
      method: 'DELETE',
      pattern: '/api/v1/devices/:id',
      handler: ({ params }) => {
        const index = mockDevices.findIndex((item) => item.id === Number(params.id))
        if (index < 0) return fail('设备不存在', 404)
        mockDevices.splice(index, 1)
        refreshCommunityCounts()
        return success(true)
      },
    },
    {
      method: 'POST',
      pattern: '/api/v1/devices/:id/bind',
      handler: ({ body, params }) => bindDevice(Number(params.id), body),
    },
    {
      method: 'POST',
      pattern: '/api/v1/devices/:id/unbind',
      handler: ({ params }) => bindDevice(Number(params.id), { elderlyId: null }),
    },
    {
      method: 'GET',
      pattern: '/api/v1/users',
      handler: ({ query }) => listUsers(query),
    },
    {
      method: 'POST',
      pattern: '/api/v1/users',
      handler: ({ body }) => {
        if (!body?.username || !body.realName || !body.role) return fail('用户名、姓名、角色不能为空')
        if (mockSystemUsers.some((user) => user.username === body.username)) return fail('用户名已存在')
        const community = body.communityId
          ? mockCommunities.find((item) => item.id === Number(body.communityId))
          : undefined
        const user: User = {
          id: nextId(mockSystemUsers),
          username: body.username,
          realName: body.realName,
          phone: body.phone || '',
          role: body.role,
          communityId: body.role === 'ADMIN' ? undefined : community?.id,
          communityName: body.role === 'ADMIN' ? undefined : community?.name,
          status: 'ACTIVE',
          createdAt: now(),
        }
        mockSystemUsers.push(user)
        mockUsers.push({
          username: user.username,
          password: body.password || '123456',
          token: `mock-user-${user.id}-token`,
          userId: user.id,
          role: user.role,
          realName: user.realName,
          communityId: user.communityId,
        })
        return success(user)
      },
    },
    {
      method: 'PUT',
      pattern: '/api/v1/users/:id',
      handler: ({ body, params }) => {
        const user = mockSystemUsers.find((item) => item.id === Number(params.id))
        if (!user) return fail('用户不存在', 404)
        const community = body?.communityId
          ? mockCommunities.find((item) => item.id === Number(body.communityId))
          : undefined
        user.realName = body?.realName ?? user.realName
        user.phone = body?.phone ?? user.phone
        user.role = body?.role ?? user.role
        user.communityId = user.role === 'ADMIN' ? undefined : community?.id
        user.communityName = user.role === 'ADMIN' ? undefined : community?.name

        const loginUser = mockUsers.find((item) => item.userId === user.id)
        if (loginUser) {
          loginUser.realName = user.realName
          loginUser.role = user.role
          loginUser.communityId = user.communityId
          if (body?.password) loginUser.password = body.password
        }
        return success(user)
      },
    },
    {
      method: 'DELETE',
      pattern: '/api/v1/users/:id',
      handler: ({ params }) => {
        const id = Number(params.id)
        const index = mockSystemUsers.findIndex((item) => item.id === id)
        if (index < 0) return fail('用户不存在', 404)
        mockSystemUsers.splice(index, 1)
        const loginIndex = mockUsers.findIndex((item) => item.userId === id)
        if (loginIndex >= 0) mockUsers.splice(loginIndex, 1)
        return success(true)
      },
    },
  ]
}

export function createMockServer(): MockServer {
  const handlers = buildHandlers()

  return {
    request: async function <T>(method: string, url: string, data?: any): Promise<ApiResult<T>> {
      const { path, query } = parseUrl(url)
      const normalizedMethod = method.toUpperCase()
      const entry = handlers.find((candidate) => {
        return candidate.method === normalizedMethod && matchPath(candidate.pattern, path)
      })

      await new Promise((resolve) => setTimeout(resolve, 240))

      if (!entry) {
        return fail(`Not found: ${normalizedMethod} ${path}`, 404) as ApiResult<T>
      }

      const params = matchPath(entry.pattern, path) ?? {}
      return entry.handler({ body: data, params, query }) as ApiResult<T>
    },
  }
}
