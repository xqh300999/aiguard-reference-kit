import { createRouter, createWebHistory } from 'vue-router'

import { useAuthStore } from '@/stores/auth'

const router = createRouter({
  history: createWebHistory(),
  routes: [
    {
      path: '/',
      component: () => import('@/layouts/WorkerLayout.vue'),
      meta: { requiresAuth: true, roles: ['WORKER', 'ADMIN'] },
      children: [
        {
          path: '',
          name: 'acceptance-dashboard',
          component: () => import('@/views/DashboardView.vue'),
        },
        {
          path: 'alerts',
          name: 'acceptance-alerts',
          component: () => import('@/views/AlertListView.vue'),
        },
        {
          path: 'alerts/:id',
          name: 'acceptance-alert-detail',
          component: () => import('@/views/AlertDetailView.vue'),
          props: (route) => ({ id: Number(route.params.id) }),
        },
      ],
    },
    {
      path: '/login',
      name: 'login',
      component: () => import('@/views/LoginView.vue'),
      meta: { public: true },
    },
    {
      path: '/worker',
      component: () => import('@/layouts/WorkerLayout.vue'),
      meta: { requiresAuth: true, roles: ['WORKER', 'ADMIN'] },
      children: [
        {
          path: '',
          name: 'worker-dashboard',
          component: () => import('@/views/DashboardView.vue'),
        },
        {
          path: 'alerts',
          name: 'worker-alerts',
          component: () => import('@/views/AlertListView.vue'),
        },
        {
          path: 'alerts/:id',
          name: 'worker-alert-detail',
          component: () => import('@/views/AlertDetailView.vue'),
          props: (route) => ({ id: Number(route.params.id) }),
        },
      ],
    },
    {
      path: '/404',
      name: 'not-found',
      component: () => import('@/views/NotFoundView.vue'),
      meta: { public: true },
    },
    {
      path: '/:pathMatch(.*)*',
      redirect: '/404',
    },
  ],
})

router.beforeEach((to) => {
  const auth = useAuthStore()
  if (to.meta.public) return true

  if (to.meta.requiresAuth && !auth.isLoggedIn) {
    return {
      path: '/login',
      query: { redirect: to.fullPath },
    }
  }

  const roles = to.meta.roles as string[] | undefined
  if (roles && auth.role && !roles.includes(auth.role)) {
    return '/404'
  }

  return true
})

export default router
