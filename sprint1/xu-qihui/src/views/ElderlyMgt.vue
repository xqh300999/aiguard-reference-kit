<template>
  <div class="page-stack">
    <section class="section-block">
      <header class="section-heading">
        <h2>老人档案</h2>
        <el-button type="primary" @click="openModal()">新增老人</el-button>
      </header>
      <el-form :inline="true" :model="searchForm" class="search-form">
        <el-form-item label="姓名">
          <el-input v-model="searchForm.name" placeholder="请输入姓名" style="width: 200px" @keyup.enter="fetchData" />
        </el-form-item>
        <el-form-item label="社区">
          <el-select v-model="searchForm.communityId" placeholder="请选择社区" style="width: 200px">
            <el-option v-for="c in communities" :key="c.id" :label="c.name" :value="c.id" />
          </el-select>
        </el-form-item>
        <el-form-item label="状态">
          <el-select v-model="searchForm.status" placeholder="请选择状态" style="width: 150px">
            <el-option label="全部" value="" />
            <el-option label="活跃" value="ACTIVE" />
            <el-option label="停用" value="INACTIVE" />
          </el-select>
        </el-form-item>
        <el-form-item>
          <el-button type="primary" @click="fetchData">搜索</el-button>
          <el-button @click="resetSearch">重置</el-button>
        </el-form-item>
      </el-form>
      <el-table :data="tableData" class="work-table" border>
        <el-table-column prop="id" label="ID" width="80" />
        <el-table-column prop="name" label="姓名" />
        <el-table-column prop="age" label="年龄" width="80" />
        <el-table-column prop="gender" label="性别" width="80">
          <template #default="scope">
            <el-tag>{{ scope.row.gender === 'MALE' ? '男' : '女' }}</el-tag>
          </template>
        </el-table-column>
        <el-table-column prop="phone" label="电话" />
        <el-table-column prop="communityName" label="社区" />
        <el-table-column prop="status" label="状态" width="100">
          <template #default="scope">
            <el-tag :type="scope.row.status === 'ACTIVE' ? 'success' : 'danger'">{{ scope.row.status === 'ACTIVE' ? '活跃' : '停用' }}</el-tag>
          </template>
        </el-table-column>
        <el-table-column label="设备" width="150">
          <template #default="scope">
            <span v-if="scope.row.device">{{ scope.row.device.name }} ({{ scope.row.device.status === 'ONLINE' ? '在线' : '离线' }})</span>
            <span v-else style="color: #999">未绑定</span>
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
    <el-dialog :title="isEdit ? '编辑老人' : '新增老人'" v-model="dialogVisible" width="500px">
      <el-form :model="form" :rules="rules" ref="formRef" label-width="100px">
        <el-form-item label="姓名" prop="name">
          <el-input v-model="form.name" placeholder="请输入姓名" />
        </el-form-item>
        <el-form-item label="年龄" prop="age">
          <el-input-number v-model="form.age" :min="0" :max="150" placeholder="请输入年龄" />
        </el-form-item>
        <el-form-item label="性别" prop="gender">
          <el-radio-group v-model="form.gender">
            <el-radio label="MALE">男</el-radio>
            <el-radio label="FEMALE">女</el-radio>
          </el-radio-group>
        </el-form-item>
        <el-form-item label="电话" prop="phone">
          <el-input v-model="form.phone" placeholder="请输入电话" />
        </el-form-item>
        <el-form-item label="社区" prop="communityId">
          <el-select v-model="form.communityId" placeholder="请选择社区">
            <el-option v-for="c in communities" :key="c.id" :label="c.name" :value="c.id" />
          </el-select>
        </el-form-item>
        <el-form-item label="紧急联系人">
          <el-input v-model="form.emergencyContact" placeholder="请输入紧急联系人电话" />
        </el-form-item>
        <el-form-item label="健康备注">
          <el-input v-model="form.healthNotes" type="textarea" :rows="3" placeholder="请输入健康备注" />
        </el-form-item>
        <el-form-item label="状态" prop="status">
          <el-radio-group v-model="form.status">
            <el-radio label="ACTIVE">活跃</el-radio>
            <el-radio label="INACTIVE">停用</el-radio>
          </el-radio-group>
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
import { getElderlies, createElderly, updateElderly, deleteElderly, getCommunities } from '@/api'
import type { Elderly, Community } from '@/types/api'

