import type {
  AlertDetail,
  AlertRecord,
  Community,
  Device,
  DispatchRecord,
  Elderly,
  ElderlySummary,
  StatsOverview,
  User,
  UserSession,
} from '@/types/api'
import { loadPersistedData, savePersistedData } from './persistence'

interface MockUser extends UserSession {
  username: string
  password: string
}

const defaultMockUsers: MockUser[] = [
  {
    username: 'superadmin',
    password: 'super123',
    token: 'mock-super-token',
    userId: 0,
    role: 'SUPER_ADMIN',
    realName: '超级管理员',
    communityId: undefined,
  },
  {
    username: 'admin',
    password: 'admin123',
    token: 'mock-admin-token',
    userId: 1,
    role: 'ADMIN',
    realName: '管理员',
    communityId: 1,
  },
  {
    username: 'worker',
    password: 'worker123',
    token: 'mock-worker-token',
    userId: 2,
    role: 'WORKER',
    realName: '李凯辉',
    communityId: 1,
  },
]

export const mockElderlyMap: Record<number, ElderlySummary> = {
  1: {
    id: 1,
    name: '王大爷',
    age: 78,
    gender: 'MALE' as const,
    genderName: '男',
    address: '幸福社区 3 号楼 101',
    phone: '010-88886666',
    emergencyContact: '王女士 13800138001',
    healthNotes: '高血压，每天服药',
    deviceStatus: 'ONLINE' as const,
    battery: 85,
  },
  2: {
    id: 2,
    name: '刘奶奶',
    age: 82,
    gender: 'FEMALE' as const,
    genderName: '女',
    address: '幸福社区 1 号楼 603',
    phone: '010-66668888',
    emergencyContact: '刘先生 13900139002',
    healthNotes: '近期膝关节不适',
    deviceStatus: 'ONLINE' as const,
    battery: 72,
  },
  3: {
    id: 3,
    name: '赵爷爷',
    age: 75,
    gender: 'MALE' as const,
    genderName: '男',
    address: '幸福社区 6 号楼 202',
    phone: '010-55557777',
    emergencyContact: '赵女士 13700137003',
    healthNotes: '糖尿病，需规律测血糖',
    deviceStatus: 'OFFLINE' as const,
    battery: 16,
  },
}

const defaultMockCommunities: Community[] = [
  { id: 1, name: '幸福社区', address: '北京市朝阳区幸福路1号', area: '朝阳区', elderlyCount: 3, deviceCount: 3, createdAt: '2026-07-01T08:00:00Z' },
  { id: 2, name: '阳光社区', address: '北京市海淀区阳光大道2号', area: '海淀区', elderlyCount: 0, deviceCount: 0, createdAt: '2026-07-01T08:00:00Z' },
  { id: 3, name: '和谐社区', address: '北京市西城区和谐街3号', area: '西城区', elderlyCount: 0, deviceCount: 0, createdAt: '2026-07-01T08:00:00Z' },
  { id: 4, name: '平安社区', address: '北京市东城区平安巷4号', area: '东城区', elderlyCount: 0, deviceCount: 0, createdAt: '2026-07-01T08:00:00Z' },
]

const defaultMockElderlies: Elderly[] = [
  { id: 1, name: '王大爷', age: 78, gender: 'MALE', phone: '010-88886666', communityId: 1, communityName: '幸福社区', emergencyContact: '王女士 13800138001', healthNotes: '高血压，每天服药', status: 'ACTIVE', createdAt: '2026-07-01T08:00:00Z', deviceId: 1 },
  { id: 2, name: '刘奶奶', age: 82, gender: 'FEMALE', phone: '010-66668888', communityId: 1, communityName: '幸福社区', emergencyContact: '刘先生 13900139002', healthNotes: '近期膝关节不适', status: 'ACTIVE', createdAt: '2026-07-01T08:00:00Z', deviceId: 2 },
  { id: 3, name: '赵爷爷', age: 75, gender: 'MALE', phone: '010-55557777', communityId: 1, communityName: '幸福社区', emergencyContact: '赵女士 13700137003', healthNotes: '糖尿病，需规律测血糖', status: 'ACTIVE', createdAt: '2026-07-01T08:00:00Z', deviceId: 3 },
]

