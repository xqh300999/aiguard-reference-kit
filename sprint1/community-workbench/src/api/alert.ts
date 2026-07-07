import request from '@/utils/request'
import type { AlertDetail, AlertListQuery, AlertRecord, PageResult } from '@/types/api'

export function getAlertsApi(params: AlertListQuery) {
  return request.get<PageResult<AlertRecord>>('/alerts', params as Record<string, unknown>)
}

export function getAlertDetailApi(id: number) {
  return request.get<AlertDetail>(`/alerts/${id}`)
}
