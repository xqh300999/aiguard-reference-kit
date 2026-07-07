export type Role = 'ADMIN' | 'WORKER' | 'FAMILY' | 'ELDERLY'

export type AlertStatus = 'PENDING' | 'PROCESSING' | 'RESOLVED' | 'NEED_HOSPITAL'

export type AlertType =
  | 'SOS'
  | 'FALL'
  | 'INACTIVITY'
  | 'LOW_BATTERY'
  | 'DEVICE_OFFLINE'
  | 'ABNORMAL'

export type AlertPriority = 'HIGH' | 'MEDIUM' | 'LOW'

export type DispatchResult = 'RESOLVED' | 'NEED_HOSPITAL' | 'NEED_FOLLOW_UP'

export interface ApiResult<T> {
  code: number
  message: string
  data: T
  ts: string
}

export interface PageResult<T> {
  records: T[]
  total: number
  page: number
  size: number
}

export interface LoginRequest {
  username: string
  password: string
}

export interface UserSession {
  token: string
  userId: number
  role: Role
  realName: string
  communityId?: number
}

export interface AlertRecord {
  id: number
  type: AlertType
  typeName: string
  elderlyId: number
  elderlyName: string
  communityId: number
  communityName: string
  status: AlertStatus
  statusName: string
  priority: AlertPriority
  handlerId: number | null
  handlerName: string | null
  happenedAt: string
  resolvedAt: string | null
}

export interface ElderlySummary {
  id: number
  name: string
  age: number
  gender: 'MALE' | 'FEMALE'
  genderName: string
  address: string
  phone: string
  emergencyContact: string
  healthNotes: string
  deviceStatus: 'ONLINE' | 'OFFLINE'
  battery: number
}

export interface DispatchRecord {
  id: number
  alertId: number
  handlerId: number
  handlerName: string
  status: 'PROCESSING' | 'COMPLETED'
  description: string | null
  result: DispatchResult | null
  createdAt: string
  completedAt: string | null
}

export interface AlertDetail extends AlertRecord {
  source: 'APP' | 'WATCH' | 'RULE' | 'SYSTEM'
  cause: string | null
  details: string | null
  lat: number | null
  lng: number | null
  elderly?: ElderlySummary
  dispatch: DispatchRecord | null
}

export interface AlertListQuery {
  communityId?: number
  status?: AlertStatus
  type?: AlertType
  page?: number
  size?: number
}

export interface CreateDispatchPayload {
  alertId: number
  handlerId: number
}

export interface UpdateDispatchPayload {
  description: string
  result: DispatchResult
}
