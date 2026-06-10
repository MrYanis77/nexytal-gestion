import { Formation } from '@/contexts/AppContext';
import { statusFromApi, statusToApi } from './status';

export function courseToApi(raw: Record<string, unknown>) {
  const desc = String(raw.description ?? '').trim();
  const prog = String(raw.programme ?? '').trim();
  const presentation = [desc, prog].filter(Boolean).join('\n\n') || '—';

  return {
    title: raw.titre,
    subtitle: raw.subtitle || null,
    category_id: Number(raw.category_id),
    duration: raw.duree || null,
    price: raw.price ? Number(raw.price) : null,
    presentation_title: raw.presentation_title || 'Le métier',
    presentation_text: presentation,
    cta_title: raw.cta_title || 'Prêt à vous lancer ?',
    cta_subtitle: raw.cta_subtitle || null,
    rncp_repertoire: raw.rncp_repertoire || null,
    rncp_code: raw.rncp || null,
    rncp_title: raw.rncp_title || null,
    rncp_level: raw.rncp_level ? Number(raw.rncp_level) : null,
    rncp_url: raw.rncp_url || null,
    is_cpf_eligible: raw.certifiante ? 1 : 0,
    is_alternance: raw.is_alternance ? 1 : 0,
    video_url: raw.video_url || null,
    meta_title: raw.meta_title || null,
    meta_description: raw.meta_description || null,
    status: statusToApi(raw.statut),
  };
}

export function courseFromApi(row: Record<string, unknown>): Formation {
  const text = String(row.presentation_text ?? '');
  const parts = text.split('\n\n');
  return {
    id: String(row.id),
    titre: String(row.title ?? ''),
    subtitle: String(row.subtitle ?? ''),
    category_id: row.category_id != null ? String(row.category_id) : '',
    categorie: String(row.category_name ?? ''),
    description: parts[0] ?? text,
    programme: parts.slice(1).join('\n\n'),
    video_url: String(row.video_url ?? ''),
    duree: String(row.duration ?? ''),
    price: row.price ? String(row.price) : undefined,
    certifiante: !!row.is_cpf_eligible,
    is_alternance: !!row.is_alternance,
    rncp_repertoire: row.rncp_repertoire ? String(row.rncp_repertoire) : undefined,
    rncp: row.rncp_code ? String(row.rncp_code) : undefined,
    rncp_title: row.rncp_title ? String(row.rncp_title) : undefined,
    rncp_level: row.rncp_level ? String(row.rncp_level) : undefined,
    rncp_url: row.rncp_url ? String(row.rncp_url) : undefined,
    presentation_title: String(row.presentation_title ?? ''),
    cta_title: String(row.cta_title ?? ''),
    cta_subtitle: String(row.cta_subtitle ?? ''),
    meta_title: String(row.meta_title ?? ''),
    meta_description: String(row.meta_description ?? ''),
    statut: statusFromApi(row.status),
    createdAt: String(row.created_at ?? ''),
  };
}

export function buildFormationFields(
  categoryOptions: { value: string; label: string }[],
): import('@/components/FormModal').FieldDef[] {
  return [
    { key: 'titre', label: 'Titre', type: 'text', required: true, span: true },
    { key: 'subtitle', label: 'Sous-titre', type: 'text', span: true },
    {
      key: 'category_id',
      label: 'Catégorie',
      type: 'select',
      required: true,
      options: categoryOptions,
    },
    { key: 'duree', label: 'Durée', type: 'text', placeholder: 'ex. 5 jours' },
    { key: 'price', label: 'Prix', type: 'text', placeholder: 'ex. 1500' },
    { key: 'presentation_title', label: 'Titre Présentation', type: 'text' },
    { key: 'video_url', label: 'URL Vidéo', type: 'text' },
    { key: 'description', label: 'Description', type: 'textarea', span: true },
    { key: 'programme', label: 'Programme', type: 'textarea', span: true },
    { key: 'certifiante', label: 'Éligible CPF', type: 'switch' },
    { key: 'is_alternance', label: 'Éligible Alternance', type: 'switch' },
    { key: 'rncp_repertoire', label: 'Répertoire RNCP (ex: RNCP, RS)', type: 'text' },
    { key: 'rncp', label: 'Code RNCP', type: 'text', placeholder: 'ex. 37680' },
    { key: 'rncp_title', label: 'Titre RNCP', type: 'text', span: true },
    { key: 'rncp_level', label: 'Niveau RNCP', type: 'text', placeholder: 'ex. 5' },
    { key: 'rncp_url', label: 'Lien France Compétences', type: 'text', span: true },
    { key: 'cta_title', label: 'Titre CTA', type: 'text' },
    { key: 'cta_subtitle', label: 'Sous-titre CTA', type: 'text', span: true },
    { key: 'meta_title', label: 'Meta Titre', type: 'text', span: true },
    { key: 'meta_description', label: 'Meta Description', type: 'textarea', span: true },
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

export function buildCategoryFields(): import('@/components/FormModal').FieldDef[] {
  return [
    { key: 'name', label: 'Nom', type: 'text', required: true, span: true },
    { key: 'slug', label: 'Slug', type: 'text', placeholder: 'Auto-généré si vide' },
    { key: 'description', label: 'Description', type: 'textarea', span: true },
    { key: 'sort_order', label: 'Ordre d\'affichage', type: 'text' },
    { key: 'is_active', label: 'Actif', type: 'switch' },
  ];
}
