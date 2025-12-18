/* global axios */
import ApiClient from '../ApiClient';

class DealsAPI extends ApiClient {
  constructor() {
    super('crm/deals', { accountScoped: true });
  }

  get(params = {}) {
    const queryParams = new URLSearchParams();

    if (params.page) queryParams.append('page', params.page);
    if (params.pipelineId) queryParams.append('pipeline_id', params.pipelineId);
    if (params.stageId) queryParams.append('stage_id', params.stageId);
    if (params.status) queryParams.append('status', params.status);

    const queryString = queryParams.toString();
    const url = queryString ? `${this.url}?${queryString}` : this.url;

    return axios.get(url);
  }

  show(id) {
    return axios.get(`${this.url}/${id}`);
  }

  create(data) {
    return axios.post(this.url, data);
  }

  update(id, data) {
    return axios.patch(`${this.url}/${id}`, data);
  }

  delete(id) {
    return axios.delete(`${this.url}/${id}`);
  }

  move(id, stageId, position = null) {
    const data = { stage_id: stageId };
    if (position !== null) {
      data.position = position;
    }
    return axios.patch(`${this.url}/${id}/move`, data);
  }

  markAsWon(id) {
    return axios.patch(`${this.url}/${id}/won`);
  }

  markAsLost(id, reason = null) {
    const data = reason ? { reason } : {};
    return axios.patch(`${this.url}/${id}/lost`, data);
  }

  getActivities(id) {
    return axios.get(`${this.url}/${id}/activities`);
  }

  getSummary(pipelineId) {
    return axios.get(`${this.url}/summary?pipeline_id=${pipelineId}`);
  }
}

export default new DealsAPI();
