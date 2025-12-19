<script setup>
import { ref, computed, onMounted } from 'vue';
import { useStore } from 'dashboard/composables/store';
import { useI18n } from 'vue-i18n';

const props = defineProps({
  stage: {
    type: Object,
    default: null,
  },
  pipelineId: {
    type: Number,
    required: true,
  },
});

const emit = defineEmits(['submit', 'cancel']);

const store = useStore();
const { t } = useI18n();

const colorOptions = [
  '#6366f1', // indigo
  '#8b5cf6', // violet
  '#a855f7', // purple
  '#ec4899', // pink
  '#ef4444', // red
  '#f97316', // orange
  '#f59e0b', // amber
  '#eab308', // yellow
  '#84cc16', // lime
  '#22c55e', // green
  '#14b8a6', // teal
  '#06b6d4', // cyan
  '#3b82f6', // blue
];

const formData = ref({
  name: '',
  color: '#6366f1',
  is_won: false,
  is_lost: false,
});

const isEditing = computed(() => !!props.stage);
const isSubmitting = computed(() => {
  const flags = store.getters['crmStages/getUIFlags'];
  return flags.isCreating || flags.isUpdating;
});

const initForm = () => {
  if (props.stage) {
    formData.value = {
      name: props.stage.name || '',
      color: props.stage.color || '#6366f1',
      is_won: props.stage.is_won || false,
      is_lost: props.stage.is_lost || false,
    };
  }
};

const handleSubmit = async () => {
  if (isEditing.value) {
    await store.dispatch('crmStages/update', {
      pipelineId: props.pipelineId,
      id: props.stage.id,
      ...formData.value,
    });
  } else {
    await store.dispatch('crmStages/create', {
      pipelineId: props.pipelineId,
      ...formData.value,
    });
  }

  emit('submit');
};

const handleCancel = () => {
  emit('cancel');
};

const handleStageTypeChange = type => {
  if (type === 'won') {
    formData.value.is_won = true;
    formData.value.is_lost = false;
  } else if (type === 'lost') {
    formData.value.is_won = false;
    formData.value.is_lost = true;
  } else {
    formData.value.is_won = false;
    formData.value.is_lost = false;
  }
};

const currentStageType = computed(() => {
  if (formData.value.is_won) return 'won';
  if (formData.value.is_lost) return 'lost';
  return 'active';
});

onMounted(() => {
  initForm();
});
</script>

<template>
  <form class="flex flex-col gap-4" @submit.prevent="handleSubmit">
    <div class="flex flex-col gap-1">
      <label class="text-sm font-medium text-n-slate-12">
        {{ t('CRM.STAGE_FORM.NAME') }}
      </label>
      <input
        v-model="formData.name"
        type="text"
        required
        class="rounded-lg border border-n-weak bg-n-solid-1 px-3 py-2 text-sm text-n-slate-12 placeholder:text-n-slate-9 focus:border-n-brand focus:outline-none"
        :placeholder="t('CRM.STAGE_FORM.NAME_PLACEHOLDER')"
      />
    </div>

    <div class="flex flex-col gap-2">
      <label class="text-sm font-medium text-n-slate-12">
        {{ t('CRM.STAGE_FORM.COLOR') }}
      </label>
      <div class="flex flex-wrap gap-2">
        <button
          v-for="color in colorOptions"
          :key="color"
          type="button"
          class="h-8 w-8 rounded-full border-2 transition-all"
          :class="
            formData.color === color
              ? 'border-n-slate-12 scale-110'
              : 'border-transparent hover:scale-105'
          "
          :style="{ backgroundColor: color }"
          @click="formData.color = color"
        />
      </div>
    </div>

    <div class="flex flex-col gap-2">
      <label class="text-sm font-medium text-n-slate-12">
        {{ t('CRM.STAGE_FORM.TYPE') }}
      </label>
      <div class="flex gap-2">
        <button
          type="button"
          class="flex-1 rounded-lg border px-3 py-2 text-sm font-medium transition-colors"
          :class="
            currentStageType === 'active'
              ? 'border-n-brand bg-n-brand-alpha text-n-brand'
              : 'border-n-weak text-n-slate-11 hover:bg-n-alpha-2'
          "
          @click="handleStageTypeChange('active')"
        >
          {{ t('CRM.STAGE_FORM.TYPE_ACTIVE') }}
        </button>
        <button
          type="button"
          class="flex-1 rounded-lg border px-3 py-2 text-sm font-medium transition-colors"
          :class="
            currentStageType === 'won'
              ? 'border-n-green-7 bg-n-green-3 text-n-green-11'
              : 'border-n-weak text-n-slate-11 hover:bg-n-alpha-2'
          "
          @click="handleStageTypeChange('won')"
        >
          {{ t('CRM.STAGE_FORM.TYPE_WON') }}
        </button>
        <button
          type="button"
          class="flex-1 rounded-lg border px-3 py-2 text-sm font-medium transition-colors"
          :class="
            currentStageType === 'lost'
              ? 'border-n-red-7 bg-n-red-3 text-n-red-11'
              : 'border-n-weak text-n-slate-11 hover:bg-n-alpha-2'
          "
          @click="handleStageTypeChange('lost')"
        >
          {{ t('CRM.STAGE_FORM.TYPE_LOST') }}
        </button>
      </div>
    </div>

    <div class="flex justify-end gap-2 pt-4">
      <button
        type="button"
        class="rounded-lg border border-n-weak px-4 py-2 text-sm font-medium text-n-slate-11 transition-colors hover:bg-n-alpha-2"
        @click="handleCancel"
      >
        {{ t('CRM.STAGE_FORM.CANCEL') }}
      </button>
      <button
        type="submit"
        :disabled="isSubmitting"
        class="rounded-lg bg-n-brand px-4 py-2 text-sm font-medium text-white transition-colors hover:bg-n-brand-dark disabled:opacity-50"
      >
        {{
          isEditing ? t('CRM.STAGE_FORM.UPDATE') : t('CRM.STAGE_FORM.CREATE')
        }}
      </button>
    </div>
  </form>
</template>
