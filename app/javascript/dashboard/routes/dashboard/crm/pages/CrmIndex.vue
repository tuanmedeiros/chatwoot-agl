<script setup>
import { ref, computed, onMounted, watch } from 'vue';
import { useStore } from 'dashboard/composables/store';
import { useI18n } from 'dashboard/composables';
import KanbanBoard from 'dashboard/components-next/Crm/KanbanBoard.vue';
import PipelineSelector from 'dashboard/components-next/Crm/PipelineSelector.vue';
import DealForm from 'dashboard/components-next/Crm/DealForm.vue';
import StageForm from 'dashboard/components-next/Crm/StageForm.vue';
import Dialog from 'dashboard/components-next/dialog/Dialog.vue';
import Spinner from 'dashboard/components-next/spinner/Spinner.vue';

const store = useStore();
const { t } = useI18n();

const selectedPipelineId = ref(null);
const showDealModal = ref(false);
const showStageModal = ref(false);
const selectedDeal = ref(null);
const selectedStage = ref(null);
const selectedStageIdForNewDeal = ref(null);

const pipelines = computed(() => store.getters['crmPipelines/getPipelines']);
const isLoadingPipelines = computed(
  () => store.getters['crmPipelines/getUIFlags'].isFetching
);

const currentPipeline = computed(() => {
  if (!selectedPipelineId.value) return null;
  return pipelines.value.find(p => p.id === selectedPipelineId.value);
});

const fetchPipelines = async () => {
  await store.dispatch('crmPipelines/get');
  if (pipelines.value.length > 0 && !selectedPipelineId.value) {
    const defaultPipeline = pipelines.value.find(p => p.is_default);
    selectedPipelineId.value = defaultPipeline?.id || pipelines.value[0].id;
  }
};

const handleDealClick = deal => {
  selectedDeal.value = deal;
  showDealModal.value = true;
};

const handleDealCreate = stageId => {
  selectedDeal.value = null;
  selectedStageIdForNewDeal.value = stageId;
  showDealModal.value = true;
};

const handleStageCreate = () => {
  selectedStage.value = null;
  showStageModal.value = true;
};

const handlePipelineCreate = async () => {
  const name = prompt(t('CRM.PIPELINE.NAME_PROMPT'));
  if (name) {
    const pipeline = await store.dispatch('crmPipelines/create', { name });
    selectedPipelineId.value = pipeline.id;
  }
};

const closeDealModal = () => {
  showDealModal.value = false;
  selectedDeal.value = null;
  selectedStageIdForNewDeal.value = null;
};

const closeStageModal = () => {
  showStageModal.value = false;
  selectedStage.value = null;
};

const handleDealSubmit = async () => {
  closeDealModal();
  if (selectedPipelineId.value) {
    await store.dispatch('crmDeals/get', {
      pipelineId: selectedPipelineId.value,
    });
    await store.dispatch('crmDeals/fetchSummary', selectedPipelineId.value);
  }
};

const handleStageSubmit = async () => {
  closeStageModal();
  if (selectedPipelineId.value) {
    await store.dispatch('crmStages/get', selectedPipelineId.value);
  }
};

onMounted(() => {
  fetchPipelines();
});

watch(selectedPipelineId, newId => {
  if (newId) {
    store.dispatch('crmPipelines/selectPipeline', newId);
  }
});
</script>

<template>
  <div class="flex h-full flex-col bg-n-background">
    <header
      class="flex items-center justify-between border-b border-n-weak bg-n-solid-2 px-6 py-4"
    >
      <div class="flex items-center gap-4">
        <h1 class="text-xl font-semibold text-n-slate-12">
          {{ t('CRM.TITLE') }}
        </h1>
        <PipelineSelector
          v-if="!isLoadingPipelines && pipelines.length > 0"
          v-model="selectedPipelineId"
          @create="handlePipelineCreate"
        />
      </div>

      <div class="flex items-center gap-2">
        <span
          v-if="currentPipeline"
          class="text-sm text-n-slate-11"
        >
          {{ t('CRM.KANBAN.PIPELINE') }}: {{ currentPipeline.name }}
        </span>
      </div>
    </header>

    <main class="flex-1 overflow-hidden">
      <div v-if="isLoadingPipelines" class="flex h-full items-center justify-center">
        <Spinner size="large" />
      </div>

      <div
        v-else-if="pipelines.length === 0"
        class="flex h-full flex-col items-center justify-center gap-4"
      >
        <fluent-icon icon="board" size="48" class="text-n-slate-9" />
        <h2 class="text-lg font-medium text-n-slate-11">
          {{ t('CRM.EMPTY_STATE.TITLE') }}
        </h2>
        <p class="text-sm text-n-slate-9">
          {{ t('CRM.EMPTY_STATE.DESCRIPTION') }}
        </p>
        <button
          class="rounded-lg bg-n-brand px-4 py-2 text-sm font-medium text-white hover:bg-n-brand-dark"
          @click="handlePipelineCreate"
        >
          {{ t('CRM.EMPTY_STATE.CREATE_PIPELINE') }}
        </button>
      </div>

      <KanbanBoard
        v-else-if="selectedPipelineId"
        :pipeline-id="selectedPipelineId"
        @deal-click="handleDealClick"
        @deal-create="handleDealCreate"
        @stage-create="handleStageCreate"
      />
    </main>

    <Dialog
      v-model:show="showDealModal"
      :title="
        selectedDeal ? t('CRM.DEAL_FORM.EDIT_TITLE') : t('CRM.DEAL_FORM.CREATE_TITLE')
      "
    >
      <DealForm
        :deal="selectedDeal"
        :pipeline-id="selectedPipelineId"
        :stage-id="selectedStageIdForNewDeal"
        @submit="handleDealSubmit"
        @cancel="closeDealModal"
      />
    </Dialog>

    <Dialog
      v-model:show="showStageModal"
      :title="
        selectedStage
          ? t('CRM.STAGE_FORM.EDIT_TITLE')
          : t('CRM.STAGE_FORM.CREATE_TITLE')
      "
    >
      <StageForm
        :stage="selectedStage"
        :pipeline-id="selectedPipelineId"
        @submit="handleStageSubmit"
        @cancel="closeStageModal"
      />
    </Dialog>
  </div>
</template>
