import { Formation } from '@/contexts/AppContext';
import { statusFromApi, statusToApi } from './status';
import { parseJsonArray, stringifyJsonArray } from './nested-json';
import { PHOTO_URL_PLACEHOLDER, PHOTO_URL_HINT, VIDEO_URL_PLACEHOLDER, VIDEO_URL_HINT } from '@/lib/constants';

export const FORMATION_NO_CATEGORY = '__none__';

function optionalJsonField(raw: Record<string, unknown>, key: string) {
  if (!(key in raw)) return undefined;
  return parseJsonArray(raw[key]);
}

function linesToListItems(text: unknown, listType: string) {
  return String(text ?? '')
    .split('\n')
    .map(l => l.trim())
    .filter(Boolean)
    .map((content, sort_order) => ({ list_type: listType, content, sort_order }));
}

function listTextFromItems(listItems: unknown, listType: string, multiline = false) {
  const items = Array.isArray(listItems) ? listItems as Array<{ list_type?: string; content?: string }> : [];
  const lines = items
    .filter(i => i.list_type === listType)
    .map(i => String(i.content ?? '').trim())
    .filter(Boolean);
  return multiline ? lines.join('\n\n') : lines.join('\n');
}

export type FormationModuleItem = { title: string; description: string };

function modulesListFromApi(modules: unknown): FormationModuleItem[] {
  if (!Array.isArray(modules) || modules.length === 0) {
    return [{ title: '', description: '' }];
  }
  return modules.map((m: Record<string, unknown>) => ({
    title: String(m.title ?? ''),
    description: String(m.description ?? ''),
  }));
}

function modulesListToApi(raw: unknown) {
  if (!Array.isArray(raw)) return [];
  return raw
    .map((m, sort_order) => {
      const item = m as FormationModuleItem;
      const title = String(item.title ?? '').trim();
      if (!title) return null;
      return {
        title,
        description: String(item.description ?? '').trim() || null,
        duration_label: null,
        sort_order,
      };
    })
    .filter((m): m is NonNullable<typeof m> => m !== null);
}

function parseStatsText(text: unknown) {
  return String(text ?? '')
    .split('\n')
    .map(l => l.trim())
    .filter(Boolean)
    .map((line, sort_order) => {
      const parts = line.split('|').map(p => p.trim());
      return { label: parts[0], value: parts[1] || '—', sort_order };
    });
}

function statsTextFromApi(stats: unknown) {
  if (!Array.isArray(stats)) return '';
  return stats.map((s: Record<string, unknown>) => {
    const label = String(s.label ?? '').trim();
    const value = String(s.value ?? '').trim();
    return value ? `${label} | ${value}` : label;
  }).filter(Boolean).join('\n');
}

function parseJobOutcomesText(text: unknown) {
  return String(text ?? '')
    .split('\n')
    .map(l => l.trim())
    .filter(Boolean)
    .map((line, sort_order) => {
      const parts = line.split('|').map(p => p.trim());
      return {
        job_title: parts[0],
        salary_label: parts[1] || 'Selon expérience',
        sort_order,
      };
    });
}

function jobOutcomesTextFromApi(jobs: unknown) {
  if (!Array.isArray(jobs)) return '';
  return jobs.map((j: Record<string, unknown>) => {
    const title = String(j.job_title ?? '').trim();
    const salary = String(j.salary_label ?? '').trim();
    if (salary && salary !== 'Selon expérience') return `${title} | ${salary}`;
    return title;
  }).filter(Boolean).join('\n');
}

function buildFormationListItems(raw: Record<string, unknown>) {
  const items = [
    ...linesToListItems(raw.objectifs_text, 'objectif'),
    ...linesToListItems(raw.competences_acquises_text, 'competence'),
    ...linesToListItems(raw.evaluation_steps_text, 'evaluation_step'),
    ...linesToListItems(raw.metiers_liste_text, 'metier_vise'),
  ];
  const modalities = String(raw.info_modalities_description ?? '').trim();
  if (modalities) {
    items.push({ list_type: 'info_modalite', content: modalities, sort_order: 0 });
  }
  const prerequisites = String(raw.info_prerequisites_description ?? '').trim();
  if (prerequisites) {
    items.push({ list_type: 'info_prerequis', content: prerequisites, sort_order: 0 });
  }
  return items;
}

