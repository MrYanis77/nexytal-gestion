export type UiStatus = 'publie' | 'brouillon';

const TO_API: Record<UiStatus, string> = {
  publie: 'published',
  brouillon: 'draft',
};

const FROM_API: Record<string, UiStatus> = {
  published: 'publie',
  draft: 'brouillon',
  review: 'brouillon',
  archived: 'brouillon',
};

export function statusToApi(statut: unknown, defaultStatus = 'draft'): string {
  if (typeof statut === 'string' && statut in TO_API) return TO_API[statut as UiStatus];
  return defaultStatus;
}

export function statusFromApi(status: unknown): UiStatus {
  if (typeof status === 'string' && status in FROM_API) return FROM_API[status];
  return 'brouillon';
}

export function formatDate(value: unknown): string {
  if (!value) return '';
  const s = String(value);
  return s.slice(0, 10);
}
