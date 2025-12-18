/* global axios */
import ApiClient from '../ApiClient';

class PipelinesAPI extends ApiClient {
  constructor() {
    super('crm/pipelines', { accountScoped: true });
  }

  get() {
    return axios.get(this.url);
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

  duplicate(id) {
    return axios.post(`${this.url}/${id}/duplicate`);
  }

  setDefault(id) {
    return axios.patch(`${this.url}/${id}/set_default`);
  }
}

export default new PipelinesAPI();
