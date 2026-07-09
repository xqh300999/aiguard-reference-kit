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
      component: () => import('@/views/LoginView.vue'),
      meta: { public: true }
    },
    {
      path: '/register',
      name: 'Register',
      component: () => import('@/views/RegisterView.vue'),
      meta: { public: true }
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
        },
        {
          path: 'test',
          name: 'Test',
          component: () => import('@/views/TestView.vue')
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
          component: () => import('@/views/WorkerAlertListView.vue')
        }
      ]
    },
    {
      path: '/alerts',
      component: () => import('@/layouts/WorkerLayout.vue'),
      meta: { role: 'WORKER' },
      children: [
        {
          path: '',
          name: 'AcceptanceAlerts',
          component: () => import('@/views/WorkerAlertListView.vue')
        },
        {
          path: ':id',
          name: 'AcceptanceAlertDetail',
          component: () => import('@/views/AlertDetailView.vue')
        }
      ]
    },
    {
      path: '/404',
      name: 'NotFound',
      component: () => import('@/views/NotFoundView.vue'),
      meta: { public: true }
    },
    {
      path: '/:pathMatch(.*)*',
      redirect: '/404'
    }
  ]
})

router.beforeEach((to, _from, next) => {
  const authStore = useAuthStore()
  authStore.init()

  const isAdmin = authStore.user?.role === 'ADMIN' || authStore.user?.role === 'SUPER_ADMIN'
  const homePath = isAdmin ? '/admin/dashboard' : '/worker/workbench'

  if (to.meta.public) {
    if (to.path === '/login' && authStore.token) {
      next(homePath)
      return
    }
    next()
    return
  }

  if (!authStore.token) {
    next('/login')
    return
  }

  const requiredRole = to.meta.role as string | undefined
  if (requiredRole) {
    const userRole = authStore.user?.role
    if (userRole === 'SUPER_ADMIN') {
    } else if (userRole === 'ADMIN') {
      if (requiredRole === 'WORKER') {
      } else if (userRole !== requiredRole) {
        next(homePath)
        return
      }
    } else if (userRole !== requiredRole) {
      next(homePath)
      return
    }
  }

  next()
})

export default router
