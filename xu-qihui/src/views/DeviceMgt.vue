<template>
  <div class="page-stack">
    <section class="section-block">
      <header class="section-heading">
        <h2>设备管理</h2>
      </header>
      <el-form :inline="true" :model="searchForm" class="search-form">
        <el-form-item label="社区">
          <el-select v-model="searchForm.communityId" placeholder="请选择社区" style="width: 200px" @change="fetchData">
            <el-option v-for="c in communities" :key="c.id" :label="c.name" :value="c.id" />
          </el-select>
        </el-form-item>
        <el-form-item label="状态">
          <el-select v-model="searchForm.status" placeholder="请选择状态" style="width: 150px">
            <el-option label="全部" value="" />
            <el-option label="在线" value="ONLINE" />
            <el-option label="离线" value="OFFLINE" />
          </el-select>
        </el-form-item>
        <el-form-item>
          <el-button type="primary" @click="fetchData">搜索</el-button>
          <el-button @click="resetSearch">重置</el-button>
        </el-form-item>
      </el-form>
      <el-table :data="tableData" class="work-table" border>
        <el-table-column prop="id" label="ID" width="80" />
        <el-table-column prop="name" label="名称" />
        <el-table-column prop="type" label="类型" width="100">
          <template #default="scope">
            <el-tag>{{ getTypeText(scope.row.type) }}</el-tag>
          </template>
        </el-table-column>
        <el-table-column prop="mac" label="MAC地址" />
        <el-table-column prop="communityName" label="社区" />
        <el-table-column prop="elderlyName" label="绑定老人" />
        <el-table-column prop="status" label="状态" width="100">
          <template #default="scope">
            <el-tag :type="scope.row.status === 'ONLINE' ? 'success' : 'danger'">{{ scope.row.status === 'ONLINE' ? '在线' : '离线' }}</el-tag>
          </template>
        </el-table-column>
        <el-table-column prop="battery" label="电量" width="80">
          <template #default="scope">
            <span v-if="scope.row.battery">{{ scope.row.battery }}%</span>
            <span v-else>-</span>
          </template>
        </el-table-column>
        <el-table-column prop="lastHeartbeat" label="心跳时间" width="180" />
        <el-table-column label="操作" width="150">
          <template #default="scope">
            <el-button size="small" @click="openBindModal(scope.row)">绑定</el-button>
            <el-button v-if="scope.row.elderlyId" size="small" type="warning" @click="handleUnbind(scope.row)">解绑</el-button>
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
    <el-dialog title="绑定老人" v-model="bindDialogVisible" width="400px">
      <el-form :model="bindForm" ref="bindFormRef" label-width="100px">
        <el-form-item label="老人">
          <el-select v-model="bindForm.elderlyId" placeholder="请选择老人">
            <el-option v-for="e in availableElderlies" :key="e.id" :label="e.name" :value="e.id" />
          </el-select>
        </el-form-item>
      </el-form>
      <template #footer>
        <el-button @click="bindDialogVisible = false">取消</el-button>
        <el-button type="primary" :loading="loading" @click="handleBind">确定</el-button>
      </template>
    </el-dialog>
  </div>
</template>

<script setup lang="ts">
import { ref, reactive, onMounted } from 'vue'
import { ElMessage, ElMessageBox } from 'element-plus'
import type { FormInstance } from 'element-plus'
import { getDevices, bindDevice, unbindDevice, getCommunities, getElderlies } from '@/api'
import type { Device, Community, Elderly } from '@/types'

const tableData = ref<Device[]>([])
const communities = ref<Community[]>([])
const availableElderlies = ref<Elderly[]>([])
const total = ref(0)
const page = ref(1)
const size = ref(10)
const bindDialogVisible = ref(false)
const loading = ref(false)
const bindFormRef = ref<FormInstance>()
const currentDevice = ref<Device | null>(null)

const searchForm = reactive({
  communityId: '',
  status: ''
})

const bindForm = reactive({
  elderlyId: 0
})

const getTypeText = (type: Device['type']) => {
  const texts: Record<Device['type'], string> = {
    WATCH: '手表',
    PANEL: '大屏',
    GATEWAY: '网关'
  }
  return texts[type]
}

