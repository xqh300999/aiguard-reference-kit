import { createRouter, createWebHistory } from 'vue-router'
import { useAuthStore } from '@/stores/auth'

const router = createRouter({
  history: createWebHistory(),
  routes: [
    {
      path: '/',
      redirect: '/login'
    },
    {
      path: '/login',
      name: 'Login',
      component: () => import('@/views/LoginView.vue')
    },
    {
      path: '/admin',
      component: () => import('@/components/AdminLayout.vue'),
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
  } else {
    if (to.path === '/login') {
      next('/admin/dashboard')
    } else {
      next()
    }
  }
})

export default router