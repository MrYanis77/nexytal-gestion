import { Formateur } from '@/contexts/AppContext';
import { parseIdList, parseJsonArray } from './nested-json';
import { PHOTO_URL_PLACEHOLDER, PHOTO_URL_HINT, VIDEO_URL_PLACEHOLDER, VIDEO_URL_HINT } from '@/lib/constants';

export function trainerFromApi(row: Record<string, unknown>): Formateur {
  return trainerDetailFromApi(row) as Formateur;
}

function trainerIdentityFromRow(row: Record<string, unknown>) {
  let prenom = String(row.first_name ?? '').trim();
  let nom = String(row.last_name ?? '').trim();
  if (!prenom && !nom) {
    const full = String(row.name ?? '').trim();
    if (full) {
      const space = full.indexOf(' ');
      if (space > 0) {
        prenom = full.slice(0, space);
        nom = full.slice(space + 1);
      } else {
        prenom = full;
      }
    }
  }
  const nomComplet = `${prenom} ${nom}`.trim();
  return { prenom, nom, nomComplet: nomComplet || String(row.name ?? '').trim() };
}

export function trainerDetailFromApi(row: Record<string, unknown>): Record<string, unknown> {
  const expertises = row.expertises
    ? (row.expertises as Array<{ id?: number; label: string }>)
    : [];

  const { prenom, nom, nomComplet } = trainerIdentityFromRow(row);
  const tjmRaw = row.tjm_eur ?? row.tjm;
  const experienceRaw = row.experience_years ?? row.experience;

  return {
    id: String(row.id),
    prenom,
    nom,
    nomComplet,
    email: String(row.email ?? ''),
    phone: String(row.phone ?? ''),
    titre: String(row.title ?? ''),
    slug: String(row.slug ?? ''),
    tagline: String(row.tagline ?? ''),
    avatar_url: String(row.avatar_url ?? ''),
    photo: String(row.avatar_url ?? ''),
    avatar_initials: String(row.avatar_initials ?? ''),
    city_id: row.city_id != null ? String(row.city_id) : '',
    region: String(row.city_name ?? row.region ?? ''),
    experience_years: experienceRaw != null ? String(experienceRaw) : '0',
    expertise: expertises.map(e => e.label),
    expertise_ids: expertises.map(e => String(e.id ?? '')).filter(Boolean).join(','),
    primary_expertise_id: row.primary_expertise_id != null ? String(row.primary_expertise_id) : '',
    tjm: tjmRaw != null && tjmRaw !== '' ? String(tjmRaw) : '',
    disponibilite: row.availability === 'available',
    availability: String(row.availability ?? 'available'),
    legal_status: String(row.legal_status ?? ''),
    linkedin_url: String(row.linkedin_url ?? ''),
    modalite: Array.isArray(row.modalities) ? row.modalities as string[] : [],
    modalities_csv: Array.isArray(row.modalities) ? (row.modalities as string[]).join(',') : '',
    bio: String(row.bio ?? row.short_bio ?? ''),
    is_featured: !!row.is_featured,
    qualiopi_eligible: !!row.qualiopi_eligible,
    statut: trainerStatusFromApi(row.status, row),
    courses_list: Array.isArray(row.courses)
      ? (row.courses as Array<{ title?: string; description?: string; duration_label?: string }>).map(c => ({
          title: String(c.title ?? ''),
          description: [c.duration_label, c.description].filter(Boolean).join(' — '),
        }))
      : [{ title: '', description: '' }],
    skill_ids: Array.isArray(row.skills)
      ? (row.skills as Array<{ id: number }>).map(s => String(s.id)).join(',')
      : '',
    certification_ids: Array.isArray(row.certifications)
      ? (row.certifications as Array<{ id: number }>).map(c => String(c.id)).join(',')
      : '',
    createdAt: String(row.created_at ?? ''),
  };
}

function mergeExpertiseIds(raw: Record<string, unknown>): number[] {
  const ids = new Set(parseIdList(raw.expertise_ids));
  const primary = raw.primary_expertise_id ? Number(raw.primary_expertise_id) : 0;
  if (primary > 0) ids.add(primary);
  return [...ids];
}

