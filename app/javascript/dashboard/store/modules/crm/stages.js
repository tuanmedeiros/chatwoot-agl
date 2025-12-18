import types from '../../mutation-types';
import StagesAPI from '../../../api/crm/stages';

const state = {
  records: {},
  uiFlags: {
    isFetching: false,
    isCreating: false,
    isUpdating: false,
    isDeleting: false,
    isReordering: false,
  },
};

const getters = {
  getStagesByPipeline: $state => pipelineId => $state.records[pipelineId] || [],
  getUIFlags: $state => $state.uiFlags,
  getStageById: $state => (pipelineId, stageId) => {
    const stages = $state.records[pipelineId] || [];
    return stages.find(s => s.id === stageId);
  },
};

const actions = {
  get: async ({ commit }, pipelineId) => {
    commit(types.SET_CRM_STAGES_UI_FLAG, { isFetching: true });
    try {
      const { data } = await StagesAPI.get(pipelineId);
      commit(types.SET_CRM_STAGES, { pipelineId, stages: data.payload });
    } catch (error) {
      throw new Error(error);
    } finally {
      commit(types.SET_CRM_STAGES_UI_FLAG, { isFetching: false });
    }
  },

  create: async ({ commit }, { pipelineId, ...stageData }) => {
    commit(types.SET_CRM_STAGES_UI_FLAG, { isCreating: true });
    try {
      const { data } = await StagesAPI.create(pipelineId, stageData);
      commit(types.ADD_CRM_STAGE, { pipelineId, stage: data.payload });
      return data.payload;
    } catch (error) {
      throw new Error(error);
    } finally {
      commit(types.SET_CRM_STAGES_UI_FLAG, { isCreating: false });
    }
  },

  update: async ({ commit }, { pipelineId, id, ...stageData }) => {
    commit(types.SET_CRM_STAGES_UI_FLAG, { isUpdating: true });
    try {
      const { data } = await StagesAPI.update(pipelineId, id, stageData);
      commit(types.EDIT_CRM_STAGE, { pipelineId, stage: data.payload });
      return data.payload;
    } catch (error) {
      throw new Error(error);
    } finally {
      commit(types.SET_CRM_STAGES_UI_FLAG, { isUpdating: false });
    }
  },

  delete: async ({ commit }, { pipelineId, id }) => {
    commit(types.SET_CRM_STAGES_UI_FLAG, { isDeleting: true });
    try {
      await StagesAPI.delete(pipelineId, id);
      commit(types.DELETE_CRM_STAGE, { pipelineId, id });
    } catch (error) {
      throw new Error(error);
    } finally {
      commit(types.SET_CRM_STAGES_UI_FLAG, { isDeleting: false });
    }
  },

  reorder: async ({ commit }, { pipelineId, stages }) => {
    commit(types.SET_CRM_STAGES_UI_FLAG, { isReordering: true });
    try {
      const stagesPayload = stages.map((stage, index) => ({
        id: stage.id,
        position: index,
      }));
      const { data } = await StagesAPI.reorder(pipelineId, stagesPayload);
      commit(types.SET_CRM_STAGES, { pipelineId, stages: data.payload });
    } catch (error) {
      throw new Error(error);
    } finally {
      commit(types.SET_CRM_STAGES_UI_FLAG, { isReordering: false });
    }
  },

  updateLocalOrder: ({ commit }, { pipelineId, stages }) => {
    commit(types.REORDER_CRM_STAGES, { pipelineId, stages });
  },
};

const mutations = {
  [types.SET_CRM_STAGES_UI_FLAG]($state, flags) {
    $state.uiFlags = { ...$state.uiFlags, ...flags };
  },

  [types.SET_CRM_STAGES]($state, { pipelineId, stages }) {
    $state.records = { ...$state.records, [pipelineId]: stages };
  },

  [types.ADD_CRM_STAGE]($state, { pipelineId, stage }) {
    const stages = $state.records[pipelineId] || [];
    $state.records = { ...$state.records, [pipelineId]: [...stages, stage] };
  },

  [types.EDIT_CRM_STAGE]($state, { pipelineId, stage }) {
    const stages = $state.records[pipelineId] || [];
    const index = stages.findIndex(s => s.id === stage.id);
    if (index !== -1) {
      stages.splice(index, 1, stage);
      $state.records = { ...$state.records, [pipelineId]: [...stages] };
    }
  },

  [types.DELETE_CRM_STAGE]($state, { pipelineId, id }) {
    const stages = $state.records[pipelineId] || [];
    $state.records = {
      ...$state.records,
      [pipelineId]: stages.filter(s => s.id !== id),
    };
  },

  [types.REORDER_CRM_STAGES]($state, { pipelineId, stages }) {
    $state.records = { ...$state.records, [pipelineId]: stages };
  },
};

export default {
  namespaced: true,
  state,
  getters,
  actions,
  mutations,
};
