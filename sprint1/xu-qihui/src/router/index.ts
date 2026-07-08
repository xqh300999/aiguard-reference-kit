import { createRouter, createWebHistory } from 'vue-router'
import { useAuthStore } from '@/stores/auth'

const router = createRouter({
  history: createWebHistory(),
  routes: [
    {
      path: '/',
      redirect: '/worker/workbench'
    },
    {
      path: '/login',
      name: 'Login',
      component: () => import('@/views/LoginView.vue')
    },
    {
      path: '/admin',
      component: () => import('@/layouts/AdminLayout.vue'),
      meta: { role: 'ADMIN' },
      redirect: '/admin/dashboard',
      children: [
        {
          path: 'dashboard',
          name: 'Dashboard',
          component: () => import('@/views/DashboardView.vue')
        },
        {
          path: 'communities',
          name: 'Communities',
          component: () => import('@/views/CommunityMgt.vue')
        },
        {
          path: 'elderly',
          name: 'Elderly',
          component: () => import('@/views/ElderlyMgt.vue')
        },
        {
          path: 'users',
          name: 'Users',
          component: () => import('@/views/UserMgt.vue')
        },
        {
          path: 'devices',
          name: 'Devices',
          component: () => import('@/views/DeviceMgt.vue')
        },
        {
          path: 'alerts',
          name: 'Alerts',
          component: () => import('@/views/AlertMgt.vue')
        },
        {
          path: 'alerts/:id',
          name: 'AlertDetail',
          component: () => import('@/views/AlertDetailView.vue')
        }
      ]
    },
    {
      path: '/worker',
      component: () => import('@/layouts/WorkerLayout.vue'),
      meta: { role: 'WORKER' },
      redirect: '/worker/workbench',
      children: [
        {
          path: 'workbench',
          name: 'Workbench',
          component: () => import('@/views/WorkbenchView.vue')
        },
        {
          path: 'alerts/:id',
          name: 'WorkerAlertDetail',
          component: () => import('@/views/AlertDetailView.vue')
        },
        {
          path: 'alerts',
          name: 'WorkerAlerts',
          component: () => import('@/views/AlertMgt.vue')
        }
      ]
    }
  ]
})

router.beforeEach((to, _from, next) => {
  const authStore = useAuthStore()
  authStore.init()

  if (!authStore.token) {
    if (to.path === '/login') {
      next()
    } else {
      next('/login')
    }
    return
  }

  if (to.path === '/login') {
    next('/worker/workbench')
    return
  }

  const requiredRole = to.meta.role as string | undefined
  if (requiredRole && authStore.user?.role !== requiredRole && authStore.user?.role !== 'ADMIN') {
    next('/worker/workbench')
    return
  }

  next()
})

export default router