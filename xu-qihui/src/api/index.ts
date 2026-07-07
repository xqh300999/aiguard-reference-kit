import request from '@/utils/request'
import type { Community, Elderly, User, Device, Alert, StatsOverview } from '@/types'

export const login = (data: { username: string; password: string }) => {
  return request.post('/auth/login', data)
}

export const getStatsOverview = (params?: { communityId?: number }) => {
  return request.get<StatsOverview>('/stats/overview', { params })
}

export const getCommunities = () => {
  return request.get<Community[]>('/communities')
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

export const getElderlies = (params?: { page?: number; size?: number; name?: string; communityId?: number; status?: string }) => {
  return request.get<{ records: Elderly[]; total: number; page: number; size: number }>('/elderly', { params })
}

export const createElderly = (data: Omit<Elderly, 'id' | 'device' | 'deviceId' | 'deviceName' | 'status' | 'createdAt'>) => {
  return request.post('/elderly', data)
}

export const updateElderly = (id: number, data: Partial<Omit<Elderly, 'id' | 'device' | 'deviceId' | 'deviceName' | 'createdAt'>>) => {
  return request.put(`/elderly/${id}`, data)
}

export const deleteElderly = (id: number) => {
  return request.delete(`/elderly/${id}`)
}

export const getUsers = (params?: { page?: number; size?: number; communityId?: number; role?: string }) => {
  return request.get<{ records: User[]; total: number; page: number; size: number }>('/users', { params })
}

export const createUser = (data: Omit<User, 'id' | 'status' | 'createdAt'>) => {
  return request.post('/users', data)
}

export const updateUser = (id: number, data: Partial<Omit<User, 'id' | 'username' | 'status' | 'createdAt'>>) => {
  return request.put(`/users/${id}`, data)
}

export const deleteUser = (id: number) => {
  return request.delete(`/users/${id}`)
}

export const getDevices = (params?: { page?: number; size?: number; communityId?: number; elderlyId?: number; status?: string }) => {
  return request.get<{ records: Device[]; total: number; page: number; size: number }>('/devices', { params })
}

export const bindDevice = (id: number, data: { elderlyId: number | null }) => {
  return request.post(`/devices/${id}/bind`, data)
}

export const unbindDevice = (id: number) => {
  return request.post(`/devices/${id}/unbind`)
}

export const getAlerts = (params?: { page?: number; size?: number; communityId?: number; status?: string; type?: string }) => {
  return request.get<{ records: Alert[]; total: number; page: number; size: number }>('/alerts', { params })
}

export const updateAlert = (id: number, data: Partial<Pick<Alert, 'status' | 'cause' | 'details'>>) => {
  return request.patch(`/alerts/${id}`, data)
}