const fetchData = async () => {
  try {
    const data = await getDevices({
      page: page.value,
      size: size.value,
      communityId: searchForm.communityId ? Number(searchForm.communityId) : undefined,
      status: searchForm.status || undefined
    })
    tableData.value = data.records
    total.value = data.total
  } catch {
    tableData.value = [
      { id: 1, name: '手表001', type: 'WATCH', mac: 'A1:B2:C3:D4:E5:F6', communityId: 1, communityName: '幸福社区', elderlyId: 1, elderlyName: '张三', status: 'ONLINE', battery: 85, lastHeartbeat: '2026-07-05T09:59:00Z', createdAt: '2026-07-01T08:00:00Z' },
      { id: 2, name: '手表002', type: 'WATCH', mac: 'A1:B2:C3:D4:E5:F7', communityId: 1, communityName: '幸福社区', elderlyId: 2, elderlyName: '李四', status: 'ONLINE', battery: 70, lastHeartbeat: '2026-07-05T09:58:00Z', createdAt: '2026-07-01T08:00:00Z' },
      { id: 3, name: '手表003', type: 'WATCH', mac: 'A1:B2:C3:D4:E5:F8', communityId: 2, communityName: '阳光社区', elderlyId: undefined, status: 'OFFLINE', battery: 20, lastHeartbeat: '2026-07-04T10:00:00Z', createdAt: '2026-07-01T08:00:00Z' },
      { id: 4, name: '大屏001', type: 'PANEL', mac: 'B1:C2:D3:E4:F5:A6', communityId: 1, communityName: '幸福社区', elderlyId: undefined, status: 'ONLINE', lastHeartbeat: '2026-07-05T09:59:00Z', createdAt: '2026-07-01T08:00:00Z' }
    ]
    total.value = 4
  }
}

const fetchCommunities = async () => {
  try {
    const data = await getCommunities()
    communities.value = data
  } catch {
    communities.value = [
      { id: 1, name: '幸福社区', address: '北京市朝阳区幸福路1号', area: '朝阳区', elderlyCount: 25, deviceCount: 12, createdAt: '2026-07-01T08:00:00Z' },
      { id: 2, name: '阳光社区', address: '北京市海淀区阳光大道2号', area: '海淀区', elderlyCount: 32, deviceCount: 18, createdAt: '2026-07-01T08:00:00Z' },
      { id: 3, name: '和谐社区', address: '北京市西城区和谐街3号', area: '西城区', elderlyCount: 18, deviceCount: 8, createdAt: '2026-07-01T08:00:00Z' },
      { id: 4, name: '平安社区', address: '北京市东城区平安巷4号', area: '东城区', elderlyCount: 45, deviceCount: 25, createdAt: '2026-07-01T08:00:00Z' }
    ]
  }
}

const fetchAvailableElderlies = async (communityId: number) => {
  try {
    const data = await getElderlies({ communityId })
    availableElderlies.value = data.records.filter((e: Elderly) => !e.deviceId)
  } catch {
    availableElderlies.value = [
      { id: 5, name: '赵六', age: 80, gender: 'MALE', communityId: communityId, status: 'ACTIVE', createdAt: '2026-07-01T08:00:00Z' },
      { id: 6, name: '孙七', age: 76, gender: 'FEMALE', communityId: communityId, status: 'ACTIVE', createdAt: '2026-07-01T08:00:00Z' }
    ]
  }
}

const openBindModal = (row: Device) => {
  currentDevice.value = row
  bindForm.elderlyId = row.elderlyId || 0
  if (row.communityId) {
    fetchAvailableElderlies(row.communityId)
  }
  bindDialogVisible.value = true
}

const handleBind = async () => {
  if (!currentDevice.value) return
  loading.value = true
  try {
    await bindDevice(currentDevice.value.id, { elderlyId: bindForm.elderlyId || null })
    ElMessage.success('绑定成功')
    bindDialogVisible.value = false
    fetchData()
  } catch {
    ElMessage.error('操作失败')
  } finally {
    loading.value = false
  }
}

const handleUnbind = async (row: Device) => {
  await ElMessageBox.confirm('确定要解绑该设备吗？', '提示', {
    type: 'warning'
  })
  try {
    await unbindDevice(row.id)
    ElMessage.success('解绑成功')
    fetchData()
  } catch {
    ElMessage.error('操作失败')
  }
}

const resetSearch = () => {
  searchForm.communityId = ''
  searchForm.status = ''
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