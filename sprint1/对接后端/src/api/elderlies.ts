import request from '@/utils/request'
import type { Elderly, PageResult } from '@/types/api'

const USE_MOCK = import.meta.env.VITE_USE_MOCK === 'true'

export const getElderlies = (params?: { page?: number; size?: number; name?: string; communityId?: number; status?: string }): Promise<PageResult<Elderly>> => {
  return request.get<PageResult<Elderly> | Elderly[]>('/elderly', { params }).then((res) => {
    if (Array.isArray(res)) {
      return {
        records: res,
        total: res.length,
        page: params?.page ?? 1,
        size: params?.size ?? res.length,
      }
    }
    return res
  })
}

export const createElderly = (data: Omit<Elderly, 'id' | 'device' | 'deviceId' | 'status' | 'createdAt'>) => {
  return request.post('/elderly', data)
}

export const updateElderly = (id: number, data: Partial<Omit<Elderly, 'id' | 'device' | 'deviceId' | 'createdAt'>>) => {
  return USE_MOCK ? request.put(`/elderly/${id}`, data) : request.put('/elderly', { ...data, id })
}

export const deleteElderly = (id: number) => {
  return request.delete(`/elderly/${id}`)
}
