import { defineStore } from 'pinia'

import { loginApi } from '@/api/auth'
import type { LoginRequest, UserSession } from '@/types/api'

const STORAGE_KEY = 'aiguard-auth'
const TOKEN_KEY = 'aiguard-token'

function readStoredSession(): UserSession | null {
  const raw = localStorage.getItem(STORAGE_KEY)
  if (!raw) return null

  try {
    return JSON.parse(raw) as UserSession
  } catch {
    localStorage.removeItem(STORAGE_KEY)
    localStorage.removeItem(TOKEN_KEY)
    return null
  }
}

export const useAuthStore = defineStore('auth', {
  state: () => ({
    session: readStoredSession() as UserSession | null,
  }),
  getters: {
    isLoggedIn: (state) => Boolean(state.session?.token),
    token: (state) => state.session?.token ?? '',
    userId: (state) => state.session?.userId ?? 0,
    realName: (state) => state.session?.realName ?? '',
    role: (state) => state.session?.role ?? '',
    communityId: (state) => state.session?.communityId,
  },
  actions: {
    async login(payload: LoginRequest) {
      const session = await loginApi(payload)
      this.session = session
      localStorage.setItem(STORAGE_KEY, JSON.stringify(session))
      localStorage.setItem(TOKEN_KEY, session.token)
      return session
    },
    logout() {
      this.session = null
      localStorage.removeItem(STORAGE_KEY)
      localStorage.removeItem(TOKEN_KEY)
    },
  },
})
