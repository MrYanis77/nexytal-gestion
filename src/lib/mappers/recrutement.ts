import { OffreEmploi, Metier } from '@/contexts/AppContext';
import { statusFromApi, statusToApi, formatDate } from './status';

export const CONTRACT_OPTIONS = [
  { value: '1', label: 'CDI' },
  { value: '2', label: 'CDD' },
  { value: '3', label: 'Freelance' },
  { value: '4', label: 'Intérim' },
  { value: '6', label: 'Stage' },
];

export function offerToApi(raw: Record<string, unknown>, siteId: number) {
  const desc = String(raw.description ?? '').trim() || '—';
  const shortDesc = desc.length > 500 ? desc.slice(0, 500) : desc;

  const payload: Record<string, unknown> = {
    title: raw.titre,
    company_name: raw.entreprise || 'Non précisé',
    location: raw.lieu || 'Non précisé',
    postal_code: raw.postal_code || null,
    contract_type_id: Number(raw.contract_type_id || 1),
    salary_range: raw.salaire || null,
    experience_level: raw.experience || null,
    duration: raw.duration || null,
    short_desc: raw.short_desc || shortDesc,
    full_desc: desc,
    is_urgent: raw.urgent ? 1 : 0,
    status: statusToApi(raw.statut, 'draft'),
    published_at: raw.date && raw.statut === 'publie' ? `${raw.date} 00:00:00` : undefined,
    expires_at: raw.expires_at || null,
  };

  if (siteId === 3) {
    payload.profession_id = raw.profession_id ? Number(raw.profession_id) : null;
    payload.job_id = null;
  } else {
    payload.job_id = raw.job_id ? Number(raw.job_id) : null;
    payload.profession_id = null;
  }

  if (raw.tag_ids) {
    payload.tag_ids = Array.isArray(raw.tag_ids)
      ? raw.tag_ids.map(Number)
      : String(raw.tag_ids).split(',').filter(Boolean).map(Number);
  }

  return payload;
}

export function offerFromApi(row: Record<string, unknown>): OffreEmploi {
  return {
    id: String(row.id),
    titre: String(row.title ?? ''),
    entreprise: String(row.company_name ?? ''),
    lieu: String(row.location ?? ''),
    postal_code: String(row.postal_code ?? ''),
    contract_type_id: row.contract_type_id != null ? String(row.contract_type_id) : '',
    contrat: String(row.contract_type_name ?? ''),
    profession_id: row.profession_id != null ? String(row.profession_id) : '',
    job_id: row.job_id != null ? String(row.job_id) : '',
    secteur: String(row.job_name ?? row.profession_name ?? ''),
    salaire: row.salary_range ? String(row.salary_range) : undefined,
    experience: row.experience_level ? String(row.experience_level) : undefined,
    duration: String(row.duration ?? ''),
    short_desc: String(row.short_desc ?? ''),
    description: String(row.full_desc ?? row.short_desc ?? ''),
    urgent: !!row.is_urgent,
    date: formatDate(row.published_at ?? row.created_at),
    expires_at: row.expires_at ? formatDate(row.expires_at) : undefined,
    statut: statusFromApi(row.status),
    site: 'recrutement',
  };
}

export function professionToApi(raw: Record<string, unknown>) {
  const slug = raw.slug != null ? String(raw.slug).trim() : '';
  return {
    name: String(raw.nom ?? '').trim(),
    ...(slug ? { slug } : {}),
    sector: raw.secteur ? String(raw.secteur).trim() : null,
    description: [raw.description, raw.debouches].filter(Boolean).join('\n\n').trim() || null,
    is_active: raw.statut === 'publie' ? 1 : 0,
  };
}

export function professionFromApi(row: Record<string, unknown>): Metier {
  return {
    id: String(row.id),
    nom: String(row.name ?? ''),
    slug: String(row.slug ?? ''),
    secteur: String(row.sector ?? ''),
    description: String(row.description ?? ''),
    statut: row.is_active ? 'publie' : 'brouillon',
  };
}

