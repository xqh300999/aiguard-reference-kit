import request from '@/utils/request'
import type { AlertStatsTrendPoint, CareStats, StatsOverview, StatsPeriod } from '@/types/api'

export const getStatsOverview = (params?: { communityId?: number }): Promise<StatsOverview> => {
  return request.get('/stats/overview', { params })
}

export const getAlertStatsTrend = (
  communityId: number,
  period: StatsPeriod = 'weekly',
): Promise<AlertStatsTrendPoint[]> => {
  return request.get(`/stats/alerts/${communityId}`, { params: { period } })
}

export const getCareStats = (
  communityId: number,
  period: StatsPeriod = 'weekly',
): Promise<CareStats> => {
  return request.get(`/stats/care/${communityId}`, { params: { period } })
}

export const exportStatsExcel = (communityId: number): Promise<Blob> => {
  return request.download('/stats/export', { communityId })
}
