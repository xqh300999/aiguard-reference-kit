import request from '@/utils/request'
import type { LoginRequest, UserSession } from '@/types/api'

export function loginApi(payload: LoginRequest) {
  return request.post<UserSession>('/auth/login', payload)
}
