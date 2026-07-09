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

    <section class="section-block">
      <div class="section-heading">
        <div>
          <p class="top-eyebrow">STATS</p>
          <h2>统计报表</h2>
        </div>
        <div class="stats-toolbar">
          <el-select v-model="selectedCommunityId" placeholder="选择社区" style="width: 180px" @change="loadStats">
            <el-option v-for="item in communities" :key="item.id" :label="item.name" :value="item.id" />
          </el-select>
          <el-segmented v-model="period" :options="periodOptions" @change="loadStats" />
          <el-button type="primary" :loading="exporting" @click="handleExport">导出 Excel</el-button>
        </div>
      </div>

      <div class="stats-grid">
        <article class="stats-panel">
          <h3>告警统计趋势</h3>
          <div v-for="item in alertTrend" :key="item.label" class="trend-row">
            <span>{{ item.label }}</span>
            <div class="trend-track">
              <i :style="{ width: `${getAlertPercent(item.total)}%` }"></i>
            </div>
            <strong>{{ item.total }}</strong>
          </div>
        </article>

        <article class="stats-panel">
          <h3>关怀统计</h3>
          <div class="care-summary">
            <div>
              <span>计划数</span>
              <strong>{{ careStats.totalPlans }}</strong>
            </div>
            <div>
              <span>完成记录</span>
              <strong>{{ careStats.completedLogs }}</strong>
            </div>
            <div>
              <span>完成率</span>
              <strong>{{ careStats.completionRate }}%</strong>
            </div>
          </div>
          <el-table :data="careStats.records" size="small" class="work-table">
            <el-table-column prop="label" label="周期" />
            <el-table-column prop="phone" label="电话" />
            <el-table-column prop="visit" label="走访" />
            <el-table-column prop="medicine" label="用药" />
            <el-table-column prop="total" label="合计" />
          </el-table>
        </article>
      </div>
    </section>
  </div>
</template>

<script setup lang="ts">
import { ElMessage } from 'element-plus'
import { computed, onMounted, ref } from 'vue'

import { exportStatsExcel, getAlertStatsTrend, getCareStats, getCommunities, getStatsOverview } from '@/api'
import type { AlertStatsTrendPoint, CareStats, Community, StatsOverview, StatsPeriod } from '@/types/api'

const stats = ref<StatsOverview>({
  totalElderly: 0,
  todayAlerts: 0,
  onlineDevices: 0,
  pendingAlerts: 0,
})
const communities = ref<Community[]>([])
const selectedCommunityId = ref(1)
const period = ref<StatsPeriod>('weekly')
const alertTrend = ref<AlertStatsTrendPoint[]>([])
const careStats = ref<CareStats>({
  totalPlans: 0,
  completedLogs: 0,
  completionRate: 0,
  records: [],
})
const exporting = ref(false)

const periodOptions = [
  { label: '按天', value: 'daily' },
  { label: '按周', value: 'weekly' },
  { label: '按月', value: 'monthly' },
]

const maxAlertTotal = computed(() => Math.max(...alertTrend.value.map((item) => item.total), 1))

function getAlertPercent(total: number) {
  return Math.max(8, Math.round((total / maxAlertTotal.value) * 100))
}

async function loadCommunities() {
  communities.value = await getCommunities()
  if (!communities.value.some((item) => item.id === selectedCommunityId.value)) {
    selectedCommunityId.value = communities.value[0]?.id || 1
  }
}

async function loadStats() {
  const communityId = selectedCommunityId.value
  const [overview, trend, care] = await Promise.all([
    getStatsOverview({ communityId }),
    getAlertStatsTrend(communityId, period.value),
    getCareStats(communityId, period.value),
  ])
  stats.value = overview
  alertTrend.value = trend
  careStats.value = care
}

async function handleExport() {
  exporting.value = true
  try {
    const blob = await exportStatsExcel(selectedCommunityId.value)
    const url = URL.createObjectURL(blob)
    const link = document.createElement('a')
    link.href = url
    link.download = `AiGuard-统计报表-${selectedCommunityId.value}.xls`
    link.click()
    URL.revokeObjectURL(url)
    ElMessage.success('导出成功')
  } finally {
    exporting.value = false
  }
}

onMounted(async () => {
  await loadCommunities()
  await loadStats()
})
</script>
