import axios from 'axios';

const API_URL = import.meta.env.VITE_API_URL || '/api';

export const api = axios.create({
  baseURL: API_URL,
  headers: {
    'Content-Type': 'application/json',
  },
  withCredentials: true,
});

api.interceptors.request.use((config) => {
  const token = localStorage.getItem('nexytal_token');
  if (token) {
    config.headers.Authorization = `Bearer ${token}`;
  }

  let siteId = '';
  
  try {
    const urlObj = new URL(config.url || '', 'http://localhost');
    siteId = urlObj.searchParams.get('site') || '';
  } catch (e) {}

  if (!siteId && config.data && typeof config.data === 'object' && config.data.site) {
    siteId = config.data.site;
  }

  if (siteId === 'formation' || siteId === 'alt-formation') siteId = '1';
  else if (siteId === 'recrutement' || siteId === 'nexytal-recrutement') siteId = '2';
  else if (siteId === 'medical' || siteId === 'nexytal-medical') siteId = '3';
  else if (siteId === 'carriere' || siteId === 'nexytal-carriere') siteId = '4';
  else if (siteId === 'trainer' || siteId === 'nexytal-trainer') siteId = '5';
  else if (siteId === 'coaching' || siteId === 'nexytal-coaching') siteId = '6';

  if (!siteId && config.url) {
    if (config.url.includes('/formation/')) siteId = '1';
    else if (config.url.includes('/recrutement/')) siteId = '2';
    else if (config.url.includes('/coaching/')) siteId = '6';
  }

  if (!siteId && typeof window !== 'undefined') {
    const path = window.location.pathname;
    if (path.includes('/formation')) siteId = '1';
    else if (path.includes('/medical')) siteId = '3';
    else if (path.includes('/recrutement')) siteId = '2';
    else if (path.includes('/carriere')) siteId = '4';
    else if (path.includes('/trainer')) siteId = '5';
    else if (path.includes('/coaching')) siteId = '6';
  }

  if (siteId) {
    config.headers['X-Site-Id'] = siteId;
  }

  if (config.url && !config.url.startsWith('/admin')) {
    config.url = `/admin${config.url.startsWith('/') ? '' : '/'}${config.url}`;
  }

  return config;
});

api.interceptors.response.use(
  (response) => response,
  (error) => {
    if (error.response?.status === 401) {
      localStorage.removeItem('nexytal_token');
      delete api.defaults.headers.common['Authorization'];
    }
    return Promise.reject(error);
  }
);
