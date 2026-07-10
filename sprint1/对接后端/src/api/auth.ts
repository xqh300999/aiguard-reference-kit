import request from '@/utils/request'
import type { LoginRequest, UserSession } from '@/types/api'

export const login = (data: LoginRequest): Promise<UserSession> => {
  return request.post('/auth/login', data)
}

export const register = (data: { username: string; password: string; realName: string; phone: string; role: string; communityId: number }): Promise<void> => {
  return request.post('/web/auth/register', data)
}

export const getProfile = (): Promise<UserSession> => {
  return request.get('/auth/profile')
}
