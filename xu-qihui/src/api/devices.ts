import request from '@/utils/request'
import type { Device, PageResult } from '@/types/api'

export const getDevices = (params?: { page?: number; size?: number; communityId?: number; elderlyId?: number; status?: string }): Promise<PageResult<Device>> => {
  return request.get('/devices', { params })
}

export const bindDevice = (id: number, data: { elderlyId: number | null }) => {
  return request.post(`/devices/${id}/bind`, data)
}

export const unbindDevice = (id: number) => {
  return request.post(`/devices/${id}/unbind`)
}