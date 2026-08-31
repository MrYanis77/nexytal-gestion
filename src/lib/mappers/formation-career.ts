import type { FieldDef } from '@/components/FormModal';
import { getSiteById } from '@/lib/nexytal-sites';
import { CONTRACT_TYPE_OPTIONS, formatDate } from './status';
import { parseMoneyAmount } from '@/lib/money';

export type PricingPlan = {
  id: string;
  site_id: number;
  amount_eur: number;
};

export type SitePricingRow = PricingPlan & {
  bilan_label: string;
  site_label: string;
};

/** Ordre id ASC sur site_pricing (site Carrière, site_id = 4) */
export const CARRIERE_BILAN_LABELS = ['Distanciel', 'Présentiel', 'Mixte'] as const;

export function carriereBilanLabel(index: number): string {
  return CARRIERE_BILAN_LABELS[index] ?? `Tarif ${index + 1}`;
}

export function sitePricingWithBilanLabels(rows: PricingPlan[]): SitePricingRow[] {
  return [...rows]
    .sort((a, b) => Number(a.id) - Number(b.id))
    .map((row, index) => ({
      ...row,
      bilan_label: carriereBilanLabel(index),
      site_label: getSiteById(row.site_id)?.label ?? `Site ${row.site_id}`,
    }));
}

export type CareerOffer = {
  id: string;
  department: string;
  reference?: string;
  slug: string;
  title: string;
  contract_type: string;
  experience_min?: string;
  location: string;
  code_postal?: string;
  departement?: string;
  region?: string;
  short_description?: string;
  full_description?: string;
  avantages?: string;
  competences_text?: string;
  salaire_min?: number;
  salaire_max?: number;
  salaire_afficher: boolean;
  teletravail: string;
  temps_travail: string;
  is_featured: boolean;
  urgent: boolean;
  statut: string;
  published_at?: string;
  expires_at?: string;
  sort_order: number;
  meta_title?: string;
  meta_description?: string;
  vues?: number;
};

export type CareerApplication = {
  id: string;
  offer_id?: string;
  offer_title?: string;
  application_type: string;
  first_name: string;
  last_name: string;
  email: string;
  phone: string;
  contract_or_expertise: string;
  cover_letter_text?: string;
  cv_filename: string;
  statut: string;
  created_at: string;
};

const CAREER_STATUS_FROM_API: Record<string, string> = {
  publiee: 'publie',
  brouillon: 'brouillon',
  archivee: 'archivee',
  pourvue: 'pourvue',
  expiree: 'expiree',
  published: 'publie',
  draft: 'brouillon',
  closed: 'archivee',
};

const CAREER_STATUS_TO_API: Record<string, string> = {
  publie: 'publiee',
  brouillon: 'brouillon',
  archivee: 'archivee',
  pourvue: 'pourvue',
  expiree: 'expiree',
  ferme: 'archivee',
};

export function careerStatusToApi(statut: unknown, defaultStatus = 'brouillon'): string {
  if (typeof statut === 'string' && statut in CAREER_STATUS_TO_API) {
    return CAREER_STATUS_TO_API[statut];
  }
  return defaultStatus;
}

export function careerStatusFromApi(status: unknown): string {
  if (typeof status === 'string' && status in CAREER_STATUS_FROM_API) {
    return CAREER_STATUS_FROM_API[status];
  }
  return 'brouillon';
}

export const CAREER_OFFER_STATUS_OPTIONS = [
  { value: 'publie', label: 'Publiée' },
  { value: 'brouillon', label: 'Brouillon' },
  { value: 'pourvue', label: 'Pourvue' },
  { value: 'expiree', label: 'Expirée' },
  { value: 'archivee', label: 'Archivée' },
];

export const CAREER_DEPARTMENT_OPTIONS = [
  { value: 'collaborateur', label: 'Collaborateur Alt RH' },
  { value: 'formateur', label: 'Formateur' },
];

const EXPERIENCE_OPTIONS = [
  { value: 'debutant', label: 'Débutant' },
  { value: '1-2', label: '1-2 ans' },
  { value: '3-5', label: '3-5 ans' },
  { value: '5-10', label: '5-10 ans' },
  { value: '10+', label: '10+ ans' },
];

const TELETRAVAIL_OPTIONS = [
  { value: 'non', label: 'Non' },
  { value: 'partiel', label: 'Partiel' },
  { value: 'total', label: 'Total' },
];

const TEMPS_TRAVAIL_OPTIONS = [
  { value: 'temps_plein', label: 'Temps plein' },
  { value: 'temps_partiel', label: 'Temps partiel' },
  { value: 'variable', label: 'Variable' },
];

