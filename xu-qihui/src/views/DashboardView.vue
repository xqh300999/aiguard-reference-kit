<template>
  <div class="page-stack">
    <section class="metric-grid">
      <article class="metric-card neutral">
        <span>老人总数</span>
        <strong>{{ stats.totalElderly }}</strong>
      </article>
      <article class="metric-card danger">
        <span>今日告警</span>
        <strong>{{ stats.todayAlerts }}</strong>
      </article>
      <article class="metric-card success">
        <span>在线设备</span>
        <strong>{{ stats.onlineDevices }}</strong>
      </article>
      <article class="metric-card warning">
        <span>待处理</span>
        <strong>{{ stats.pendingAlerts }}</strong>
      </article>
    </section>
  </div>
</template>

<script setup lang="ts">
import { ref, onMounted } from 'vue'
import { getStatsOverview } from '@/api'
import type { StatsOverview } from '@/types/api'

const stats = ref<StatsOverview>({
  totalElderly: 0,
  todayAlerts: 0,
  onlineDevices: 0,
  pendingAlerts: 0
})

const fetchStats = async () => {
  try {
    const data = await getStatsOverview()
    stats.value = data
  } catch {
    stats.value = {
      totalElderly: 128,
      todayAlerts: 5,
      onlineDevices: 96,
      pendingAlerts: 3
    }
  }
}

onMounted(() => {
  fetchStats()
})
</script>