function formationListItemsFromApi(listItems: unknown) {
  return {
    info_modalities_description: listTextFromItems(listItems, 'info_modalite', true),
    info_prerequisites_description: listTextFromItems(listItems, 'info_prerequis', true),
    objectifs_text: listTextFromItems(listItems, 'objectif'),
    competences_acquises_text: listTextFromItems(listItems, 'competence'),
    evaluation_steps_text: listTextFromItems(listItems, 'evaluation_step'),
    metiers_liste_text: listTextFromItems(listItems, 'metier_vise'),
  };
}

export function courseToApi(raw: Record<string, unknown>) {
  const payload: Record<string, unknown> = {
    hero_title: raw.titre,
    hero_subtitle: raw.hero_subtitle || null,
    type: raw.type || 'longue',
    category_id: raw.category_id && String(raw.category_id) !== '' && String(raw.category_id) !== FORMATION_NO_CATEGORY
      ? Number(raw.category_id)
      : null,
    hero_image_url: raw.hero_image_url || raw.photo_principale || null,
    card_image_url: raw.card_image_url || raw.photo_carte || null,
    presentation_image: raw.presentation_image || raw.photo_presentation || null,
    hero_video_url: raw.hero_video_url || raw.video_url || null,
    seo_title: raw.meta_title || null,
    seo_description: raw.meta_description || null,
    presentation_title: raw.presentation_title || 'Le métier',
    presentation_content: raw.description || null,
    programme_duration_label: raw.duree || null,
    methodology: raw.methodology || null,
    certification_label: raw.certification_label || null,
    evaluation_title: raw.evaluation_title || null,
    evaluation_description: raw.evaluation_description || null,
    debouches_title: raw.debouches_title || null,
    debouches_subtitle: raw.debouches_subtitle || null,
    debouches_sectors: raw.debouches_sectors || null,
    info_modalities_title: raw.info_modalities_title || null,
    info_prerequisites_title: raw.info_prerequisites_title || null,
    status: statusToApi(raw.statut),
    published_at: raw.date && raw.statut === 'publie' ? `${raw.date} 00:00:00` : undefined,
  };

  if ('modules_list' in raw) {
    payload.modules = modulesListToApi(raw.modules_list);
  } else {
    const modules = optionalJsonField(raw, 'modules_json');
    if (modules !== undefined) payload.modules = modules;
  }

  if ('stats_text' in raw) {
    payload.stats = parseStatsText(raw.stats_text);
  } else {
    const stats = optionalJsonField(raw, 'stats_json');
    if (stats !== undefined) payload.stats = stats;
  }

  if ('metiers_vises_text' in raw) {
    payload.job_outcomes = parseJobOutcomesText(raw.metiers_vises_text);
  } else {
    const jobOutcomes = optionalJsonField(raw, 'job_outcomes_json');
    if (jobOutcomes !== undefined) payload.job_outcomes = jobOutcomes;
  }

  if (
    'modules_list' in raw || 'objectifs_text' in raw || 'competences_acquises_text' in raw
    || 'evaluation_steps_text' in raw || 'metiers_liste_text' in raw
    || 'info_modalities_description' in raw || 'info_prerequisites_description' in raw
  ) {
    payload.list_items = buildFormationListItems(raw);
  } else {
    const listItems = optionalJsonField(raw, 'list_items_json');
    if (listItems !== undefined) payload.list_items = listItems;
  }

  const cert = parseJsonArray<Record<string, unknown>>(raw.official_certification_json);
  if (cert.length > 0 && cert[0]?.code) {
    payload.official_certification = cert[0];
  } else if (raw.rncp_code) {
    payload.official_certification = {
      repertoire: raw.rncp_repertoire || 'RNCP',
      code: raw.rncp_code,
      official_title: raw.rncp_title || raw.titre,
      level: raw.rncp_level ? Number(raw.rncp_level) : null,
      france_competences_url: raw.rncp_url || 'https://www.francecompetences.fr',
      show_on_certification_page: 1,
    };
  }

  return payload;
}

export function courseFromApi(row: Record<string, unknown>): Formation {
  return courseDetailFromApi(row);
}

