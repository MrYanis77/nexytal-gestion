import { parseIdList } from './nested-json';
import { PHOTO_URL_PLACEHOLDER, PHOTO_URL_HINT } from '@/lib/constants';

export function coachFromApi(row: Record<string, unknown>): Record<string, unknown> {
  const specialties = row.specialties
    ? (typeof row.specialties === 'string' ? row.specialties.split(',') : row.specialties as string[])
    : [];
  
  const certifications = row.certifications
    ? (typeof row.certifications === 'string' ? row.certifications.split(',') : row.certifications as string[])
    : [];

  const languages = row.languages
    ? (typeof row.languages === 'string' ? row.languages.split(',') : row.languages as string[])
    : [];

  const name = row.name ?? `${row.first_name ?? ''} ${row.last_name ?? ''}`.trim();

  return {
    id: String(row.id),
    first_name: String(row.first_name ?? ''),
    last_name: String(row.last_name ?? ''),
    name,
    title: String(row.title ?? ''),
    slug: String(row.slug ?? ''),
    avatar_url: String(row.avatar_url ?? ''),
    photo: String(row.avatar_url ?? ''),
    city_id: row.city_id != null ? String(row.city_id) : '',
    location: String(row.location ?? ''),
    email: String(row.email ?? ''),
    phone: String(row.phone ?? ''),
    linkedin_url: String(row.linkedin_url ?? ''),
    experience_years: row.experience_years != null ? String(row.experience_years) : '0',
    status: String(row.status ?? 'active'),
    is_featured: !!row.is_featured,
    sort_order: row.sort_order != null ? String(row.sort_order) : '0',
    bio_short: String(row.bio_short ?? row.bio ?? ''),
    bio_full: String(row.bio_full ?? row.full_bio ?? ''),
    specialty_ids: Array.isArray(row.specialties) && row.specialties.length > 0
      ? (typeof row.specialties[0] === 'number'
        ? (row.specialties as number[]).join(',')
        : '')
      : '',
    specialties_display: specialties.join(', '),
    certification_ids: Array.isArray(row.certifications) && row.certifications.length > 0
      ? (typeof row.certifications[0] === 'number'
        ? (row.certifications as number[]).join(',')
        : '')
      : '',
    certifications_display: certifications.join(', '),
    language_ids: Array.isArray(row.languages) && row.languages.length > 0
      ? (typeof row.languages[0] === 'number'
        ? (row.languages as number[]).join(',')
        : '')
      : '',
    languages_display: languages.join(', '),
    published_at: String(row.published_at ?? ''),
  };
}

export function coachToApi(raw: Record<string, unknown>) {
  const payload: Record<string, unknown> = {
    first_name: raw.first_name,
    last_name: raw.last_name,
    title: raw.title,
    email: raw.email || null,
    phone: raw.phone || null,
    avatar_url: raw.photo || raw.avatar_url || null,
    experience_years: raw.experience_years ? Number(raw.experience_years) : 0,
    linkedin_url: raw.linkedin_url || null,
    status: raw.status || 'pending_review',
    is_featured: raw.is_featured ? 1 : 0,
    sort_order: raw.sort_order ? Number(raw.sort_order) : 0,
    bio_short: raw.bio_short || null,
    bio_full: raw.bio_full || null,
  };

  if (raw.city_id) payload.city_id = Number(raw.city_id);

  if ('specialty_ids' in raw) payload.specialties = parseIdList(raw.specialty_ids);
  if ('certification_ids' in raw) payload.certifications = parseIdList(raw.certification_ids);
  if ('language_ids' in raw) payload.languages = parseIdList(raw.language_ids);

  return payload;
}

