import { BlogArticle } from '@/contexts/AppContext';
import { statusFromApi, statusToApi, formatDate } from './status';
import { PHOTO_URL_PLACEHOLDER, PHOTO_URL_HINT } from '@/lib/constants';

export const BLOG_NO_CATEGORY = '__none__';
export const BLOG_NO_AUTHOR = '__none__';

export interface BlogArticleFieldOptions {
  categoryOptions: { value: string; label: string }[];
  authorOptions?: { value: string; label: string }[];
  tagOptions?: { value: string; label: string }[];
}

function optionalId(raw: unknown, noneValue: string): number | null {
  if (raw == null || raw === '' || String(raw) === noneValue) {
    return null;
  }
  const n = Number(raw);
  return n > 0 ? n : null;
}

function slugifyClient(value: string): string {
  return value
    .normalize('NFD')
    .replace(/[\u0300-\u036f]/g, '')
    .toLowerCase()
    .replace(/[^a-z0-9]+/g, '-')
    .replace(/^-+|-+$/g, '')
    .slice(0, 200);
}

export function blogPostToApi(raw: Record<string, unknown>) {
  const excerpt = String(raw.extrait ?? '').trim();
  const content = String(raw.contenu ?? '').trim() || excerpt || '—';
  const title = String(raw.titre ?? '').trim();
  const slug = slugifyClient(title);

  const readTimeRaw = raw.read_time_mins;
  const readTime = readTimeRaw != null && String(readTimeRaw).trim() !== ''
    ? Number(readTimeRaw)
    : null;

  const tagIds = Array.isArray(raw.tag_ids)
    ? raw.tag_ids.map(id => Number(id)).filter(n => n > 0)
    : undefined;

  const payload: Record<string, unknown> = {
    title,
    slug,
    excerpt: excerpt || null,
    content,
    category_id: optionalId(raw.category_id, BLOG_NO_CATEGORY),
    author_id: optionalId(raw.author_id, BLOG_NO_AUTHOR),
    cover_image_url: raw.cover_image_url || raw.photo || null,
    read_time_mins: readTime != null && !Number.isNaN(readTime) && readTime > 0 ? readTime : null,
    is_featured: raw.is_featured ? 1 : 0,
    status: statusToApi(raw.statut),
  };

  if (raw.date && raw.statut === 'publie') {
    payload.published_at = `${raw.date} 00:00:00`;
  }

  if (tagIds !== undefined) {
    payload.tag_ids = tagIds;
  }

  return payload;
}

export function blogPostFromApi(row: Record<string, unknown>): BlogArticle {
  return blogPostDetailFromApi(row) as BlogArticle;
}

export function blogPostDetailFromApi(row: Record<string, unknown>): Record<string, unknown> {
  const tags = Array.isArray(row.tags)
    ? row.tags.map(t => String((t as Record<string, unknown>).id))
    : [];

  return {
    id: String(row.id),
    titre: String(row.title ?? ''),
    extrait: String(row.excerpt ?? ''),
    contenu: String(row.content ?? ''),
    category_id: row.category_id != null ? String(row.category_id) : BLOG_NO_CATEGORY,
    categorie: String(row.category_name ?? ''),
    author_id: row.author_id != null ? String(row.author_id) : BLOG_NO_AUTHOR,
    auteur: String(row.author_name ?? ''),
    cover_image_url: String(row.cover_image_url ?? ''),
    photo: String(row.cover_image_url ?? ''),
    read_time_mins: row.read_time_mins != null ? String(row.read_time_mins) : '',
    is_featured: !!row.is_featured,
    tag_ids: tags,
    date: formatDate(row.published_at ?? row.created_at),
    statut: statusFromApi(row.status),
    site: 'formation',
  };
}

export function blogCategoryToApi(raw: Record<string, unknown>) {
  const name = String(raw.name ?? '').trim();

  return {
    name,
    slug: slugifyClient(name),
    description: String(raw.description ?? '').trim() || null,
    is_active: raw.is_active ? 1 : 0,
    sort_order: Number(raw.sort_order ?? 0) || 0,
  };
}

