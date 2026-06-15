export type UiStatus = 'publie' | 'brouillon';

const FORMATION_TO_API: Record<UiStatus, string> = {
  publie: 'published',
  brouillon: 'draft',
};

const FORMATION_FROM_API: Record<string, UiStatus> = {
  published: 'publie',
  draft: 'brouillon',
  review: 'brouillon',
  archived: 'brouillon',
};

const OFFER_TO_API: Record<UiStatus, string> = {
  publie: 'publiee',
  brouillon: 'brouillon',
};

const OFFER_FROM_API: Record<string, UiStatus> = {
  publiee: 'publie',
  brouillon: 'brouillon',
  pourvue: 'brouillon',
  expiree: 'brouillon',
  archivee: 'brouillon',
};

export function statusToApi(statut: unknown, defaultStatus = 'draft'): string {
  if (typeof statut === 'string' && statut in FORMATION_TO_API) {
    return FORMATION_TO_API[statut as UiStatus];
  }
  return defaultStatus;
}

export function statusFromApi(status: unknown): UiStatus {
  if (typeof status === 'string' && status in FORMATION_FROM_API) {
    return FORMATION_FROM_API[status];
  }
  return 'brouillon';
}

export function offerStatusToApi(statut: unknown, defaultStatus = 'brouillon'): string {
  if (typeof statut === 'string' && statut in OFFER_TO_API) {
    return OFFER_TO_API[statut as UiStatus];
  }
  return defaultStatus;
}

export function offerStatusFromApi(statut: unknown): UiStatus {
  if (typeof statut === 'string' && statut in OFFER_FROM_API) {
    return OFFER_FROM_API[statut];
  }
  return 'brouillon';
}

export const APPLICATION_STATUS_OPTIONS = [
  { value: 'recue', label: 'Reçue' },
  { value: 'vue', label: 'Vue' },
  { value: 'shortlist', label: 'Shortlist' },
  { value: 'entretien', label: 'Entretien' },
  { value: 'offre', label: 'Offre' },
  { value: 'refusee', label: 'Refusée' },
  { value: 'retiree', label: 'Retirée' },
];

export const CONTRACT_TYPE_OPTIONS = [
  { value: 'cdi', label: 'CDI' },
  { value: 'cdd', label: 'CDD' },
  { value: 'interim', label: 'Intérim' },
  { value: 'alternance', label: 'Alternance' },
  { value: 'freelance', label: 'Freelance' },
  { value: 'stage', label: 'Stage' },
];

export function formatDate(value: unknown): string {
  if (!value) return '';
  return String(value).slice(0, 10);
}
