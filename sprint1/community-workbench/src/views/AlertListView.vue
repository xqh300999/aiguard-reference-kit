<template>
  <div class="page-stack">
    <section class="section-block">
      <div class="section-heading">
        <div>
          <p class="top-eyebrow">ALERTS</p>
          <h2>告警列表</h2>
        </div>
        <el-button :loading="loading" @click="loadAlerts">
          <RefreshCw :size="16" />
          刷新
        </el-button>
      </div>

      <el-tabs v-model="activeStatus" @tab-change="handleTabChange">
        <el-tab-pane label="全部" name="ALL" />
        <el-tab-pane label="待处理" name="PENDING" />
        <el-tab-pane label="处理中" name="PROCESSING" />
        <el-tab-pane label="已解决" name="RESOLVED" />
      </el-tabs>

      <el-table v-loading="loading" :data="records" row-key="id" class="work-table">
        <el-table-column label="类型" min-width="150">
          <template #default="{ row }: { row: AlertRecord }">
            <span :class="['type-pill', alertTypeTone[row.type]]">{{ row.typeName }}</span>
          </template>
        </el-table-column>
        <el-table-column prop="elderlyName" label="老人" min-width="120" />
        <el-table-column prop="communityName" label="社区" min-width="120" />
        <el-table-column label="状态" min-width="120">
          <template #default="{ row }: { row: AlertRecord }">
            <el-tag :type="alertStatusTag[row.status]" effect="light">
              {{ row.statusName }}
            </el-tag>
          </template>
        </el-table-column>
        <el-table-column label="优先级" min-width="100">
          <template #default="{ row }: { row: AlertRecord }">
            {{ priorityText[row.priority] }}
          </template>
        </el-table-column>
        <el-table-column label="发生时间" min-width="160">
          <template #default="{ row }: { row: AlertRecord }">
            {{ formatDateTime(row.happenedAt) }}
          </template>
        </el-table-column>
        <el-table-column label="处理人" min-width="120">
          <template #default="{ row }: { row: AlertRecord }">
            {{ row.handlerName || '-' }}
          </template>
        </el-table-column>
        <el-table-column label="操作" width="120" fixed="right">
          <template #default="{ row }: { row: AlertRecord }">
            <el-button type="primary" link @click="router.push(`/worker/alerts/${row.id}`)">
              查看
            </el-button>
          </template>
        </el-table-column>
      </el-table>

      <div class="pagination-row">
        <el-pagination
          v-model:current-page="page"
          v-model:page-size="size"
          background
          layout="total, prev, pager, next"
          :total="total"
          @current-change="loadAlerts"
        />
      </div>
    </section>
  </div>
</template>

<script setup lang="ts">
import { RefreshCw } from 'lucide-vue-next'
import { onMounted, ref } from 'vue'
import { useRouter } from 'vue-router'

import { getAlertsApi } from '@/api/alert'
import type { AlertRecord, AlertStatus } from '@/types/api'
import { alertStatusTag, alertTypeTone, formatDateTime, priorityText } from '@/utils/labels'

type StatusTab = AlertStatus | 'ALL'

const router = useRouter()
const loading = ref(false)
const activeStatus = ref<StatusTab>('ALL')
const records = ref<AlertRecord[]>([])
const page = ref(1)
const size = ref(5)
const total = ref(0)

async function loadAlerts() {
  loading.value = true
  try {
    const status = activeStatus.value === 'ALL' ? undefined : activeStatus.value
    const result = await getAlertsApi({ status, page: page.value, size: size.value })
    records.value = result.records
    total.value = result.total
  } finally {
    loading.value = false
  }
}

function handleTabChange() {
  page.value = 1
  loadAlerts()
}

onMounted(loadAlerts)
</script>