const tableData = ref<Elderly[]>([])
const communities = ref<Community[]>([])
const total = ref(0)
const page = ref(1)
const size = ref(10)
const dialogVisible = ref(false)
const isEdit = ref(false)
const loading = ref(false)
const formRef = ref<FormInstance>()

const searchForm = reactive({
  name: '',
  communityId: '',
  status: ''
})

const form = reactive({
  id: 0,
  name: '',
  age: 0,
  gender: 'MALE' as 'MALE' | 'FEMALE',
  phone: '',
  communityId: 0,
  emergencyContact: '',
  healthNotes: '',
  status: 'ACTIVE' as 'ACTIVE' | 'INACTIVE'
})

const rules: FormRules = {
  name: [{ required: true, message: '请输入姓名', trigger: 'blur' }],
  age: [{ required: true, message: '请输入年龄', trigger: 'blur' }],
  gender: [{ required: true, message: '请选择性别', trigger: 'change' }],
  communityId: [{ required: true, message: '请选择社区', trigger: 'change' }],
  status: [{ required: true, message: '请选择状态', trigger: 'change' }]
}

const fetchData = async () => {
  tableData.value = []
  total.value = 0
  try {
    const data = await getElderlies({
      page: page.value,
      size: size.value,
      name: searchForm.name || undefined,
      communityId: searchForm.communityId ? Number(searchForm.communityId) : undefined,
      status: searchForm.status || undefined
    })
    tableData.value = data.records
    total.value = data.total
    if (data.records.length === 0) {
      ElMessage.info('暂无老人数据')
    }
  } catch (error: any) {
    ElMessage.error('获取老人列表失败: ' + (error.response?.data?.message || error.message || '未知错误'))
  }
}

const fetchCommunities = async () => {
  communities.value = []
  try {
    const data = await getCommunities()
    communities.value = data
  } catch (error: any) {
    ElMessage.error('获取社区列表失败: ' + (error.response?.data?.message || error.message || '未知错误'))
  }
}

const openModal = (row?: Elderly) => {
  if (row) {
    isEdit.value = true
    form.id = row.id
    form.name = row.name
    form.age = row.age
    form.gender = row.gender
    form.phone = row.phone || ''
    form.communityId = row.communityId
    form.emergencyContact = row.emergencyContact || ''
    form.healthNotes = row.healthNotes || ''
    form.status = row.status
  } else {
    isEdit.value = false
    form.id = 0
    form.name = ''
    form.age = 0
    form.gender = 'MALE'
    form.phone = ''
    form.communityId = 0
    form.emergencyContact = ''
    form.healthNotes = ''
    form.status = 'ACTIVE'
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
        await updateElderly(form.id, { name: form.name, age: form.age, gender: form.gender, phone: form.phone, communityId: form.communityId, emergencyContact: form.emergencyContact, healthNotes: form.healthNotes, status: form.status })
        ElMessage.success('更新成功')
      } else {
        await createElderly({ name: form.name, age: form.age, gender: form.gender, phone: form.phone, communityId: form.communityId, emergencyContact: form.emergencyContact, healthNotes: form.healthNotes })
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

const handleDelete = async (row: Elderly) => {
  await ElMessageBox.confirm('确定要删除该老人吗？删除后关联设备将解绑。', '提示', {
    type: 'warning'
  })
  try {
    await deleteElderly(row.id)
    ElMessage.success('删除成功')
    fetchData()
  } catch {
    ElMessage.error('删除失败')
  }
}

const resetSearch = () => {
  searchForm.name = ''
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