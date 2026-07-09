import request from '@/utils/request'
import type { Community } from '@/types/api'

export const getCommunities = (): Promise<Community[]> => {
  return request.get<Community[] | { records: Community[] }>('/communities').then((res) => {
    if (Array.isArray(res)) return res
    return res?.records || []
  })
}

export const createCommunity = (data: Omit<Community, 'id' | 'elderlyCount' | 'deviceCount' | 'createdAt'>) => {
  return request.post('/communities', data)
}

export const updateCommunity = (id: number, data: Omit<Community, 'id' | 'elderlyCount' | 'deviceCount' | 'createdAt'>) => {
  return request.put(`/communities/${id}`, data)
}

export const deleteCommunity = (id: number) => {
  return request.delete(`/communities/${id}`)
}
