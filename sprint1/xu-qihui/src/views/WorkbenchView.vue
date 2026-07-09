<template>
  <div class="page-stack">
    <section class="metric-grid">
      <article class="metric-card danger">
        <span>待处理</span>
        <strong>{{ pendingTotal }}</strong>
      </article>
      <article class="metric-card warning">
        <span>处理中</span>
        <strong>{{ processingTotal }}</strong>
      </article>
      <article class="metric-card success">
        <span>已解决</span>
        <strong>{{ resolvedTotal }}</strong>
      </article>
      <article class="metric-card neutral">
        <span>今日告警</span>
        <strong>{{ todayTotal }}</strong>
      </article>
    </section>

    <section class="section-block">
      <div class="section-heading">
        <div>
          <p class="top-eyebrow">PENDING</p>
          <h2>最新待处理告警</h2>
        </div>
        <div class="header-actions">
          <el-button type="primary" plain @click="loadDashboard">
            <RefreshCw :size="16" />
            刷新
          </el-button>
          <el-button type="primary" plain @click="router.push('/worker/alerts')">
            <ListChecks :size="16" />
            全部告警
          </el-button>
        </div>
      </div>

      <el-skeleton v-if="loading" :rows="5" animated />
      <el-empty v-else-if="pendingAlerts.length === 0" description="暂无待处理告警" />
      <div v-else class="alert-card-grid">
        <article
          v-for="alert in pendingAlerts"
          :key="alert.id"
          class="alert-card"
          @click="router.push(`/worker/alerts/${alert.id}`)"
        >
          <div class="alert-card-head">
            <span :class="['type-pill', alertTypeTone[alert.type]]">{{ alert.typeName }}</span>
            <el-tag :type="alertStatusTag[alert.status]" effect="light">
              {{ alert.statusName }}
            </el-tag>
          </div>
          <h3>{{ alert.elderlyName }}</h3>
          <p>{{ alert.communityName }} · {{ formatDateTime(alert.happenedAt) }}</p>
          <div class="alert-card-foot">
            <span>优先级 {{ priorityText[alert.priority] }}</span>
            <ArrowRight :size="16" />
          </div>
        </article>
      </div>
    </section>
  </div>
</template>

<script setup lang="ts">
import { ArrowRight, ListChecks, RefreshCw } from 'lucide-vue-next'
import { onMounted, onUnmounted, ref } from 'vue'
import { useRouter } from 'vue-router'

import { getAlerts } from '@/api/alerts'
import type { AlertRecord } from '@/types/api'
import { alertStatusTag, alertTypeTone, formatDateTime, priorityText } from '@/utils/labels'

const router = useRouter()
const loading = ref(false)
const pendingAlerts = ref<AlertRecord[]>([])
const pendingTotal = ref(0)
const processingTotal = ref(0)
const resolvedTotal = ref(0)
const todayTotal = ref(0)

async function loadDashboard() {
  loading.value = true
  try {
    const [pending, processing, resolved, all] = await Promise.all([
      getAlerts({ status: 'PENDING', page: 1, size: 5 }),
      getAlerts({ status: 'PROCESSING', page: 1, size: 1 }),
      getAlerts({ status: 'RESOLVED', page: 1, size: 1 }),
      getAlerts({ page: 1, size: 100 }),
    ])
    pendingAlerts.value = pending.records
    pendingTotal.value = pending.total
    processingTotal.value = processing.total
    resolvedTotal.value = resolved.total
    todayTotal.value = all.total
  } finally {
    loading.value = false
  }
}

onMounted(() => {
  loadDashboard()
  router.afterEach((to) => {
    if (to.path === '/worker/workbench') {
      loadDashboard()
    }
  })
})

onUnmounted(() => {
})
</script>