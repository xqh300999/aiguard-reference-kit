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
          <el-form-item label="确认密码" prop="confirmPassword">
            <el-input v-model="form.confirmPassword" type="password" placeholder="请再次输入密码" />
          </el-form-item>
          <el-form-item label="姓名" prop="realName">
            <el-input v-model="form.realName" placeholder="请输入姓名" />
          </el-form-item>
          <el-form-item label="电话" prop="phone">
            <el-input v-model="form.phone" placeholder="请输入手机号" />
          </el-form-item>
          <el-form-item label="角色" prop="role">
            <el-select v-model="form.role" placeholder="请选择角色">
              <el-option label="社区工作人员" value="WORKER" />
              <el-option label="家属" value="FAMILY" />
            </el-select>
          </el-form-item>
          <el-form-item label="社区ID" prop="communityId">
            <el-input v-model.number="form.communityId" type="number" placeholder="请输入社区ID" />
          </el-form-item>
          <el-form-item>
            <el-button type="primary" :loading="loading" @click="handleRegister" class="full-button">
              注册
            </el-button>
          </el-form-item>
          <p style="margin: 12px 0 0; color: #768198; font-size: 13px;">
            已有账号？<router-link to="/login">点击登录</router-link>
          </p>
        </el-form>
      </section>
    </div>
  </div>
</template>

<script setup lang="ts">
import { ref, reactive } from 'vue'
import { useRouter } from 'vue-router'
import { ElMessage } from 'element-plus'
import type { FormInstance, FormRules } from 'element-plus'
import { register } from '@/api/auth'

const router = useRouter()

const formRef = ref<FormInstance>()
const loading = ref(false)

const form = reactive({
  username: '',
  password: '',
  confirmPassword: '',
  realName: '',
  phone: '',
  role: 'WORKER',
  communityId: 1
})

const rules: FormRules = {
  username: [
    { required: true, message: '请输入用户名', trigger: 'blur' },
    { min: 3, max: 20, message: '用户名长度在 3 到 20 个字符', trigger: 'blur' }
  ],
  password: [
    { required: true, message: '请输入密码', trigger: 'blur' },
    { min: 6, message: '密码至少 6 位', trigger: 'blur' }
  ],
  confirmPassword: [
    { required: true, message: '请确认密码', trigger: 'blur' },
    {
      validator: (_rule, value, callback) => {
        if (value !== form.password) {
          callback(new Error('两次输入密码不一致'))
        } else {
          callback()
        }
      },
      trigger: 'blur'
    }
  ],
  realName: [{ required: true, message: '请输入姓名', trigger: 'blur' }],
  phone: [
    { required: true, message: '请输入手机号', trigger: 'blur' },
    { pattern: /^1[3-9]\d{9}$/, message: '请输入正确的手机号', trigger: 'blur' }
  ],
  role: [{ required: true, message: '请选择角色', trigger: 'change' }],
  communityId: [{ required: true, message: '请输入社区ID', trigger: 'blur' }]
}

const handleRegister = async () => {
  if (!formRef.value) return
  await formRef.value.validate(async (valid) => {
    if (!valid) return
    loading.value = true
    try {
      await register({
        username: form.username,
        password: form.password,
        realName: form.realName,
        phone: form.phone,
        role: form.role,
        communityId: form.communityId
      })
      ElMessage.success('注册成功，请登录')
      router.push('/login')
    } catch (error: any) {
      ElMessage.error(error.response?.data?.message || error.message || '注册失败')
    } finally {
      loading.value = false
    }
  })
}
</script>

<style scoped>
.login-page {
  min-height: 100vh;
  display: flex;
  align-items: center;
  justify-content: center;
  background: linear-gradient(135deg, #1a1a2e 0%, #16213e 100%);
}

.login-panel {
  background: white;
  border-radius: 16px;
  box-shadow: 0 20px 60px rgba(0, 0, 0, 0.3);
  display: flex;
  width: 720px;
  overflow: hidden;
}

.login-copy {
  padding: 60px 40px;
  background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
  color: white;
  flex: 1;
  display: flex;
  flex-direction: column;
  align-items: center;
  justify-content: center;
}

.brand-mark {
  width: 72px;
  height: 72px;
  border-radius: 16px;
  background: white;
  color: #667eea;
  display: flex;
  align-items: center;
  justify-content: center;
  font-size: 32px;
  font-weight: bold;
  margin-bottom: 20px;
}

.brand-mark.large {
  width: 80px;
  height: 80px;
  font-size: 40px;
}

.login-copy h1 {
  font-size: 28px;
  margin: 0 0 8px;
}

.login-copy p {
  font-size: 14px;
  opacity: 0.9;
  margin: 0;
}

.login-form {
  padding: 48px 40px;
  flex: 1;
}

.full-button {
  width: 100%;
}
</style>
