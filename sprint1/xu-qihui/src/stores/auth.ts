import { defineStore } from 'pinia'
import { ref } from 'vue'
import type { UserSession } from '@/types/api'

export const useAuthStore = defineStore('auth', () => {
  const user = ref<UserSession | null>(null)
  const token = ref<string>('')

  const login = (data: UserSession) => {
    user.value = data
    token.value = data.token
    localStorage.setItem('token', data.token)
    localStorage.setItem('user', JSON.stringify(data))
  }

  const logout = () => {
    user.value = null
    token.value = ''
    localStorage.removeItem('token')
    localStorage.removeItem('user')
  }

  const init = () => {
    const savedToken = localStorage.getItem('token')
    const savedUser = localStorage.getItem('user')
    if (savedToken && savedUser) {
      token.value = savedToken
      user.value = JSON.parse(savedUser)
    }
  }

  return { user, token, login, logout, init }
})