export function trainerToApi(raw: Record<string, unknown>) {
  const modalities = raw.modalities_csv
    ? String(raw.modalities_csv).split(',').map(s => s.trim()).filter(Boolean)
    : Array.isArray(raw.modalite) ? raw.modalite as string[] : [];

  const payload: Record<string, unknown> = {
    first_name: raw.prenom ?? raw.first_name,
    last_name: raw.nom ?? raw.last_name,
    title: raw.titre ?? raw.title,
    tagline: raw.tagline || null,
    email: raw.email,
    phone: raw.phone || null,
    avatar_url: raw.photo || raw.avatar_url || null,
    experience_years: raw.experience_years ? Number(raw.experience_years) : 0,
    tjm_eur: raw.tjm ? Number(raw.tjm) : null,
    availability: (raw.availability as string) || (raw.disponibilite ? 'available' : 'available'),
    legal_status: raw.legal_status || null,
    linkedin_url: raw.linkedin_url || null,
    status: trainerStatusToApi(raw.statut),
    is_featured: raw.is_featured ? 1 : 0,
    qualiopi_eligible: raw.qualiopi_eligible ? 1 : 0,
    bio: raw.bio || null,
  };
  if (modalities.length > 0) payload.modalities = modalities;
  if (raw.primary_expertise_id) payload.primary_expertise_id = Number(raw.primary_expertise_id);

  if ('expertise_ids' in raw || raw.primary_expertise_id) {
    payload.expertise_ids = mergeExpertiseIds(raw);
  }
  if ('skill_ids' in raw) payload.skill_ids = parseIdList(raw.skill_ids);
  if ('certification_ids' in raw) payload.certification_ids = parseIdList(raw.certification_ids);

  if ('language_ids' in raw) payload.language_ids = parseIdList(raw.language_ids);
  if ('city_ids' in raw) payload.city_ids = parseIdList(raw.city_ids);

  if ('courses_list' in raw && Array.isArray(raw.courses_list)) {
    payload.courses = (raw.courses_list as Array<{ title?: string; description?: string }>)
      .filter(c => String(c.title ?? '').trim())
      .map((c, idx) => {
        const desc = String(c.description ?? '').trim();
        const dash = desc.indexOf(' — ');
        const duration = dash > 0 ? desc.slice(0, dash).trim() : null;
        const description = dash > 0 ? desc.slice(dash + 3).trim() || null : desc || null;
        return {
          title: String(c.title).trim(),
          duration_label: duration,
          description,
          sort_order: idx,
          is_active: 1,
        };
      });
  } else if ('courses_json' in raw) {
    payload.courses = parseJsonArray(raw.courses_json);
  }
  return payload;
}

function trainerStatusFromApi(status: unknown, row?: Record<string, unknown>): Formateur['statut'] {
  const map: Record<string, Formateur['statut']> = {
    active: 'actif',
    inactive: 'inactif',
    pending_review: 'en_attente',
    draft: 'inactif',
    rejected: 'inactif',
  };
  if (typeof status === 'string' && status in map) {
    return map[status];
  }
  // Ancienne API (vue catalogue) : pas de status, mais seuls les actifs y figurent
  if (row && (row.name != null || row.title != null) && row.status == null) {
    return 'actif';
  }
  return 'en_attente';
}

function trainerStatusToApi(statut: unknown): string {
  const map: Record<string, string> = {
    actif: 'active',
    inactif: 'inactive',
    en_attente: 'pending_review',
  };
  return typeof statut === 'string' && statut in map ? map[statut] : 'active';
}

export function expertiseToApi(raw: Record<string, unknown>) {
  return { label: raw.label ?? raw.name };
}

