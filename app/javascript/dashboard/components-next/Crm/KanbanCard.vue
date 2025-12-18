<script setup>
import { computed } from 'vue';
import Avatar from 'dashboard/components-next/avatar/Avatar.vue';

const props = defineProps({
  deal: {
    type: Object,
    required: true,
  },
});

const formattedValue = computed(() => {
  if (!props.deal.value) return null;
  return new Intl.NumberFormat('pt-BR', {
    style: 'currency',
    currency: props.deal.currency || 'BRL',
  }).format(props.deal.value);
});

const formattedDate = computed(() => {
  if (!props.deal.expected_close_date) return null;
  return new Date(props.deal.expected_close_date).toLocaleDateString('pt-BR', {
    day: '2-digit',
    month: 'short',
  });
});

const statusBadgeClass = computed(() => {
  const statusClasses = {
    open: 'bg-n-blue-3 text-n-blue-11',
    won: 'bg-n-green-3 text-n-green-11',
    lost: 'bg-n-red-3 text-n-red-11',
  };
  return statusClasses[props.deal.status] || statusClasses.open;
});

const statusLabel = computed(() => {
  const labels = {
    open: 'Aberto',
    won: 'Ganho',
    lost: 'Perdido',
  };
  return labels[props.deal.status] || labels.open;
});
</script>

<template>
  <div
    class="cursor-pointer rounded-lg border border-n-weak bg-n-solid-1 p-3 shadow-sm transition-all hover:border-n-solid hover:shadow-md"
    :data-deal-id="deal.id"
  >
    <div class="mb-2 flex items-start justify-between gap-2">
      <h4 class="text-sm font-medium text-n-slate-12 line-clamp-2">
        {{ deal.title }}
      </h4>
      <span
        :class="statusBadgeClass"
        class="shrink-0 rounded px-1.5 py-0.5 text-xs font-medium"
      >
        {{ statusLabel }}
      </span>
    </div>

    <div v-if="formattedValue" class="mb-2">
      <span class="text-base font-semibold text-n-slate-12">
        {{ formattedValue }}
      </span>
    </div>

    <div class="flex items-center justify-between">
      <div class="flex items-center gap-2">
        <Avatar
          :name="deal.contact_name || 'Contact'"
          :size="24"
          rounded="full"
        />
        <span class="text-xs text-n-slate-11">
          {{ deal.contact_name || `#${deal.contact_id}` }}
        </span>
      </div>

      <div v-if="formattedDate" class="flex items-center gap-1 text-n-slate-11">
        <fluent-icon icon="calendar" size="12" />
        <span class="text-xs">{{ formattedDate }}</span>
      </div>
    </div>
  </div>
</template>
