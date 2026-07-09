<template>
  <div class="page-stack">
    <section class="section-block">
      <header class="section-heading">
        <h2>告警管理</h2>
      </header>
      <el-form :inline="true" :model="searchForm" class="search-form">
        <el-form-item label="状态">
          <el-select v-model="searchForm.status" placeholder="请选择状态" style="width: 150px">
            <el-option label="全部" value="" />
            <el-option label="待处理" value="PENDING" />
            <el-option label="处理中" value="PROCESSING" />
            <el-option label="已解决" value="RESOLVED" />
            <el-option label="需送医" value="NEED_HOSPITAL" />
          </el-select>
        </el-form-item>
        <el-form-item label="类型">
          <el-select v-model="searchForm.type" placeholder="请选择类型" style="width: 150px">
            <el-option label="全部" value="" />
            <el-option label="SOS" value="SOS" />
            <el-option label="跌倒" value="FALL" />
            <el-option label="长时间未活动" value="INACTIVITY" />
            <el-option label="低电量" value="LOW_BATTERY" />
            <el-option label="设备离线" value="DEVICE_OFFLINE" />
            <el-option label="异常" value="ABNORMAL" />
          </el-select>
        </el-form-item>
        <el-form-item label="社区">
          <el-select v-model="searchForm.communityId" placeholder="请选择社区" style="width: 200px">
            <el-option label="全部" value="" />
            <el-option v-for="c in communities" :key="c.id" :label="c.name" :value="c.id" />
          </el-select>
        </el-form-item>
        <el-form-item>
          <el-button type="primary" @click="fetchData">搜索</el-button>
          <el-button @click="resetSearch">重置</el-button>
        </el-form-item>
      </el-form>
      <el-table :data="tableData" class="work-table" border>
        <el-table-column prop="id" label="ID" width="80" />
        <el-table-column label="类型" width="120">
          <template #default="scope">
            <span :class="['type-pill', getTypeClass(scope.row.type)]">{{ scope.row.typeName || getTypeText(scope.row.type) }}</span>
          </template>
        </el-table-column>
        <el-table-column prop="elderlyName" label="老人姓名" />
        <el-table-column prop="communityName" label="社区" />
        <el-table-column prop="status" label="状态" width="100">
          <template #default="scope">
            <el-tag :type="getStatusTag(scope.row.status)">{{ scope.row.statusName || getStatusText(scope.row.status) }}</el-tag>
          </template>
        </el-table-column>
        <el-table-column prop="priority" label="优先级" width="100">
          <template #default="scope">
            <el-tag v-if="scope.row.priority" :type="getPriorityTag(scope.row.priority)">{{ scope.row.priority }}</el-tag>
          </template>
        </el-table-column>
        <el-table-column prop="handlerName" label="处理人" width="100" />
        <el-table-column prop="happenedAt" label="发生时间" width="180" />
        <el-table-column label="操作" width="200">
          <template #default="scope">
            <el-button v-if="scope.row.status === 'PENDING'" size="small" type="primary" @click="handleUpdateStatus(scope.row, 'PROCESSING')">处理中</el-button>
            <el-button v-if="scope.row.status === 'PROCESSING'" size="small" type="success" @click="handleUpdateStatus(scope.row, 'RESOLVED')">已解决</el-button>
            <el-button v-if="scope.row.status === 'PROCESSING'" size="small" type="danger" @click="handleUpdateStatus(scope.row, 'NEED_HOSPITAL')">需送医</el-button>
          </template>
        </el-table-column>
      </el-table>
      <div class="pagination-row">
        <el-pagination
          @size-change="handleSizeChange"
          @current-change="handleCurrentChange"
          :current-page="page"
          :page-sizes="[10, 20, 50]"
          :page-size="size"
          :total="total"
          layout="total, sizes, prev, pager, next, jumper"
        />
      </div>
    </section>
  </div>
</template>

<script setup lang="ts">
import { ref, reactive, onMounted } from 'vue'
import { ElMessage } from 'element-plus'
import { getAlerts, updateAlert, getCommunities } from '@/api'
import type { AlertRecord as Alert, Community } from '@/types/api'

const tableData = ref<Alert[]>([])
const communities = ref<Community[]>([])
const total = ref(0)
const page = ref(1)
const size = ref(10)

const searchForm = reactive({
  status: '' as '',
  type: '' as '',
  communityId: '' as ''
})

const getTypeText = (type: Alert['type']) => {
  const texts: Record<Alert['type'], string> = {
    SOS: '紧急求助',
    FALL: '跌倒检测',
    INACTIVITY: '长时间未活动',
    LOW_BATTERY: '低电量',
    DEVICE_OFFLINE: '设备离线',
    ABNORMAL: '异常'
  }
  return texts[type]
}

const getTypeClass = (type: Alert['type']) => {
  const classes: Record<Alert['type'], string> = {
    SOS: 'type-sos',
    FALL: 'type-fall',
    INACTIVITY: 'type-inactivity',
    LOW_BATTERY: 'type-low-battery',
    DEVICE_OFFLINE: 'type-device-offline',
    ABNORMAL: 'type-abnormal'
  }
  return classes[type]
}

const getStatusText = (status: Alert['status']) => {
  const texts: Record<Alert['status'], string> = {
    PENDING: '待处理',
    PROCESSING: '处理中',
    RESOLVED: '已解决',
    NEED_HOSPITAL: '需送医'
  }
  return texts[status]
}

const getStatusTag = (status: Alert['status']) => {
  const tags: Record<Alert['status'], string> = {
    PENDING: 'warning',
    PROCESSING: 'primary',
    RESOLVED: 'success',
    NEED_HOSPITAL: 'danger'
  }
  return tags[status]
}

const getPriorityTag = (priority: Alert['priority']) => {
  if (!priority) return ''
  const tags: Record<NonNullable<Alert['priority']>, string> = {
    HIGH: 'danger',
    MEDIUM: 'warning',
    LOW: 'info'
  }
  return tags[priority]
}

const fetchData = async () => {
  try {
    const data = await getAlerts({
      page: page.value,
      size: size.value,
      status: searchForm.status || undefined,
      type: searchForm.type || undefined,
      communityId: searchForm.communityId ? Number(searchForm.communityId) : undefined
    })
    tableData.value = data.records
    total.value = data.total
  } catch {
    tableData.value = []
    total.value = 0
  }
}

const fetchCommunities = async () => {
  try {
    const data = await getCommunities()
    communities.value = data
  } catch {
    communities.value = []
  }
}

const handleUpdateStatus = async (row: Alert, status: Alert['status']) => {
  try {
    await updateAlert(row.id, { status })
    ElMessage.success('状态更新成功')
    fetchData()
  } catch {
    ElMessage.error('操作失败')
  }
}

const resetSearch = () => {
  searchForm.status = ''
  searchForm.type = ''
  searchForm.communityId = ''
  fetchData()
}

const handleSizeChange = (val: number) => {
  size.value = val
  page.value = 1
  fetchData()
}

const handleCurrentChange = (val: number) => {
  page.value = val
  fetchData()
}

onMounted(() => {
  fetchCommunities()
  fetchData()
})
</script>