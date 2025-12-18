<script setup>
import { computed } from 'vue';
import { useStore } from 'dashboard/composables/store';

const props = defineProps({
  modelValue: {
    type: Number,
    default: null,
  },
});

const emit = defineEmits(['update:modelValue', 'create']);

const store = useStore();

const pipelines = computed(() => {
  return store.getters['crmPipelines/getPipelines'];
});

const selectedPipeline = computed(() => {
  return pipelines.value.find(p => p.id === props.modelValue);
});

const handleSelect = pipelineId => {
  emit('update:modelValue', pipelineId);
};

const handleCreate = () => {
  emit('create');
};
</script>

<template>
  <div class="relative">
    <div class="flex items-center gap-2">
      <select
        :value="modelValue"
        class="rounded-lg border border-n-weak bg-n-solid-1 px-3 py-2 pr-8 text-sm font-medium text-n-slate-12 focus:border-n-brand focus:outline-none"
        @change="handleSelect(Number($event.target.value))"
      >
        <option
          v-for="pipeline in pipelines"
          :key="pipeline.id"
          :value="pipeline.id"
        >
          {{ pipeline.name }}
          <template v-if="pipeline.is_default">(Default)</template>
        </option>
      </select>

      <button
        class="flex items-center gap-1 rounded-lg border border-n-weak px-3 py-2 text-sm text-n-slate-11 transition-colors hover:bg-n-alpha-2"
        @click="handleCreate"
      >
        <fluent-icon icon="add" size="14" />
        <span>{{ $t('CRM.PIPELINE.NEW') }}</span>
      </button>
    </div>
  </div>
</template>
