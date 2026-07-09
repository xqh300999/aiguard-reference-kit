<template>
  <div class="page-stack">
    <section class="section-block">
      <header class="section-heading">
        <h2>功能自测面板</h2>
        <el-button type="primary" @click="runAllTests">运行全部测试</el-button>
      </header>

      <div class="test-grid">
        <el-card v-for="module in testModules" :key="module.name" class="test-card">
          <template #header>
            <span>{{ module.title }}</span>
            <span :class="['test-status', module.status]" class="status-badge">
              {{ getStatusText(module.status) }}
            </span>
          </template>
          <div class="test-items">
            <div v-for="test in module.tests" :key="test.name" class="test-item">
              <span class="test-label">{{ test.label }}</span>
              <el-button size="small" :type="test.passed ? 'success' : 'primary'" :disabled="test.passed" @click="runTest(test)">
                {{ test.passed ? '✓ 通过' : '测试' }}
              </el-button>
            </div>
          </div>
          <div v-if="module.results.length > 0" class="test-results">
            <el-alert v-for="(result, idx) in module.results" :key="idx" :type="result.success ? 'success' : 'error'" :title="result.message" show-icon :closable="false" />
          </div>
        </el-card>
      </div>

      <div class="summary-section">
        <h3>测试报告</h3>
        <el-row :gutter="20">
          <el-col :span="6">
            <div class="summary-card total">
              <span class="summary-label">总测试数</span>
              <span class="summary-value">{{ totalTests }}</span>
            </div>
          </el-col>
          <el-col :span="6">
            <div class="summary-card passed">
              <span class="summary-label">通过</span>
              <span class="summary-value">{{ passedTests }}</span>
            </div>
          </el-col>
          <el-col :span="6">
            <div class="summary-card failed">
              <span class="summary-label">失败</span>
              <span class="summary-value">{{ failedTests }}</span>
            </div>
          </el-col>
          <el-col :span="6">
            <div class="summary-card rate">
              <span class="summary-label">通过率</span>
              <span class="summary-value">{{ passRate }}%</span>
            </div>
          </el-col>
        </el-row>
      </div>
    </section>
  </div>
</template>

<script setup lang="ts">
import { reactive, computed } from 'vue'
import { ElMessage } from 'element-plus'

const testModules = reactive([
  {
    name: 'auth',
    title: '认证模块',
    status: 'pending' as 'pending' | 'running' | 'passed' | 'failed',
    tests: [
      { name: 'login', label: '用户登录', passed: false },
      { name: 'profile', label: '获取用户信息', passed: false },
    ],
    results: [] as { success: boolean; message: string }[],
  },
  {
    name: 'communities',
    title: '社区管理',
    status: 'pending' as 'pending' | 'running' | 'passed' | 'failed',
    tests: [
      { name: 'list', label: '获取社区列表', passed: false },
      { name: 'create', label: '创建社区', passed: false },
      { name: 'update', label: '更新社区', passed: false },
      { name: 'delete', label: '删除社区', passed: false },
    ],
    results: [] as { success: boolean; message: string }[],
  },
  {
    name: 'elderlies',
    title: '老人管理',
    status: 'pending' as 'pending' | 'running' | 'passed' | 'failed',
    tests: [
      { name: 'list', label: '获取老人列表', passed: false },
      { name: 'create', label: '添加老人', passed: false },
      { name: 'update', label: '更新老人', passed: false },
      { name: 'delete', label: '删除老人', passed: false },
    ],
    results: [] as { success: boolean; message: string }[],
  },
  {
    name: 'devices',
    title: '设备管理',
    status: 'pending' as 'pending' | 'running' | 'passed' | 'failed',
    tests: [
      { name: 'list', label: '获取设备列表', passed: false },
      { name: 'create', label: '添加设备', passed: false },
      { name: 'update', label: '更新设备', passed: false },
      { name: 'delete', label: '删除设备', passed: false },
    ],
    results: [] as { success: boolean; message: string }[],
  },
  {
    name: 'users',
    title: '用户管理',
    status: 'pending' as 'pending' | 'running' | 'passed' | 'failed',
    tests: [
      { name: 'list', label: '获取用户列表', passed: false },
      { name: 'create', label: '创建用户', passed: false },
      { name: 'update', label: '更新用户', passed: false },
      { name: 'delete', label: '删除用户', passed: false },
    ],
    results: [] as { success: boolean; message: string }[],
  },
  {
    name: 'alerts',
    title: '告警管理',
    status: 'pending' as 'pending' | 'running' | 'passed' | 'failed',
    tests: [
      { name: 'list', label: '获取告警列表', passed: false },
      { name: 'detail', label: '获取告警详情', passed: false },
      { name: 'dispatch', label: '创建派单', passed: false },
      { name: 'updateDispatch', label: '更新派单', passed: false },
    ],
    results: [] as { success: boolean; message: string }[],
  },
  {
    name: 'stats',
    title: '统计模块',
    status: 'pending' as 'pending' | 'running' | 'passed' | 'failed',
    tests: [
      { name: 'overview', label: '数据总览', passed: false },
    ],
    results: [] as { success: boolean; message: string }[],
  },
])