export const CAREER_APPLICATION_STATUS_OPTIONS = [
  { value: 'recue', label: 'Reçue' },
  { value: 'vue', label: 'Vue' },
  { value: 'entretien', label: 'Entretien' },
  { value: 'offre', label: 'Offre' },
  { value: 'refusee', label: 'Refusée' },
];

export function pricingFromApi(row: Record<string, unknown>): PricingPlan {
  return {
    id: String(row.id),
    site_id: Number(row.site_id ?? 0),
    amount_eur: parseMoneyAmount(row.amount_eur) ?? 0,
  };
}

export function pricingToApi(raw: Record<string, unknown>) {
  const amount = parseMoneyAmount(raw.amount_eur);
  if (amount == null) {
    throw new Error('Montant invalide');
  }
  return {
    amount_eur: amount,
  };
}

export function buildPricingFields(): FieldDef[] {
  return [
    { key: 'amount_eur', label: 'Prix (€)', type: 'text', required: true, span: true, placeholder: '1600', hint: 'Montant en euros (ex. 1600 ou 1600,00).' },
  ];
}

export function careerOfferFromApi(row: Record<string, unknown>): CareerOffer {
  return {
    id: String(row.id),
    department: String(row.department ?? ''),
    reference: row.reference ? String(row.reference) : undefined,
    slug: String(row.slug ?? ''),
    title: String(row.title ?? row.titre ?? ''),
    contract_type: String(row.contract_type ?? row.type_contrat ?? 'cdi'),
    experience_min: row.experience_min ? String(row.experience_min) : undefined,
    location: String(row.location ?? row.ville ?? ''),
    code_postal: row.code_postal ? String(row.code_postal) : undefined,
    departement: row.departement ? String(row.departement) : undefined,
    region: row.region ? String(row.region) : undefined,
    short_description: row.short_description ?? row.profil_recherche
      ? String(row.short_description ?? row.profil_recherche)
      : undefined,
    full_description: row.full_description ?? row.description
      ? String(row.full_description ?? row.description)
      : undefined,
    avantages: row.avantages ? String(row.avantages) : undefined,
    competences_text: row.competences_text ? String(row.competences_text) : undefined,
    salaire_min: row.salaire_min != null ? Number(row.salaire_min) : undefined,
    salaire_max: row.salaire_max != null ? Number(row.salaire_max) : undefined,
    salaire_afficher: row.salaire_afficher === 1 || row.salaire_afficher === true,
    teletravail: String(row.teletravail ?? 'non'),
    temps_travail: String(row.temps_travail ?? 'temps_plein'),
    is_featured: row.is_featured === 1 || row.is_featured === true,
    urgent: row.urgent === 1 || row.urgent === true || row.is_urgent === 1 || row.is_urgent === true,
    statut: careerStatusFromApi(row.statut ?? row.status),
    published_at: row.published_at ?? row.date_publication
      ? formatDate(row.published_at ?? row.date_publication)
      : undefined,
    expires_at: row.expires_at ?? row.date_expiration
      ? formatDate(row.expires_at ?? row.date_expiration)
      : undefined,
    sort_order: Number(row.sort_order ?? 0),
    meta_title: row.meta_title ? String(row.meta_title) : undefined,
    meta_description: row.meta_description ? String(row.meta_description) : undefined,
    vues: row.vues != null ? Number(row.vues) : undefined,
  };
}

export function careerOfferToApi(raw: Record<string, unknown>) {
  const statut = careerStatusToApi(raw.statut);
  const salaireMin = raw.salaire_min != null && raw.salaire_min !== '' ? Number(raw.salaire_min) : null;
  const salaireMax = raw.salaire_max != null && raw.salaire_max !== '' ? Number(raw.salaire_max) : null;

  return {
    department: raw.department,
    reference: raw.reference || null,
    slug: raw.slug || undefined,
    title: raw.title,
    titre: raw.title,
    contract_type: raw.contract_type,
    type_contrat: raw.contract_type,
    experience_min: raw.experience_min || null,
    location: raw.location,
    ville: raw.location,
    code_postal: raw.code_postal || null,
    departement: raw.departement || null,
    region: raw.region || null,
    short_description: raw.short_description || null,
    profil_recherche: raw.short_description || null,
    full_description: raw.full_description || null,
    description: raw.full_description || raw.short_description || '—',
    avantages: raw.avantages || null,
    competences_text: raw.competences_text || null,
    salaire_min: salaireMin,
    salaire_max: salaireMax,
    salaire_afficher: raw.salaire_afficher ? 1 : 0,
    teletravail: raw.teletravail || 'non',
    temps_travail: raw.temps_travail || 'temps_plein',
    is_featured: raw.is_featured ? 1 : 0,
    urgent: raw.urgent ? 1 : 0,
    is_urgent: raw.urgent ? 1 : 0,
    statut,
    published_at: raw.published_at || undefined,
    date: raw.published_at || undefined,
    expires_at: raw.expires_at || null,
    sort_order: Number(raw.sort_order ?? 0),
    meta_title: raw.meta_title || null,
    meta_description: raw.meta_description || null,
  };
}

