import { api } from '@/lib/api';
import type { UploadFileKind } from '@/lib/upload';

export interface MediaItem {
  id: number;
  site_id: number | null;
  url: string;
  path?: string;
  file_name: string;
  original_name: string | null;
  mime_type: string;
  file_type: 'image' | 'video' | 'document' | 'other';
  file_size: number;
  alt_text: string | null;
  uploaded_by?: number | null;
  created_at: string;
  updated_at?: string | null;
}

export interface DiskSpaceStats {
  free_bytes: number | null;
  total_bytes: number | null;
  used_bytes: number | null;
  free_mb: number | null;
  total_mb: number | null;
}

export const SITE_LABELS: Record<string, string> = {
  '1': 'Alt Formation',
  '2': 'Recrutement',
  '3': 'Médical',
  '4': 'Carrière',
  '5': 'Trainer',
  '6': 'Coaching',
};

export const FILE_TYPE_LABELS: Record<string, string> = {
  image: 'Image',
  video: 'Vidéo',
  document: 'Document',
  other: 'Autre',
};

export function buildMediaQuery(params: {
  siteId?: string;
  fileType?: string;
  limit?: number;
}): string {
  const qs = new URLSearchParams();
  if (params.siteId && params.siteId !== 'all') qs.set('site_id', params.siteId);
  if (params.fileType && params.fileType !== 'all') qs.set('file_type', params.fileType);
  if (params.limit) qs.set('limit', String(params.limit));
  const s = qs.toString();
  return s ? `?${s}` : '';
}

export async function fetchMediaList(params: {
  siteId?: string;
  fileType?: string;
  limit?: number;
} = {}): Promise<MediaItem[]> {
  const res = await api.get<{ data: MediaItem[] }>(`/media${buildMediaQuery({ ...params, limit: params.limit ?? 100 })}`);
  return res.data?.data ?? [];
}

export async function updateMediaAltText(id: number, altText: string | null): Promise<MediaItem> {
  const res = await api.put<{ data: MediaItem }>(`/media/${id}`, { alt_text: altText });
  return res.data.data;
}

export async function deleteMedia(id: number): Promise<void> {
  await api.delete(`/media/${id}`);
}

export async function fetchDiskSpace(): Promise<DiskSpaceStats> {
  const res = await api.get<{ data: DiskSpaceStats }>('/media/disk-space');
  return res.data.data;
}

export function mediaMatchesKind(item: MediaItem, kind: UploadFileKind): boolean {
  if (kind === 'image') return item.file_type === 'image';
  if (kind === 'video') return item.file_type === 'video';
  if (kind === 'document') return item.file_type === 'document';
  return true;
}

export function mediaSearchHaystack(item: MediaItem): string {
  return [
    item.file_name,
    item.original_name,
    item.url,
    item.alt_text,
    item.mime_type,
  ].filter(Boolean).join(' ').toLowerCase();
}