const totalTests = computed(() => testModules.reduce((sum, m) => sum + m.tests.length, 0))
const passedTests = computed(() => testModules.reduce((sum, m) => sum + m.tests.filter(t => t.passed).length, 0))
const failedTests = computed(() => totalTests.value - passedTests.value)
const passRate = computed(() => totalTests.value > 0 ? Math.round((passedTests.value / totalTests.value) * 100) : 0)

const getStatusText = (status: string) => {
  const texts: Record<string, string> = {
    pending: '未测试',
    running: '测试中',
    passed: '通过',
    failed: '失败',
  }
  return texts[status]
}

const runAllTests = async () => {
  for (const module of testModules) {
    module.status = 'running'
    module.results = []
    module.tests.forEach(t => t.passed = false)

    for (const test of module.tests) {
      await runTest(test)
      await new Promise(resolve => setTimeout(resolve, 100))
    }

    module.status = module.tests.every(t => t.passed) ? 'passed' : 'failed'
  }

  if (passRate.value === 100) {
    ElMessage.success('所有测试通过！')
  } else {
    ElMessage.warning(`测试完成，通过率 ${passRate.value}%`)
  }
}

const runTest = async (test: { name: string; label: string; passed: boolean }) => {
  const module = testModules.find(m => m.tests.includes(test))
  if (!module) return

  try {
    await executeTest(module.name, test.name)
    test.passed = true
    module.results.push({ success: true, message: `${test.label} - 通过` })
  } catch (error: any) {
    test.passed = false
    module.results.push({ success: false, message: `${test.label} - ${error.message || '未知错误'}` })
  }

  module.status = module.tests.every(t => t.passed) ? 'passed' : 'failed'
}

let testData: Record<string, any> = {}

