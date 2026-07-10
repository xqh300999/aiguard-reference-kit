export interface User {
  id: number
  username: string
  realName: string
  role: 'SUPER_ADMIN' | 'ADMIN' | 'WORKER' | 'FAMILY' | 'ELDERLY'
  phone?: string
  communityId: number | null
  communityName?: string
  status: 'ACTIVE' | 'INACTIVE'
  createdAt: string
}

export interface Community {
  id: number
  name: string
  address: string
  area: string
  elderlyCount: number
  deviceCount: number
  createdAt: string
}

export interface Elderly {
  id: number
  name: string
  age: number
  gender: 'MALE' | 'FEMALE'
  address?: string
  phone?: string
  emergencyContact?: string
  healthNotes?: string
  communityId: number
  communityName?: string
  device?: Device
  deviceId?: number
  status: 'ACTIVE' | 'INACTIVE'
  createdAt: string
}

export interface Device {
  id: number
  name: string
  type: 'WATCH' | 'PANEL' | 'GATEWAY'
  mac: string
  communityId: number
  communityName?: string
  elderlyId?: number
  elderlyName?: string
  status: 'ONLINE' | 'OFFLINE'
  battery?: number
  lastHeartbeat?: string
  createdAt: string
}

export interface Alert {
  id: number
  type: 'SOS' | 'FALL' | 'INACTIVITY' | 'LOW_BATTERY' | 'DEVICE_OFFLINE' | 'ABNORMAL'
  typeName?: string
  elderlyId: number
  elderlyName: string
  communityId: number
  communityName?: string
  status: 'PENDING' | 'PROCESSING' | 'RESOLVED' | 'NEED_HOSPITAL'
  statusName?: string
  priority?: 'HIGH' | 'MEDIUM' | 'LOW'
  handlerId?: number
  handlerName?: string
  cause?: string
  details?: string
  happenedAt: string
  resolvedAt?: string
}

export interface Dispatch {
  id: number
  alertId: number
  handlerId: number
  status: 'ASSIGNED' | 'ARRIVED' | 'RESOLVED'
  description?: string
  result?: 'RESOLVED' | 'NEED_HOSPITAL' | 'NEED_FOLLOW_UP'
  createdAt: string
}

export interface StatsOverview {
  totalElderly: number
  todayAlerts: number
  onlineDevices: number
  pendingAlerts: number
}
