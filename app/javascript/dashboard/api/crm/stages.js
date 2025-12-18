/* global axios */
import ApiClient from '../ApiClient';

class StagesAPI extends ApiClient {
  constructor() {
    super('crm/pipelines', { accountScoped: true });
  }

  getStagesUrl(pipelineId) {
    return `${this.url}/${pipelineId}/stages`;
  }

  get(pipelineId) {
    return axios.get(this.getStagesUrl(pipelineId));
  }

  show(pipelineId, stageId) {
    return axios.get(`${this.getStagesUrl(pipelineId)}/${stageId}`);
  }

  create(pipelineId, data) {
    return axios.post(this.getStagesUrl(pipelineId), data);
  }

  update(pipelineId, stageId, data) {
    return axios.patch(`${this.getStagesUrl(pipelineId)}/${stageId}`, data);
  }

  delete(pipelineId, stageId) {
    return axios.delete(`${this.getStagesUrl(pipelineId)}/${stageId}`);
  }

  reorder(pipelineId, stages) {
    return axios.post(`${this.getStagesUrl(pipelineId)}/reorder`, { stages });
  }
}

export default new StagesAPI();
