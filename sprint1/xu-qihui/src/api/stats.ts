import request from '@/utils/request'
import type { StatsOverview } from '@/types/api'

export const getStatsOverview = (params?: { communityId?: number }): Promise<StatsOverview> => {
  return request.get('/stats/overview', { params })
}