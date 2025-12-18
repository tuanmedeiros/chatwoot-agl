import types from '../../mutation-types';
import DealsAPI from '../../../api/crm/deals';

const state = {
  records: [],
  meta: {
    count: 0,
    currentPage: 1,
  },
  activities: {},
  summary: [],
  uiFlags: {
    isFetching: false,
    isCreating: false,
    isUpdating: false,
    isDeleting: false,
    isMoving: false,
    isFetchingActivities: false,
    isFetchingSummary: false,
  },
};

const getters = {
  getDeals: $state => $state.records,
  getDealsByStage: $state => stageId =>
    $state.records.filter(d => d.stage_id === stageId),
  getUIFlags: $state => $state.uiFlags,
  getMeta: $state => $state.meta,
  getDealById: $state => id => $state.records.find(d => d.id === id),
  getActivities: $state => dealId => $state.activities[dealId] || [],
  getSummary: $state => $state.summary,
};

const actions = {
  get: async ({ commit }, params = {}) => {
    commit(types.SET_CRM_DEALS_UI_FLAG, { isFetching: true });
    try {
      const { data } = await DealsAPI.get(params);
      commit(types.CLEAR_CRM_DEALS);
      commit(types.SET_CRM_DEALS, data.payload);
      commit(types.SET_CRM_DEALS_META, data.meta);
    } catch (error) {
      throw new Error(error);
    } finally {
      commit(types.SET_CRM_DEALS_UI_FLAG, { isFetching: false });
    }
  },

  show: async ({ commit }, id) => {
    commit(types.SET_CRM_DEALS_UI_FLAG, { isFetching: true });
    try {
      const { data } = await DealsAPI.show(id);
      commit(types.SET_CRM_DEAL, data.payload);
      return data.payload;
    } catch (error) {
      throw new Error(error);
    } finally {
      commit(types.SET_CRM_DEALS_UI_FLAG, { isFetching: false });
    }
  },

  create: async ({ commit }, dealData) => {
    commit(types.SET_CRM_DEALS_UI_FLAG, { isCreating: true });
    try {
      const { data } = await DealsAPI.create(dealData);
      commit(types.ADD_CRM_DEAL, data.payload);
      return data.payload;
    } catch (error) {
      throw new Error(error);
    } finally {
      commit(types.SET_CRM_DEALS_UI_FLAG, { isCreating: false });
    }
  },

  update: async ({ commit }, { id, ...dealData }) => {
    commit(types.SET_CRM_DEALS_UI_FLAG, { isUpdating: true });
    try {
      const { data } = await DealsAPI.update(id, dealData);
      commit(types.EDIT_CRM_DEAL, data.payload);
      return data.payload;
    } catch (error) {
      throw new Error(error);
    } finally {
      commit(types.SET_CRM_DEALS_UI_FLAG, { isUpdating: false });
    }
  },

  delete: async ({ commit }, id) => {
    commit(types.SET_CRM_DEALS_UI_FLAG, { isDeleting: true });
    try {
      await DealsAPI.delete(id);
      commit(types.DELETE_CRM_DEAL, id);
    } catch (error) {
      throw new Error(error);
    } finally {
      commit(types.SET_CRM_DEALS_UI_FLAG, { isDeleting: false });
    }
  },

  move: async ({ commit }, { id, stageId, position }) => {
    commit(types.SET_CRM_DEALS_UI_FLAG, { isMoving: true });
    try {
      const { data } = await DealsAPI.move(id, stageId, position);
      commit(types.EDIT_CRM_DEAL, data.payload);
      return data.payload;
    } catch (error) {
      throw new Error(error);
    } finally {
      commit(types.SET_CRM_DEALS_UI_FLAG, { isMoving: false });
    }
  },

  moveLocal: ({ commit }, { dealId, stageId, position }) => {
    commit(types.MOVE_CRM_DEAL, { dealId, stageId, position });
  },

  markAsWon: async ({ commit }, id) => {
    commit(types.SET_CRM_DEALS_UI_FLAG, { isUpdating: true });
    try {
      const { data } = await DealsAPI.markAsWon(id);
      commit(types.EDIT_CRM_DEAL, data.payload);
      return data.payload;
    } catch (error) {
      throw new Error(error);
    } finally {
      commit(types.SET_CRM_DEALS_UI_FLAG, { isUpdating: false });
    }
  },

  markAsLost: async ({ commit }, { id, reason }) => {
    commit(types.SET_CRM_DEALS_UI_FLAG, { isUpdating: true });
    try {
      const { data } = await DealsAPI.markAsLost(id, reason);
      commit(types.EDIT_CRM_DEAL, data.payload);
      return data.payload;
    } catch (error) {
      throw new Error(error);
    } finally {
      commit(types.SET_CRM_DEALS_UI_FLAG, { isUpdating: false });
    }
  },

  fetchActivities: async ({ commit }, dealId) => {
    commit(types.SET_CRM_DEALS_UI_FLAG, { isFetchingActivities: true });
    try {
      const { data } = await DealsAPI.getActivities(dealId);
      commit(types.SET_CRM_DEAL_ACTIVITIES, { dealId, activities: data.payload });
    } catch (error) {
      throw new Error(error);
    } finally {
      commit(types.SET_CRM_DEALS_UI_FLAG, { isFetchingActivities: false });
    }
  },

  fetchSummary: async ({ commit }, pipelineId) => {
    commit(types.SET_CRM_DEALS_UI_FLAG, { isFetchingSummary: true });
    try {
      const { data } = await DealsAPI.getSummary(pipelineId);
      commit(types.SET_CRM_DEALS_SUMMARY, data.payload);
    } catch (error) {
      throw new Error(error);
    } finally {
      commit(types.SET_CRM_DEALS_UI_FLAG, { isFetchingSummary: false });
    }
  },
};

const mutations = {
  [types.SET_CRM_DEALS_UI_FLAG]($state, flags) {
    $state.uiFlags = { ...$state.uiFlags, ...flags };
  },

  [types.SET_CRM_DEALS]($state, deals) {
    $state.records = deals;
  },

  [types.CLEAR_CRM_DEALS]($state) {
    $state.records = [];
  },

  [types.SET_CRM_DEALS_META]($state, meta) {
    $state.meta = meta;
  },

  [types.SET_CRM_DEAL]($state, deal) {
    const index = $state.records.findIndex(d => d.id === deal.id);
    if (index !== -1) {
      $state.records.splice(index, 1, deal);
    } else {
      $state.records.push(deal);
    }
  },

  [types.ADD_CRM_DEAL]($state, deal) {
    $state.records.push(deal);
  },

  [types.EDIT_CRM_DEAL]($state, deal) {
    const index = $state.records.findIndex(d => d.id === deal.id);
    if (index !== -1) {
      $state.records.splice(index, 1, deal);
    }
  },

  [types.DELETE_CRM_DEAL]($state, id) {
    $state.records = $state.records.filter(d => d.id !== id);
  },

  [types.MOVE_CRM_DEAL]($state, { dealId, stageId, position }) {
    const index = $state.records.findIndex(d => d.id === dealId);
    if (index !== -1) {
      $state.records[index] = {
        ...$state.records[index],
        stage_id: stageId,
        position,
      };
    }
  },

  [types.SET_CRM_DEAL_ACTIVITIES]($state, { dealId, activities }) {
    $state.activities = { ...$state.activities, [dealId]: activities };
  },

  [types.SET_CRM_DEALS_SUMMARY]($state, summary) {
    $state.summary = summary;
  },
};

export default {
  namespaced: true,
  state,
  getters,
  actions,
  mutations,
};
