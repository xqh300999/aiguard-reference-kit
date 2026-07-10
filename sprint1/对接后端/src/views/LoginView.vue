<template>
  <div class="login-page">
    <div class="login-panel">
      <section class="login-copy">
        <span class="brand-mark large">A</span>
        <h1>AiGuard</h1>
        <p>智能养老监护平台</p>
      </section>
      <section class="login-form">
        <el-form :model="form" :rules="rules" ref="formRef" label-width="80px">
          <el-form-item label="用户名" prop="username">
            <el-input v-model="form.username" placeholder="请输入用户名" />
          </el-form-item>
          <el-form-item label="密码" prop="password">
            <el-input v-model="form.password" type="password" placeholder="请输入密码" />
          </el-form-item>
          <el-form-item>
            <el-button type="primary" :loading="loading" @click="handleLogin" class="full-button">
              登录
            </el-button>
          </el-form-item>
          <p class="login-hint">{{ loginHint }}</p>
          <p class="login-hint">
            没有账号？<router-link to="/register">立即注册</router-link>
          </p>
        </el-form>
      </section>
    </div>
  </div>
</template>

<script setup lang="ts">
import { ref, reactive, onMounted } from 'vue'
import { useRouter } from 'vue-router'
import { ElMessage } from 'element-plus'
import type { FormInstance, FormRules } from 'element-plus'
import { useAuthStore } from '@/stores/auth'
import { login } from '@/api/auth'

const router = useRouter()
const authStore = useAuthStore()

const formRef = ref<FormInstance>()
const loading = ref(false)
const loginHint = import.meta.env.VITE_USE_MOCK === 'true'
  ? '测试账号：admin/admin123 或 worker/worker123'
  : '真实后端账号以后端数据库实际初始化为准'

const form = reactive({
  username: '',
  password: ''
})

const rules: FormRules = {
  username: [{ required: true, message: '请输入用户名', trigger: 'blur' }],
  password: [
    { required: true, message: '请输入密码', trigger: 'blur' },
    { min: 6, message: '密码至少 6 位', trigger: 'blur' }
  ]
}

const getHomePath = () => {
  if (authStore.user?.role === 'ADMIN' || authStore.user?.role === 'SUPER_ADMIN') return '/admin/dashboard'
  if (authStore.user?.role === 'WORKER') return '/worker/workbench'
  return ''
}

const handleLogin = async () => {
  if (!formRef.value) return
  await formRef.value.validate(async (valid) => {
    if (!valid) return
    loading.value = true
    try {
      const data = await login(form)
      authStore.login(data)
      const homePath = getHomePath()
      if (!homePath) {
        authStore.logout()
        ElMessage.error('当前角色不能进入管理端')
        return
      }
      router.push(homePath)
      ElMessage.success('登录成功')
    } catch (error) {
      if (error instanceof Error && (error.message === 'Network Error' || error.message.includes('ERR_CONNECTION') || error.message.includes('ETIMEDOUT'))) {
        ElMessage.error('网络连接失败，请检查后端服务')
      }
    } finally {
      loading.value = false
    }
  })
}

onMounted(() => {
  authStore.init()
  if (authStore.token) {
    router.push(getHomePath() || '/worker/workbench')
  }
})
</script>
