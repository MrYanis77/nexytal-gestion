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
  const expertiseLabels = String(row.expertise_labels ?? '')
    .split(',')
    .map(s => s.trim())
    .filter(Boolean);

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
    expertise: expertises.length > 0
      ? expertises.map(e => e.label)
      : expertiseLabels,
    expertise_display: expertises.length > 0
      ? expertises.map(e => e.label).join(', ')
      : expertiseLabels.join(', '),
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
    on_catalog: row.on_catalog === 1 || row.on_catalog === true || (row.status === 'active' && row.validated_at != null),
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
    legal_status: raw.legal_status || null,
    linkedin_url: raw.linkedin_url || null,
    status: trainerStatusToApi(raw.statut) || 'pending_review',
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
  return typeof statut === 'string' && statut in map ? map[statut] : 'pending_review';
}

function linesFromStringArray(val: unknown): string {
  if (!Array.isArray(val)) return '';
  return val.map(v => String(v).trim()).filter(Boolean).join('\n');
}

function stringArrayFromLines(raw: unknown): string[] {
  if (Array.isArray(raw)) {
    return raw.map(v => String(v).trim()).filter(Boolean);
  }
  if (typeof raw !== 'string') return [];
  return raw
    .split(/\r?\n/)
    .flatMap(line => line.split(','))
    .map(s => s.trim())
    .filter(Boolean);
}

function faqListFromApi(val: unknown): Array<{ title: string; description: string; duration?: string }> {
  if (!Array.isArray(val) || val.length === 0) {
    return [{ title: '', description: '', duration: '' }];
  }
  return val.map(item => {
    const o = item as { q?: string; a?: string; title?: string; description?: string };
    return {
      title: String(o.q ?? o.title ?? ''),
      description: String(o.a ?? o.description ?? ''),
      duration: '',
    };
  });
}

function faqListToApi(raw: unknown): Array<{ q: string; a: string }> {
  if (!Array.isArray(raw)) return [];
  return raw
    .map(item => {
      const o = item as { title?: string; description?: string; q?: string; a?: string };
      const q = String(o.title ?? o.q ?? '').trim();
      const a = String(o.description ?? o.a ?? '').trim();
      if (!q && !a) return null;
      return { q, a };
    })
    .filter((x): x is { q: string; a: string } => x !== null);
}

export function expertiseFromApi(row: Record<string, unknown>): Record<string, unknown> {
  return {
    id: row.id != null ? String(row.id) : '',
    slug: String(row.slug ?? ''),
    label: String(row.label ?? ''),
    name: String(row.name ?? ''),
    subtitle: String(row.subtitle ?? ''),
    description: String(row.description ?? ''),
    icon: String(row.icon ?? ''),
    sort_order: row.sort_order != null ? String(row.sort_order) : '0',
    is_active: row.is_active !== 0 && row.is_active !== false,
    skills_lines: linesFromStringArray(row.skills_json),
    certifications_lines: linesFromStringArray(row.certifications_json),
    faq_list: faqListFromApi(row.faq_json),
    trainers_count: row.trainers_count ?? 0,
  };
}

function slugifyExpertiseLabel(label: string): string {
  return label
    .normalize('NFD')
    .replace(/[\u0300-\u036f]/g, '')
    .toLowerCase()
    .replace(/[^a-z0-9]+/g, '-')
    .replace(/^-+|-+$/g, '');
}

export function expertiseToApi(raw: Record<string, unknown>) {
  const label = String(raw.label ?? raw.name ?? '').trim();
  const slug = String(raw.slug ?? '').trim() || (label ? slugifyExpertiseLabel(label) : '');

  const payload: Record<string, unknown> = {
    site_id: 5,
    label,
    slug,
    name: raw.name || label || null,
    subtitle: raw.subtitle || null,
    description: raw.description || null,
    icon: raw.icon || null,
    sort_order: raw.sort_order != null ? Number(raw.sort_order) : 0,
    is_active: raw.is_active !== false && raw.is_active !== 0 ? 1 : 0,
    skills_json: stringArrayFromLines(raw.skills_lines),
    certifications_json: stringArrayFromLines(raw.certifications_lines),
    faq_json: faqListToApi(raw.faq_list),
  };
  return payload;
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
      : [
          { key: 'expertise_ids', label: 'Spécialités', type: 'text' as const, span: true, section: 'Spécialités & compétences', hint: 'Aucune spécialité dans le référentiel — onglet Référentiels > Spécialités', placeholder: 'Ajoutez des spécialités dans Référentiels' },
        ]),
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
      key: 'statut', label: 'Statut', type: 'select',
      options: [
        { value: 'actif', label: 'Actif (publié)' },
        { value: 'en_attente', label: 'En revue' },
        { value: 'inactif', label: 'Inactif' },
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
    { key: 'region', label: 'Région', type: 'text' },
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
  const iconOptions = [
    { value: 'brain', label: 'IA (brain)' },
    { value: 'shield', label: 'Cybersécurité (shield)' },
    { value: 'cloud', label: 'Cloud' },
    { value: 'code2', label: 'Développement (code2)' },
    { value: 'bar-chart3', label: 'Data (bar-chart3)' },
    { value: 'briefcase', label: 'RH (briefcase)' },
    { value: 'users', label: 'Management (users)' },
    { value: 'globe', label: 'Bureautique (globe)' },
  ];

  return [
    { key: 'label', label: 'Titre affiché', type: 'text', required: true, span: true, section: 'Identité', hint: 'Ex. Formateur IA — page SEO sur trainer.nexytal.com' },
    { key: 'name', label: 'Nom court (menu)', type: 'text', hint: 'Ex. IA' },
    { key: 'slug', label: 'Slug URL', type: 'text', hint: 'Laisser vide = généré automatiquement (ex. formateur-ia → ia)' },
    { key: 'subtitle', label: 'Sous-titre', type: 'text', span: true },
    { key: 'icon', label: 'Icône', type: 'select', options: iconOptions, section: 'Présentation' },
    { key: 'sort_order', label: 'Ordre menu', type: 'number' },
    { key: 'description', label: 'Description SEO', type: 'textarea', span: true },
    {
      key: 'skills_lines',
      label: 'Compétences',
      type: 'textarea',
      span: true,
      section: 'Contenu catalogue',
      hint: 'Une compétence par ligne (ex. Machine Learning)',
      placeholder: 'Machine Learning\nPython\nDeep Learning',
    },
    {
      key: 'certifications_lines',
      label: 'Certifications',
      type: 'textarea',
      span: true,
      hint: 'Une certification par ligne',
      placeholder: 'CISSP\nCEH\nISO 27001',
    },
    {
      key: 'faq_list',
      label: 'FAQ',
      type: 'module_list',
      moduleListMode: 'faq',
      span: true,
      hint: 'Questions fréquentes affichées sur la page expertise',
    },
    { key: 'is_active', label: 'Active (visible sur le site)', type: 'switch', section: 'Publication' },
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
