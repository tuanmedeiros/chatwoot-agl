<script setup>
import { ref, computed, onMounted } from 'vue';
import { useStore } from 'dashboard/composables/store';
import { useI18n } from 'dashboard/composables';

const props = defineProps({
  deal: {
    type: Object,
    default: null,
  },
  pipelineId: {
    type: Number,
    required: true,
  },
  stageId: {
    type: Number,
    default: null,
  },
});

const emit = defineEmits(['submit', 'cancel']);

const store = useStore();
const { t } = useI18n();

const formData = ref({
  title: '',
  contact_id: null,
  value: '',
  currency: 'BRL',
  expected_close_date: '',
  pipeline_id: props.pipelineId,
  stage_id: props.stageId,
});

const isEditing = computed(() => !!props.deal);
const isSubmitting = computed(() => {
  const flags = store.getters['crmDeals/getUIFlags'];
  return flags.isCreating || flags.isUpdating;
});

const stages = computed(() => {
  return store.getters['crmStages/getStagesByPipeline'](props.pipelineId);
});

const currencyOptions = [
  { value: 'BRL', label: 'BRL (R$)' },
  { value: 'USD', label: 'USD ($)' },
  { value: 'EUR', label: 'EUR (€)' },
];

const initForm = () => {
  if (props.deal) {
    formData.value = {
      title: props.deal.title || '',
      contact_id: props.deal.contact_id,
      value: props.deal.value || '',
      currency: props.deal.currency || 'BRL',
      expected_close_date: props.deal.expected_close_date || '',
      pipeline_id: props.deal.pipeline_id,
      stage_id: props.deal.stage_id,
    };
  } else if (props.stageId) {
    formData.value.stage_id = props.stageId;
  } else if (stages.value.length > 0) {
    formData.value.stage_id = stages.value[0].id;
  }
};

const handleSubmit = async () => {
  const data = {
    ...formData.value,
    value: parseFloat(formData.value.value) || 0,
  };

  if (isEditing.value) {
    await store.dispatch('crmDeals/update', { id: props.deal.id, ...data });
  } else {
    await store.dispatch('crmDeals/create', data);
  }

  emit('submit');
};

const handleCancel = () => {
  emit('cancel');
};

onMounted(() => {
  initForm();
});
</script>

<template>
  <form class="flex flex-col gap-4" @submit.prevent="handleSubmit">
    <div class="flex flex-col gap-1">
      <label class="text-sm font-medium text-n-slate-12">
        {{ t('CRM.DEAL_FORM.TITLE') }}
      </label>
      <input
        v-model="formData.title"
        type="text"
        required
        class="rounded-lg border border-n-weak bg-n-solid-1 px-3 py-2 text-sm text-n-slate-12 placeholder:text-n-slate-9 focus:border-n-brand focus:outline-none"
        :placeholder="t('CRM.DEAL_FORM.TITLE_PLACEHOLDER')"
      />
    </div>

    <div class="flex flex-col gap-1">
      <label class="text-sm font-medium text-n-slate-12">
        {{ t('CRM.DEAL_FORM.CONTACT_ID') }}
      </label>
      <input
        v-model="formData.contact_id"
        type="number"
        required
        class="rounded-lg border border-n-weak bg-n-solid-1 px-3 py-2 text-sm text-n-slate-12 placeholder:text-n-slate-9 focus:border-n-brand focus:outline-none"
        :placeholder="t('CRM.DEAL_FORM.CONTACT_ID_PLACEHOLDER')"
      />
    </div>

    <div class="flex gap-4">
      <div class="flex flex-1 flex-col gap-1">
        <label class="text-sm font-medium text-n-slate-12">
          {{ t('CRM.DEAL_FORM.VALUE') }}
        </label>
        <input
          v-model="formData.value"
          type="number"
          step="0.01"
          min="0"
          class="rounded-lg border border-n-weak bg-n-solid-1 px-3 py-2 text-sm text-n-slate-12 placeholder:text-n-slate-9 focus:border-n-brand focus:outline-none"
          placeholder="0.00"
        />
      </div>

      <div class="flex w-32 flex-col gap-1">
        <label class="text-sm font-medium text-n-slate-12">
          {{ t('CRM.DEAL_FORM.CURRENCY') }}
        </label>
        <select
          v-model="formData.currency"
          class="rounded-lg border border-n-weak bg-n-solid-1 px-3 py-2 text-sm text-n-slate-12 focus:border-n-brand focus:outline-none"
        >
          <option
            v-for="option in currencyOptions"
            :key="option.value"
            :value="option.value"
          >
            {{ option.label }}
          </option>
        </select>
      </div>
    </div>

    <div class="flex flex-col gap-1">
      <label class="text-sm font-medium text-n-slate-12">
        {{ t('CRM.DEAL_FORM.STAGE') }}
      </label>
      <select
        v-model="formData.stage_id"
        required
        class="rounded-lg border border-n-weak bg-n-solid-1 px-3 py-2 text-sm text-n-slate-12 focus:border-n-brand focus:outline-none"
      >
        <option v-for="stage in stages" :key="stage.id" :value="stage.id">
          {{ stage.name }}
        </option>
      </select>
    </div>

    <div class="flex flex-col gap-1">
      <label class="text-sm font-medium text-n-slate-12">
        {{ t('CRM.DEAL_FORM.EXPECTED_CLOSE_DATE') }}
      </label>
      <input
        v-model="formData.expected_close_date"
        type="date"
        class="rounded-lg border border-n-weak bg-n-solid-1 px-3 py-2 text-sm text-n-slate-12 focus:border-n-brand focus:outline-none"
      />
    </div>

    <div class="flex justify-end gap-2 pt-4">
      <button
        type="button"
        class="rounded-lg border border-n-weak px-4 py-2 text-sm font-medium text-n-slate-11 transition-colors hover:bg-n-alpha-2"
        @click="handleCancel"
      >
        {{ t('CRM.DEAL_FORM.CANCEL') }}
      </button>
      <button
        type="submit"
        :disabled="isSubmitting"
        class="rounded-lg bg-n-brand px-4 py-2 text-sm font-medium text-white transition-colors hover:bg-n-brand-dark disabled:opacity-50"
      >
        {{ isEditing ? t('CRM.DEAL_FORM.UPDATE') : t('CRM.DEAL_FORM.CREATE') }}
      </button>
    </div>
  </form>
</template>
