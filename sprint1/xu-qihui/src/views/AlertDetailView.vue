<template>
  <div class="page-stack">
    <section class="section-block">
      <div class="detail-toolbar">
        <el-button @click="router.back()">
          <ArrowLeft :size="16" />
          返回
        </el-button>
        <div class="detail-actions" v-if="alert">
          <el-button
            v-if="alert.status === 'PENDING'"
            type="danger"
            :loading="actionLoading"
            @click="acceptAlert"
          >
            <CheckCircle2 :size="16" />
            接单
          </el-button>
          <el-button
            v-if="alert.status === 'PROCESSING'"
            type="primary"
            :loading="actionLoading"
            @click="openProcessDialog"
          >
            <ClipboardCheck :size="16" />
            处理
          </el-button>
        </div>
      </div>

      <el-skeleton v-if="loading" :rows="8" animated />
      <el-empty v-else-if="!alert" description="告警不存在" />
      <div v-else class="detail-grid">
        <article class="detail-main">
          <div class="detail-title">
            <span :class="['type-pill', alertTypeTone[alert.type]]">{{ alert.typeName }}</span>
            <el-tag :type="alertStatusTag[alert.status]" effect="light">
              {{ alert.statusName }}
            </el-tag>
          </div>
          <h2>{{ alert.elderlyName }} · {{ alert.communityName }}</h2>

          <el-descriptions :column="2" border>
            <el-descriptions-item label="告警编号">#{{ alert.id }}</el-descriptions-item>
            <el-descriptions-item label="来源">{{ alert.source }}</el-descriptions-item>
            <el-descriptions-item label="优先级">
              {{ priorityText[alert.priority] }}
            </el-descriptions-item>
            <el-descriptions-item label="发生时间">
              {{ formatDateTime(alert.happenedAt) }}
            </el-descriptions-item>
            <el-descriptions-item label="处理人">
              {{ alert.handlerName || '-' }}
            </el-descriptions-item>
            <el-descriptions-item label="完成时间">
              {{ formatDateTime(alert.resolvedAt) }}
            </el-descriptions-item>
            <el-descriptions-item label="定位">
              {{ alert.lat && alert.lng ? `${alert.lat}, ${alert.lng}` : '-' }}
            </el-descriptions-item>
            <el-descriptions-item label="处理结果">
              {{ alert.dispatch?.result ? dispatchResultText[alert.dispatch.result] : '-' }}
            </el-descriptions-item>
            <el-descriptions-item label="原因" :span="2">
              {{ alert.cause || '-' }}
            </el-descriptions-item>
            <el-descriptions-item label="详情" :span="2">
              {{ alert.details || '-' }}
            </el-descriptions-item>
          </el-descriptions>

          <el-timeline class="detail-timeline">
            <el-timeline-item :timestamp="formatDateTime(alert.happenedAt)" type="danger">
              告警产生
            </el-timeline-item>
            <el-timeline-item
              v-if="alert.dispatch"
              :timestamp="formatDateTime(alert.dispatch.createdAt)"
              type="warning"
            >
              {{ alert.dispatch.handlerName }} 已接单
            </el-timeline-item>
            <el-timeline-item
              v-if="alert.resolvedAt"
              :timestamp="formatDateTime(alert.resolvedAt)"
              type="success"
            >
              {{ alert.statusName }}
            </el-timeline-item>
          </el-timeline>
        </article>

        <aside class="detail-side">
          <h3>老人信息</h3>
          <div class="elderly-avatar">{{ displayElderly.name.slice(0, 1) }}</div>
          <el-descriptions :column="1" border>
            <el-descriptions-item label="姓名">{{ displayElderly.name }}</el-descriptions-item>
            <el-descriptions-item label="年龄">{{ displayElderly.age }}</el-descriptions-item>
            <el-descriptions-item label="性别">
              {{ displayElderly.genderName }}
            </el-descriptions-item>
            <el-descriptions-item label="住址">{{ displayElderly.address }}</el-descriptions-item>
            <el-descriptions-item label="电话">{{ displayElderly.phone }}</el-descriptions-item>
            <el-descriptions-item label="紧急联系人">
              {{ displayElderly.emergencyContact }}
            </el-descriptions-item>
            <el-descriptions-item label="设备">
              <el-tag
                :type="displayElderly.deviceStatus === 'ONLINE' ? 'success' : 'info'"
                effect="light"
              >
                {{ displayElderly.deviceStatus }}
              </el-tag>
              <span class="battery-text"> {{ displayElderly.battery }}%</span>
            </el-descriptions-item>
            <el-descriptions-item label="备注">
              {{ displayElderly.healthNotes }}
            </el-descriptions-item>
          </el-descriptions>
        </aside>
      </div>
    </section>

    <el-dialog v-model="processVisible" title="填写处理结果" width="480px">
      <el-form :model="processForm" label-position="top">
        <el-form-item label="结果">
          <el-select v-model="processForm.result" class="full-width">
            <el-option label="已解决" value="RESOLVED" />
            <el-option label="需送医" value="NEED_HOSPITAL" />
            <el-option label="需跟进" value="NEED_FOLLOW_UP" />
          </el-select>
        </el-form-item>
        <el-form-item label="原因">
          <el-input
            v-model.trim="processForm.cause"
            placeholder="请填写原因（如：误触SOS按钮、卫生间滑倒等）"
          />
        </el-form-item>
        <el-form-item label="描述">
          <el-input
            v-model.trim="processForm.description"
            type="textarea"
            :rows="4"
            maxlength="200"
            show-word-limit
          />
        </el-form-item>
      </el-form>
      <template #footer>
        <el-button @click="processVisible = false">取消</el-button>
        <el-button type="primary" :loading="actionLoading" @click="submitProcess">提交</el-button>
      </template>
    </el-dialog>
  </div>
