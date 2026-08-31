import { useState, type ReactNode } from 'react';
import { BlogArticle } from '@/contexts/AppContext';
import { api } from '@/lib/api';
import { getApiErrorMessage } from '@/lib/api-errors';
import { fetchApiDetail } from '@/lib/detail-fetch';
import { saveBlogArticle } from '@/lib/blog-article-save';
import {
  blogPostDetailFromApi,
  blogCategoryToApi,
  blogAuthorToApi,
  blogTagToApi,
} from '@/lib/mappers';
import { useBlogAdmin } from '@/hooks/useBlogAdmin';
import { SiteHeader } from '@/components/SiteHeader';
import { DataTable, StatusBadge } from '@/components/DataTable';
import { FormModal, ConfirmDelete } from '@/components/FormModal';
import { toast } from 'sonner';

interface BlogSitePageProps {
  siteId: number;
  color: string;
  title: string;
  description: string;
  icon: ReactNode;
}

export function BlogSitePage({ siteId, color, title, description, icon }: BlogSitePageProps) {
  const {
    SITE_QS,
    articles,
    blogCategoriesData,
    authorsData,
    tagsData,
    articleFields,
    blogCategoryFields,
    authorFields,
    tagFields,
    refetchArticles,
    refetchCategories,
    refetchAuthors,
    refetchTags,
  } = useBlogAdmin(siteId);

  const [tab, setTab] = useState('articles');
  const [modal, setModal] = useState<{ type: string; item?: unknown } | null>(null);
  const [deleteTarget, setDeleteTarget] = useState<{ type: string; id: string; label: string } | null>(null);
  const [loadingDetail, setLoadingDetail] = useState(false);

  const openArticleEdit = async (item: BlogArticle) => {
    setLoadingDetail(true);
    try {
      const row = await fetchApiDetail<Record<string, unknown>>(`/blog/posts/${item.id}${SITE_QS}`);
      setModal({ type: 'article', item: blogPostDetailFromApi(row) });
    } catch (err) {
      toast.error(getApiErrorMessage(err, 'Impossible de charger l\'article.'));
    } finally {
      setLoadingDetail(false);
    }
  };

  const handleDelete = async () => {
    if (!deleteTarget) return;
    try {
      const map: Record<string, () => Promise<void>> = {
        article: async () => { await api.delete(`/blog/posts/${deleteTarget.id}${SITE_QS}`); refetchArticles(); },
        blog_category: async () => { await api.delete(`/blog/categories/${deleteTarget.id}${SITE_QS}`); refetchCategories(); },
        blog_author: async () => { await api.delete(`/blog/authors/${deleteTarget.id}${SITE_QS}`); refetchAuthors(); },
        blog_tag: async () => { await api.delete(`/blog/tags/${deleteTarget.id}${SITE_QS}`); refetchTags(); },
      };
      await map[deleteTarget.type]?.();
      toast.success('Élément supprimé.');
    } catch (err) {
      toast.error(getApiErrorMessage(err, 'Erreur lors de la suppression.'));
    }
    setDeleteTarget(null);
  };

  return (
    <div className="h-full flex flex-col fade-up">
      <SiteHeader
        icon={icon}
        title={title}
        description={description}
        color={color}
        tabs={[
          { key: 'articles', label: 'Articles', count: articles.length },
          { key: 'blog_categories', label: 'Catégories', count: blogCategoriesData?.data?.length ?? 0 },
          { key: 'blog_authors', label: 'Auteurs', count: authorsData?.data?.length ?? 0 },
          { key: 'blog_tags', label: 'Tags', count: tagsData?.data?.length ?? 0 },
        ]}
        activeTab={tab}
        onTabChange={setTab}
      />

      {loadingDetail && <div className="px-6 py-2 text-sm text-muted-foreground">Chargement…</div>}

      <div className="flex-1 overflow-y-auto p-6">
        {tab === 'articles' && (
          <DataTable<BlogArticle>
            data={articles}
            accentColor={color}
            addLabel="Nouvel article"
            onAdd={() => setModal({ type: 'article' })}
            onEdit={openArticleEdit}
            onDelete={item => setDeleteTarget({ type: 'article', id: item.id, label: item.titre })}
            searchKeys={['titre', 'categorie', 'auteur']}
            columns={[
              { key: 'titre', label: 'Titre', render: a => <span className="font-medium text-foreground">{a.titre}</span> },
              { key: 'categorie', label: 'Catégorie', hidden: 'sm' },
              { key: 'auteur', label: 'Auteur', hidden: 'md' },
              { key: 'statut', label: 'Statut', render: a => <StatusBadge statut={a.statut} /> },
            ]}
          />
        )}

        {tab === 'blog_categories' && (
          <DataTable<Record<string, unknown>>
            data={blogCategoriesData?.data ?? []}
            accentColor={color}
            addLabel="Nouvelle catégorie"
            onAdd={() => setModal({ type: 'blog_category' })}
            onEdit={item => setModal({ type: 'blog_category', item })}
            onDelete={item => setDeleteTarget({ type: 'blog_category', id: String(item.id), label: String(item.name) })}
            searchKeys={['name']}
            columns={[
              { key: 'name', label: 'Nom', render: c => <span className="font-medium text-foreground">{String(c.name)}</span> },
              { key: 'is_active', label: 'Visible', render: c => c.is_active ? 'Oui' : 'Non' },
            ]}
          />
        )}

        {tab === 'blog_authors' && (
          <DataTable<Record<string, unknown>>
            data={authorsData?.data ?? []}
            accentColor={color}
            addLabel="Nouvel auteur"
            onAdd={() => setModal({ type: 'blog_author' })}
            onEdit={item => setModal({ type: 'blog_author', item })}
            onDelete={item => setDeleteTarget({
              type: 'blog_author',
              id: String(item.id),
              label: `${item.first_name} ${item.last_name}`,
            })}
            searchKeys={['first_name', 'last_name', 'email']}
            columns={[
              {
                key: 'name',
                label: 'Auteur',
                render: a => <span className="font-medium text-foreground">{String(a.first_name)} {String(a.last_name)}</span>,
              },
              { key: 'email', label: 'Email', hidden: 'sm' },
              { key: 'is_active', label: 'Actif', render: a => a.is_active ? 'Oui' : 'Non' },
            ]}
          />
        )}

        {tab === 'blog_tags' && (
          <DataTable<Record<string, unknown>>
            data={tagsData?.data ?? []}
            accentColor={color}
            addLabel="Nouveau tag"
            onAdd={() => setModal({ type: 'blog_tag' })}
            onEdit={item => setModal({ type: 'blog_tag', item })}
            onDelete={item => setDeleteTarget({ type: 'blog_tag', id: String(item.id), label: String(item.name) })}
            searchKeys={['name']}
            columns={[
              { key: 'name', label: 'Tag', render: t => <span className="font-medium text-foreground">{String(t.name)}</span> },
            ]}
          />
        )}
      </div>

      <FormModal open={modal?.type === 'article'} onClose={() => setModal(null)} onSave={async (raw) => {
        const item = modal?.item as BlogArticle | undefined;
        await saveBlogArticle(raw, SITE_QS, item?.id);
        toast.success('Article enregistré'); refetchArticles(); setModal(null);
      }} title={modal?.item ? 'Modifier l\'article' : 'Nouvel article'} fields={articleFields}
        initialData={modal?.item as Record<string, unknown>} accentColor={color} wide siteId={String(siteId)} />

      <FormModal open={modal?.type === 'blog_category'} onClose={() => setModal(null)} onSave={async (raw) => {
        const item = modal?.item as { id: string } | undefined;
        const payload = blogCategoryToApi(raw);
        if (item) await api.put(`/blog/categories/${item.id}${SITE_QS}`, payload);
        else await api.post(`/blog/categories${SITE_QS}`, payload);
        toast.success('Catégorie enregistrée'); refetchCategories(); setModal(null);
      }} title="Catégorie d'article" fields={blogCategoryFields} initialData={modal?.item as Record<string, unknown>} accentColor={color} />

      <FormModal open={modal?.type === 'blog_author'} onClose={() => setModal(null)} onSave={async (raw) => {
        const item = modal?.item as { id: string } | undefined;
        const payload = blogAuthorToApi(raw);
        if (item) await api.put(`/blog/authors/${item.id}${SITE_QS}`, payload);
        else await api.post(`/blog/authors${SITE_QS}`, payload);
        toast.success('Auteur enregistré'); refetchAuthors(); setModal(null);
      }} title={modal?.item ? 'Modifier l\'auteur' : 'Nouvel auteur'} fields={authorFields}
        initialData={modal?.item as Record<string, unknown>} accentColor={color} siteId={String(siteId)} />

      <FormModal open={modal?.type === 'blog_tag'} onClose={() => setModal(null)} onSave={async (raw) => {
        const item = modal?.item as { id: string } | undefined;
        const payload = blogTagToApi(raw);
        if (item) await api.put(`/blog/tags/${item.id}${SITE_QS}`, payload);
        else await api.post(`/blog/tags${SITE_QS}`, payload);
        toast.success('Tag enregistré'); refetchTags(); setModal(null);
      }} title={modal?.item ? 'Modifier le tag' : 'Nouveau tag'} fields={tagFields}
        initialData={modal?.item as Record<string, unknown>} accentColor={color} />

      <ConfirmDelete open={!!deleteTarget} onClose={() => setDeleteTarget(null)} onConfirm={handleDelete} label={deleteTarget?.label} />
    </div>
  );
}
