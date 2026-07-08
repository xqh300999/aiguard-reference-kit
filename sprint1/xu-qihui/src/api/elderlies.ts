import request from '@/utils/request'
import type { Elderly, PageResult } from '@/types/api'

export const getElderlies = (params?: { page?: number; size?: number; name?: string; communityId?: number; status?: string }): Promise<PageResult<Elderly>> => {
  return request.get('/elderlies', { params })
}

export const createElderly = (data: Omit<Elderly, 'id' | 'device' | 'deviceId' | 'status' | 'createdAt'>) => {
  return request.post('/elderlies', data)
}

export const updateElderly = (id: number, data: Partial<Omit<Elderly, 'id' | 'device' | 'deviceId' | 'createdAt'>>) => {
  return request.put(`/elderlies/${id}`, data)
}

export const deleteElderly = (id: number) => {
  return request.delete(`/elderlies/${id}`)
}