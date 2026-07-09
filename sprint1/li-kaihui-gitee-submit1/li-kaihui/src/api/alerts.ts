import request from '@/utils/request'
import type { AlertDetail, AlertRecord, AlertListQuery, PageResult, DispatchRecord, CreateDispatchPayload, UpdateDispatchPayload } from '@/types/api'

export const getAlerts = (params?: AlertListQuery): Promise<PageResult<AlertRecord>> => {
  return request.get('/alerts', { params })
}

export const getAlertDetail = (id: number): Promise<AlertDetail> => {
  return request.get(`/alerts/${id}`)
}

export const createDispatch = (data: CreateDispatchPayload): Promise<DispatchRecord> => {
  return request.post('/dispatches', data)
}

export const getDispatchByAlert = (alertId: number): Promise<DispatchRecord> => {
  return request.get(`/dispatches/alert/${alertId}`)
}

export const updateDispatch = (id: number, data: UpdateDispatchPayload): Promise<DispatchRecord> => {
  return request.patch(`/dispatches/${id}`, data)
}

export const updateAlert = (id: number, data: Partial<Pick<AlertRecord, 'status'>>): Promise<AlertDetail> => {
  return request.patch(`/alerts/${id}`, data)
}
