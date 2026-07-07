import type { ElderlySummary } from '@/types/api'
import request from '@/utils/request'

export function getElderlyDetailApi(id: number) {
  return request.get<ElderlySummary>(`/elderly/${id}`)
}
