<template>
  <main class="login-page">
    <section class="login-panel">
      <div class="login-copy">
        <span class="brand-mark large">A</span>
        <h1>AiGuard 社区工作台</h1>
        <p>告警接单、现场处理、状态回传</p>
      </div>

      <el-form ref="formRef" :model="form" :rules="rules" class="login-form" size="large">
        <el-form-item prop="username">
          <el-input v-model.trim="form.username" placeholder="账号" autocomplete="username" />
        </el-form-item>
        <el-form-item prop="password">
          <el-input
            v-model="form.password"
            placeholder="密码"
            type="password"
            autocomplete="current-password"
            show-password
            @keyup.enter="submit"
          />
        </el-form-item>
        <el-button class="full-button" type="primary" :loading="loading" @click="submit">
          登录
        </el-button>
      </el-form>
    </section>
  </main>
</template>

<script setup lang="ts">
import type { FormInstance, FormRules } from 'element-plus'
import { ElMessage } from 'element-plus'
import { reactive, ref } from 'vue'
import { useRoute, useRouter } from 'vue-router'

import { useAuthStore } from '@/stores/auth'

const router = useRouter()
const route = useRoute()
const auth = useAuthStore()
const formRef = ref<FormInstance>()
const loading = ref(false)

const form = reactive({
  username: 'worker',
  password: 'worker123',
})

const rules: FormRules<typeof form> = {
  username: [{ required: true, message: '请输入账号', trigger: 'blur' }],
  password: [
    { required: true, message: '请输入密码', trigger: 'blur' },
    { min: 6, message: '密码至少 6 位', trigger: 'blur' },
  ],
}

async function submit() {
  if (loading.value) return
  const valid = await formRef.value?.validate().catch(() => false)
  if (!valid) return

  loading.value = true
  try {
    const session = await auth.login(form)
    if (!['WORKER', 'ADMIN'].includes(session.role)) {
      auth.logout()
      ElMessage.error('当前角色不能进入社区工作台')
      return
    }
    const redirect = typeof route.query.redirect === 'string' ? route.query.redirect : '/worker'
    router.replace(redirect)
  } finally {
    loading.value = false
  }
}
</script>
