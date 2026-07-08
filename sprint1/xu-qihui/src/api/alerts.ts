import request from '@/utils/request'
import type { AlertDetail, AlertRecord, AlertListQuery, PageResult, DispatchRecord, CreateDispatchPayload, UpdateDispatchPayload } from '@/types/api'

export const getAlerts = (params?: AlertListQuery): Promise<PageResult<AlertRecord>> => {
  return request.get('/alerts', { params })
}

export const getAlertDetail = (id: number): Promise<AlertDetail> => {
  return request.get(`/alerts/${id}`)
}

export const takeAlert = (id: number): Promise<AlertDetail> => {
  return request.post(`/alerts/${id}/take`)
}

export const completeAlert = (id: number, data: UpdateDispatchPayload): Promise<AlertDetail> => {
  return request.post(`/alerts/${id}/complete`, data)
}

export const dispatchAlert = (id: number, data: CreateDispatchPayload): Promise<DispatchRecord> => {
  return request.post(`/alerts/${id}/dispatch`, data)
}

export const updateAlert = (id: number, data: Partial<Pick<AlertRecord, 'status'>>): Promise<AlertDetail> => {
  return request.patch(`/alerts/${id}`, data)
}