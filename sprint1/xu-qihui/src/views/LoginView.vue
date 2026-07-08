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
          <p style="margin: 12px 0 0; color: #768198; font-size: 13px;">测试账号：admin/admin123 或 worker/worker123</p>
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

const form = reactive({
  username: '',
  password: ''
})

const rules: FormRules = {
  username: [{ required: true, message: '请输入用户名', trigger: 'blur' }],
  password: [{ required: true, message: '请输入密码', trigger: 'blur' }]
}

const handleLogin = async () => {
  if (!formRef.value) return
  await formRef.value.validate(async (valid) => {
    if (!valid) return
    loading.value = true
    try {
      const data = await login(form)
      authStore.login(data)
      router.push('/worker/workbench')
      ElMessage.success('登录成功')
    } catch {
      ElMessage.error('用户名或密码错误')
    } finally {
      loading.value = false
    }
  })
}

onMounted(() => {
  authStore.init()
  if (authStore.token) {
    router.push('/worker/workbench')
  }
})
</script>