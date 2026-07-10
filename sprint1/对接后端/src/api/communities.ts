import request from '@/utils/request'
import type { Community } from '@/types/api'

const COMMUNITY_PATH = import.meta.env.VITE_COMMUNITY_PATH
  || (import.meta.env.VITE_USE_MOCK === 'true' ? '/communities' : '/community')

export const getCommunities = (): Promise<Community[]> => {
  return request.get<Community[] | { records: Community[] }>(COMMUNITY_PATH).then((res) => {
    const rows = Array.isArray(res) ? res : res?.records || []
    return rows.map((row) => ({
      ...row,
      area: row.area || '',
      elderlyCount: row.elderlyCount ?? 0,
      deviceCount: row.deviceCount ?? 0,
    }))
  })
}

export const createCommunity = (data: Omit<Community, 'id' | 'elderlyCount' | 'deviceCount' | 'createdAt'>) => {
  return request.post(COMMUNITY_PATH, data)
}

export const updateCommunity = (id: number, data: Omit<Community, 'id' | 'elderlyCount' | 'deviceCount' | 'createdAt'>) => {
  return request.put(`${COMMUNITY_PATH}/${id}`, data)
}

export const deleteCommunity = (id: number) => {
  return request.delete(`${COMMUNITY_PATH}/${id}`)
}