const defaultMockDevices: Device[] = [
  { id: 1, name: '手表001', type: 'WATCH', mac: 'A1:B2:C3:D4:E5:F6', communityId: 1, communityName: '幸福社区', elderlyId: 1, elderlyName: '王大爷', status: 'ONLINE', battery: 85, lastHeartbeat: '2026-07-07T09:59:00Z', createdAt: '2026-07-01T08:00:00Z' },
  { id: 2, name: '手表002', type: 'WATCH', mac: 'A1:B2:C3:D4:E5:F7', communityId: 1, communityName: '幸福社区', elderlyId: 2, elderlyName: '刘奶奶', status: 'ONLINE', battery: 72, lastHeartbeat: '2026-07-07T09:58:00Z', createdAt: '2026-07-01T08:00:00Z' },
  { id: 3, name: '手表003', type: 'WATCH', mac: 'A1:B2:C3:D4:E5:F8', communityId: 1, communityName: '幸福社区', elderlyId: 3, elderlyName: '赵爷爷', status: 'OFFLINE', battery: 16, lastHeartbeat: '2026-07-07T08:00:00Z', createdAt: '2026-07-01T08:00:00Z' },
]

const defaultMockSystemUsers: User[] = [
  { id: 0, username: 'superadmin', realName: '超级管理员', phone: '', role: 'SUPER_ADMIN', communityId: undefined, status: 'ACTIVE', createdAt: '2026-07-01T08:00:00Z' },
  { id: 1, username: 'admin', realName: '管理员', phone: '', role: 'ADMIN', communityId: undefined, status: 'ACTIVE', createdAt: '2026-07-01T08:00:00Z' },
  { id: 2, username: 'worker1', realName: '李凯辉', phone: '13800138000', role: 'WORKER', communityId: 1, communityName: '幸福社区', status: 'ACTIVE', createdAt: '2026-07-01T08:00:00Z' },
]

export const mockStatsOverview: StatsOverview = {
  totalElderly: 3,
  todayAlerts: 3,
  onlineDevices: 2,
  pendingAlerts: 3,
}

const defaultMockAlerts: AlertDetail[] = [
  {
    id: 1001,
    type: 'SOS',
    typeName: '紧急求助',
    elderlyId: 1,
    elderlyName: '王大爷',
    communityId: 1,
    communityName: '幸福社区',
    status: 'PENDING',
    statusName: '待处理',
    priority: 'HIGH',
    handlerId: null,
    handlerName: null,
    happenedAt: '2026-07-07T09:42:00Z',
    resolvedAt: null,
    source: 'WATCH',
    cause: null,
    details: null,
    lat: 30.5728,
    lng: 104.0668,
    elderly: mockElderlyMap[1],
    dispatch: null,
  },
  {
    id: 1002,
    type: 'FALL',
    typeName: '跌倒告警',
    elderlyId: 2,
    elderlyName: '刘奶奶',
    communityId: 1,
    communityName: '幸福社区',
    status: 'PENDING',
    statusName: '待处理',
    priority: 'HIGH',
    handlerId: null,
    handlerName: null,
    happenedAt: '2026-07-07T09:16:00Z',
    resolvedAt: null,
    source: 'WATCH',
    cause: null,
    details: null,
    lat: 30.5736,
    lng: 104.0673,
    elderly: mockElderlyMap[2],
    dispatch: null,
  },
  {
    id: 1003,
    type: 'LOW_BATTERY',
    typeName: '低电量',
    elderlyId: 3,
    elderlyName: '赵爷爷',
    communityId: 1,
    communityName: '幸福社区',
    status: 'PROCESSING',
    statusName: '处理中',
    priority: 'MEDIUM',
    handlerId: 2,
    handlerName: '李凯辉',
    happenedAt: '2026-07-07T08:35:00Z',
    resolvedAt: null,
    source: 'SYSTEM',
    cause: '设备电量低于 20%',
    details: null,
    lat: null,
    lng: null,
    elderly: mockElderlyMap[3],
    dispatch: null,
  },
  {
    id: 1004,
    type: 'DEVICE_OFFLINE',
    typeName: '设备离线',
    elderlyId: 3,
    elderlyName: '赵爷爷',
    communityId: 1,
    communityName: '幸福社区',
    status: 'RESOLVED',
    statusName: '已解决',
    priority: 'MEDIUM',
    handlerId: 2,
    handlerName: '李凯辉',
    happenedAt: '2026-07-06T17:30:00Z',
    resolvedAt: '2026-07-06T17:58:00Z',
    source: 'SYSTEM',
    cause: '室内网关临时断电',
    details: '已联系家属恢复电源，设备重新在线。',
    lat: null,
    lng: null,
    elderly: mockElderlyMap[3],
    dispatch: null,
  },
  {
    id: 1005,
    type: 'SOS',
    typeName: '紧急求助',
    elderlyId: 2,
    elderlyName: '刘奶奶',
    communityId: 1,
    communityName: '幸福社区',
    status: 'PENDING',
    statusName: '待处理',
    priority: 'HIGH',
    handlerId: null,
    handlerName: null,
    happenedAt: '2026-07-07T07:54:00Z',
    resolvedAt: null,
    source: 'APP',
    cause: null,
    details: null,
    lat: 30.575,
    lng: 104.0659,
    elderly: mockElderlyMap[2],
    dispatch: null,
  },
  {
    id: 1006,
    type: 'INACTIVITY',
    typeName: '久未活动',
    elderlyId: 1,
    elderlyName: '王大爷',
    communityId: 1,
    communityName: '幸福社区',
    status: 'RESOLVED',
    statusName: '已解决',
    priority: 'LOW',
    handlerId: 2,
    handlerName: '李凯辉',
    happenedAt: '2026-07-05T21:20:00Z',
    resolvedAt: '2026-07-05T21:44:00Z',
    source: 'RULE',
    cause: '晚间活动量低',
    details: '电话确认老人已休息，无异常。',
    lat: null,
    lng: null,
    elderly: mockElderlyMap[1],
    dispatch: null,
  },
]

