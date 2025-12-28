import axios, { AxiosRequestConfig, AxiosResponse } from 'axios';

const instance = axios.create({
  baseURL: '',
  headers: {
    'Content-Type': 'application/json',
  },
});

instance.interceptors.request.use(config => {
  const token = window.localStorage.getItem('api_access_token');
  if (token && config.headers) {
    config.headers.api_access_token = token;
  }
  return config;
});

instance.interceptors.response.use(
  response => response,
  error => {
    if (error.response?.status === 401) {
      window.location.href = '/app/login';
    }
    return Promise.reject(error);
  }
);

export const customInstance = <T>(
  config: AxiosRequestConfig
): Promise<AxiosResponse<T>> => {
  return instance(config);
};

export default customInstance;
