import types from '../../mutation-types';
import PipelinesAPI from '../../../api/crm/pipelines';

const state = {
  records: [],
  uiFlags: {
    isFetching: false,
    isCreating: false,
    isUpdating: false,
    isDeleting: false,
  },
  selectedPipelineId: null,
};

const getters = {
  getPipelines: $state => $state.records,
  getUIFlags: $state => $state.uiFlags,
  getSelectedPipelineId: $state => $state.selectedPipelineId,
  getSelectedPipeline: $state => {
    if (!$state.selectedPipelineId) {
      return $state.records.find(p => p.is_default) || $state.records[0];
    }
    return $state.records.find(p => p.id === $state.selectedPipelineId);
  },
  getPipelineById: $state => id => $state.records.find(p => p.id === id),
};

const actions = {
  get: async ({ commit }) => {
    commit(types.SET_CRM_PIPELINES_UI_FLAG, { isFetching: true });
    try {
      const { data } = await PipelinesAPI.get();
      commit(types.SET_CRM_PIPELINES, data.payload);
    } catch (error) {
      throw new Error(error);
    } finally {
      commit(types.SET_CRM_PIPELINES_UI_FLAG, { isFetching: false });
    }
  },

  create: async ({ commit }, pipelineData) => {
    commit(types.SET_CRM_PIPELINES_UI_FLAG, { isCreating: true });
    try {
      const { data } = await PipelinesAPI.create(pipelineData);
      commit(types.ADD_CRM_PIPELINE, data.payload);
      return data.payload;
    } catch (error) {
      throw new Error(error);
    } finally {
      commit(types.SET_CRM_PIPELINES_UI_FLAG, { isCreating: false });
    }
  },

  update: async ({ commit }, { id, ...pipelineData }) => {
    commit(types.SET_CRM_PIPELINES_UI_FLAG, { isUpdating: true });
    try {
      const { data } = await PipelinesAPI.update(id, pipelineData);
      commit(types.EDIT_CRM_PIPELINE, data.payload);
      return data.payload;
    } catch (error) {
      throw new Error(error);
    } finally {
      commit(types.SET_CRM_PIPELINES_UI_FLAG, { isUpdating: false });
    }
  },

  delete: async ({ commit }, id) => {
    commit(types.SET_CRM_PIPELINES_UI_FLAG, { isDeleting: true });
    try {
      await PipelinesAPI.delete(id);
      commit(types.DELETE_CRM_PIPELINE, id);
    } catch (error) {
      throw new Error(error);
    } finally {
      commit(types.SET_CRM_PIPELINES_UI_FLAG, { isDeleting: false });
    }
  },

  duplicate: async ({ commit }, id) => {
    commit(types.SET_CRM_PIPELINES_UI_FLAG, { isCreating: true });
    try {
      const { data } = await PipelinesAPI.duplicate(id);
      commit(types.ADD_CRM_PIPELINE, data.payload);
      return data.payload;
    } catch (error) {
      throw new Error(error);
    } finally {
      commit(types.SET_CRM_PIPELINES_UI_FLAG, { isCreating: false });
    }
  },

  setDefault: async ({ commit }, id) => {
    commit(types.SET_CRM_PIPELINES_UI_FLAG, { isUpdating: true });
    try {
      const { data } = await PipelinesAPI.setDefault(id);
      commit(types.EDIT_CRM_PIPELINE, data.payload);
      return data.payload;
    } catch (error) {
      throw new Error(error);
    } finally {
      commit(types.SET_CRM_PIPELINES_UI_FLAG, { isUpdating: false });
    }
  },

  selectPipeline: ({ commit }, pipelineId) => {
    commit(types.SET_CRM_PIPELINE, pipelineId);
  },
};

const mutations = {
  [types.SET_CRM_PIPELINES_UI_FLAG]($state, flags) {
    $state.uiFlags = { ...$state.uiFlags, ...flags };
  },

  [types.SET_CRM_PIPELINES]($state, pipelines) {
    $state.records = pipelines;
  },

  [types.SET_CRM_PIPELINE]($state, pipelineId) {
    $state.selectedPipelineId = pipelineId;
  },

  [types.ADD_CRM_PIPELINE]($state, pipeline) {
    $state.records.push(pipeline);
  },

  [types.EDIT_CRM_PIPELINE]($state, pipeline) {
    const index = $state.records.findIndex(p => p.id === pipeline.id);
    if (index !== -1) {
      $state.records.splice(index, 1, pipeline);
    }
  },

  [types.DELETE_CRM_PIPELINE]($state, id) {
    $state.records = $state.records.filter(p => p.id !== id);
  },
};

export default {
  namespaced: true,
  state,
  getters,
  actions,
  mutations,
};