export function buildCoachFields(
  specialtyOptions: { value: string; label: string }[] = [],
  certificationOptions: { value: string; label: string }[] = [],
  languageOptions: { value: string; label: string }[] = [],
  cityOptions: { value: string; label: string }[] = [],
): import('@/components/FormModal').FieldDef[] {
  return [
    { key: 'first_name', label: 'Prénom', type: 'text', required: true, section: 'Identité' },
    { key: 'last_name', label: 'Nom', type: 'text', required: true },
    { key: 'title', label: 'Titre', type: 'text', required: true, span: true, hint: 'Ex. Coach Dirigeants & Managers' },
    { key: 'email', label: 'Email', type: 'email', section: 'Contact' },
    { key: 'phone', label: 'Téléphone', type: 'text' },
    { key: 'linkedin_url', label: 'Profil LinkedIn', type: 'text', span: true },
    { key: 'city_id', label: 'Ville', type: 'select', options: cityOptions },
    {
      key: 'photo', label: 'Photo du coach', type: 'file', fileKind: 'image', uploadContext: 'coaches',
      span: true, section: 'Photo', placeholder: PHOTO_URL_PLACEHOLDER, hint: PHOTO_URL_HINT,
    },
    { key: 'experience_years', label: 'Années d\'expérience', type: 'number', section: 'Profil' },
    ...(specialtyOptions.length
      ? [{ key: 'specialty_ids', label: 'Spécialités', type: 'multi_select' as const, options: specialtyOptions, span: true }]
      : []),
    ...(certificationOptions.length
      ? [{ key: 'certification_ids', label: 'Certifications', type: 'multi_select' as const, options: certificationOptions, span: true }]
      : []),
    ...(languageOptions.length
      ? [{ key: 'language_ids', label: 'Langues', type: 'multi_select' as const, options: languageOptions, span: true }]
      : []),
    { key: 'bio_short', label: 'Bio courte', type: 'textarea', span: true, section: 'Contenu' },
    { key: 'bio_full', label: 'Bio longue', type: 'textarea', span: true },
    { key: 'is_featured', label: 'Mettre en avant', type: 'switch', section: 'Publication' },
    {
      key: 'status', label: 'Statut', type: 'select',
      options: [
        { value: 'active', label: 'Actif' },
        { value: 'inactive', label: 'Inactif' },
        { value: 'pending_review', label: 'En revue' },
        { value: 'draft', label: 'Brouillon' },
      ],
    },
    { key: 'sort_order', label: 'Ordre d\'affichage', type: 'number' },
  ];
}

export function buildCoachingSpecialtyFields(): import('@/components/FormModal').FieldDef[] {
  return [
    { key: 'name', label: 'Nom de la spécialité', type: 'text', required: true, span: true },
    { key: 'sort_order', label: 'Ordre', type: 'number' },
    { key: 'is_active', label: 'Actif', type: 'switch' },
  ];
}

export function buildCoachingCertificationFields(): import('@/components/FormModal').FieldDef[] {
  return [
    { key: 'name', label: 'Nom de la certification', type: 'text', required: true, span: true },
    { key: 'sort_order', label: 'Ordre', type: 'number' },
  ];
}

export function buildCoachingCityFields(): import('@/components/FormModal').FieldDef[] {
  return [
    { key: 'name', label: 'Ville', type: 'text', required: true },
    { key: 'region', label: 'Région', type: 'text' },
    { key: 'is_active', label: 'Actif', type: 'switch', span: true },
  ];
}

export function buildCoachingLanguageFields(): import('@/components/FormModal').FieldDef[] {
  return [
    { key: 'name', label: 'Langue', type: 'text', required: true },
    { key: 'code', label: 'Code', type: 'text', required: true, hint: 'Ex: fr, en' },
    { key: 'flag_emoji', label: 'Emoji Drapeau', type: 'text', span: true },
  ];
}

export function buildCoachingContactSlotFields(): import('@/components/FormModal').FieldDef[] {
  return [
    { key: 'label', label: 'Label', type: 'text', required: true, span: true },
    { key: 'description', label: 'Description', type: 'text', span: true },
    { key: 'sort_order', label: 'Ordre', type: 'number' },
    { key: 'is_active', label: 'Actif', type: 'switch' },
  ];
}

export function buildCoachingAppointmentSlotFields(coachOptions: { value: string; label: string }[]): import('@/components/FormModal').FieldDef[] {
  return [
    { key: 'slot_date', label: 'Date', type: 'date', required: true },
    { key: 'start_time', label: 'Heure de début', type: 'text', required: true, hint: 'HH:MM:SS' },
    { key: 'end_time', label: 'Heure de fin', type: 'text', hint: 'HH:MM:SS' },
    { key: 'coach_id', label: 'Coach', type: 'select', options: coachOptions },
    { key: 'capacity', label: 'Capacité', type: 'number' },
    { key: 'is_active', label: 'Actif', type: 'switch' },
  ];
}

export function buildCoachingContactRequestFields(): import('@/components/FormModal').FieldDef[] {
  return [
    {
      key: 'statut', label: 'Statut', type: 'select',
      options: [
        { value: 'nouveau', label: 'Nouveau' },
        { value: 'contacte', label: 'Contacté' },
        { value: 'planifie', label: 'Planifié' },
        { value: 'ferme', label: 'Fermé' },
      ],
    },
  ];
}

export function buildCoachingDiagnosticRequestFields(): import('@/components/FormModal').FieldDef[] {
  return [
    {
      key: 'statut', label: 'Statut', type: 'select',
      options: [
        { value: 'nouveau', label: 'Nouveau' },
        { value: 'confirme', label: 'Confirmé' },
        { value: 'termine', label: 'Terminé' },
        { value: 'annule', label: 'Annulé' },
      ],
    },
  ];
}
