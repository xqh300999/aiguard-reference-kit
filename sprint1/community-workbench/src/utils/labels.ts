import type { AlertPriority, AlertStatus, AlertType, DispatchResult } from '@/types/api'

export const alertStatusText: Record<AlertStatus, string> = {
  PENDING: '待处理',
  PROCESSING: '处理中',
  RESOLVED: '已解决',
  NEED_HOSPITAL: '需送医',
}

export const alertStatusTag: Record<AlertStatus, 'danger' | 'warning' | 'success' | 'info'> = {
  PENDING: 'danger',
  PROCESSING: 'warning',
  RESOLVED: 'success',
  NEED_HOSPITAL: 'danger',
}

export const alertTypeText: Record<AlertType, string> = {
  SOS: '紧急求助',
  FALL: '跌倒告警',
  INACTIVITY: '久未活动',
  LOW_BATTERY: '低电量',
  DEVICE_OFFLINE: '设备离线',
  ABNORMAL: '异常告警',
}

export const alertTypeTone: Record<AlertType, string> = {
  SOS: 'type-sos',
  FALL: 'type-fall',
  INACTIVITY: 'type-inactivity',
  LOW_BATTERY: 'type-low-battery',
  DEVICE_OFFLINE: 'type-device-offline',
  ABNORMAL: 'type-abnormal',
}

export const priorityText: Record<AlertPriority, string> = {
  HIGH: '高',
  MEDIUM: '中',
  LOW: '低',
}

export const dispatchResultText: Record<DispatchResult, string> = {
  RESOLVED: '已解决',
  NEED_HOSPITAL: '需送医',
  NEED_FOLLOW_UP: '需跟进',
}

export function formatDateTime(value: string | null | undefined) {
  if (!value) return '-'
  const date = new Date(value)
  if (Number.isNaN(date.getTime())) return value
  return new Intl.DateTimeFormat('zh-CN', {
    month: '2-digit',
    day: '2-digit',
    hour: '2-digit',
    minute: '2-digit',
  }).format(date)
}
