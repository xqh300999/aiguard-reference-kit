const STORAGE_KEY = 'zhishou_mock_data'

interface PersistedData {
  users: any[]
  systemUsers: any[]
  communities: any[]
  elderlies: any[]
  devices: any[]
  alerts: any[]
  dispatches: any[]
}

const defaultData: PersistedData = {
  users: [],
  systemUsers: [],
  communities: [],
  elderlies: [],
  devices: [],
  alerts: [],
  dispatches: [],
}

export function loadPersistedData(): PersistedData {
  try {
    const stored = localStorage.getItem(STORAGE_KEY)
    if (stored) {
      return JSON.parse(stored)
    }
  } catch {
  }
  return defaultData
}

export function savePersistedData(data: PersistedData): void {
  try {
    localStorage.setItem(STORAGE_KEY, JSON.stringify(data))
  } catch {
  }
}

export function clearPersistedData(): void {
  try {
    localStorage.removeItem(STORAGE_KEY)
  } catch {
  }
}