export function buildOfferFieldsIT(
  tagOptions: { value: string; label: string }[],
): import('@/components/FormModal').FieldDef[] {
  return [
    { key: 'titre', label: 'Titre du poste', type: 'text', required: true, span: true },
    { key: 'entreprise', label: 'Entreprise', type: 'text', required: true },
    { key: 'lieu', label: 'Lieu', type: 'text', required: true },
    { key: 'postal_code', label: 'Code postal', type: 'text' },
    { key: 'contract_type_id', label: 'Type de contrat', type: 'select', required: true, options: CONTRACT_OPTIONS },
    { key: 'salaire', label: 'Salaire / TJM', type: 'text' },
    { key: 'experience', label: 'Expérience requise', type: 'text' },
    { key: 'duration', label: 'Durée (CDD/Mission)', type: 'text' },
    { key: 'short_desc', label: 'Description courte', type: 'textarea', span: true },
    { key: 'description', label: 'Description complète du poste', type: 'textarea', required: true, span: true },
    { key: 'urgent', label: 'Offre urgente', type: 'switch' },
    { key: 'date', label: 'Date de publication', type: 'date' },
    { key: 'expires_at', label: 'Date d\'expiration', type: 'date' },
    {
      key: 'statut',
      label: 'Statut',
      type: 'select',
      options: [
        { value: 'publie', label: 'Publié' },
        { value: 'brouillon', label: 'Brouillon' },
      ],
    },
    ...(tagOptions.length
      ? [{ key: 'tag_ids', label: 'Tags techniques (IDs séparés par virgule)', type: 'text' as const, span: true }]
      : []),
  ];
}

export function buildOfferFieldsMedical(
  professionOptions: { value: string; label: string }[],
): import('@/components/FormModal').FieldDef[] {
  return [
    { key: 'titre', label: 'Titre du poste', type: 'text', required: true, span: true },
    { key: 'entreprise', label: 'Établissement', type: 'text', required: true },
    { key: 'lieu', label: 'Lieu', type: 'text', required: true },
    { key: 'postal_code', label: 'Code postal', type: 'text' },
    { key: 'contract_type_id', label: 'Type de contrat', type: 'select', required: true, options: CONTRACT_OPTIONS },
    {
      key: 'profession_id',
      label: 'Métier',
      type: 'select',
      options: professionOptions,
    },
    { key: 'salaire', label: 'Salaire', type: 'text' },
    { key: 'experience', label: 'Expérience requise', type: 'text' },
    { key: 'duration', label: 'Durée (CDD/Mission)', type: 'text' },
    { key: 'short_desc', label: 'Description courte', type: 'textarea', span: true },
    { key: 'description', label: 'Description complète', type: 'textarea', required: true, span: true },
    { key: 'urgent', label: 'Offre urgente', type: 'switch' },
    { key: 'date', label: 'Date de publication', type: 'date' },
    { key: 'expires_at', label: 'Date d\'expiration', type: 'date' },
    {
      key: 'statut',
      label: 'Statut',
      type: 'select',
      options: [
        { value: 'publie', label: 'Publié' },
        { value: 'brouillon', label: 'Brouillon' },
      ],
    },
  ];
}

export function buildMetierFields(): import('@/components/FormModal').FieldDef[] {
  return [
    { key: 'nom', label: 'Nom du métier', type: 'text', required: true },
    { key: 'slug', label: 'Slug URL', type: 'text', placeholder: 'ex. medecin-generaliste' },
    { key: 'secteur', label: 'Secteur', type: 'text' },
    { key: 'description', label: 'Description', type: 'textarea', span: true },
    {
      key: 'statut',
      label: 'Statut',
      type: 'select',
      options: [
        { value: 'publie', label: 'Publié' },
        { value: 'brouillon', label: 'Brouillon' },
      ],
    },
  ];
}

export function buildContractTypeFields(): import('@/components/FormModal').FieldDef[] {
  return [
    { key: 'code', label: 'Code (ex: CDI)', type: 'text', required: true },
    { key: 'name', label: 'Nom complet', type: 'text', required: true, span: true },
  ];
}

export function buildSectorFields(): import('@/components/FormModal').FieldDef[] {
  return [
    { key: 'name', label: 'Nom du secteur', type: 'text', required: true, span: true },
    { key: 'slug', label: 'Slug URL', type: 'text', placeholder: 'Auto-généré' },
  ];
}
