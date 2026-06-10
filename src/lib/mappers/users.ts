import { User, Role, SiteId } from '@/contexts/AppContext';

const SITE_ID_MAP: Record<SiteId, number> = {
  formation: 1,
  recrutement: 2,
  medical: 3,
  carriere: 4,
  trainer: 5,
  coaching: 6,
};

const ID_TO_SITE: Record<number, SiteId> = {
  1: 'formation',
  2: 'recrutement',
  3: 'medical',
  4: 'carriere',
  5: 'trainer',
  6: 'coaching',
};

const SLUG_TO_SITE: Record<string, SiteId> = {
  'alt-formation': 'formation',
  'nexytal-recrutement': 'recrutement',
  'nexytal-medical': 'medical',
  'nexytal-carriere': 'carriere',
  'nexytal-trainer': 'trainer',
  'nexytal-coaching': 'coaching',
};

export function userToApi(form: {
  email: string;
  first_name: string;
  last_name: string;
  role: Role;
  sites: SiteId[];
  active: boolean;
  password?: string;
}) {
  const payload: Record<string, unknown> = {
    email: form.email,
    first_name: form.first_name,
    last_name: form.last_name,
    role: form.role === 'user' ? 'editor' : form.role,
    is_active: form.active ? 1 : 0,
    site_ids: form.sites.map(s => SITE_ID_MAP[s]).filter(Boolean),
  };
  if (form.password) payload.password = form.password;
  return payload;
}

export function userFromApi(row: Record<string, unknown>): User {
  const sitesRaw = (row.sites as Array<{ id?: number; slug?: string }>) ?? [];
  const sites: SiteId[] = sitesRaw
    .map(s => (s.id ? ID_TO_SITE[s.id] : s.slug ? SLUG_TO_SITE[s.slug] : undefined))
    .filter((s): s is SiteId => !!s);

  const firstName = String(row.first_name ?? '');
  const lastName = String(row.last_name ?? '');
  const displayName = `${firstName} ${lastName}`.trim() || String(row.email ?? '');

  return {
    id: String(row.id),
    username: displayName,
    email: String(row.email ?? ''),
    first_name: firstName,
    last_name: lastName,
    role: (row.role as Role) || 'editor',
    sites,
    createdAt: String(row.created_at ?? '').slice(0, 10),
    active: row.is_active !== false && row.is_active !== 0,
  };
}
