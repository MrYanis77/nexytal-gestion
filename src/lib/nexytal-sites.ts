/**
 * Référentiel des 6 sites — aligné api/sql/bdd.sql (core_sites.site_code)
 */
export interface NexytalSite {
  id: number;
  code: 'formation' | 'recrutement' | 'medical' | 'carriere' | 'trainers' | 'coaching';
  slug: string;
  label: string;
  domain: string;
  color: string;
  /** Route contenu éditorial (formations, coachs, blog…) */
  contentHref: string;
  /** Contexte AppContext pour droits d'accès */
  appSiteId?: 'formation' | 'medical' | 'recrutement' | 'carriere' | 'coaching' | 'trainer';
}

export const NEXYTAL_SITES: NexytalSite[] = [
  { id: 1, code: 'formation', slug: 'alt-formation', label: 'Alt Formation', domain: 'alt-formation.fr', color: '#7C3AED', contentHref: '/formation', appSiteId: 'formation' },
  { id: 2, code: 'recrutement', slug: 'nexytal-recrutement', label: 'Nexytal Recrutement', domain: 'recrutement.nexytal.com', color: '#2563EB', contentHref: '/recrutement', appSiteId: 'recrutement' },
  { id: 3, code: 'medical', slug: 'nexytal-medical', label: 'Nexytal Medical', domain: 'medical.nexytal.com', color: '#059669', contentHref: '/medical', appSiteId: 'medical' },
  { id: 4, code: 'carriere', slug: 'nexytal-carriere', label: 'Nexytal Carrière', domain: 'carriere.nexytal.com', color: '#D97706', contentHref: '/carriere', appSiteId: 'carriere' },
  { id: 5, code: 'trainers', slug: 'nexytal-trainer', label: 'Nexytal Trainer', domain: 'trainer.nexytal.com', color: '#0891B2', contentHref: '/trainer', appSiteId: 'trainer' },
  { id: 6, code: 'coaching', slug: 'nexytal-coaching', label: 'Nexytal Coaching', domain: 'coaching.nexytal.com', color: '#DC2626', contentHref: '/coaching', appSiteId: 'coaching' },
];

export function getSiteById(id: number): NexytalSite | undefined {
  return NEXYTAL_SITES.find(s => s.id === id);
}

/** Sites avec offres d'emploi / recruteurs (hors coaching & trainer) */
export const RECRUITMENT_JOB_SITE_CODES: NexytalSite['code'][] = [
  'formation',
  'recrutement',
  'medical',
  'carriere',
];

export function getRecruitmentJobSites(): NexytalSite[] {
  return NEXYTAL_SITES.filter(s => RECRUITMENT_JOB_SITE_CODES.includes(s.code));
}

export function getSiteByCode(code: string): NexytalSite | undefined {
  return NEXYTAL_SITES.find(s => s.code === code);
}

export function siteLabelFromCode(code: string): string {
  return getSiteByCode(code)?.label ?? code;
}

export function siteQueryString(siteId: number | null | undefined): string {
  return siteId ? `?site_id=${siteId}` : '';
}

/** Query string avec site_id + paramètres optionnels (limit, statut, _all, …) */
export function siteListQueryString(
  siteId: number | null | undefined,
  extra: Record<string, string | number | undefined | null> = {},
): string {
  const params = new URLSearchParams();
  if (siteId) params.set('site_id', String(siteId));
  for (const [key, value] of Object.entries(extra)) {
    if (value !== undefined && value !== null && value !== '') {
      params.set(key, String(value));
    }
  }
  const qs = params.toString();
  return qs ? `?${qs}` : '';
}

/** Métiers / secteurs : référentiels rattachés à un site (bdd.sql metiers.site_id) */
export function siteRequiresScope(siteId: number | null): boolean {
  return siteId === null;
}