export function courseDetailFromApi(row: Record<string, unknown>): Formation & Record<string, unknown> {
  const oc = row.official_certification as Record<string, unknown> | null;
  const listFields = formationListItemsFromApi(row.list_items);
  return {
    id: String(row.id),
    titre: String(row.hero_title ?? ''),
    hero_subtitle: String(row.hero_subtitle ?? ''),
    type: String(row.type ?? 'longue'),
    slug: String(row.slug ?? ''),
    category_id: row.category_id != null ? String(row.category_id) : FORMATION_NO_CATEGORY,
    categorie: String(row.category_label ?? ''),
    description: String(row.presentation_content ?? ''),
    video_url: String(row.hero_video_url ?? ''),
    hero_image_url: String(row.hero_image_url ?? ''),
    card_image_url: String(row.card_image_url ?? ''),
    presentation_image: String(row.presentation_image ?? ''),
    photo_principale: String(row.hero_image_url ?? ''),
    photo_carte: String(row.card_image_url ?? ''),
    photo_presentation: String(row.presentation_image ?? ''),
    duree: String(row.programme_duration_label ?? ''),
    methodology: String(row.methodology ?? ''),
    certification_label: row.certification_label ? String(row.certification_label) : undefined,
    presentation_title: String(row.presentation_title ?? ''),
    evaluation_title: String(row.evaluation_title ?? ''),
    evaluation_description: String(row.evaluation_description ?? ''),
    debouches_title: String(row.debouches_title ?? ''),
    debouches_subtitle: String(row.debouches_subtitle ?? ''),
    debouches_sectors: String(row.debouches_sectors ?? ''),
    info_modalities_title: String(row.info_modalities_title ?? 'Modalités pratiques'),
    info_prerequisites_title: String(row.info_prerequisites_title ?? 'Prérequis'),
    ...listFields,
    modules_list: modulesListFromApi(row.modules),
    stats_text: statsTextFromApi(row.stats),
    metiers_vises_text: jobOutcomesTextFromApi(row.job_outcomes),
    internal_reference: String(row.internal_reference ?? ''),
    sort_order: row.sort_order != null ? String(row.sort_order) : '',
    meta_title: String(row.seo_title ?? ''),
    meta_description: String(row.seo_description ?? ''),
    statut: statusFromApi(row.status),
    date: String(row.published_at ?? '').slice(0, 10),
    createdAt: String(row.created_at ?? ''),
    rncp_repertoire: oc ? String(oc.repertoire ?? '') : '',
    rncp_code: oc ? String(oc.code ?? '') : '',
    rncp_title: oc ? String(oc.official_title ?? '') : '',
    rncp_level: oc?.level != null ? String(oc.level) : '',
    rncp_url: oc ? String(oc.france_competences_url ?? '') : '',
    modules_json: stringifyJsonArray(row.modules),
    stats_json: stringifyJsonArray(row.stats),
    list_items_json: stringifyJsonArray(row.list_items),
    job_outcomes_json: stringifyJsonArray(row.job_outcomes),
    official_certification_json: stringifyJsonArray(oc ? [oc] : []),
  };
}

export function categoryToApi(raw: Record<string, unknown>) {
  return {
    label: raw.label ?? raw.name,
    description: raw.description || null,
    catalogue_type: 'all',
    is_active: raw.is_active ? 1 : 0,
  };
}