</template>

<script setup lang="ts">
import { ArrowLeft, CheckCircle2, ClipboardCheck } from 'lucide-vue-next'
import { ElMessage, ElMessageBox } from 'element-plus'
import { computed, onMounted, reactive, ref } from 'vue'
import { useRoute, useRouter } from 'vue-router'

import { createDispatch, getAlertDetail, getDispatchByAlert, updateAlert, updateDispatch } from '@/api/alerts'
import { getElderlyDetail } from '@/api/elderlies'
import { useAuthStore } from '@/stores/auth'
import type { AlertDetail as AlertDetailType, DispatchResult, ElderlySummary } from '@/types/api'
import {
  alertStatusTag,
  alertTypeTone,
  dispatchResultText,
  formatDateTime,
  priorityText,
} from '@/utils/labels'

const route = useRoute()
const router = useRouter()
const authStore = useAuthStore()
const loading = ref(false)
const actionLoading = ref(false)
const processVisible = ref(false)
const alert = ref<AlertDetailType | null>(null)
const elderlyDetail = ref<ElderlySummary | null>(null)
const processForm = reactive({
  result: 'RESOLVED' as DispatchResult,
  cause: '',
  description: '',
})

const emptyElderly: ElderlySummary = {
  id: 0,
  name: '-',
  age: 0,
  gender: 'MALE',
  genderName: '-',
  address: '-',
  phone: '-',
  emergencyContact: '-',
  healthNotes: '-',
  deviceStatus: 'OFFLINE',
  battery: 0,
}

const displayElderly = computed(() => elderlyDetail.value ?? alert.value?.elderly ?? emptyElderly)

function toGenderName(gender?: string) {
  if (!gender) return '-'
  if (gender === 'MALE') return '男'
  if (gender === 'FEMALE') return '女'
  return gender
}

function toElderlySummary(data: any): ElderlySummary {
  return {
    id: data?.id ?? 0,
    name: data?.name ?? '-',
    age: data?.age ?? 0,
    gender: data?.gender ?? 'MALE',
    genderName: toGenderName(data?.gender),
    address: data?.address ?? '-',
    phone: data?.phone ?? '-',
    emergencyContact: data?.emergencyContact ?? '-',
    healthNotes: data?.healthNotes ?? '-',
    deviceStatus: data?.device?.status ?? 'OFFLINE',
    battery: data?.device?.battery ?? 0,
  }
}

async function fetchElderlyFallback(elderlyId?: number | null) {
  elderlyDetail.value = null
  if (!elderlyId) return
  try {
    const res = await getElderlyDetail(elderlyId)
    elderlyDetail.value = toElderlySummary(res)
  } catch {
    elderlyDetail.value = null
  }
}

async function loadDetail() {
  loading.value = true
  try {
    const id = Number(route.params.id)
    const detail = await getAlertDetail(id)
    alert.value = detail
    await fetchElderlyFallback(detail?.elderlyId)
  } finally {
    loading.value = false
  }
}

async function acceptAlert() {
  if (!alert.value) return
  await ElMessageBox.confirm(`确认接单 #${alert.value.id}？`, '接单确认', {
    type: 'warning',
    confirmButtonText: '接单',
    cancelButtonText: '取消',
  })

  actionLoading.value = true
  try {
    await createDispatch({
      alertId: alert.value.id,
      handlerId: authStore.user?.userId || 2,
    })
    await updateAlert(alert.value.id, { status: 'PROCESSING' })
    ElMessage.success('接单成功')
    await loadDetail()
  } finally {
    actionLoading.value = false
  }
}

function openProcessDialog() {
  processVisible.value = true
}

async function submitProcess() {
  if (!alert.value) return
  if (!processForm.description) {
    ElMessage.warning('请填写处理描述')
    return
  }

  actionLoading.value = true
  try {
    const dispatch = alert.value.dispatch ?? (await getDispatchByAlert(alert.value.id))
    await updateDispatch(dispatch.id, {
      result: processForm.result,
      cause: processForm.cause,
      description: processForm.description,
      details: processForm.description,
    })
    ElMessage.success('处理结果已提交')
    processVisible.value = false
    await loadDetail()
  } finally {
    actionLoading.value = false
  }
}

onMounted(loadDetail)
</script>
