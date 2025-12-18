<script setup>
import { ref, computed, onMounted, watch } from 'vue';
import { useStore } from 'dashboard/composables/store';
import Draggable from 'vuedraggable';
import KanbanColumn from './KanbanColumn.vue';
import Spinner from 'dashboard/components-next/spinner/Spinner.vue';

const props = defineProps({
  pipelineId: {
    type: Number,
    required: true,
  },
});

const emit = defineEmits(['deal-click', 'deal-create', 'stage-create']);

const store = useStore();
const isDraggingStage = ref(false);

const stages = computed(() => {
  return store.getters['crmStages/getStagesByPipeline'](props.pipelineId);
});

const deals = computed(() => {
  return store.getters['crmDeals/getDeals'];
});

const isLoading = computed(() => {
  return (
    store.getters['crmStages/getUIFlags'].isFetching ||
    store.getters['crmDeals/getUIFlags'].isFetching
  );
});

const getDealsByStage = stageId => {
  return deals.value
    .filter(deal => deal.stage_id === stageId)
    .sort((a, b) => a.position - b.position);
};

const fetchData = async () => {
  if (props.pipelineId) {
    await Promise.all([
      store.dispatch('crmStages/get', props.pipelineId),
      store.dispatch('crmDeals/get', { pipelineId: props.pipelineId }),
      store.dispatch('crmDeals/fetchSummary', props.pipelineId),
    ]);
  }
};

const onStageReorder = async () => {
  isDraggingStage.value = false;
  await store.dispatch('crmStages/reorder', {
    pipelineId: props.pipelineId,
    stages: stages.value,
  });
};

const onDealMove = async (event, stageId) => {
  const { item, newIndex } = event;
  const dealId = parseInt(item.dataset.dealId, 10);

  store.dispatch('crmDeals/moveLocal', {
    dealId,
    stageId,
    position: newIndex,
  });

  await store.dispatch('crmDeals/move', {
    id: dealId,
    stageId,
    position: newIndex,
  });

  await store.dispatch('crmDeals/fetchSummary', props.pipelineId);
};

const handleDealClick = deal => {
  emit('deal-click', deal);
};

const handleDealCreate = stageId => {
  emit('deal-create', stageId);
};

const handleStageCreate = () => {
  emit('stage-create');
};

onMounted(() => {
  fetchData();
});

watch(
  () => props.pipelineId,
  () => {
    fetchData();
  }
);
</script>

<template>
  <div class="flex h-full w-full flex-col">
    <div v-if="isLoading" class="flex h-full items-center justify-center">
      <Spinner size="large" />
    </div>

    <div v-else class="flex h-full gap-4 overflow-x-auto p-4">
      <Draggable
        v-model="stages"
        :disabled="false"
        item-key="id"
        handle=".stage-drag-handle"
        class="flex gap-4"
        @start="isDraggingStage = true"
        @end="onStageReorder"
      >
        <template #item="{ element: stage }">
          <KanbanColumn
            :key="stage.id"
            :stage="stage"
            :deals="getDealsByStage(stage.id)"
            :is-dragging="isDraggingStage"
            @deal-move="event => onDealMove(event, stage.id)"
            @deal-click="handleDealClick"
            @deal-create="handleDealCreate(stage.id)"
          />
        </template>
      </Draggable>

      <button
        class="flex h-12 min-w-[280px] items-center justify-center gap-2 rounded-lg border-2 border-dashed border-n-weak bg-n-alpha-1 text-n-slate-11 transition-colors hover:border-n-solid hover:bg-n-alpha-2"
        @click="handleStageCreate"
      >
        <fluent-icon icon="add" size="16" />
        <span>{{ $t('CRM.KANBAN.ADD_STAGE') }}</span>
      </button>
    </div>
  </div>
</template>
