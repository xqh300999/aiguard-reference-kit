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
        <el-tab-pane label="待处理" name="PENDING" />
        <el-tab-pane label="处理中" name="PROCESSING" />
        <el-tab-pane label="已解决" name="RESOLVED" />
        <el-tab-pane label="全部" name="ALL" />
      </el-tabs>

      <el-table v-loading="loading" :data="records" row-key="id" class="work-table">
        <el-table-column label="类型" min-width="140">
          <template #default="{ row }: { row: AlertRecord }">
            <span :class="['type-pill', alertTypeTone[row.type]]">{{ row.typeName }}</span>
          </template>
        </el-table-column>
        <el-table-column prop="elderlyName" label="老人" min-width="110" />
        <el-table-column prop="communityName" label="社区" min-width="120" />
        <el-table-column label="时间" min-width="170">
          <template #default="{ row }: { row: AlertRecord }">
            {{ formatDateTime(row.happenedAt) }}
          </template>
        </el-table-column>
        <el-table-column label="状态" min-width="110">
          <template #default="{ row }: { row: AlertRecord }">
            <el-tag :type="alertStatusTag[row.status]" effect="light">
              {{ row.statusName }}
            </el-tag>
          </template>
        </el-table-column>
        <el-table-column label="优先级" min-width="90">
          <template #default="{ row }: { row: AlertRecord }">
            {{ priorityText[row.priority] }}
          </template>
        </el-table-column>
        <el-table-column label="操作" width="110" fixed="right">
          <template #default="{ row }: { row: AlertRecord }">
            <el-button type="primary" link @click="goDetail(row.id)">查看详情</el-button>
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
import { useRoute, useRouter } from 'vue-router'

import { getAlerts } from '@/api/alerts'
import type { AlertRecord, AlertStatus } from '@/types/api'
import { alertStatusTag, alertTypeTone, formatDateTime, priorityText } from '@/utils/labels'

type StatusTab = AlertStatus | 'ALL'

const route = useRoute()
const router = useRouter()
const loading = ref(false)
const activeStatus = ref<StatusTab>('PENDING')
const records = ref<AlertRecord[]>([])
const page = ref(1)
const size = ref(10)
const total = ref(0)

async function loadAlerts() {
  loading.value = true
  try {
    const status = activeStatus.value === 'ALL' ? undefined : activeStatus.value
    const data = await getAlerts({ status, page: page.value, size: size.value })
    records.value = data.records
    total.value = data.total
  } finally {
    loading.value = false
  }
}

function handleTabChange() {
  page.value = 1
  loadAlerts()
}

function goDetail(id: number) {
  router.push(route.path.startsWith('/alerts') ? `/alerts/${id}` : `/worker/alerts/${id}`)
}

onMounted(loadAlerts)
</script>