export function buildCareerOfferFields(): FieldDef[] {
  return [
    { key: 'title', label: 'Intitulé du poste', type: 'text', required: true, span: true, section: 'Alt RH' },
    {
      key: 'department', label: 'Département', type: 'select', required: true,
      options: CAREER_DEPARTMENT_OPTIONS,
    },
    { key: 'reference', label: 'Référence interne', type: 'text', placeholder: 'REF-2026-01' },
    { key: 'slug', label: 'Slug URL', type: 'text', hint: 'Généré automatiquement si vide' },
    { key: 'sort_order', label: 'Ordre d\'affichage', type: 'number' },
    { key: 'contract_type', label: 'Type de contrat', type: 'select', required: true, options: CONTRACT_TYPE_OPTIONS, section: 'Conditions' },
    { key: 'experience_min', label: 'Expérience minimum', type: 'select', options: EXPERIENCE_OPTIONS },
    { key: 'temps_travail', label: 'Temps de travail', type: 'select', options: TEMPS_TRAVAIL_OPTIONS },
    { key: 'teletravail', label: 'Télétravail', type: 'select', options: TELETRAVAIL_OPTIONS },
    { key: 'salaire_min', label: 'Salaire min (€/an)', type: 'number', section: 'Rémunération' },
    { key: 'salaire_max', label: 'Salaire max (€/an)', type: 'number' },
    { key: 'salaire_afficher', label: 'Afficher le salaire', type: 'switch' },
    { key: 'location', label: 'Ville', type: 'text', required: true, section: 'Localisation', placeholder: 'Paris, Lyon…' },
    { key: 'code_postal', label: 'Code postal', type: 'text' },
    { key: 'departement', label: 'Département', type: 'text', placeholder: '75, 69…' },
    { key: 'region', label: 'Région', type: 'text', placeholder: 'Île-de-France…' },
    { key: 'full_description', label: 'Description du poste', type: 'textarea', required: true, span: true, section: 'Contenu' },
    { key: 'short_description', label: 'Profil recherché', type: 'textarea', span: true },
    { key: 'avantages', label: 'Avantages', type: 'textarea', span: true },
    {
      key: 'competences_text', label: 'Compétences recherchées', type: 'textarea', span: true, section: 'Compétences',
      hint: 'Une compétence par ligne',
      placeholder: 'Communication\nOrganisation\nExcel',
    },
    { key: 'urgent', label: 'Offre urgente', type: 'switch', section: 'Publication' },
    { key: 'is_featured', label: 'Mettre en avant', type: 'switch' },
    { key: 'published_at', label: 'Date de publication', type: 'date' },
    { key: 'expires_at', label: 'Date de fin de publication', type: 'date' },
    { key: 'statut', label: 'Statut', type: 'select', options: CAREER_OFFER_STATUS_OPTIONS },
    { key: 'meta_title', label: 'Meta title (SEO)', type: 'text', section: 'SEO', placeholder: '70 caractères max.' },
    { key: 'meta_description', label: 'Meta description (SEO)', type: 'textarea', span: true, placeholder: '160 caractères max.' },
  ];
}

export function careerApplicationFromApi(row: Record<string, unknown>): CareerApplication {
  return {
    id: String(row.id),
    offer_id: row.offer_id != null ? String(row.offer_id) : undefined,
    offer_title: row.offer_title ? String(row.offer_title) : undefined,
    application_type: String(row.application_type ?? ''),
    first_name: String(row.first_name ?? ''),
    last_name: String(row.last_name ?? ''),
    email: String(row.email ?? ''),
    phone: String(row.phone ?? ''),
    contract_or_expertise: String(row.contract_or_expertise ?? ''),
    cover_letter_text: row.cover_letter_text ? String(row.cover_letter_text) : undefined,
    cv_filename: String(row.cv_filename ?? ''),
    statut: String(row.statut ?? row.status ?? 'recue'),
    created_at: String(row.created_at ?? ''),
  };
}

export function buildCareerApplicationFields(): FieldDef[] {
  return [
    {
      key: 'statut', label: 'Statut', type: 'select',
      options: CAREER_APPLICATION_STATUS_OPTIONS,
    },
  ];
}