export function buildFormationFields(
  categoryOptions: { value: string; label: string }[] = [],
): import('@/components/FormModal').FieldDef[] {
  return [
    { key: 'titre', label: 'Nom de la formation', type: 'text', required: true, span: true, section: 'Informations' },
    {
      key: 'category_id', label: 'Type de formation', type: 'select', section: 'Informations',
      options: [
        { value: FORMATION_NO_CATEGORY, label: '— Aucun —' },
        ...categoryOptions,
      ],
      hint: categoryOptions.length
        ? undefined
        : 'Créez d\'abord un type dans l\'onglet « Types de formation ».',
    },
    { key: 'hero_subtitle', label: 'Phrase d\'accroche', type: 'text', span: true, hint: 'Courte description visible en haut de la page' },
    { key: 'duree', label: 'Durée', type: 'text', placeholder: 'Ex. 6 mois, 1050 heures' },
    {
      key: 'photo_principale', label: 'Photo principale', type: 'file', fileKind: 'image', uploadContext: 'formation',
      span: true, section: 'Médias', placeholder: PHOTO_URL_PLACEHOLDER, hint: PHOTO_URL_HINT,
    },
    {
      key: 'photo_carte', label: 'Photo pour la liste', type: 'file', fileKind: 'image', uploadContext: 'formation',
      span: true, hint: 'Image affichée dans le catalogue des formations',
    },
    {
      key: 'photo_presentation', label: 'Photo de présentation', type: 'file', fileKind: 'image', uploadContext: 'formation',
      span: true, hint: 'Illustration de la section « présentation »',
    },
    {
      key: 'video_url', label: 'Vidéo de présentation', type: 'file', fileKind: 'video', uploadContext: 'formation',
      span: true, placeholder: VIDEO_URL_PLACEHOLDER, hint: VIDEO_URL_HINT,
    },
    { key: 'presentation_title', label: 'Titre de la présentation', type: 'text', section: 'Contenu' },
    { key: 'description', label: 'Texte de présentation', type: 'textarea', span: true },
    { key: 'methodology', label: 'Méthode pédagogique', type: 'textarea', span: true },
    { key: 'certification_label', label: 'Intitulé de la certification', type: 'text' },
    {
      key: 'modules_list', label: 'Programme', type: 'module_list', span: true, section: 'Programme détaillé',
      hint: 'Ajoutez chaque module avec son nom et le détail de son contenu.',
    },
    { key: 'evaluation_title', label: 'Titre — évaluation', type: 'text', section: 'Évaluation & débouchés' },
    { key: 'evaluation_description', label: 'Texte — évaluation', type: 'textarea', span: true },
    {
      key: 'evaluation_steps_text', label: 'Étapes d\'évaluation', type: 'textarea', span: true,
      hint: 'Une étape par ligne (ex. QCM, mise en situation, soutenance…)',
    },
    { key: 'debouches_title', label: 'Titre — débouchés', type: 'text' },
    { key: 'debouches_subtitle', label: 'Sous-titre — débouchés', type: 'text' },
    { key: 'debouches_sectors', label: 'Secteurs d\'activité visés', type: 'textarea', span: true },
    {
      key: 'metiers_vises_text', label: 'Métiers visés & salaires', type: 'textarea', span: true,
      hint: 'Une ligne par métier : Intitulé | Fourchette salariale',
      placeholder: 'Développeur Full Stack | 35 000 - 45 000 €',
    },
    {
      key: 'stats_text', label: 'Chiffres clés', type: 'textarea', span: true,
      hint: 'Une ligne par indicateur : Libellé | Valeur',
      placeholder: 'Taux d\'insertion | 87%\nDurée moyenne | 6 mois',
    },
    {
      key: 'info_modalities_title', label: 'Titre de la section modalités', type: 'text', section: 'Infos pratiques',
      placeholder: 'Modalités pratiques',
    },
    {
      key: 'info_modalities_description', label: 'Modalités', type: 'textarea', span: true,
      hint: 'Horaires, rythme, lieu, financement, accessibilité…',
    },
    {
      key: 'info_prerequisites_title', label: 'Titre de la section prérequis', type: 'text',
      placeholder: 'Prérequis',
    },
    {
      key: 'info_prerequisites_description', label: 'Prérequis', type: 'textarea', span: true,
      hint: 'Niveau requis, expérience, diplômes, tests d\'entrée…',
    },
    {
      key: 'objectifs_text', label: 'Objectifs pédagogiques', type: 'textarea', span: true,
      hint: 'Un objectif par ligne',
    },
    {
      key: 'competences_acquises_text', label: 'Compétences acquises', type: 'textarea', span: true,
      hint: 'Une compétence par ligne',
    },
    { key: 'rncp_code', label: 'Code certification (RNCP)', type: 'text', section: 'Certification officielle', hint: 'Optionnel' },
    { key: 'rncp_title', label: 'Titre officiel de la certification', type: 'text', span: true },
    { key: 'rncp_level', label: 'Niveau (1 à 8)', type: 'number' },
    { key: 'rncp_url', label: 'Lien France Compétences', type: 'text', span: true, placeholder: 'https://www.francecompetences.fr/…' },
    { key: 'date', label: 'Date de publication', type: 'date', section: 'Publication' },
    {
      key: 'statut', label: 'Visibilité', type: 'select',
      options: [{ value: 'publie', label: 'Visible sur le site' }, { value: 'brouillon', label: 'Brouillon (masqué)' }],
    },
  ];
}

export function buildCategoryFields(): import('@/components/FormModal').FieldDef[] {
  return [
    { key: 'label', label: 'Nom du type de formation', type: 'text', required: true, span: true },
    { key: 'description', label: 'Description', type: 'textarea', span: true },
    { key: 'is_active', label: 'Visible sur le site', type: 'switch' },
  ];
}