const executeTest = async (module: string, test: string) => {
  const api = await import('@/api')
  const authStore = await import('@/stores/auth')

  switch (module) {
    case 'auth':
      if (test === 'login') {
        const result = await api.login({ username: 'worker', password: 'worker123' })
        if (!result.token) throw new Error('登录失败')
        authStore.useAuthStore().login(result)
      } else if (test === 'profile') {
        const profile = await api.getProfile()
        if (!profile.userId) throw new Error('获取用户信息失败')
      }
      break

    case 'communities':
      if (test === 'list') {
        const list = await api.getCommunities()
        if (!Array.isArray(list)) throw new Error('返回格式错误')
      } else if (test === 'create') {
        const community: any = await api.createCommunity({ name: '测试社区', address: '测试地址', area: '测试区' })
        if (!community.id) throw new Error('创建失败')
        testData['communityId'] = community.id
      } else if (test === 'update') {
        const updated: any = await api.updateCommunity(testData['communityId'], { name: '更新社区', address: '更新地址', area: '更新区' })
        if (updated.name !== '更新社区') throw new Error('更新失败')
      } else if (test === 'delete') {
        await api.deleteCommunity(testData['communityId'])
      }
      break

    case 'elderlies':
      if (test === 'list') {
        const list = await api.getElderlies({ page: 1, size: 10 })
        if (!list.records) throw new Error('返回格式错误')
      } else if (test === 'create') {
        const elderly: any = await api.createElderly({ name: '测试老人', age: 75, gender: 'MALE', phone: '13800138000', communityId: 1, emergencyContact: '测试联系人', healthNotes: '健康备注' })
        if (!elderly.id) throw new Error('创建失败')
        testData['elderlyId'] = elderly.id
      } else if (test === 'update') {
        const updated: any = await api.updateElderly(testData['elderlyId'], { name: '更新老人', age: 76 })
        if (updated.name !== '更新老人') throw new Error('更新失败')
      } else if (test === 'delete') {
        await api.deleteElderly(testData['elderlyId'])
      }
      break

    case 'devices':
      if (test === 'list') {
        const list = await api.getDevices({ page: 1, size: 10 })
        if (!list.records) throw new Error('返回格式错误')
      } else if (test === 'create') {
        const device: any = await api.createDevice({ name: '测试设备', type: 'WATCH', mac: 'AA:BB:CC:DD:EE:FF', communityId: 1 })
        if (!device.id) throw new Error('创建失败')
        testData['deviceId'] = device.id
      } else if (test === 'update') {
        const updated: any = await api.updateDevice(testData['deviceId'], { name: '更新设备' })
        if (updated.name !== '更新设备') throw new Error('更新失败')
      } else if (test === 'delete') {
        await api.deleteDevice(testData['deviceId'])
      }
      break

    case 'users':
      if (test === 'list') {
        const list = await api.getUsers({ page: 1, size: 10 })
        if (!list.records) throw new Error('返回格式错误')
      } else if (test === 'create') {
        const user: any = await api.createUser({ username: 'testuser', password: 'test123', realName: '测试用户', phone: '13800138000', role: 'WORKER', communityId: 1 })
        if (!user.id) throw new Error('创建失败')
        testData['userId'] = user.id
      } else if (test === 'update') {
        const updated: any = await api.updateUser(testData['userId'], { realName: '更新用户' })
        if (updated.realName !== '更新用户') throw new Error('更新失败')
      } else if (test === 'delete') {
        await api.deleteUser(testData['userId'])
      }
      break

    case 'alerts':
      if (test === 'list') {
        const list = await api.getAlerts({ page: 1, size: 10 })
        if (!list.records) throw new Error('返回格式错误')
      } else if (test === 'detail') {
        const detail = await api.getAlertDetail(1001)
        if (!detail.id) throw new Error('获取详情失败')
      } else if (test === 'dispatch') {
        const dispatch = await api.createDispatch({ alertId: 1001, handlerId: 2 })
        if (!dispatch.id) throw new Error('创建派单失败')
        testData['dispatchId'] = dispatch.id
      } else if (test === 'updateDispatch') {
        const updated = await api.updateDispatch(testData['dispatchId'], { result: 'RESOLVED', description: '测试处理' })
        if (updated.status !== 'COMPLETED') throw new Error('更新派单失败')
      }
      break

    case 'stats':
      if (test === 'overview') {
        const overview = await api.getStatsOverview(1)
        if (overview.totalElderly === undefined) throw new Error('返回格式错误')
      }
      break
  }
}
</script>

<style scoped>
.test-grid {
  display: grid;
  grid-template-columns: repeat(auto-fit, minmax(300px, 1fr));
  gap: 16px;
  margin-bottom: 24px;
}

.test-card {
  .status-badge {
    float: right;
    font-size: 12px;
    padding: 2px 8px;
    border-radius: 4px;
  }
}

.test-status {
  &.pending { background: #f5f5f5; color: #999; }
  &.running { background: #e6f7ff; color: #1890ff; }
  &.passed { background: #f6ffed; color: #52c41a; }
  &.failed { background: #fff2f0; color: #ff4d4f; }
}

.test-items {
  margin-top: 12px;
}

.test-item {
  display: flex;
  justify-content: space-between;
  align-items: center;
  margin-bottom: 8px;
}

.test-label {
  flex: 1;
}

.test-results {
  margin-top: 12px;
  max-height: 200px;
  overflow-y: auto;
}

.summary-section {
  margin-top: 24px;
}

.summary-section h3 {
  margin-bottom: 16px;
}

.summary-card {
  padding: 16px;
  text-align: center;
  border-radius: 8px;
  
  .summary-label {
    display: block;
    font-size: 14px;
    color: #999;
    margin-bottom: 8px;
  }
  
  .summary-value {
    display: block;
    font-size: 24px;
    font-weight: bold;
  }
  
  &.total { background: #f5f5f5; .summary-value { color: #333; } }
  &.passed { background: #f6ffed; .summary-value { color: #52c41a; } }
  &.failed { background: #fff2f0; .summary-value { color: #ff4d4f; } }
  &.rate { background: #e6f7ff; .summary-value { color: #1890ff; } }
}
</style>
