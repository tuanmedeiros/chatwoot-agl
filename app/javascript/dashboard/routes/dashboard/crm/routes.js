import { frontendURL } from 'dashboard/helper/URLHelper';

const CrmIndex = () => import('./pages/CrmIndex.vue');

export default {
  routes: [
    {
      path: frontendURL('accounts/:accountId/crm'),
      name: 'crm_dashboard',
      meta: {
        permissions: ['administrator', 'agent'],
      },
      component: CrmIndex,
    },
  ],
};
