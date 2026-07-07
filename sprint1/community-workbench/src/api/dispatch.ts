import request from '@/utils/request'
import type { CreateDispatchPayload, DispatchRecord, UpdateDispatchPayload } from '@/types/api'

export function createDispatchApi(payload: CreateDispatchPayload) {
  return request.post<DispatchRecord>('/dispatches', payload)
}

export function getDispatchByAlertApi(alertId: number) {
  return request.get<DispatchRecord>(`/dispatches/alert/${alertId}`)
}

export function updateDispatchApi(id: number, payload: UpdateDispatchPayload) {
  return request.patch<DispatchRecord>(`/dispatches/${id}`, payload)
}
