const API_BASE = import.meta.env.VITE_API_URL || '/api';

export type UploadFileKind = 'image' | 'video' | 'document';

export interface UploadResult {
  id: number;
  url: string;
  file_name: string;
  original_name: string;
  mime_type: string;
  file_type: string;
  file_size: number;
}

/** Contexte d'upload → site_id par défaut (bdd.sql core_sites). */
const UPLOAD_CONTEXT_SITE: Record<string, string> = {
  formation: '1',
  alt: '1',
  medical: '3',
  recrutement: '2',
  recrut: '2',
  carriere: '4',
  trainers: '5',
  trainer: '5',
  coaching: '6',
  coaches: '6',
};

function resolveSiteIdFromPage(): string {
  if (typeof window === 'undefined') return '';
  const path = window.location.pathname;
  const search = new URLSearchParams(window.location.search);
  const fromQuery = search.get('site_id') || search.get('site');
  if (fromQuery && /^\d+$/.test(fromQuery)) return fromQuery;

  if (path.includes('/formation')) return '1';
  if (path.includes('/medical')) return '3';
  if (path.includes('/recrutement-gestion') || path.includes('/validation-offres')) return fromQuery && /^\d+$/.test(fromQuery) ? fromQuery : '';
  if (path.includes('/recrutement')) return '2';
  if (path.includes('/carriere')) return '4';
  if (path.includes('/trainer')) return '5';
  if (path.includes('/coaching')) return '6';
  return '';
}

function resolveSiteId(options: { context?: string; siteId?: string }): string {
  if (options.siteId) return options.siteId;
  const fromPage = resolveSiteIdFromPage();
  if (fromPage) return fromPage;
  if (options.context) {
    const key = options.context.toLowerCase();
    if (UPLOAD_CONTEXT_SITE[key]) return UPLOAD_CONTEXT_SITE[key];
  }
  return '';
}

const MEDIA_BASE = (import.meta.env.VITE_MEDIA_BASE_URL || '').replace(/\/$/, '');

/** URL publique pour afficher un média (chemin relatif, CDN ou URL externe). */
export function resolveMediaUrl(path: string): string {
  if (!path) return '';
  if (path.startsWith('http://') || path.startsWith('https://')) return path;

  let normalized = path.startsWith('/') ? path : `/${path}`;

  // L'API Ionos est sous /api/ — les fichiers sont servis depuis /api/uploads/
  if (normalized.startsWith('/uploads/') && !normalized.startsWith('/api/uploads/')) {
    normalized = `/api${normalized}`;
  }

  if (MEDIA_BASE) {
    return `${MEDIA_BASE}${normalized}`;
  }

  return normalized;
}

export async function uploadMediaFile(
  file: File,
  options: { type: UploadFileKind; context?: string; altText?: string; siteId?: string },
): Promise<UploadResult> {
  const token = localStorage.getItem('nexytal_token');
  const fd = new FormData();
  fd.append('file', file);
  fd.append('type', options.type);
  if (options.context) fd.append('context', options.context);
  if (options.altText) fd.append('alt_text', options.altText);

  const headers: Record<string, string> = { 'X-Requested-With': 'XMLHttpRequest' };
  if (token) headers.Authorization = `Bearer ${token}`;
  const csrfToken = localStorage.getItem('nexytal_csrf_token');
  if (csrfToken) headers['X-CSRF-Token'] = csrfToken;

  const siteId = resolveSiteId(options);
  if (siteId) headers['X-Site-Id'] = siteId;

  const res = await fetch(`${API_BASE}/admin/media/upload`, {
    method: 'POST',
    headers,
    body: fd,
    credentials: 'include',
  });

  const json = await res.json().catch(() => ({}));

  if (!res.ok) {
    const msg = json?.error || json?.message || `Erreur upload (${res.status})`;
    throw new Error(typeof msg === 'string' ? msg : 'Échec de l\'upload');
  }

  const data = json?.data ?? json;
  if (!data?.url) {
    throw new Error('Réponse serveur invalide après upload');
  }

  return data as UploadResult;
}

export function formatFileSize(bytes: number): string {
  if (bytes < 1024) return `${bytes} o`;
  if (bytes < 1024 * 1024) return `${(bytes / 1024).toFixed(1)} Ko`;
  return `${(bytes / (1024 * 1024)).toFixed(1)} Mo`;
}

export const FILE_ACCEPT: Record<UploadFileKind, string> = {
  image: 'image/jpeg,image/png,image/gif,image/webp,image/svg+xml',
  video: 'video/mp4,video/webm,video/quicktime,.mp4,.webm,.mov',
  document: 'application/pdf,.pdf',
};

export const FILE_KIND_HINT: Record<UploadFileKind, string> = {
  image: 'JPEG, PNG, GIF, WebP ou SVG — max 5 Mo',
  video: 'MP4, WebM ou MOV — max 100 Mo',
  document: 'PDF — max 10 Mo',
};
