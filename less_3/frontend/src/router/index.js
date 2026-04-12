import { createRouter, createWebHistory } from 'vue-router'
import HomeView from '../views/HomeView.vue'
import { projectRoutes } from '../projects/registry'

const router = createRouter({
  history: createWebHistory(),
  routes: [
    {
      path: '/',
      name: 'home',
      component: HomeView,
    },
    ...projectRoutes,
    {
      path: '/:pathMatch(.*)*',
      redirect: '/',
    },
  ],
})

export default router