const defaultMockDispatches: DispatchRecord[] = [
  {
    id: 5001,
    alertId: 1003,
    handlerId: 2,
    handlerName: '李凯辉',
    status: 'PROCESSING',
    description: null,
    result: null,
    createdAt: '2026-07-07T08:38:00Z',
    completedAt: null,
  },
  {
    id: 5002,
    alertId: 1004,
    handlerId: 2,
    handlerName: '李凯辉',
    status: 'COMPLETED',
    description: '已联系家属恢复电源，设备重新在线。',
    result: 'RESOLVED',
    createdAt: '2026-07-06T17:34:00Z',
    completedAt: '2026-07-06T17:58:00Z',
  },
  {
    id: 5003,
    alertId: 1006,
    handlerId: 2,
    handlerName: '李凯辉',
    status: 'COMPLETED',
    description: '电话确认老人已休息，无异常。',
    result: 'RESOLVED',
    createdAt: '2026-07-05T21:22:00Z',
    completedAt: '2026-07-05T21:44:00Z',
  },
]

const persistedData = loadPersistedData()

export const mockUsers: MockUser[] = persistedData.users.length > 0 ? persistedData.users : defaultMockUsers
export const mockSystemUsers: User[] = persistedData.systemUsers.length > 0 ? persistedData.systemUsers : defaultMockSystemUsers
export const mockCommunities: Community[] = persistedData.communities.length > 0 ? persistedData.communities : defaultMockCommunities
export const mockElderlies: Elderly[] = persistedData.elderlies.length > 0 ? persistedData.elderlies : defaultMockElderlies
export const mockDevices: Device[] = persistedData.devices.length > 0 ? persistedData.devices : defaultMockDevices
export const mockAlerts: AlertDetail[] = persistedData.alerts.length > 0 ? persistedData.alerts : defaultMockAlerts
export const mockDispatches: DispatchRecord[] = persistedData.dispatches.length > 0 ? persistedData.dispatches : defaultMockDispatches

mockAlerts.forEach((alert) => {
  alert.dispatch = mockDispatches.find((dispatch) => dispatch.alertId === alert.id) ?? null
})

export function persistData(): void {
  savePersistedData({
    users: mockUsers,
    systemUsers: mockSystemUsers,
    communities: mockCommunities,
    elderlies: mockElderlies,
    devices: mockDevices,
    alerts: mockAlerts,
    dispatches: mockDispatches,
  })
}

export function toAlertRecord(alert: AlertDetail): AlertRecord {
  const {
    id,
    type,
    typeName,
    elderlyId,
    elderlyName,
    communityId,
    communityName,
    status,
    statusName,
    priority,
    handlerId,
    handlerName,
    happenedAt,
    resolvedAt,
  } = alert

  return {
    id,
    type,
    typeName,
    elderlyId,
    elderlyName,
    communityId,
    communityName,
    status,
    statusName,
    priority,
    handlerId,
    handlerName,
    happenedAt,
    resolvedAt,
  }
}