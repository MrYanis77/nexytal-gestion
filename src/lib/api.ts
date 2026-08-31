import axios from 'axios';

const API_URL = import.meta.env.VITE_API_URL || '/api';

/** Routes recrutement globales — pas de X-Site-Id imposé par défaut */
const GLOBAL_RECRUTEMENT_API = /\/recrutement\/(?:offers\/pending|offers\/\d+\/(?:publish|reject|candidatures)|stats|recruteurs(?:\/pending-count)?|candidatures(?:\/\d+\/verify)?|externes(?:\/\d+\/verify|\/unverified-count)?(?:\?|$))/;

/** Routes coaching globales (file validation hub) */
const GLOBAL_COACHING_API = /\/coaching\/coaches(?:\/pending(?:-count)?|\/?\d+\/(?:publish|reject))(?:\?|$)/;

/** Routes trainer globales (file validation hub) */
const GLOBAL_TRAINER_API = /\/trainer\/trainers(?:\/pending(?:-count)?|\/?\d+\/(?:publish|reject))(?:\?|$)/;

const HUB_ADMIN_PATHS = [
  '/recrutement-gestion',
  '/validation-offres',
  '/offres-publiees',
  '/config-scoring',
  '/validation-recruteurs',
  '/qualification-candidatures',
  '/validation-coaches',
  '/validation-trainers',
];

export const api = axios.create({
  baseURL: API_URL,
  headers: {
    'Content-Type': 'application/json',
    'X-Requested-With': 'XMLHttpRequest',
  },
  withCredentials: true,
});

/** Télécharge un fichier protégé (CV, lettre) depuis l'espace recruteur. */
export async function downloadPortalAttachment(apiPath: string, fallbackName: string): Promise<void> {
  const token = localStorage.getItem('nexytal_token');
  const normalized = apiPath.startsWith('/admin') ? apiPath : `/admin${apiPath.startsWith('/') ? '' : '/'}${apiPath}`;
  const res = await fetch(`${API_URL}${normalized}`, {
    method: 'GET',
    headers: token ? { Authorization: `Bearer ${token}` } : {},
    credentials: 'include',
  });

  if (!res.ok) {
    let message = `Téléchargement impossible (${res.status})`;
    try {
      const json = await res.json();
      if (typeof json?.error === 'string') message = json.error;
    } catch {
      // ignore
    }
    throw new Error(message);
  }

  const blob = await res.blob();
  const disposition = res.headers.get('Content-Disposition') ?? '';
  const match = disposition.match(/filename="?([^";]+)"?/i);
  const filename = match?.[1] ?? fallbackName;

  const objectUrl = URL.createObjectURL(blob);
  const anchor = document.createElement('a');
  anchor.href = objectUrl;
  anchor.download = filename;
  anchor.click();
  URL.revokeObjectURL(objectUrl);
}

api.interceptors.request.use((config) => {
  const token = localStorage.getItem('nexytal_token');
  if (token) {
    config.headers.Authorization = `Bearer ${token}`;
  }

  const method = (config.method || 'get').toUpperCase();
  if (['POST', 'PUT', 'PATCH', 'DELETE'].includes(method)) {
    const csrfToken = localStorage.getItem('nexytal_csrf_token');
    if (csrfToken) {
      config.headers['X-CSRF-Token'] = csrfToken;
    }
    config.headers['X-Requested-With'] = 'XMLHttpRequest';
  }

  const requestUrl = config.url || '';
  let siteId = '';
  let urlSearchSite = '';

  try {
    const urlObj = new URL(requestUrl, 'http://localhost');
    siteId = urlObj.searchParams.get('site_id') || urlObj.searchParams.get('site') || '';
    urlSearchSite = urlObj.searchParams.get('site') || urlObj.searchParams.get('site_id') || '';
  } catch {
    // ignore
  }

  if (!siteId && config.data && typeof config.data === 'object' && config.data.site) {
    siteId = String(config.data.site);
  }

  if (siteId === 'formation' || siteId === 'alt-formation') siteId = '1';
  else if (siteId === 'recrutement' || siteId === 'nexytal-recrutement') siteId = '2';
  else if (siteId === 'medical' || siteId === 'nexytal-medical') siteId = '3';
  else if (siteId === 'carriere' || siteId === 'nexytal-carriere') siteId = '4';
  else if (siteId === 'trainer' || siteId === 'nexytal-trainer') siteId = '5';
  else if (siteId === 'coaching' || siteId === 'nexytal-coaching') siteId = '6';

  const isGlobalRecrutementApi = GLOBAL_RECRUTEMENT_API.test(requestUrl);
  const isGlobalCoachingApi = GLOBAL_COACHING_API.test(requestUrl);
  const isGlobalTrainerApi = GLOBAL_TRAINER_API.test(requestUrl);
  const isGlobalApi = isGlobalRecrutementApi || isGlobalCoachingApi || isGlobalTrainerApi;
  const isHubAdminPage = typeof window !== 'undefined'
    && HUB_ADMIN_PATHS.some(p => window.location.pathname.includes(p));

  if (!siteId && typeof window !== 'undefined') {
    const path = window.location.pathname;
    const pageSearch = new URLSearchParams(window.location.search);
    if (isHubAdminPage) {
      siteId = pageSearch.get('site') || urlSearchSite || '';
    } else if (path.includes('/formation')) siteId = '1';
    else if (path.includes('/medical')) siteId = '3';
    else if (path.includes('/recrutement')) siteId = '2';
    else if (path.includes('/carriere')) siteId = '4';
    else if (path.includes('/trainer')) siteId = '5';
    else if (path.includes('/coaching')) siteId = '6';
  }

  if (!siteId && requestUrl && !isGlobalApi && !(isHubAdminPage && !urlSearchSite)) {
    if (requestUrl.includes('/formation/')) siteId = '1';
    else if (requestUrl.includes('/recrutement/')) siteId = '2';
    else if (requestUrl.includes('/carriere/')) siteId = '4';
    else if (requestUrl.includes('/coaching/')) siteId = '6';
    else if (requestUrl.includes('/trainer/')) siteId = '5';
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
      localStorage.removeItem('nexytal_csrf_token');
      delete api.defaults.headers.common['Authorization'];
    }
    return Promise.reject(error);
  }
);
