<script setup>
import { computed } from 'vue';
import Draggable from 'vuedraggable';
import KanbanCard from './KanbanCard.vue';

const props = defineProps({
  stage: {
    type: Object,
    required: true,
  },
  deals: {
    type: Array,
    default: () => [],
  },
  isDragging: {
    type: Boolean,
    default: false,
  },
});

const emit = defineEmits(['deal-move', 'deal-click', 'deal-create', 'stage-edit']);

const localDeals = computed({
  get: () => props.deals,
  set: () => {},
});

const stageHeaderStyle = computed(() => ({
  borderLeftColor: props.stage.color || '#6366f1',
}));

const totalValue = computed(() => {
  const value = props.stage.deals_total_value || 0;
  return new Intl.NumberFormat('pt-BR', {
    style: 'currency',
    currency: 'BRL',
  }).format(value);
});

const dealsCount = computed(() => {
  return props.stage.deals_count || props.deals.length;
});

const onDragEnd = event => {
  emit('deal-move', event);
};

const handleDealClick = deal => {
  emit('deal-click', deal);
};

const handleAddDeal = () => {
  emit('deal-create');
};

const handleEditStage = () => {
  emit('stage-edit', props.stage);
};
</script>

<template>
  <div
    class="flex h-full w-[320px] min-w-[320px] flex-col rounded-lg bg-n-alpha-1"
  >
    <div
      class="stage-drag-handle flex cursor-grab items-center justify-between border-l-4 p-3"
      :style="stageHeaderStyle"
    >
      <div class="flex items-center gap-2">
        <h3 class="text-sm font-semibold text-n-slate-12">
          {{ stage.name }}
        </h3>
        <span
          class="flex h-5 min-w-[20px] items-center justify-center rounded-full bg-n-alpha-2 px-1.5 text-xs font-medium text-n-slate-11"
        >
          {{ dealsCount }}
        </span>
      </div>
      <div class="flex items-center gap-2">
        <span class="text-xs font-medium text-n-slate-11">
          {{ totalValue }}
        </span>
        <button
          class="rounded p-1 text-n-slate-11 transition-colors hover:bg-n-alpha-2"
          @click="handleEditStage"
        >
          <fluent-icon icon="more-vertical" size="14" />
        </button>
      </div>
    </div>

    <div class="flex-1 overflow-y-auto p-2">
      <Draggable
        v-model="localDeals"
        group="deals"
        item-key="id"
        class="flex min-h-[100px] flex-col gap-2"
        @end="onDragEnd"
      >
        <template #item="{ element: deal }">
          <KanbanCard
            :key="deal.id"
            :deal="deal"
            :data-deal-id="deal.id"
            @click="handleDealClick(deal)"
          />
        </template>
      </Draggable>
    </div>

    <div class="p-2">
      <button
        class="flex w-full items-center justify-center gap-2 rounded-lg border border-dashed border-n-weak py-2 text-sm text-n-slate-11 transition-colors hover:border-n-solid hover:bg-n-alpha-2"
        @click="handleAddDeal"
      >
        <fluent-icon icon="add" size="14" />
        <span>{{ $t('CRM.KANBAN.ADD_DEAL') }}</span>
      </button>
    </div>
  </div>
</template>