export function buildTrainerFields(
  expertiseOptions: { value: string; label: string }[] = [],
  skillOptions: { value: string; label: string }[] = [],
  certificationOptions: { value: string; label: string }[] = [],
): import('@/components/FormModal').FieldDef[] {
  return [
    { key: 'prenom', label: 'Prénom', type: 'text', required: true, section: 'Informations' },
    { key: 'nom', label: 'Nom', type: 'text', required: true },
    { key: 'titre', label: 'Titre professionnel', type: 'text', required: true, span: true, hint: 'Ex. Consultant React & Node.js' },
    { key: 'tagline', label: 'Phrase d\'accroche', type: 'text', span: true },
    { key: 'email', label: 'Email', type: 'email', required: true, section: 'Contact' },
    { key: 'phone', label: 'Téléphone', type: 'text' },
    { key: 'linkedin_url', label: 'Profil LinkedIn', type: 'text', span: true, placeholder: 'https://linkedin.com/in/…' },
    {
      key: 'photo', label: 'Photo du formateur', type: 'file', fileKind: 'image', uploadContext: 'trainers',
      span: true, section: 'Photo', placeholder: PHOTO_URL_PLACEHOLDER, hint: PHOTO_URL_HINT,
    },
    { key: 'experience_years', label: 'Années d\'expérience', type: 'number', section: 'Profil' },
    { key: 'tjm', label: 'Tarif journalier (€)', type: 'number' },
    {
      key: 'legal_status', label: 'Statut juridique', type: 'select',
      options: [
        { value: 'auto_entrepreneur', label: 'Auto-entrepreneur' },
        { value: 'sasu', label: 'SASU' },
        { value: 'eurl', label: 'EURL' },
        { value: 'portage_salarial', label: 'Portage salarial' },
        { value: 'other', label: 'Autre' },
      ],
    },
    {
      key: 'availability', label: 'Disponibilité', type: 'select',
      options: [
        { value: 'available', label: 'Disponible' },
        { value: 'soon', label: 'Bientôt disponible' },
        { value: 'unavailable', label: 'Indisponible' },
      ],
    },
    ...(expertiseOptions.length
      ? [
          { key: 'expertise_ids', label: 'Spécialités', type: 'multi_select' as const, options: expertiseOptions, span: true, section: 'Spécialités & compétences', hint: 'Sélectionnez une ou plusieurs spécialités affichées sur le site' },
          { key: 'primary_expertise_id', label: 'Spécialité principale', type: 'select' as const, options: expertiseOptions },
        ]
      : []),
    ...(skillOptions.length
      ? [{ key: 'skill_ids', label: 'Compétences techniques', type: 'multi_select' as const, options: skillOptions, span: true, hint: 'Compétences visibles sur la fiche formateur' }]
      : []),
    ...(certificationOptions.length
      ? [{ key: 'certification_ids', label: 'Certifications', type: 'multi_select' as const, options: certificationOptions, span: true, hint: 'Certifications rattachées au profil' }]
      : []),
    {
      key: 'courses_list', label: 'Formations proposées', type: 'module_list', span: true, section: 'Formations proposées',
      hint: 'Titres et descriptions des formations que ce formateur peut animer',
    },
    { key: 'bio', label: 'Présentation', type: 'textarea', span: true, section: 'Contenu' },
    { key: 'is_featured', label: 'Mettre en avant sur le site', type: 'switch', section: 'Publication' },
    { key: 'qualiopi_eligible', label: 'Éligible Qualiopi', type: 'switch' },
    {
      key: 'statut', label: 'Profil visible', type: 'select',
      options: [
        { value: 'actif', label: 'Oui' },
        { value: 'inactif', label: 'Non' },
      ],
    },
  ];
}

export function buildTrainerSkillFields(): import('@/components/FormModal').FieldDef[] {
  return [
    { key: 'name', label: 'Compétence', type: 'text', required: true, span: true },
  ];
}

export function buildTrainerCityFields(): import('@/components/FormModal').FieldDef[] {
  return [
    { key: 'name', label: 'Ville', type: 'text', required: true },
    { key: 'region', label: 'Région', type: 'text', required: true },
    { key: 'description', label: 'Description', type: 'textarea', span: true },
    { key: 'is_active', label: 'Visible sur le site', type: 'switch' },
  ];
}

export function buildTrainerCertificationFields(): import('@/components/FormModal').FieldDef[] {
  return [
    { key: 'name', label: 'Nom de la certification', type: 'text', required: true, span: true },
  ];
}

export function buildTrainerLanguageFields(): import('@/components/FormModal').FieldDef[] {
  return [
    { key: 'name', label: 'Langue', type: 'text', required: true, span: true },
  ];
}

export function buildTrainerReviewFields(
  trainerOptions: { value: string; label: string }[],
): import('@/components/FormModal').FieldDef[] {
  return [
    { key: 'trainer_id', label: 'Formateur', type: 'select', required: true, options: trainerOptions, span: true },
    { key: 'author_name', label: 'Auteur avis', type: 'text', required: true },
    { key: 'company', label: 'Entreprise', type: 'text' },
    { key: 'rating', label: 'Note (1-5)', type: 'number', required: true },
    { key: 'comment', label: 'Commentaire', type: 'textarea', required: true, span: true },
    { key: 'is_published', label: 'Publié', type: 'switch' },
  ];
}

export function buildExpertiseFields(): import('@/components/FormModal').FieldDef[] {
  return [
    { key: 'label', label: 'Nom de la spécialité', type: 'text', required: true, span: true },
  ];
}

export function buildTrainerApplicationFields(): import('@/components/FormModal').FieldDef[] {
  return [
    {
      key: 'status',
      label: 'Statut',
      type: 'select',
      options: [
        { value: 'new', label: 'Nouvelle' },
        { value: 'in_review', label: 'En revue' },
        { value: 'interview', label: 'Entretien' },
        { value: 'approved', label: 'Approuvée' },
        { value: 'rejected', label: 'Refusée' },
      ],
    },
  ];
}
