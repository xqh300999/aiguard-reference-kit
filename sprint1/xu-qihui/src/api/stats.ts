import request from '@/utils/request'
import type { StatsOverview, AlertTrendStats, CareStats } from '@/types/api'

export const getStatsOverview = (communityId: number): Promise<StatsOverview> => {
  return request.get(`/stats/overview/${communityId}`)
}

export const getAlertTrend = (
  communityId: number,
  params?: { period?: 'daily' | 'weekly' | 'monthly' }
): Promise<AlertTrendStats> => {
  return request.get(`/stats/alerts/${communityId}`, { params })
}

export const getCareStats = (
  communityId: number,
  params?: { period?: 'daily' | 'weekly' | 'monthly' }
): Promise<CareStats> => {
  return request.get(`/stats/care/${communityId}`, { params })
}

export const exportStatsExcel = (communityId: number): Promise<Blob> => {
  return request.get('/stats/export', {
    params: { communityId },
    responseType: 'blob'
  })
}
