import request from '@/utils/request'
import type { Elderly, PageResult } from '@/types/api'

export const getElderlies = (params?: { page?: number; size?: number; name?: string; communityId?: number; status?: string }): Promise<PageResult<Elderly>> => {
  return request.get<PageResult<Elderly> | Elderly[]>('/elderly', { params }).then((res) => {
    if (Array.isArray(res)) {
      return { records: res, total: res.length, page: 1, size: res.length }
    }
    return res
  })
}

export const createElderly = (data: Omit<Elderly, 'id' | 'device' | 'deviceId' | 'status' | 'createdAt'>) => {
  return request.post('/elderly', data)
}

export const updateElderly = (id: number, data: Partial<Omit<Elderly, 'id' | 'device' | 'deviceId' | 'createdAt'>>) => {
  return request.put('/elderly', { id, ...data })
}

export const deleteElderly = (id: number) => {
  return request.delete(`/elderly/${id}`)
}