export function blogAuthorToApi(raw: Record<string, unknown>) {
  const first = String(raw.first_name ?? '').trim();
  const last = String(raw.last_name ?? '').trim();

  return {
    first_name: first,
    last_name: last,
    email: String(raw.email ?? '').trim(),
    slug: slugifyClient(`${first}-${last}`),
    bio: String(raw.bio ?? '').trim() || null,
    is_active: raw.is_active ? 1 : 0,
  };
}

export function blogTagToApi(raw: Record<string, unknown>) {
  const name = String(raw.name ?? '').trim();

  return {
    name,
    slug: slugifyClient(name),
  };
}

export function buildBlogArticleFields(opts: BlogArticleFieldOptions): import('@/components/FormModal').FieldDef[] {
  const {
    categoryOptions,
    authorOptions = [],
    tagOptions = [],
  } = opts;

  const fields: import('@/components/FormModal').FieldDef[] = [
    { key: 'titre', label: 'Titre de l\'article', type: 'text', required: true, span: true, section: 'Article' },
    { key: 'extrait', label: 'Résumé court', type: 'textarea', span: true, hint: 'Visible dans la liste des articles' },
    { key: 'contenu', label: 'Texte de l\'article', type: 'textarea', required: true, span: true, hint: 'Contenu affiché sur le site public' },
    {
      key: 'photo', label: 'Photo de couverture', type: 'file', fileKind: 'image', uploadContext: 'blog',
      span: true, section: 'Illustration', placeholder: PHOTO_URL_PLACEHOLDER, hint: PHOTO_URL_HINT,
    },
    {
      key: 'category_id', label: 'Catégorie', type: 'select', section: 'Publication',
      options: [{ value: BLOG_NO_CATEGORY, label: '— Aucune —' }, ...categoryOptions],
    },
    {
      key: 'author_id', label: 'Auteur', type: 'select',
      options: [{ value: BLOG_NO_AUTHOR, label: '— Aucun —' }, ...authorOptions],
      hint: authorOptions.length === 0 ? 'Créez un auteur dans l\'onglet Auteurs.' : undefined,
    },
    { key: 'read_time_mins', label: 'Durée de lecture (minutes)', type: 'number', placeholder: '5' },
    { key: 'date', label: 'Date de publication', type: 'date' },
    { key: 'is_featured', label: 'Mettre en avant sur la page d\'accueil', type: 'switch' },
    {
      key: 'statut', label: 'Statut', type: 'select',
      options: [
        { value: 'publie', label: 'Publié (visible)' },
        { value: 'brouillon', label: 'Brouillon (masqué)' },
      ],
    },
  ];

  if (tagOptions.length > 0) {
    fields.push({
      key: 'tag_ids', label: 'Tags', type: 'multi_select', section: 'Tags',
      options: tagOptions,
    });
  }

  return fields;
}

export function buildBlogCategoryFields(): import('@/components/FormModal').FieldDef[] {
  return [
    { key: 'name', label: 'Nom de la catégorie', type: 'text', required: true, span: true },
    { key: 'description', label: 'Description', type: 'textarea', span: true },
    { key: 'sort_order', label: 'Ordre d\'affichage', type: 'number', placeholder: '0' },
    { key: 'is_active', label: 'Visible sur le site', type: 'switch' },
  ];
}

export function buildBlogAuthorFields(): import('@/components/FormModal').FieldDef[] {
  return [
    { key: 'first_name', label: 'Prénom', type: 'text', required: true },
    { key: 'last_name', label: 'Nom', type: 'text', required: true },
    { key: 'email', label: 'Email', type: 'email', required: true, span: true },
    { key: 'bio', label: 'Biographie', type: 'textarea', span: true },
    { key: 'is_active', label: 'Actif', type: 'switch' },
  ];
}

export function buildBlogTagFields(): import('@/components/FormModal').FieldDef[] {
  return [
    { key: 'name', label: 'Nom du tag', type: 'text', required: true, span: true },
  ];
}
