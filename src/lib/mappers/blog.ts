import { BlogArticle } from '@/contexts/AppContext';
import { statusFromApi, statusToApi, formatDate } from './status';

/** Valeur sentinel pour Radix Select (n'accepte pas value="") */
export const BLOG_NO_CATEGORY = '__none__';

export function blogPostToApi(raw: Record<string, unknown>) {
  const excerpt = String(raw.extrait ?? '').trim();
  const content = String(raw.contenu ?? raw.extrait ?? '').trim() || excerpt || '—';
  const catRaw = raw.category_id;
  const categoryId = catRaw && String(catRaw) !== '' && String(catRaw) !== BLOG_NO_CATEGORY
    ? Number(catRaw)
    : null;

  return {
    title: raw.titre,
    excerpt: excerpt || null,
    content,
    category_id: categoryId,
    author_id: raw.auteur || raw.author_id ? Number(raw.auteur || raw.author_id) : null,
    cover_image_url: raw.cover_image_url || null,
    read_time_mins: raw.read_time_mins ? Number(raw.read_time_mins) : null,
    is_featured: raw.is_featured ? 1 : 0,
    meta_title: raw.meta_title || null,
    meta_description: raw.meta_description || null,
    status: statusToApi(raw.statut),
    published_at: raw.date && raw.statut === 'publie' ? `${raw.date} 00:00:00` : undefined,
  };
}

export function blogPostFromApi(row: Record<string, unknown>): BlogArticle {
  return {
    id: String(row.id),
    titre: String(row.title ?? ''),
    extrait: String(row.excerpt ?? ''),
    contenu: String(row.content ?? ''),
    category_id: row.category_id != null ? String(row.category_id) : BLOG_NO_CATEGORY,
    categorie: String(row.category_name ?? ''),
    author_id: row.author_id != null ? String(row.author_id) : '',
    auteur: String(row.author_name ?? ''),
    cover_image_url: String(row.cover_image_url ?? ''),
    read_time_mins: row.read_time_mins ? String(row.read_time_mins) : undefined,
    is_featured: !!row.is_featured,
    date: formatDate(row.published_at ?? row.created_at),
    meta_title: String(row.meta_title ?? ''),
    meta_description: String(row.meta_description ?? ''),
    statut: statusFromApi(row.status),
    site: 'formation',
  };
}

export function buildBlogArticleFields(
  categoryOptions: { value: string; label: string }[],
): import('@/components/FormModal').FieldDef[] {
  return [
    { key: 'titre', label: 'Titre', type: 'text', required: true, span: true },
    { key: 'auteur', label: 'Auteur (Nom ou ID)', type: 'text' },
    { key: 'extrait', label: 'Extrait', type: 'textarea', span: true },
    { key: 'contenu', label: 'Contenu', type: 'textarea', span: true },
    { key: 'cover_image_url', label: 'URL Image de couverture', type: 'text', span: true },
    { key: 'read_time_mins', label: 'Temps de lecture (min)', type: 'text' },
    { key: 'is_featured', label: 'Article mis en avant', type: 'switch' },
    {
      key: 'category_id',
      label: 'Catégorie',
      type: 'select',
      options: [
        { value: BLOG_NO_CATEGORY, label: '— Aucune —' },
        ...categoryOptions,
      ],
    },
    { key: 'date', label: 'Date de publication', type: 'date' },
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

export function buildBlogCategoryFields(): import('@/components/FormModal').FieldDef[] {
  return [
    { key: 'name', label: 'Nom', type: 'text', required: true, span: true },
    { key: 'slug', label: 'Slug', type: 'text', placeholder: 'Auto-généré si vide' },
    { key: 'description', label: 'Description', type: 'textarea', span: true },
    { key: 'color', label: 'Couleur (Hex)', type: 'text', placeholder: '#6366f1' },
    { key: 'is_active', label: 'Actif', type: 'switch' },
  ];
}
