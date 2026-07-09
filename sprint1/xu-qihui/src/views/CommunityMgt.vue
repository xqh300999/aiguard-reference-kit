<template>
  <div class="page-stack">
    <section class="section-block">
      <header class="section-heading">
        <h2>社区管理</h2>
        <el-button type="primary" @click="openModal()">新增社区</el-button>
      </header>
      <el-table :data="tableData" class="work-table" border>
        <el-table-column prop="id" label="ID" width="80" />
        <el-table-column prop="name" label="名称" />
        <el-table-column prop="address" label="地址" />
        <el-table-column prop="area" label="区域" />
        <el-table-column prop="elderlyCount" label="老人数" width="100" />
        <el-table-column prop="deviceCount" label="设备数" width="100" />
        <el-table-column label="操作" width="180">
          <template #default="scope">
            <el-button size="small" @click="openModal(scope.row)">编辑</el-button>
            <el-button size="small" type="danger" :disabled="scope.row.elderlyCount > 0" @click="handleDelete(scope.row)">删除</el-button>
          </template>
        </el-table-column>
      </el-table>
    </section>
    <el-dialog :title="isEdit ? '编辑社区' : '新增社区'" v-model="dialogVisible" width="500px">
      <el-form :model="form" :rules="rules" ref="formRef" label-width="100px">
        <el-form-item label="名称" prop="name">
          <el-input v-model="form.name" placeholder="请输入社区名称" />
        </el-form-item>
        <el-form-item label="地址" prop="address">
          <el-input v-model="form.address" placeholder="请输入社区地址" />
        </el-form-item>
        <el-form-item label="区域" prop="area">
          <el-input v-model="form.area" placeholder="请输入区域" />
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
import { getCommunities, createCommunity, updateCommunity, deleteCommunity } from '@/api'
import type { Community } from '@/types/api'

const tableData = ref<Community[]>([])
const dialogVisible = ref(false)
const isEdit = ref(false)
const loading = ref(false)
const formRef = ref<FormInstance>()

const form = reactive({
  id: 0,
  name: '',
  address: '',
  area: ''
})

const rules: FormRules = {
  name: [{ required: true, message: '请输入社区名称', trigger: 'blur' }],
  address: [{ required: true, message: '请输入社区地址', trigger: 'blur' }],
  area: [{ required: true, message: '请输入区域', trigger: 'blur' }]
}

const fetchData = async () => {
  tableData.value = []
  try {
    const data = await getCommunities()
    tableData.value = data.map(item => ({
      ...item,
      elderlyCount: item.elderlyCount ?? 0,
      deviceCount: item.deviceCount ?? 0
    }))
    if (tableData.value.length === 0) {
      ElMessage.info('暂无社区数据')
    }
  } catch (error: any) {
    ElMessage.error('获取社区列表失败: ' + (error.response?.data?.message || error.message || '未知错误'))
  }
}

const openModal = (row?: Community) => {
  if (row) {
    isEdit.value = true
    form.id = row.id
    form.name = row.name
    form.address = row.address
    form.area = row.area
  } else {
    isEdit.value = false
    form.id = 0
    form.name = ''
    form.address = ''
    form.area = ''
  }
  dialogVisible.value = true
}

const handleSubmit = async () => {
  if (!formRef.value) return
  await formRef.value.validate(async (valid) => {
    if (!valid) return
    loading.value = true
    try {
      if (isEdit.value) {
        await updateCommunity(form.id, { name: form.name, address: form.address, area: form.area })
        ElMessage.success('更新成功')
      } else {
        await createCommunity({ name: form.name, address: form.address, area: form.area })
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

const handleDelete = async (row: Community) => {
  await ElMessageBox.confirm('确定要删除该社区吗？', '提示', {
    type: 'warning'
  })
  try {
    await deleteCommunity(row.id)
    ElMessage.success('删除成功')
    fetchData()
  } catch {
    ElMessage.error('删除失败')
  }
}

onMounted(() => {
  fetchData()
})
</script>