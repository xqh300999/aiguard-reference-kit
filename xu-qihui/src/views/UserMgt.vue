<template>
  <div class="page-stack">
    <section class="section-block">
      <header class="section-heading">
        <h2>用户管理</h2>
        <el-button type="primary" @click="openModal()">新增用户</el-button>
      </header>
      <el-table :data="tableData" class="work-table" border>
        <el-table-column prop="id" label="ID" width="80" />
        <el-table-column prop="username" label="用户名" />
        <el-table-column prop="realName" label="姓名" />
        <el-table-column prop="phone" label="电话" />
        <el-table-column prop="role" label="角色" width="100">
          <template #default="scope">
            <el-tag :type="getRoleType(scope.row.role)">{{ getRoleText(scope.row.role) }}</el-tag>
          </template>
        </el-table-column>
        <el-table-column prop="communityName" label="社区" />
        <el-table-column prop="status" label="状态" width="100">
          <template #default="scope">
            <el-tag :type="scope.row.status === 'ACTIVE' ? 'success' : 'danger'">{{ scope.row.status === 'ACTIVE' ? '启用' : '停用' }}</el-tag>
          </template>
        </el-table-column>
        <el-table-column label="操作" width="180">
          <template #default="scope">
            <el-button size="small" @click="openModal(scope.row)">编辑</el-button>
            <el-button size="small" type="danger" @click="handleDelete(scope.row)">删除</el-button>
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
    <el-dialog :title="isEdit ? '编辑用户' : '新增用户'" v-model="dialogVisible" width="500px">
      <el-form :model="form" :rules="rules" ref="formRef" label-width="100px">
        <el-form-item label="用户名" prop="username">
          <el-input v-model="form.username" :disabled="isEdit" placeholder="请输入用户名" />
        </el-form-item>
        <el-form-item label="姓名" prop="realName">
          <el-input v-model="form.realName" placeholder="请输入姓名" />
        </el-form-item>
        <el-form-item label="密码" :prop="isEdit ? '' : 'password'">
          <el-input v-model="form.password" type="password" :placeholder="isEdit ? '不填则不变' : '请输入密码'" />
        </el-form-item>
        <el-form-item label="电话">
          <el-input v-model="form.phone" placeholder="请输入电话" />
        </el-form-item>
        <el-form-item label="角色" prop="role">
          <el-select v-model="form.role" placeholder="请选择角色">
            <el-option label="管理员" value="ADMIN" />
            <el-option label="工作人员" value="WORKER" />
            <el-option label="家人" value="FAMILY" />
            <el-option label="老人" value="ELDERLY" />
          </el-select>
        </el-form-item>
        <el-form-item label="社区" prop="communityId">
          <el-select v-model="form.communityId" placeholder="请选择社区" :disabled="form.role === 'ADMIN'">
            <el-option v-for="c in communities" :key="c.id" :label="c.name" :value="c.id" />
          </el-select>
        </el-form-item>
      </el-form>
      <template #footer>
        <el-button @click="dialogVisible = false">取消</el-button>
        <el-button type="primary" :loading="loading" @click="handleSubmit">确定</el-button>
      </template>
    </el-dialog>
  </div>
</template>

<script setup lang="ts">
import { ref, reactive, onMounted } from 'vue'
import { ElMessage, ElMessageBox } from 'element-plus'
import type { FormInstance, FormRules } from 'element-plus'
import { getUsers, createUser, updateUser, deleteUser, getCommunities } from '@/api'
import type { User, Community } from '@/types'

const tableData = ref<User[]>([])
const communities = ref<Community[]>([])
const total = ref(0)
const page = ref(1)
const size = ref(10)
const dialogVisible = ref(false)
const isEdit = ref(false)
const loading = ref(false)
const formRef = ref<FormInstance>()

const form = reactive({
  id: 0,
  username: '',
  realName: '',
  password: '',
  phone: '',
  role: 'WORKER' as 'ADMIN' | 'WORKER' | 'FAMILY' | 'ELDERLY',
  communityId: 0
})

const rules: FormRules = {
  username: [{ required: true, message: '请输入用户名', trigger: 'blur' }],
  realName: [{ required: true, message: '请输入姓名', trigger: 'blur' }],
  password: [{ required: true, message: '请输入密码', trigger: 'blur' }],
  role: [{ required: true, message: '请选择角色', trigger: 'change' }]
}

const getRoleType = (role: User['role']) => {
  const types: Record<User['role'], string> = {
    ADMIN: 'danger',
    WORKER: 'primary',
    FAMILY: 'warning',
    ELDERLY: 'success'
  }
  return types[role]
}

const getRoleText = (role: User['role']) => {
  const texts: Record<User['role'], string> = {
    ADMIN: '管理员',
    WORKER: '工作人员',
    FAMILY: '家人',
    ELDERLY: '老人'
  }
  return texts[role]
}

const fetchData = async () => {
  try {
    const data = await getUsers({ page: page.value, size: size.value })
    tableData.value = data.records
    total.value = data.total
  } catch {
    tableData.value = [
      { id: 1, username: 'admin', realName: '管理员', phone: '', role: 'ADMIN', communityId: null, status: 'ACTIVE', createdAt: '2026-07-01T08:00:00Z' },
      { id: 2, username: 'worker1', realName: '张三', phone: '13800138000', role: 'WORKER', communityId: 1, communityName: '幸福社区', status: 'ACTIVE', createdAt: '2026-07-01T08:00:00Z' },
      { id: 3, username: 'worker2', realName: '李四', phone: '13800138001', role: 'WORKER', communityId: 2, communityName: '阳光社区', status: 'ACTIVE', createdAt: '2026-07-01T08:00:00Z' },
      { id: 4, username: 'family1', realName: '王五', phone: '13800138002', role: 'FAMILY', communityId: 1, communityName: '幸福社区', status: 'ACTIVE', createdAt: '2026-07-01T08:00:00Z' }
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

const openModal = (row?: User) => {
  if (row) {
    isEdit.value = true
    form.id = row.id
    form.username = row.username
    form.realName = row.realName
    form.password = ''
    form.phone = row.phone || ''
    form.role = row.role
    form.communityId = row.communityId || 0
  } else {
    isEdit.value = false
    form.id = 0
    form.username = ''
    form.realName = ''
    form.password = ''
    form.phone = ''
    form.role = 'WORKER'
    form.communityId = 0
  }
  dialogVisible.value = true
}

const handleSubmit = async () => {
  if (!formRef.value) return
  await formRef.value.validate(async (valid) => {
    if (!valid) return
    loading.value = true
    try {
      const data: Partial<User> & { password?: string } = { realName: form.realName, phone: form.phone, role: form.role, communityId: form.role === 'ADMIN' ? null : form.communityId }
      if (form.password) {
        data.password = form.password
      }
      if (isEdit.value) {
        await updateUser(form.id, data)
        ElMessage.success('更新成功')
      } else {
        await createUser({ ...data, username: form.username, password: form.password! } as User)
        ElMessage.success('创建成功')
      }
      dialogVisible.value = false
      fetchData()
    } catch {
      ElMessage.error('操作失败')
    } finally {
      loading.value = false
    }
  })
}

const handleDelete = async (row: User) => {
  await ElMessageBox.confirm('确定要删除该用户吗？', '提示', {
    type: 'warning'
  })
  try {
    await deleteUser(row.id)
    ElMessage.success('删除成功')
    fetchData()
  } catch {
    ElMessage.error('删除失败')
  }
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