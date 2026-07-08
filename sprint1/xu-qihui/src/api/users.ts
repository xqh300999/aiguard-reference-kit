import request from '@/utils/request'
import type { User, PageResult } from '@/types/api'

export const getUsers = (params?: { page?: number; size?: number; communityId?: number; role?: string }): Promise<PageResult<User>> => {
  return request.get('/users', { params })
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