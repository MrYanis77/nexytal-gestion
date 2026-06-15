import { useMemo, useState, type ReactNode } from 'react';
import { BlogArticle } from '@/contexts/AppContext';
import { useFetch } from '@/hooks/useFetch';
import { api } from '@/lib/api';
import { getApiErrorMessage } from '@/lib/api-errors';
import { fetchApiDetail } from '@/lib/detail-fetch';
import {
  blogPostFromApi,
  blogPostToApi,
  blogPostDetailFromApi,
  buildBlogArticleFields,
  buildBlogCategoryFields,
} from '@/lib/mappers';
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
  const SITE_QS = `?site_id=${siteId}`;
  const [tab, setTab] = useState('articles');
  const [modal, setModal] = useState<{ type: string; item?: unknown } | null>(null);
  const [deleteTarget, setDeleteTarget] = useState<{ type: string; id: string; label: string } | null>(null);
  const [loadingDetail, setLoadingDetail] = useState(false);

  const { data: articlesData, refetch: refetchA } = useFetch<{ data: Record<string, unknown>[] }>(`/blog/posts${SITE_QS}`);
  const { data: blogCategoriesData, refetch: refetchBc } = useFetch<{ data: Record<string, unknown>[] }>(`/blog/categories${SITE_QS}`);

  const blogCategoryOptions = useMemo(
    () => (blogCategoriesData?.data ?? []).map(c => ({ value: String(c.id), label: String(c.name ?? '') })),
    [blogCategoriesData],
  );

  const articles = useMemo(() => (articlesData?.data ?? []).map(blogPostFromApi), [articlesData]);
  const articleFields = useMemo(() => buildBlogArticleFields(blogCategoryOptions), [blogCategoryOptions]);
  const blogCategoryFields = useMemo(() => buildBlogCategoryFields(), []);

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
        article: async () => { await api.delete(`/blog/posts/${deleteTarget.id}${SITE_QS}`); refetchA(); },
        blog_category: async () => { await api.delete(`/blog/categories/${deleteTarget.id}${SITE_QS}`); refetchBc(); },
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
      </div>

      <FormModal open={modal?.type === 'article'} onClose={() => setModal(null)} onSave={async (raw) => {
        const item = modal?.item as BlogArticle | undefined;
        const payload = blogPostToApi(raw);
        if (item) await api.put(`/blog/posts/${item.id}${SITE_QS}`, payload);
        else await api.post(`/blog/posts${SITE_QS}`, payload);
        toast.success('Article enregistré'); refetchA(); setModal(null);
      }} title={modal?.item ? 'Modifier l\'article' : 'Nouvel article'} fields={articleFields}
        initialData={modal?.item as Record<string, unknown>} accentColor={color} wide />
      <FormModal open={modal?.type === 'blog_category'} onClose={() => setModal(null)} onSave={async (raw) => {
        const item = modal?.item as { id: string } | undefined;
        if (item) await api.put(`/blog/categories/${item.id}${SITE_QS}`, raw);
        else await api.post(`/blog/categories${SITE_QS}`, raw);
        toast.success('Catégorie enregistrée'); refetchBc(); setModal(null);
      }} title="Catégorie d'article" fields={blogCategoryFields} initialData={modal?.item as Record<string, unknown>} accentColor={color} />

      <ConfirmDelete open={!!deleteTarget} onClose={() => setDeleteTarget(null)} onConfirm={handleDelete} label={deleteTarget?.label} />
    </div>
  );
}
