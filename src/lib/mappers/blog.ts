import { BlogArticle } from '@/contexts/AppContext';
import { statusFromApi, statusToApi, formatDate } from './status';
import { PHOTO_URL_PLACEHOLDER, PHOTO_URL_HINT } from '@/lib/constants';

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
    cover_image_url: raw.cover_image_url || raw.photo || null,
    is_featured: raw.is_featured ? 1 : 0,
    status: statusToApi(raw.statut),
    published_at: raw.date && raw.statut === 'publie' ? `${raw.date} 00:00:00` : undefined,
  };
}

export function blogPostFromApi(row: Record<string, unknown>): BlogArticle {
  return blogPostDetailFromApi(row) as BlogArticle;
}

export function blogPostDetailFromApi(row: Record<string, unknown>): Record<string, unknown> {
  return {
    id: String(row.id),
    titre: String(row.title ?? ''),
    extrait: String(row.excerpt ?? ''),
    contenu: String(row.content ?? ''),
    category_id: row.category_id != null ? String(row.category_id) : BLOG_NO_CATEGORY,
    categorie: String(row.category_name ?? ''),
    auteur: String(row.author_name ?? ''),
    cover_image_url: String(row.cover_image_url ?? ''),
    photo: String(row.cover_image_url ?? ''),
    is_featured: !!row.is_featured,
    date: formatDate(row.published_at ?? row.created_at),
    statut: statusFromApi(row.status),
    site: 'formation',
  };
}

export function buildBlogArticleFields(
  categoryOptions: { value: string; label: string }[],
): import('@/components/FormModal').FieldDef[] {
  return [
    { key: 'titre', label: 'Titre de l\'article', type: 'text', required: true, span: true, section: 'Article' },
    { key: 'auteur', label: 'Nom de l\'auteur', type: 'text', placeholder: 'Prénom Nom' },
    { key: 'extrait', label: 'Résumé court', type: 'textarea', span: true, hint: 'Quelques lignes visibles dans la liste des articles' },
    { key: 'contenu', label: 'Texte de l\'article', type: 'textarea', span: true, hint: 'Le contenu affiché sur le site public' },
    {
      key: 'photo', label: 'Photo de couverture', type: 'file', fileKind: 'image', uploadContext: 'blog',
      span: true, section: 'Illustration', placeholder: PHOTO_URL_PLACEHOLDER, hint: PHOTO_URL_HINT,
    },
    {
      key: 'category_id', label: 'Catégorie', type: 'select', section: 'Publication',
      options: [{ value: BLOG_NO_CATEGORY, label: '— Aucune —' }, ...categoryOptions],
    },
    { key: 'date', label: 'Date de publication', type: 'date' },
    { key: 'is_featured', label: 'Mettre en avant sur la page d\'accueil', type: 'switch' },
    {
      key: 'statut', label: 'Visibilité', type: 'select',
      options: [{ value: 'publie', label: 'Visible sur le site' }, { value: 'brouillon', label: 'Brouillon (masqué)' }],
    },
  ];
}

export function buildBlogCategoryFields(): import('@/components/FormModal').FieldDef[] {
  return [
    { key: 'name', label: 'Nom de la catégorie', type: 'text', required: true, span: true },
    { key: 'description', label: 'Description', type: 'textarea', span: true },
    { key: 'is_active', label: 'Visible sur le site', type: 'switch' },
  ];
}
