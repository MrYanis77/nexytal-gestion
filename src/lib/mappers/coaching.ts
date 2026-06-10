import { Coach, Creneau } from '@/contexts/AppContext';
import { formatDate } from './status';

function splitName(nom: string): { first_name: string; last_name: string } {
  const parts = nom.trim().split(/\s+/);
  if (parts.length <= 1) return { first_name: parts[0] || 'Coach', last_name: '—' };
  return { first_name: parts[0], last_name: parts.slice(1).join(' ') };
}

export function coachToApi(raw: Record<string, unknown>) {
  const { first_name, last_name } = splitName(String(raw.nom ?? ''));
  return {
    first_name,
    last_name,
    email: raw.email || `${first_name.toLowerCase()}.${last_name.toLowerCase().replace(/\s/g, '')}@nexytal.com`,
    phone: raw.phone || null,
    avatar_url: raw.avatar_url || null,
    title: raw.titre || 'Coach certifié',
    short_bio: raw.short_bio || null,
    full_bio: raw.bio || null,
    experience_years: raw.experience_years ? Number(raw.experience_years) : 0,
    languages: raw.languages ? (typeof raw.languages === 'string' ? raw.languages : JSON.stringify(raw.languages)) : null,
    city_id: raw.city_id ? Number(raw.city_id) : null,
    is_available: raw.visible !== false ? 1 : 0,
    status: raw.statut || (raw.visible === false ? 'inactive' : 'active'),
    meta_title: raw.meta_title || null,
    meta_description: raw.meta_description || null,
  };
}

export function coachFromApi(row: Record<string, unknown>): Coach {
  return {
    id: String(row.id),
    nom: `${row.first_name ?? ''} ${row.last_name ?? ''}`.trim(),
    email: String(row.email ?? ''),
    phone: String(row.phone ?? ''),
    avatar_url: String(row.avatar_url ?? ''),
    titre: String(row.title ?? ''),
    short_bio: String(row.short_bio ?? ''),
    bio: String(row.full_bio ?? row.short_bio ?? ''),
    experience_years: row.experience_years != null ? String(row.experience_years) : '',
    languages: typeof row.languages === 'string' ? row.languages : JSON.stringify(row.languages ?? []),
    city_id: row.city_id != null ? String(row.city_id) : '',
    localisation: String(row.city_name ?? ''),
    visible: !!row.is_available,
    statut: String(row.status ?? 'pending'),
    meta_title: String(row.meta_title ?? ''),
    meta_description: String(row.meta_description ?? ''),
    createdAt: String(row.created_at ?? ''),
  };
}

export function bookingFromApi(row: Record<string, unknown>): Creneau {
  const bookedFor = String(row.booked_for ?? '');
  const [date, timePart] = bookedFor.split(' ');
  return {
    id: String(row.id),
    date: date || formatDate(row.created_at),
    heure: timePart ? timePart.slice(0, 5) : '—',
    coach: String(row.coach_id ?? ''),
    coach_nom: `${row.coach_first_name ?? ''} ${row.coach_last_name ?? ''}`.trim(),
    client_nom: `${row.first_name ?? ''} ${row.last_name ?? ''}`.trim(),
    client_email: String(row.email ?? ''),
    statut: String(row.status ?? 'pending'),
    notes: String(row.internal_notes ?? row.notes ?? ''),
  };
}

export function bookingToApi(raw: Record<string, unknown>) {
  return {
    status: raw.statut ?? raw.status,
    internal_notes: raw.notes ?? raw.internal_notes ?? null,
  };
}

export function buildCoachFields(cityOptions: { value: string; label: string }[] = []): import('@/components/FormModal').FieldDef[] {
  return [
    { key: 'nom', label: 'Nom complet', type: 'text', required: true },
    { key: 'email', label: 'Email', type: 'email', required: true },
    { key: 'phone', label: 'Téléphone', type: 'text' },
    { key: 'avatar_url', label: 'URL Avatar', type: 'text', span: true },
    { key: 'titre', label: 'Titre / Certification', type: 'text', required: true },
    { key: 'short_bio', label: 'Bio courte', type: 'textarea', span: true },
    { key: 'bio', label: 'Biographie (longue)', type: 'textarea', span: true },
    { key: 'experience_years', label: 'Années d\'expérience', type: 'text' },
    { key: 'languages', label: 'Langues (JSON ["fr", "en"])', type: 'text' },
    { key: 'city_id', label: 'Ville', type: 'select', options: cityOptions },
    { key: 'visible', label: 'Disponible sur le site', type: 'switch' },
    {
      key: 'statut',
      label: 'Statut',
      type: 'select',
      options: [
        { value: 'active', label: 'Actif' },
        { value: 'inactive', label: 'Inactif' },
        { value: 'pending', label: 'En attente' },
      ],
    },
    { key: 'meta_title', label: 'Meta Titre', type: 'text', span: true },
    { key: 'meta_description', label: 'Meta Description', type: 'textarea', span: true },
  ];
}

export function buildCityFields(): import('@/components/FormModal').FieldDef[] {
  return [
    { key: 'name', label: 'Nom de la ville', type: 'text', required: true, span: true },
    { key: 'slug', label: 'Slug', type: 'text', placeholder: 'Auto-généré si vide', span: true },
  ];
}

export function buildSpecialtyFields(): import('@/components/FormModal').FieldDef[] {
  return [
    { key: 'name', label: 'Nom de la spécialité', type: 'text', required: true, span: true },
    { key: 'slug', label: 'Slug', type: 'text', placeholder: 'Auto-généré si vide' },
    { key: 'icon', label: 'Icône (ex: star)', type: 'text' },
  ];
}

export function buildCertificationFields(): import('@/components/FormModal').FieldDef[] {
  return [
    { key: 'code', label: 'Code (Interne)', type: 'text', required: true },
    { key: 'organization', label: 'Organisme', type: 'text', required: true },
    { key: 'level', label: 'Niveau (1-5)', type: 'text' },
  ];
}

export const BOOKING_STATUS_OPTIONS = [
  { value: 'pending', label: 'En attente' },
  { value: 'confirmed', label: 'Confirmée' },
  { value: 'completed', label: 'Terminée' },
  { value: 'cancelled', label: 'Annulée' },
];

export function buildBookingEditFields(): import('@/components/FormModal').FieldDef[] {
  return [
    {
      key: 'statut',
      label: 'Statut',
      type: 'select',
      options: BOOKING_STATUS_OPTIONS,
    },
    { key: 'notes', label: 'Notes internes', type: 'textarea', span: true },
  ];
}
