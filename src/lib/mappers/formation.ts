import { Formation } from '@/contexts/AppContext';

import { statusFromApi, statusToApi } from './status';

import { parseJsonArray, stringifyJsonArray } from './nested-json';

import { PHOTO_URL_PLACEHOLDER, PHOTO_URL_HINT, VIDEO_URL_PLACEHOLDER, VIDEO_URL_HINT } from '@/lib/constants';



export const FORMATION_NO_CATEGORY = '__none__';



export const FORMATION_COURSE_TYPE_OPTIONS = [

  { value: 'diplomante', label: 'Diplômante' },

  { value: 'certifiante', label: 'Certifiante' },

  { value: 'elearning', label: 'E-learning' },

];



export type FormationModuleItem = { title: string; description: string; duration?: string };



function optionalJsonField(raw: Record<string, unknown>, key: string) {

  if (!(key in raw)) return undefined;

  return parseJsonArray(raw[key]);

}



function linesToList(text: unknown) {

  return String(text ?? '')

    .split('\n')

    .map(l => l.trim())

    .filter(Boolean);

}



function modulesListFromApi(modules: unknown): FormationModuleItem[] {

  if (!Array.isArray(modules) || modules.length === 0) {

    return [{ title: '', description: '', duration: '' }];

  }

  return modules.map((m: Record<string, unknown>) => ({

    title: String(m.title ?? ''),

    description: String(m.description ?? ''),

    duration: String(m.duration_label ?? m.duration ?? ''),

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

        duration_label: String(item.duration ?? '').trim() || null,

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

      return {

        label: parts[0],

        value: parts[1] || '—',

        icon: parts[2] || null,

        sort_order,

      };

    });

}



function statsTextFromApi(stats: unknown) {

  if (!Array.isArray(stats)) return '';

  return stats.map((s: Record<string, unknown>) => {

    const label = String(s.label ?? '').trim();

    const value = String(s.value ?? '').trim();

    const icon = String(s.icon ?? '').trim();

    const base = value ? `${label} | ${value}` : label;

    return icon ? `${base} | ${icon}` : base;

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

    const title = String(j.job_title ?? j.title ?? '').trim();

    const salary = String(j.salary_label ?? '').trim();

    if (salary && salary !== 'Selon expérience') return `${title} | ${salary}`;

    return title;

  }).filter(Boolean).join('\n');

}



function skillsTextFromApi(skills: unknown) {

  if (!Array.isArray(skills)) return '';

  return skills

    .map((s: Record<string, unknown>) => String(s.name ?? '').trim())

    .filter(Boolean)

    .join('\n');

}



function objectivesTextFromApi(objectives: unknown) {

  if (!Array.isArray(objectives)) return '';

  return objectives

    .map((o: Record<string, unknown>) => String(o.content ?? '').trim())

    .filter(Boolean)

    .join('\n');

}



function infoBlockPointsFromApi(blocks: unknown, blockType: string) {

  if (!Array.isArray(blocks)) return { title: '', points: '' };

  const block = blocks.find((b: Record<string, unknown>) => b.block_type === blockType);

  if (!block) return { title: '', points: '' };

  const points = Array.isArray(block.points)

    ? block.points.map((p: Record<string, unknown>) => String(p.content ?? '').trim()).filter(Boolean)

    : [];

  return {

    title: String(block.title ?? ''),

    points: points.join('\n'),

  };

}



function skillsToApi(text: unknown) {

  return linesToList(text).map((name, sort_order) => ({ name, sort_order }));

}



function objectivesToApi(text: unknown) {

  return linesToList(text).map((content, sort_order) => ({ content, sort_order }));

}



export function courseToApi(raw: Record<string, unknown>) {

  const payload: Record<string, unknown> = {

    hero_title: raw.titre,

    slug: raw.slug || undefined,

    course_type: raw.course_type || raw.type || 'diplomante',

    type: raw.course_type || raw.type || 'diplomante',

    category_id: raw.category_id && String(raw.category_id) !== '' && String(raw.category_id) !== FORMATION_NO_CATEGORY

      ? Number(raw.category_id)

      : null,

    hero_subtitle: raw.hero_subtitle || null,

    hero_image_url: raw.hero_image_url || raw.photo_principale || null,

    card_image_url: raw.card_image_url || raw.photo_carte || null,

    presentation_image_url: raw.presentation_image_url || raw.photo_presentation || raw.presentation_image || null,

    hero_video_url: raw.hero_video_url || raw.video_url || null,

    seo_title: raw.meta_title || null,

    seo_description: raw.meta_description || null,

    presentation_title: raw.presentation_title || 'Le métier',

    presentation_content: raw.description || null,

    programme_duration_label: raw.duree || null,

    programme_duration_total: raw.programme_duration_total || null,

    modality_label: raw.modality_label || null,

    methodology: raw.methodology || null,

    certification_label: raw.certification_label || null,

    reference_code: raw.reference_code || raw.internal_reference || null,

    evaluation_title: raw.evaluation_title || null,

    evaluation_description: raw.evaluation_description || null,

    debouches_title: raw.debouches_title || null,

    debouches_subtitle: raw.debouches_subtitle || null,

    debouches_sectors: raw.debouches_sectors || null,

    info_modalities_title: raw.info_modalities_title || null,

    info_prerequisites_title: raw.info_prerequisites_title || null,

    pour_qui_title: raw.pour_qui_title || null,

    evaluation_steps_title: raw.evaluation_steps_title || null,

    info_modalities_points: raw.info_modalities_points ?? raw.info_modalities_description ?? null,

    info_prerequisites_points: raw.info_prerequisites_points ?? raw.info_prerequisites_description ?? null,

    pour_qui_points: raw.pour_qui_points ?? null,

    evaluation_steps_text: raw.evaluation_steps_text ?? null,

    cta_title: raw.cta_title || null,

    cta_subtitle: raw.cta_subtitle || null,

    cta_button_label: raw.cta_button_label || null,

    cta_button_url: raw.cta_button_url || null,

    status: statusToApi(raw.statut),

    published_at: raw.date && raw.statut === 'publie' ? `${raw.date} 00:00:00` : undefined,

    price: raw.price !== '' && raw.price != null ? Number(raw.price) : null,

    sort_order: raw.sort_order !== '' && raw.sort_order != null ? Number(raw.sort_order) : 0,

    is_cpf_eligible: raw.is_cpf_eligible ? 1 : 0,

    is_alternance: raw.is_alternance ? 1 : 0,

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



  if ('competences_acquises_text' in raw) {

    payload.skills = skillsToApi(raw.competences_acquises_text);

  } else {

    const skills = optionalJsonField(raw, 'skills_json');

    if (skills !== undefined) payload.skills = skills;

  }



  if ('objectifs_text' in raw) {

    payload.objectives = objectivesToApi(raw.objectifs_text);

  } else {

    const objectives = optionalJsonField(raw, 'objectives_json');

    if (objectives !== undefined) payload.objectives = objectives;

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

  const modalites = infoBlockPointsFromApi(row.info_blocks, 'modalites');

  const prerequis = infoBlockPointsFromApi(row.info_blocks, 'prerequis');

  const pourQui = infoBlockPointsFromApi(row.info_blocks, 'pour_qui');

  const evalSteps = infoBlockPointsFromApi(row.info_blocks, 'evaluation_etapes');



  return {

    id: String(row.id),

    titre: String(row.hero_title ?? ''),

    slug: String(row.slug ?? ''),

    course_type: String(row.course_type ?? row.type ?? 'diplomante'),

    type: String(row.course_type ?? row.type ?? 'diplomante'),

    hero_subtitle: String(row.hero_subtitle ?? ''),

    category_id: row.category_id != null ? String(row.category_id) : FORMATION_NO_CATEGORY,

    categorie: String(row.category_label ?? ''),

    description: String(row.presentation_content ?? ''),

    video_url: String(row.hero_video_url ?? ''),

    hero_image_url: String(row.hero_image_url ?? ''),

    card_image_url: String(row.card_image_url ?? ''),

    presentation_image: String(row.presentation_image_url ?? row.presentation_image ?? ''),

    presentation_image_url: String(row.presentation_image_url ?? row.presentation_image ?? ''),

    photo_principale: String(row.hero_image_url ?? ''),

    photo_carte: String(row.card_image_url ?? ''),

    photo_presentation: String(row.presentation_image_url ?? row.presentation_image ?? ''),

    duree: String(row.programme_duration_label ?? ''),

    programme_duration_total: String(row.programme_duration_total ?? ''),

    modality_label: String(row.modality_label ?? ''),

    methodology: String(row.methodology ?? ''),

    certification_label: row.certification_label ? String(row.certification_label) : undefined,

    reference_code: String(row.reference_code ?? row.internal_reference ?? ''),

    internal_reference: String(row.reference_code ?? row.internal_reference ?? ''),

    presentation_title: String(row.presentation_title ?? ''),

    evaluation_title: String(row.evaluation_title ?? ''),

    evaluation_description: String(row.evaluation_description ?? ''),

    debouches_title: String(row.debouches_title ?? ''),

    debouches_subtitle: String(row.debouches_subtitle ?? ''),

    debouches_sectors: String(row.debouches_sectors ?? ''),

    info_modalities_title: modalites.title || String(row.info_modalities_title ?? 'Modalités d\'apprentissage'),

    info_modalities_points: modalites.points,

    info_modalities_description: modalites.points,

    info_prerequisites_title: prerequis.title || String(row.info_prerequisites_title ?? 'Public concerné & Prérequis'),

    info_prerequisites_points: prerequis.points,

    info_prerequisites_description: prerequis.points,

    pour_qui_title: pourQui.title || 'Public',

    pour_qui_points: pourQui.points,

    evaluation_steps_title: evalSteps.title || 'Étapes d\'évaluation',

    evaluation_steps_text: evalSteps.points,

    objectifs_text: objectivesTextFromApi(row.objectives),

    competences_acquises_text: skillsTextFromApi(row.skills),

    modules_list: modulesListFromApi(row.modules),

    stats_text: statsTextFromApi(row.stats),

    metiers_vises_text: jobOutcomesTextFromApi(row.job_outcomes),

    cta_title: String(row.cta_title ?? ''),

    cta_subtitle: String(row.cta_subtitle ?? ''),

    cta_button_label: String(row.cta_button_label ?? ''),

    cta_button_url: String(row.cta_button_url ?? ''),

    sort_order: row.sort_order != null ? String(row.sort_order) : '0',

    meta_title: String(row.seo_title ?? ''),

    meta_description: String(row.seo_description ?? ''),

    statut: statusFromApi(row.status),

    date: String(row.published_at ?? '').slice(0, 10),

    price: row.price != null ? String(row.price) : '',

    is_cpf_eligible: row.is_cpf_eligible === 1 || row.is_cpf_eligible === true,

    is_alternance: row.is_alternance === 1 || row.is_alternance === true,

    createdAt: String(row.created_at ?? ''),

    rncp_repertoire: oc ? String(oc.repertoire ?? '') : '',

    rncp_code: oc ? String(oc.code ?? '') : '',

    rncp_title: oc ? String(oc.official_title ?? '') : '',

    rncp_level: oc?.level != null ? String(oc.level) : '',

    rncp_url: oc ? String(oc.france_competences_url ?? '') : '',

    modules_json: stringifyJsonArray(row.modules),

    stats_json: stringifyJsonArray(row.stats),

    skills_json: stringifyJsonArray(row.skills),

    objectives_json: stringifyJsonArray(row.objectives),

    info_blocks_json: stringifyJsonArray(row.info_blocks),

    job_outcomes_json: stringifyJsonArray(row.job_outcomes),

    official_certification_json: stringifyJsonArray(oc ? [oc] : []),

    extra_json: stringifyJsonArray(row.extra_json),

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

    { key: 'titre', label: 'Titre de la formation', type: 'text', required: true, span: true, section: 'Informations générales' },

    { key: 'slug', label: 'Slug URL', type: 'text', hint: 'Généré automatiquement si vide (ex. formations-developpeur-web)' },

    {

      key: 'course_type', label: 'Type de parcours', type: 'select',

      options: FORMATION_COURSE_TYPE_OPTIONS,

    },

    {

      key: 'category_id', label: 'Catégorie catalogue', type: 'select',

      options: [

        { value: FORMATION_NO_CATEGORY, label: '— Aucun —' },

        ...categoryOptions,

      ],

      hint: categoryOptions.length

        ? undefined

        : 'Créez d\'abord une catégorie dans l\'onglet « Types de formation ».',

    },

    { key: 'hero_subtitle', label: 'Accroche', type: 'text', span: true },

    { key: 'reference_code', label: 'Code interne / référence', type: 'text' },

    { key: 'sort_order', label: 'Ordre d\'affichage', type: 'number', placeholder: '0' },



    { key: 'duree', label: 'Durée (libellé court)', type: 'text', section: 'Durée & tarifs', placeholder: 'Ex. 24 mois' },

    { key: 'programme_duration_total', label: 'Durée programme détaillée', type: 'text', placeholder: 'Ex. Programme complet – 820 heures' },

    { key: 'modality_label', label: 'Modalité catalogue', type: 'text', placeholder: 'Ex. Présentiel, distanciel…' },

    { key: 'price', label: 'Prix (€)', type: 'number', placeholder: 'Ex. 4500' },

    { key: 'is_cpf_eligible', label: 'Éligible CPF', type: 'switch' },

    { key: 'is_alternance', label: 'Alternance possible', type: 'switch' },



    {

      key: 'photo_principale', label: 'Image hero', type: 'file', fileKind: 'image', uploadContext: 'formation',

      span: true, section: 'Médias', placeholder: PHOTO_URL_PLACEHOLDER, hint: PHOTO_URL_HINT,

    },

    {

      key: 'photo_carte', label: 'Image catalogue', type: 'file', fileKind: 'image', uploadContext: 'formation',

      span: true, hint: 'Vignette dans la liste des formations',

    },

    {

      key: 'photo_presentation', label: 'Image de présentation', type: 'file', fileKind: 'image', uploadContext: 'formation',

      span: true, hint: 'Illustration de la section « présentation »',

    },

    {

      key: 'video_url', label: 'Vidéo de présentation', type: 'file', fileKind: 'video', uploadContext: 'formation',

      span: true, placeholder: VIDEO_URL_PLACEHOLDER, hint: VIDEO_URL_HINT,

    },



    { key: 'presentation_title', label: 'Titre présentation', type: 'text', section: 'Présentation' },

    { key: 'description', label: 'Texte de présentation', type: 'textarea', span: true },

    { key: 'methodology', label: 'Méthode pédagogique', type: 'textarea', span: true },



    {

      key: 'stats_text', label: 'Chiffres clés', type: 'textarea', span: true, section: 'Chiffres clés',

      hint: 'Une ligne par indicateur : Libellé | Valeur | Icône (optionnel)',

      placeholder: 'Durée | 24 mois\nCompétences clés | +20 compétences clés',

    },



    {

      key: 'objectifs_text', label: 'Objectifs pédagogiques', type: 'textarea', span: true, section: 'Objectifs & compétences',

      hint: 'Un objectif par ligne',

    },

    {

      key: 'competences_acquises_text', label: 'Compétences acquises', type: 'textarea', span: true,

      hint: 'Une compétence par ligne',

    },



    {

      key: 'modules_list', label: 'Modules du programme', type: 'module_list', span: true, section: 'Programme',

      hint: 'Chaque module : titre, description et durée optionnelle.',

    },



    { key: 'evaluation_title', label: 'Titre — évaluation', type: 'text', section: 'Évaluation' },

    { key: 'evaluation_description', label: 'Texte — évaluation', type: 'textarea', span: true },

    {

      key: 'evaluation_steps_title', label: 'Titre — étapes d\'évaluation', type: 'text',

      placeholder: 'Étapes d\'évaluation',

    },

    {

      key: 'evaluation_steps_text', label: 'Étapes d\'évaluation', type: 'textarea', span: true,

      hint: 'Une étape par ligne (QCM, mise en situation, soutenance…)',

    },



    { key: 'debouches_title', label: 'Titre — débouchés', type: 'text', section: 'Débouchés' },

    { key: 'debouches_subtitle', label: 'Sous-titre — débouchés', type: 'text' },

    { key: 'debouches_sectors', label: 'Secteurs visés', type: 'textarea', span: true },

    {

      key: 'metiers_vises_text', label: 'Métiers & salaires', type: 'textarea', span: true,

      hint: 'Une ligne par métier : Intitulé | Fourchette salariale',

      placeholder: 'Développeur Full Stack | 35 000 - 45 000 €',

    },



    {

      key: 'info_modalities_title', label: 'Titre — modalités', type: 'text', section: 'Infos pratiques',

      placeholder: 'Modalités d\'apprentissage',

    },

    {

      key: 'info_modalities_points', label: 'Points — modalités', type: 'textarea', span: true,

      hint: 'Horaires, rythme, financement… une ligne par point',

    },

    {

      key: 'info_prerequisites_title', label: 'Titre — prérequis', type: 'text',

      placeholder: 'Public concerné & Prérequis',

    },

    {

      key: 'info_prerequisites_points', label: 'Points — prérequis', type: 'textarea', span: true,

      hint: 'Niveau requis, expérience… une ligne par point',

    },

    {

      key: 'pour_qui_title', label: 'Titre — public visé', type: 'text', placeholder: 'Public',

    },

    {

      key: 'pour_qui_points', label: 'Points — public visé', type: 'textarea', span: true,

      hint: 'Profils visés, une ligne par point (JSON accepté pour contenu structuré)',

    },



    { key: 'certification_label', label: 'Intitulé certification affiché', type: 'text', section: 'Certification RNCP' },

    { key: 'rncp_code', label: 'Code RNCP / RS', type: 'text', hint: 'Optionnel' },

    { key: 'rncp_title', label: 'Titre officiel', type: 'text', span: true },

    { key: 'rncp_level', label: 'Niveau (1 à 8)', type: 'number' },

    { key: 'rncp_url', label: 'Lien France Compétences', type: 'text', span: true, placeholder: 'https://www.francecompetences.fr/…' },



    { key: 'cta_title', label: 'Titre CTA final', type: 'text', section: 'Appel à l\'action' },

    { key: 'cta_subtitle', label: 'Sous-titre CTA', type: 'text', span: true },

    { key: 'cta_button_label', label: 'Libellé bouton principal', type: 'text', placeholder: 'S\'inscrire maintenant' },

    { key: 'cta_button_url', label: 'URL bouton principal', type: 'text', placeholder: '/contact' },



    { key: 'meta_title', label: 'Titre SEO', type: 'text', section: 'SEO & publication' },

    { key: 'meta_description', label: 'Description SEO', type: 'textarea', span: true },

    { key: 'date', label: 'Date de publication', type: 'date' },

    {

      key: 'statut', label: 'Visibilité', type: 'select',

      options: [

        { value: 'publie', label: 'Visible sur le site' },

        { value: 'brouillon', label: 'Brouillon (masqué)' },

      ],

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

